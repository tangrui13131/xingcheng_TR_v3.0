================================================================================
                        1-源代码 —— 项目全部源码
================================================================================

本目录包含"星辰健康管理系统"的全部源代码，分为两大版本：

--------------------------------------------------------------------------------
一、XingChen-Vue（第一版：Java后端 + Vue用户端）
--------------------------------------------------------------------------------

【技术栈】Spring Boot + MyBatis + Vue3 + Vite

├── pom.xml                      Maven父工程配置，定义所有模块及依赖版本
├── xingchen-admin/              管理后台服务（Spring Boot入口）
│   ├── pom.xml                  模块依赖配置
│   └── src/
│       ├── main/java/com/xingchen/    Java源码（Controller/Service/Mapper等）
│       └── main/resources/           配置文件与MyBatis映射
│           ├── application.yml           主配置（端口/数据库/Redis等）
│           ├── application-druid.yml      数据源配置
│           ├── logback.xml                日志配置
│           └── mybatis/                   MyBatis XML映射文件
├── xingchen-common/             公共模块（工具类/注解/过滤器/异常处理）
│   └── src/main/java/com/xingchen/common/
│       ├── annotation/          自定义注解（限流/日志/权限等）
│       ├── config/              通用配置
│       ├── constant/            常量定义
│       ├── core/                核心类（BaseController/分页/响应封装）
│       ├── enums/               枚举类
│       ├── exception/           异常处理
│       ├── filter/              过滤器（XSS/重复请求等）
│       ├── utils/               工具类
│       └── xss/                 XSS防护
├── xingchen-framework/          框架核心（AOP切面/安全/配置）
│   └── src/main/java/com/xingchen/framework/
│       ├── aspectj/             AOP切面（日志/权限/数据源）
│       ├── config/              框架自动化配置（Druid/Redis/Shiro等）
│       ├── security/            安全相关（认证/授权）
│       └── web/                 Web层（异常/响应封装）
├── xingchen-generator/          代码生成器
│   └── src/main/resources/      生成模板与配置
├── xingchen-quartz/             定时任务模块
│   └── src/main/resources/mapper/quartz/   定时任务SQL映射
├── xingchen-system/             系统业务模块（用户/角色/菜单/日志/积分兑换）
│   └── src/main/resources/mapper/system/   系统业务SQL映射
└── xingchen-ui-user/            用户端前端（Vue3 + Vite）
    └── src/
        ├── api/                 后端API调用封装
        ├── assets/              静态资源（Logo/图片/样式）
        ├── components/          通用组件
        ├── router/              路由配置
        ├── store/               状态管理（Pinia）
        ├── utils/               前端工具函数
        ├── views/               页面视图
        │   ├── AiHealthAssistant/   AI健康助手
        │   ├── MyHealthData/        我的健康数据
        │   ├── PointsMall/          积分商城
        │   ├── profile/             个人中心
        │   ├── login/               登录
        │   └── register/            注册
        ├── App.vue              根组件
        └── main.js              入口文件

--------------------------------------------------------------------------------
二、XingChen-Vue3（第二版：Vue3管理后台）
--------------------------------------------------------------------------------

【技术栈】Vue3 + Vite + Element Plus + Pinia

├── App.vue                     根组件
├── main.js                     入口文件（挂载插件/路由/状态）
├── permission.js               路由权限守卫
├── settings.js                 全局设置
├── api/                        后端API调用（按模块划分）
├── assets/                     静态资源
│   ├── 404_images/             404页面插图
│   ├── images/                 通用图片
│   └── logo/                   管理后台Logo
├── components/                 组件库（21个公共组件）
├── directive/                  自定义指令（权限/防抖等）
├── layout/                     布局组件（侧边栏/顶栏/主体）
├── plugins/                    插件（SVG图标/自动导入等）
├── router/                     路由配置
├── store/                      状态管理（Pinia modules）
├── utils/                      工具函数（请求/认证/缓存等）
├── views/                      页面视图（按业务模块组织）
├── vite/plugins/               Vite构建插件（压缩/自动导入/SVG）
└── xingchen-ui/                独立UI组件库

================================================================================
【源码统计】
- Java模块：6个（admin/common/framework/generator/quartz/system）
- Vue前端：  2个（用户端 xingchen-ui-user / 管理后台 XingChen-Vue3）
- 总代码量：约15万行（不含node_modules和编译产物）
================================================================================
