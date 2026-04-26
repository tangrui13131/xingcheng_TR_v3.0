@echo off
chcp 65001 >nul
title 星辰健康管理系统 - 一键启动
color 0A

echo.
echo ========================================
echo       星辰健康管理系统 v2.0 一键启动
echo ========================================
echo.

set FRONTEND_DIR=%~dp0
set BACKEND_DIR=%~dp0..\XingChen-Vue

echo [1/3] 检查并启动基础设施...
echo ----------------------------------------
echo 提示: 请确保 MySQL 和 Redis 已手动启动
echo MySQL 默认端口: 3306
echo Redis 默认端口: 6379
echo.

echo [2/3] 启动后端服务...
echo ----------------------------------------
cd /d "%BACKEND_DIR%"
if %errorLevel% neq 0 (
    echo [×] 未找到后端目录: %BACKEND_DIR%
    pause
    exit /b 1
)

echo 正在新窗口启动后端服务...
start "星辰后端服务" cmd /c "chcp 65001 >nul && title 星辰后端服务 && echo 正在通过 Maven 启动后端... && mvn spring-boot:run -pl xingchen-admin || pause"
echo [√] 后端启动指令已发出
echo.

echo [3/3] 启动管理后台前端...
echo ----------------------------------------
cd /d "%FRONTEND_DIR%"
echo 正在新窗口启动前端服务...
start "星辰管理后台前端" cmd /c "chcp 65001 >nul && title 星辰管理后台前端 && echo 正在启动 Vite 开发服务器... && npm run dev || pause"
echo [√] 前端启动指令已发出
echo.

echo ========================================
echo   服务启动中，请在弹出的窗口查看详情
echo ========================================
echo.
echo 访问地址:
echo   管理后台: http://localhost:5173
echo   后端接口: http://localhost:8080
echo.
echo 登录信息:
echo   账号: admin
echo   密码: admin123
echo.
echo ========================================
pause
