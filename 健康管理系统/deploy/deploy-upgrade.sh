#!/bin/bash
# ============================================
# 星辰健康管理系统 - 版本升级脚本（保留数据库）
# 使用方法：chmod +x deploy-upgrade.sh && ./deploy-upgrade.sh
# 适用场景：旧版已在运行，只更新程序文件并重启
# ============================================

set -e

APP_HOME="/home/xingchen"
ZIP_FILE="$APP_HOME/xingchen-deploy.zip"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo_success() { echo -e "${GREEN}[√]${NC} $1"; }
echo_info()    { echo -e "${YELLOW}[→]${NC} $1"; }
echo_error()   { echo -e "${RED}[×]${NC} $1"; }

echo ""
echo "════════════════════════════════════════════"
echo "   星辰健康管理系统 - 版本升级部署"
echo "════════════════════════════════════════════"
echo ""

# ── 1. 创建目录（如不存在） ──
echo_info "确认目录结构..."
mkdir -p $APP_HOME/{backend,admin-ui,user-ui,sql,uploadPath,logs}
echo_success "目录确认完成"

# ── 2. 解压部署包 ──
echo_info "解压新版部署包..."
if [ -f "$ZIP_FILE" ]; then
    cd $APP_HOME
    unzip -o xingchen-deploy.zip
    # 移动 JAR 到 backend 目录
    if [ -f "$APP_HOME/xingchen-admin.jar" ]; then
        mv -f $APP_HOME/xingchen-admin.jar $APP_HOME/backend/
    fi
    echo_success "解压完成"
else
    echo_error "未找到 $ZIP_FILE，请先上传新版 xingchen-deploy.zip"
    exit 1
fi

# ── 3. 跳过 SQL 导入（升级模式，保留现有数据库） ──
echo_info "升级模式：跳过 SQL 重导入，保护现有数据..."
echo_success "数据库数据已保留"

# ── 4. 检查 Redis 是否运行 ──
echo_info "检查 Redis 状态..."
if pgrep redis-server &> /dev/null; then
    echo_success "Redis 正在运行"
elif command -v redis-server &> /dev/null; then
    systemctl start redis 2>/dev/null || redis-server --daemonize yes 2>/dev/null || true
    echo_success "Redis 已启动"
else
    echo_error "Redis 未运行，请手动启动：systemctl start redis"
fi

# ── 5. 更新 Nginx 配置并重载 ──
echo_info "更新 Nginx 配置..."
if command -v nginx &> /dev/null; then
    cat > /etc/nginx/nginx.conf << 'NGINX_EOF'
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    sendfile      on;
    keepalive_timeout  65;
    client_max_body_size 20m;

    gzip  on;
    gzip_min_length  1k;
    gzip_types  text/plain text/css application/json application/javascript text/xml application/xml;

    # ===== 管理后台 (端口 80) =====
    server {
        listen       80;
        server_name  _;

        location / {
            root   /home/xingchen/admin-ui;
            index  index.html;
            try_files $uri $uri/ /index.html;
        }

        location /prod-api/ {
            proxy_pass http://127.0.0.1:8080/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout 60s;
            proxy_read_timeout    120s;
        }

        location /profile/ {
            alias /home/xingchen/uploadPath/;
        }
    }

    # ===== 用户端 (端口 81) =====
    server {
        listen       81;
        server_name  _;

        location / {
            root   /home/xingchen/user-ui;
            index  index.html;
            try_files $uri $uri/ /index.html;
        }

        location /user-api/ {
            proxy_pass http://127.0.0.1:8080/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_connect_timeout 60s;
            proxy_read_timeout    120s;
        }
    }
}
NGINX_EOF

    nginx -t 2>/dev/null && echo_success "Nginx 配置校验通过" || echo_error "Nginx 配置有误，请检查"

    if pgrep nginx &> /dev/null; then
        nginx -s reload
        echo_success "Nginx 已热重载（前端已更新）"
    else
        systemctl start nginx 2>/dev/null || nginx
        systemctl enable nginx 2>/dev/null || true
        echo_success "Nginx 已启动"
    fi
else
    echo_error "Nginx 未安装，请先运行 deploy.sh 完整部署"
fi

# ── 6. 停止旧版后端进程 ──
echo_info "停止旧版后端进程..."
pkill -f xingchen-admin.jar 2>/dev/null && echo_success "旧进程已停止" || echo_success "无旧进程在运行"
sleep 3

# ── 7. 启动新版后端 ──
echo_info "启动新版后端服务..."
cd $APP_HOME/backend
nohup java -Xms512m -Xmx1024m \
    -Dname=xingchen-admin.jar \
    -Duser.timezone=Asia/Shanghai \
    -jar xingchen-admin.jar \
    --spring.profiles.active=druid \
    > $APP_HOME/logs/backend.log 2>&1 &
BACKEND_PID=$!
echo_success "新版后端已启动 (PID: $BACKEND_PID)"

# ── 8. 等待后端就绪 ──
echo_info "等待后端服务就绪（约 30 秒）..."
for i in $(seq 1 30); do
    sleep 1
    if curl -s http://127.0.0.1:8080 > /dev/null 2>&1; then
        echo_success "后端服务已就绪！"
        break
    fi
    if [ $i -eq 30 ]; then
        echo_info "后端启动中，请稍后查看日志：tail -f $APP_HOME/logs/backend.log"
    fi
done

# ── 完成 ──
echo ""
echo "════════════════════════════════════════════"
echo -e "  ${GREEN}升级部署完成！${NC}"
echo "────────────────────────────────────────────"
echo "  管理后台：http://$(hostname -I | awk '{print $1}')"
echo "  用户端  ：http://$(hostname -I | awk '{print $1}'):81"
echo "  后端API ：http://127.0.0.1:8080"
echo "────────────────────────────────────────────"
echo "  常用命令："
echo "    查看后端日志：tail -f $APP_HOME/logs/backend.log"
echo "    停止后端    ：pkill -f xingchen-admin.jar"
echo "    重启后端    ：cd $APP_HOME/backend && nohup java -jar xingchen-admin.jar --spring.profiles.active=druid > $APP_HOME/logs/backend.log 2>&1 &"
echo "    重启 Nginx  ：nginx -s reload"
echo "════════════════════════════════════════════"
echo ""
