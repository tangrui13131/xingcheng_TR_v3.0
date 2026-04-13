@echo off
chcp 65001 >nul
title XingChen 一键停止
color 0C

echo.
echo ========================================
echo       XingChen 系统一键停止
echo ========================================
echo.

echo [步骤 1/3] 停止后端服务...
echo ----------------------------------------
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :8080 ^| findstr LISTENING') do (
    echo [!] 发现后端进程 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
    if %errorLevel% equ 0 (
        echo [√] 后端服务已停止
    ) else (
        echo [×] 后端服务停止失败
    )
    goto :backend_done
)
echo [√] 后端服务未运行
:backend_done
echo.

echo [步骤 2/3] 停止 MySQL...
echo ----------------------------------------
sc query MySQL80 | find "RUNNING" >nul
if %errorLevel% equ 0 (
    echo [!] 正在停止 MySQL...
    net stop MySQL80 >nul 2>&1
    if %errorLevel% equ 0 (
        echo [√] MySQL 已停止
    ) else (
        echo [×] MySQL 停止失败,可能需要管理员权限
    )
) else (
    echo [√] MySQL 未运行
)
echo.

echo [步骤 3/3] 停止 Redis...
echo ----------------------------------------
for /f "tokens=5" %%a in ('netstat -ano ^| findstr :6379 ^| findstr LISTENING') do (
    echo [!] 发现 Redis 进程 PID: %%a
    taskkill /F /PID %%a >nul 2>&1
    if %errorLevel% equ 0 (
        echo [√] Redis 已停止
    ) else (
        echo [×] Redis 停止失败
    )
    goto :redis_done
)
echo [√] Redis 未运行
:redis_done
echo.

echo ========================================
echo   所有服务已停止!
echo ========================================
echo.
pause
