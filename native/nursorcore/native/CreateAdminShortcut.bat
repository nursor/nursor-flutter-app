@echo off
:: 使用 PowerShell 提升权限启动应用程序
powershell -Command "Start-Process '{app}\{#MyAppExeName}' -Verb runAs"
