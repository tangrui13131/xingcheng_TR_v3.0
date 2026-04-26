@echo off
chcp 65001 >nul
title 星辰健康管理系统 - 一键构建
color 0A

echo.
echo ══════════════════════════════════════════
echo    星辰健康管理系统 - 一键构建全部产物
echo ══════════════════════════════════════════
echo.

set "ROOT=%~dp0.."
set "OUTPUT=%~dp0package"

REM 清理旧产物
if exist "%OUTPUT%" rd /s /q "%OUTPUT%"
mkdir "%OUTPUT%\backend"
mkdir "%OUTPUT%\admin-ui"
mkdir "%OUTPUT%\user-ui"
mkdir "%OUTPUT%\nginx\conf"
mkdir "%OUTPUT%\nginx\logs"
mkdir "%OUTPUT%\redis"
mkdir "%OUTPUT%\sql"

echo [1/5] 构建后端 JAR ...
echo ────────────────────────────────────────
cd /d "%ROOT%\XingChen-Vue"
call mvn clean package -DskipTests -q
if %errorLevel% neq 0 (
    echo [×] 后端构建失败！请检查 Maven 环境
    pause & exit /b 1
)
copy /y "xingchen-admin\target\xingchen-admin.jar" "%OUTPUT%\backend\" >nul
echo [√] xingchen-admin.jar 已生成
echo.

echo [2/5] 构建管理后台前端 ...
echo ────────────────────────────────────────
cd /d "%ROOT%\XingChen-Vue3"
call npm install --silent 2>nul
call npm run build:prod
if %errorLevel% neq 0 (
    echo [×] 管理后台前端构建失败！
    pause & exit /b 1
)
xcopy /s /e /q /y "dist\*" "%OUTPUT%\admin-ui\" >nul
echo [√] admin-ui 已生成
echo.

echo [3/5] 构建用户端前端 ...
echo ────────────────────────────────────────
cd /d "%ROOT%\XingChen-Vue\xingchen-ui-user"
call npm install --silent 2>nul
call npm run build:prod
if %errorLevel% neq 0 (
    echo [×] 用户端前端构建失败！
    pause & exit /b 1
)
xcopy /s /e /q /y "dist\*" "%OUTPUT%\user-ui\" >nul
echo [√] user-ui 已生成
echo.

echo [4/5] 复制 SQL 初始化脚本 ...
echo ────────────────────────────────────────
copy /y "%ROOT%\XingChen-Vue\sql\*.sql" "%OUTPUT%\sql\" >nul
echo [√] SQL 文件已复制
echo.

echo [5/5] 复制运行脚本和配置 ...
echo ────────────────────────────────────────
copy /y "%~dp0start.bat"  "%OUTPUT%\" >nul
copy /y "%~dp0stop.bat"   "%OUTPUT%\" >nul
copy /y "%~dp0nginx.conf" "%OUTPUT%\nginx\conf\" >nul
echo [√] 脚本和配置已复制
echo.

echo ══════════════════════════════════════════
echo  构建完成！产物目录：%OUTPUT%
echo ══════════════════════════════════════════
echo.
echo 下一步：
echo   1. 将便携版 JDK17 放入 %OUTPUT%\jdk\
echo   2. 将便携版 Redis 放入 %OUTPUT%\redis\
echo   3. 将便携版 Nginx 放入 %OUTPUT%\nginx\
echo   4. 用 Inno Setup 编译 installer.iss 生成安装包
echo.
pause
