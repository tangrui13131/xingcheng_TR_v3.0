#!/bin/bash
# ============================================
# 星辰健康管理系统 - 服务器一键部署脚本
# 使用方法：chmod +x deploy.sh && ./deploy.sh
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
echo "   星辰健康管理系统 - 一键部署"
echo "════════════════════════════════════════════"
echo ""

# ── 1. 创建目录 ──
echo_info "创建目录结构..."
mkdir -p $APP_HOME/{backend,admin-ui,user-ui,sql,uploadPath,logs}
echo_success "目录创建完成"

# ── 2. 解压部署包 ──
echo_info "解压部署包..."
if [ -f "$ZIP_FILE" ]; then
    cd $APP_HOME
    unzip -o xingchen-deploy.zip
    # 移动 JAR 到 backend 目录
    if [ -f "$APP_HOME/xingchen-admin.jar" ]; then
        mv $APP_HOME/xingchen-admin.jar $APP_HOME/backend/
    fi
    echo_success "解压完成"
else
    echo_error "未找到 $ZIP_FILE，请确认文件已上传"
    exit 1
fi

# ── 3. 初始化 MySQL 数据库 ──
echo_info "初始化 MySQL 数据库..."
if command -v mysql &> /dev/null; then
    mysql -u root -p'123456Tr!' -e "CREATE DATABASE IF NOT EXISTS \`ry-vue\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null || \
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS \`ry-vue\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;" 2>/dev/null || \
    echo_error "MySQL 连接失败，请手动初始化数据库（见下方说明）"

    # 导入 SQL
    if [ -f "$APP_HOME/sql/ry_20260321.sql" ]; then
        mysql -u root -p'123456Tr!' ry-vue < $APP_HOME/sql/ry_20260321.sql 2>/dev/null || \
        mysql -u root ry-vue < $APP_HOME/sql/ry_20260321.sql 2>/dev/null || \
        echo_error "SQL 导入失败，请手动执行"
    fi
    if [ -f "$APP_HOME/sql/quartz.sql" ]; then
        mysql -u root -p'123456Tr!' ry-vue < $APP_HOME/sql/quartz.sql 2>/dev/null || \
        mysql -u root ry-vue < $APP_HOME/sql/quartz.sql 2>/dev/null || true
    fi
    if [ -f "$APP_HOME/sql/points_log.sql" ]; then
        mysql -u root -p'123456Tr!' ry-vue < $APP_HOME/sql/points_log.sql 2>/dev/null || \
        mysql -u root ry-vue < $APP_HOME/sql/points_log.sql 2>/dev/null || true
    fi
    echo_success "MySQL 初始化完成"
else
    echo_error "MySQL 未安装，请先安装 MySQL 8.0"
    echo "  安装命令：yum install -y mysql-server"
    echo "  初始化命令：mysql -u root -p < $APP_HOME/sql/ry_20260321.sql"
fi

# ── 4. 启动 Redis ──
echo_info "启动 Redis..."
if command -v redis-server &> /dev/null; then
    if pgrep redis-server &> /dev/null; then
        echo_success "Redis 已运行"
    else
        systemctl start redis 2>/dev/null || redis-server --daemonize yes 2>/dev/null || true
        echo_success "Redis 已启动"
    fi
elif [ -f "/usr/local/bin/redis-server" ]; then
    /usr/local/bin/redis-server --daemonize yes
    echo_success "Redis 已启动"
else
    echo_error "Redis 未安装，正在安装..."
    yum install -y redis
    systemctl start redis
    systemctl enable redis
    echo_success "Redis 安装并启动完成"
fi

# ── 5. 配置 Nginx ──
echo_info "配置 Nginx..."
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

    nginx -t 2>/dev/null && echo_success "Nginx 配置写入成功" || echo_error "Nginx 配置有误"

    # 启动 Nginx
    if pgrep nginx &> /dev/null; then
        nginx -s reload
        echo_success "Nginx 已重新加载"
    else
        systemctl start nginx 2>/dev/null || nginx
        systemctl enable nginx 2>/dev/null || true
        echo_success "Nginx 已启动"
    fi
else
    echo_error "Nginx 未安装，正在安装..."
    yum install -y epel-release
    yum install -y nginx
    # 重新写配置
    cat > /etc/nginx/nginx.conf << 'NGINX_EOF2'
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
        }

        location /profile/ {
            alias /home/xingchen/uploadPath/;
        }
    }

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
        }
    }
}
NGINX_EOF2
    systemctl start nginx
    systemctl enable nginx
    echo_success "Nginx 安装配置完成"
fi

# ── 6. 停止旧的后端进程（如果有） ──
echo_info "检查旧后端进程..."
pkill -f xingchen-admin.jar 2>/dev/null && echo_success "旧进程已停止" || echo_success "无旧进程"

# ── 7. 启动后端 Spring Boot ──
echo_info "启动后端服务..."
cd $APP_HOME/backend
nohup java -Xms512m -Xmx1024m \
    -Dname=xingchen-admin.jar \
    -Duser.timezone=Asia/Shanghai \
    -jar xingchen-admin.jar \
    --spring.profiles.active=druid \
    > $APP_HOME/logs/backend.log 2>&1 &
BACKEND_PID=$!
echo_success "后端已启动 (PID: $BACKEND_PID)"

# ── 8. 开放防火墙端口 ──
echo_info "配置防火墙..."
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=80/tcp 2>/dev/null || true
    firewall-cmd --permanent --add-port=81/tcp 2>/dev/null || true
    firewall-cmd --permanent --add-port=8080/tcp 2>/dev/null || true
    firewall-cmd --reload 2>/dev/null || true
    echo_success "防火墙端口已开放 (80, 81, 8080)"
else
    echo_info "未检测到 firewalld，请确认阿里云安全组已放行 80/81/8080 端口"
fi

# ── 9. 等待后端启动 ──
echo_info "等待后端服务就绪（约 20 秒）..."
for i in $(seq 1 20); do
    sleep 1
    if curl -s http://127.0.0.1:8080 > /dev/null 2>&1; then
        echo_success "后端服务已就绪！"
        break
    fi
    if [ $i -eq 20 ]; then
        echo_info "后端可能还在启动中，请查看日志：tail -f $APP_HOME/logs/backend.log"
    fi
done

# ── 完成 ──
echo ""
echo "════════════════════════════════════════════"
echo -e "  ${GREEN}部署完成！${NC}"
echo "────────────────────────────────────────────"
echo "  管理后台：http://$(hostname -I | awk '{print $1}')"
echo "  用户端  ：http://$(hostname -I | awk '{print $1}'):81"
echo "  后端API ：http://127.0.0.1:8080"
echo "────────────────────────────────────────────"
echo "  管理员账号：admin / admin123"
echo "────────────────────────────────────────────"
echo "  常用命令："
echo "    查看后端日志：tail -f $APP_HOME/logs/backend.log"
echo "    停止后端    ：pkill -f xingchen-admin.jar"
echo "    重启后端    ：cd $APP_HOME/backend && nohup java -jar xingchen-admin.jar > $APP_HOME/logs/backend.log 2>&1 &"
echo "    重启 Nginx  ：nginx -s reload"
echo "════════════════════════════════════════════"
echo ""
echo -e "${YELLOW}重要提醒：请到阿里云控制台 → 安全组 → 放行 80 和 81 端口！${NC}"
echo ""
