# 星辰健康管理系统 (XingChen Health Management System)

基于 Spring Boot + Vue3 的智能健康管理系统，融合健康打卡、积分激励、AI 健康助手等核心功能，以温馨治愈风格为用户提供全方位的健康管理服务。

## 项目简介

星辰健康管理系统是一款面向普通用户和健康管理人员的综合性健康管理平台。系统通过每日健康打卡、积分奖励机制、健康商品兑换等特色功能，激励用户养成健康的生活习惯；同时集成 AI 健康助手，为用户提供智能化的健康咨询与建议。管理后台提供完善的用户管理、权限控制、数据监控等功能，便于运营人员高效管理。

## 功能架构

```
健康管理系统
├── 用户端功能
│   ├── 健康打卡 ── 每日打卡 / 打卡记录 / 打卡提醒
│   ├── 积分管理 ── 积分获取 / 积分查询 / 积分明细
│   ├── 健康商品兑换 ── 商品浏览 / 积分兑换 / 兑换记录
│   ├── 我的健康数据 ── 健康数据查看 / 数据导出
│   └── AI 健康助手 ── 智能健康咨询 / 对话记录
│
├── 管理后台功能
│   ├── 系统管理 ── 参数配置 / 字典管理
│   ├── 权限管理 ── 用户管理 / 角色管理 / 菜单管理
│   ├── 健康管理 ── 健康数据看板 / 积分管理 / 兑换审核
│   ├── 监控告警 ── 在线用户 / 操作日志 / 登录日志
│   └── 定时任务 ── 任务调度 / 日志查看
│
└── 系统支撑功能
    ├── 基础框架 ── 数据源管理 / 缓存配置
    ├── 代码生成 ── 自动生成 CRUD 代码
    └── 安全防护 ── XSS 过滤 / 重复提交拦截 / 敏感信息脱敏
```

## 技术栈

### 后端

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 4.0.3 | 核心框架 |
| MyBatis | 4.0.1 | ORM 框架 |
| Druid | 1.2.28 | 数据库连接池 |
| Spring Security | - | 安全认证 |
| JWT | 0.9.1 | Token 认证 |
| Fastjson | 2.0.61 | JSON 处理 |
| Quartz | - | 定时任务调度 |
| SpringDoc | 3.0.2 | API 文档 |
| Java | 17 | 运行环境 |

### 管理后台前端 (XingChen-Vue3)

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.x | 前端框架 |
| Vite | 5.x | 构建工具 |
| Element Plus | 2.13.1 | UI 组件库 |
| Pinia | - | 状态管理 |
| Vue Router | 4.x | 路由管理 |
| ECharts | 5.6.0 | 图表可视化 |
| Axios | 1.13.2 | HTTP 客户端 |

### 用户端前端 (xingchen-ui-user)

| 技术 | 版本 | 说明 |
|------|------|------|
| Vue | 3.3.x | 前端框架 |
| Vite | 5.x | 构建工具 |
| Element Plus | 2.4.x | UI 组件库 |
| Pinia | 2.1.x | 状态管理 |
| ECharts | 6.x | 图表可视化 |
| html2canvas | 1.4.x | 截图导出 |
| jsPDF | 4.x | PDF 生成 |

### 数据库

- MySQL 8.0+

## 项目结构

