@echo off
chcp 65001 >nul
title XingChen 一键启动
color 0A

echo.
echo ========================================
echo       XingChen 系统一键启动
echo ========================================
echo.

REM 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [警告] 建议以管理员身份运行此脚本
    echo         否则 MySQL 可能无法启动
    echo.
    timeout /t 3 /nobreak >nul
)

echo [步骤 1/4] 检查并启动 MySQL...
echo ----------------------------------------
sc query MySQL80 | find "RUNNING" >nul
if %errorLevel% equ 0 (
    echo [√] MySQL 已在运行
) else (
    echo [!] MySQL 未运行,正在启动...
    net start MySQL80 >nul 2>&1
    if %errorLevel% equ 0 (
        echo [√] MySQL 启动成功
    ) else (
        echo [×] MySQL 启动失败,请检查服务是否存在
        echo     或手动启动 MySQL 服务
    )
)
echo.

echo [步骤 2/4] 检查并启动 Redis...
echo ----------------------------------------
netstat -ano | findstr :6379 | findstr LISTENING >nul
if %errorLevel% equ 0 (
    echo [√] Redis 已在运行
) else (
    echo [!] Redis 未运行
    if exist "C:\Program Files\Redis\redis-server.exe" (
        echo [!] 正在启动 Redis...
        start "" "C:\Program Files\Redis\redis-server.exe" --service-run
        echo [√] Redis 已启动
    ) else if exist "D:\Redis\redis-server.exe" (
        echo [!] 正在启动 Redis...
        start "" "D:\Redis\redis-server.exe" --service-run
        echo [√] Redis 已启动
    ) else (
        echo [×] 未找到 Redis,请先安装 Redis
        echo     下载地址: https://github.com/microsoftarchive/redis/releases
    )
)
echo.

echo [步骤 3/4] 等待服务就绪...
echo ----------------------------------------
timeout /t 3 /nobreak >nul

echo 检查端口状态:
netstat -ano | findstr :3306 | findstr LISTENING >nul
if %errorLevel% equ 0 (
    echo [√] MySQL 端口 3306 正常
) else (
    echo [×] MySQL 端口 3306 未监听
)

netstat -ano | findstr :6379 | findstr LISTENING >nul
if %errorLevel% equ 0 (
    echo [√] Redis 端口 6379 正常
) else (
    echo [×] Redis 端口 6379 未监听
)
echo.

echo [步骤 4/4] 启动后端服务...
echo ----------------------------------------
cd /d "%~dp0..\XingChen-Vue"

where mvn >nul 2>&1
if %errorLevel% equ 0 (
    echo [√] 检测到 Maven,使用命令行启动
    echo.
    echo 提示: 
    echo   - 首次启动需要下载依赖,请耐心等待
    echo   - 启动后会占用此窗口,请勿关闭
    echo   - 按 Ctrl+C 可停止后端服务
    echo.
    echo 正在启动后端...
    echo ========================================
    call mvn spring-boot:run -pl xingchen-admin
) else (
    echo [!] 未检测到 Maven
    echo.
    echo 请使用以下方式启动后端:
    echo   1. 打开 IntelliJ IDEA
    echo   2. 打开项目: e:\XingChen-Vue
    echo   3. 运行 XingChenApplication.java
    echo.
    echo 或者先安装 Maven:
    echo   下载: https://maven.apache.org/download.cgi
)
echo.

echo ========================================
echo   环境服务已就绪!
echo ========================================
echo.
echo 访问地址:
echo   前端: http://localhost:80
echo   后端: http://localhost:8080
echo.
echo 登录信息:
echo   账号: admin
echo   密码: admin123
echo.
echo ========================================
pause
