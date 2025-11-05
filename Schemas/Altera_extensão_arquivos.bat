@echo off
setlocal enabledelayedexpansion

echo Alterando extensões de .txt para .sql...
echo.

for %%f in (*.txt) do (
    set "nome=%%~nf"
    if not exist "!nome!.sql" (
        ren "%%f" "!nome!.sql"
        echo Renomeado: %%f → !nome!.sql
    ) else (
        echo [AVISO] Já existe: !nome!.sql — Arquivo %%f NÃO foi renomeado.
    )
)

echo.
echo Processo concluído.
pause