```
健康管理系统/
├── XingChen-Vue/                    # 后端 + 用户端前端
│   ├── xingchen-admin/              # 管理后台模块（启动入口）
│   ├── xingchen-framework/          # 核心框架模块
│   ├── xingchen-system/             # 系统业务模块
│   ├── xingchen-quartz/             # 定时任务模块
│   ├── xingchen-common/             # 公共工具模块
│   ├── xingchen-generator/          # 代码生成模块
│   ├── xingchen-ui-user/            # 用户端前端源码
│   │   ├── src/
│   │   │   ├── views/               # 页面组件
│   │   │   │   ├── AiHealthAssistant.vue   # AI 健康助手
│   │   │   │   ├── MyHealthData.vue        # 我的健康数据
│   │   │   │   ├── PointsMall.vue          # 积分商城
│   │   │   │   ├── index.vue               # 首页（打卡）
│   │   │   │   ├── login.vue               # 登录
│   │   │   │   ├── register.vue            # 注册
│   │   │   │   └── profile.vue             # 个人中心
│   │   │   ├── api/                 # API 接口
│   │   │   ├── assets/              # 静态资源
│   │   │   └── router/              # 路由配置
│   │   └── vite.config.js
│   ├── sql/                         # 数据库脚本
│   ├── bin/                         # 运维脚本
│   └── pom.xml
│
├── XingChen-Vue3/                   # 管理后台前端源码
│   ├── src/
│   │   ├── views/
│   │   │   ├── ai/                  # AI 模块页面
│   │   │   ├── hr/                  # 健康管理页面
│   │   │   │   ├── dashboard.vue           # 健康数据看板
│   │   │   │   ├── PointsManage.vue        # 积分管理
│   │   │   │   └── RedemptionAudit.vue     # 兑换审核
│   │   │   ├── system/              # 系统管理页面
│   │   │   ├── monitor/             # 系统监控页面
│   │   │   └── tool/                # 系统工具页面
│   │   ├── api/                     # API 接口
│   │   ├── components/              # 公共组件
│   │   ├── store/                   # 状态管理
│   │   └── router/                  # 路由配置
│   └── vite.config.js
│
└── deploy/                          # 部署配置
    └── xingchen-deploy/             # 部署包

项目归档分类/
├── 1-源代码/                         # 完整源代码副本
├── 2-素材包/                         # 图片、图标等素材
├── 3-数据库脚本/                     # SQL 初始化脚本
├── 4-安装配置说明/                   # 部署配置文件与说明
└── 5-设计文档/                       # 产品设计文档
```

## 快速开始

### 环境要求

- JDK 17+
- Node.js 18+
- MySQL 8.0+
- Maven 3.8+
- Redis 6.0+

### 1. 初始化数据库

```bash
# 创建数据库
mysql -u root -p
CREATE DATABASE xingcheng DEFAULT CHARACTER SET utf8mb4;

# 导入初始化脚本（按顺序执行）
mysql -u root -p xingcheng < 健康管理系统/XingChen-Vue/sql/ry_20260321.sql
mysql -u root -p xingcheng < 健康管理系统/XingChen-Vue/sql/points_log.sql
mysql -u root -p xingcheng < 健康管理系统/XingChen-Vue/sql/redemption.sql
mysql -u root -p xingcheng < 健康管理系统/XingChen-Vue/sql/quartz.sql
```

### 2. 启动后端

```bash
# 修改数据库连接配置
# 编辑 xingchen-admin/src/main/resources/application-druid.yml
# 修改 url、username、password

# 编译打包
cd 健康管理系统/XingChen-Vue
mvn clean package -DskipTests

# 启动服务
java -jar xingchen-admin/target/xingchen-admin.jar
```

后端默认启动端口：`8080`

### 3. 启动管理后台前端

```bash
cd 健康管理系统/XingChen-Vue3

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

管理后台默认访问地址：`http://localhost:80`

### 4. 启动用户端前端

```bash
cd 健康管理系统/XingChen-Vue/xingchen-ui-user

# 安装依赖
npm install

# 启动开发服务器
npm run dev
```

用户端默认访问地址：`http://localhost:81`

## 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |

> 首次登录后请及时修改默认密码。

## 项目特色

- **温馨治愈风格 UI** - 用户端采用柔和配色与圆角设计，营造温暖舒适的使用体验
- **积分激励体系** - 通过每日打卡获取积分，积分可兑换健康商品，形成正向健康习惯闭环
- **AI 健康助手** - 集成智能对话功能，为用户提供个性化的健康咨询与建议
- **健康数据可视化** - 基于 ECharts 的多维度健康数据图表展示，直观了解健康状况
- **完善的权限管理** - 基于 RBAC 的细粒度权限控制，支持菜单级、按钮级权限配置
- **安全防护** - XSS 过滤、重复提交拦截、敏感信息脱敏等多层安全机制

## 许可证

MIT License
