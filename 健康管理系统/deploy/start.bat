@echo off
chcp 65001 >nul
title 星辰健康管理系统 - 启动
color 0A

set "APP_HOME=%~dp0"
set "JAVA_HOME=%APP_HOME%jdk"
set "PATH=%JAVA_HOME%\bin;%PATH%"

echo.
echo ══════════════════════════════════════════
echo       星辰健康管理系统  正在启动...
echo ══════════════════════════════════════════
echo.

REM ── 1. 检查 MySQL ──
echo [1/4] 检查 MySQL 服务...
sc query MySQL80 | find "RUNNING" >nul 2>&1
if %errorLevel% equ 0 (
    echo   [√] MySQL 已运行
) else (
    echo   [!] MySQL 未运行，正在尝试启动...
    net start MySQL80 >nul 2>&1
    if %errorLevel% equ 0 (
        echo   [√] MySQL 启动成功
    ) else (
        echo   [×] MySQL 启动失败！请确认已安装 MySQL 8.0 且服务名为 MySQL80
        echo       你也可以手动启动 MySQL 后重试
        pause & exit /b 1
    )
)

REM ── 2. 启动便携版 Redis ──
echo [2/4] 启动 Redis...
netstat -ano | findstr ":6379" | findstr "LISTENING" >nul 2>&1
if %errorLevel% equ 0 (
    echo   [√] Redis 已运行
) else (
    if exist "%APP_HOME%redis\redis-server.exe" (
        start "" /min "%APP_HOME%redis\redis-server.exe"
        timeout /t 2 /nobreak >nul
        echo   [√] Redis 已启动（便携版）
    ) else (
        echo   [×] 未找到 redis\redis-server.exe，请将 Redis 放入安装目录
        pause & exit /b 1
    )
)

REM ── 3. 启动后端 Spring Boot ──
echo [3/4] 启动后端服务...
if exist "%APP_HOME%backend\xingchen-admin.jar" (
    start "" /min "%JAVA_HOME%\bin\javaw.exe" -Xms512m -Xmx1024m -jar "%APP_HOME%backend\xingchen-admin.jar" --spring.profiles.active=druid
    echo   [√] 后端 JAR 已启动（端口 8080）
) else (
    echo   [×] 未找到 backend\xingchen-admin.jar
    pause & exit /b 1
)

REM ── 4. 启动 Nginx ──
echo [4/4] 启动 Nginx...
if exist "%APP_HOME%nginx\nginx.exe" (
    cd /d "%APP_HOME%nginx"
    start "" nginx.exe
    echo   [√] Nginx 已启动（管理台:80  用户端:81）
) else (
    echo   [×] 未找到 nginx\nginx.exe
    pause & exit /b 1
)

echo.
REM 等待后端启动
echo 等待后端服务就绪（约 15 秒）...
timeout /t 15 /nobreak >nul

echo.
echo ══════════════════════════════════════════
echo   启动完成！
echo ──────────────────────────────────────────
echo   管理后台：http://localhost
echo   用户端  ：http://localhost:81
echo   后端API ：http://localhost:8080
echo ──────────────────────────────────────────
echo   管理员账号：admin / admin123
echo ══════════════════════════════════════════
echo.

REM 自动打开浏览器
start "" "http://localhost"
start "" "http://localhost:81"

echo 按任意键可关闭此窗口（服务将在后台继续运行）
echo 关闭服务请运行 stop.bat
pause >nul
