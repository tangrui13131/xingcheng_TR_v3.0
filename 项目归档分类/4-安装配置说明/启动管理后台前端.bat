@echo off
chcp 65001 >nul
title 星辰管理后台前端启动(Vue3)
color 0D

echo.
echo ========================================
echo       星辰管理后台前端服务启动
echo         (Vue 3 + Vite)
echo ========================================
echo.

echo [步骤 1/2] 正在定位前端目录...
echo ----------------------------------------
cd /d "%~dp0"
if %errorLevel% neq 0 (
    echo [×] 目录异常，请检查脚本所在位置
    pause
    exit /b 1
)
echo [√] 当前目录: %cd%
echo.

echo [步骤 2/2] 启动管理后台前端开发服务器...
echo ----------------------------------------
echo 提示:
echo   - 启动后会占用此窗口，请勿关闭
echo   - 按 Ctrl+C 可停止服务
echo   - 访问地址: http://localhost:5173
echo.
echo 正在启动...
echo ========================================
echo.

npm run dev

pause
