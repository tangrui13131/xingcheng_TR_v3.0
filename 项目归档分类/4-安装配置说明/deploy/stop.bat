@echo off
chcp 65001 >nul
title 星辰健康管理系统 - 停止
color 0C

echo.
echo ══════════════════════════════════════════
echo       星辰健康管理系统  正在停止...
echo ══════════════════════════════════════════
echo.

REM ── 1. 停止 Nginx ──
echo [1/3] 停止 Nginx...
tasklist /fi "imagename eq nginx.exe" 2>nul | find /i "nginx.exe" >nul
if %errorLevel% equ 0 (
    taskkill /f /im nginx.exe >nul 2>&1
    echo   [√] Nginx 已停止
) else (
    echo   [-] Nginx 未运行
)

REM ── 2. 停止后端 Java 进程 ──
echo [2/3] 停止后端服务...
for /f "tokens=1" %%p in ('jps -l 2^>nul ^| findstr "xingchen-admin.jar"') do (
    taskkill /f /pid %%p >nul 2>&1
    echo   [√] 后端进程 %%p 已终止
)
REM 备用：如果 jps 不可用
tasklist /fi "imagename eq javaw.exe" 2>nul | find /i "javaw.exe" >nul
if %errorLevel% equ 0 (
    echo   [!] 检测到 javaw.exe 进程，如需终止请手动确认
)

REM ── 3. 停止 Redis ──
echo [3/3] 停止 Redis...
tasklist /fi "imagename eq redis-server.exe" 2>nul | find /i "redis-server.exe" >nul
if %errorLevel% equ 0 (
    taskkill /f /im redis-server.exe >nul 2>&1
    echo   [√] Redis 已停止
) else (
    echo   [-] Redis 未运行
)

echo.
echo ══════════════════════════════════════════
echo   所有服务已停止
echo   （MySQL 作为系统服务保持运行）
echo ══════════════════════════════════════════
echo.
pause
