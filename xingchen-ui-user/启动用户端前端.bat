@echo off
chcp 65001 >nul
title 星辰用户端前端启动
color 0A

echo.
echo ========================================
echo       星辰用户端前端服务启动
echo ========================================
echo.

echo [步骤 1/2] 进入用户端前端目录...
echo ----------------------------------------
cd /d "e:\计算机设计大赛\tr_xingcgen\项目1\XingChen-Vue\xingchen-ui-user"
if %errorLevel% neq 0 (
    echo [×] 目录不存在，请检查路径
    pause
    exit /b 1
)
echo [√] 已进入用户端前端目录
echo.

echo [步骤 2/2] 启动用户端前端开发服务器...
echo ----------------------------------------
echo 提示:
echo   - 首次启动需要安装依赖，请耐心等待
echo   - 启动后会占用此窗口，请勿关闭
echo   - 按 Ctrl+C 可停止服务
echo.
echo 正在启动...
echo ========================================
echo.

npm run dev

pause
