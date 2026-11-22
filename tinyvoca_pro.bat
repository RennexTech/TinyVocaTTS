@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ============================================
echo   Tiny Voca Studio Pro
echo ============================================
echo.

set PY=.venv\Scripts\python.exe
set DZ=https://github.com/n4ze3m/dizione/archive/refs/heads/main.zip
set PKGS=onnxruntime soundfile numpy pygame huggingface_hub

rem ---------- 1. virtual environment (first run only) ----------
if exist "%PY%" goto have_venv
echo [*] First run: creating virtual environment...
where py >nul 2>nul
if errorlevel 1 (
    echo [X] Python launcher "py" not found. Install Python 3.12 first.
    pause & exit /b 1
)
py -3.12 -m venv .venv
if errorlevel 1 (
    echo [X] Could not create the virtual environment.
    pause & exit /b 1
)
"%PY%" -m pip install --upgrade pip
echo.
:have_venv

rem ---------- 2. packages (only installs what is missing) ----------
"%PY%" -c "import onnxruntime, soundfile, numpy, pygame, huggingface_hub, dizione" 2>nul
if not errorlevel 1 goto have_pkgs
echo [*] Installing packages...
"%PY%" -m pip install %PKGS%
if errorlevel 1 goto pip_fail
"%PY%" -m pip install %DZ%
if errorlevel 1 goto pip_fail
echo.
:have_pkgs

rem ---------- 3. model + phonemizer data (first run only) ----------
if exist "tiny-voca\onnx\model.onnx" if exist "tiny-voca\phonemizer\lexicon.tsv" goto have_model
echo [*] Downloading tiny-voca model and phonemizer data (about 30 MB)...
"%PY%" -c "from huggingface_hub import snapshot_download as d; d('n4ze3m/tiny-voca', local_dir='tiny-voca', allow_patterns=['onnx/model.onnx','config.json','phonemizer/*'])"
if errorlevel 1 goto dl_fail
if not exist "tiny-voca\onnx\model.onnx" goto dl_fail
if not exist "tiny-voca\phonemizer\lexicon.tsv" goto dl_fail
echo.
:have_model

if not exist "tiny_voca_studio.py" (
    echo [X] tiny_voca_studio.py missing next to this .bat
    pause & exit /b 1
)

where ffmpeg >nul 2>nul
if errorlevel 1 (
    if exist "ffmpeg.exe" (echo [*] ffmpeg.exe found locally.) else (echo [!] ffmpeg not found - WAV only.)
) else (
    echo [*] ffmpeg found on PATH.
)

echo.
echo [*] Launching Tiny Voca Studio Pro...
set DIZIONE_DATA=%~dp0tiny-voca\phonemizer
"%PY%" tiny_voca_studio.py
if errorlevel 1 (
    echo.
    echo [X] GUI crashed. Scroll up for details.
    pause
)
exit /b 0

:pip_fail
echo.
echo [X] Package install failed. Check your internet connection and run this .bat again.
pause & exit /b 1

:dl_fail
echo.
echo [X] Model download failed. Check your internet connection and run this .bat again.
pause & exit /b 1
