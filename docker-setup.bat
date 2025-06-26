@echo off
REM openSIS Classic Docker Setup Script for Windows
REM This script helps set up and manage the openSIS Docker environment

setlocal enabledelayedexpansion

REM Colors (limited in Windows CMD)
set "INFO=[INFO]"
set "SUCCESS=[SUCCESS]"
set "WARNING=[WARNING]"
set "ERROR=[ERROR]"

REM Function to check if Docker is installed and running
:check_docker
echo %INFO% Checking Docker installation...

docker --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker is not installed. Please install Docker Desktop first.
    pause
    exit /b 1
)

docker info >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker is not running. Please start Docker Desktop first.
    pause
    exit /b 1
)

echo %SUCCESS% Docker is installed and running
goto :eof

REM Function to check if Docker Compose is installed
:check_docker_compose
echo %INFO% Checking Docker Compose installation...

docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo %ERROR% Docker Compose is not installed. Please install Docker Compose first.
    pause
    exit /b 1
)

echo %SUCCESS% Docker Compose is installed
goto :eof

REM Function to start containers
:start_containers
echo %INFO% Building and starting Docker containers...

docker-compose up -d --build
if errorlevel 1 (
    echo %ERROR% Failed to start containers
    pause
    exit /b 1
)

echo %SUCCESS% Containers started successfully
goto :eof

REM Function to wait for database
:wait_for_database
echo %INFO% Waiting for database to be ready...
echo This may take a few minutes on first run...

timeout /t 30 /nobreak >nul
echo %SUCCESS% Database should be ready now
goto :eof

REM Function to show access information
:show_access_info
echo.
echo %SUCCESS% openSIS Classic Docker environment is ready!
echo.
echo Access URLs:
echo   openSIS Application: http://localhost:8080
echo   phpMyAdmin:         http://localhost:8081
echo.
echo Database Information:
echo   Host:     opensis-db (from container) / localhost (from host)
echo   Port:     3306
echo   Database: opensis
echo   Username: opensis_user
echo   Password: opensis_pass
echo   Root Password: root_password
echo.
echo Next Steps:
echo 1. Open http://localhost:8080 in your browser
echo 2. Follow the openSIS installation wizard
echo 3. Use the database information above when prompted
echo.
goto :eof

REM Function to show container status
:show_status
echo %INFO% Container Status:
docker-compose ps
goto :eof

REM Function to show logs
:show_logs
if "%~1"=="" (
    echo %INFO% Showing all container logs:
    docker-compose logs
) else (
    echo %INFO% Showing logs for %~1:
    docker-compose logs %~1
)
goto :eof

REM Function to stop containers
:stop_containers
echo %INFO% Stopping Docker containers...
docker-compose down
echo %SUCCESS% Containers stopped
goto :eof

REM Function to restart containers
:restart_containers
echo %INFO% Restarting Docker containers...
docker-compose restart
echo %SUCCESS% Containers restarted
goto :eof

REM Function to cleanup
:cleanup
echo %WARNING% This will remove all containers and database data!
set /p "confirm=Are you sure? (y/N): "
if /i "!confirm!"=="y" (
    echo %INFO% Cleaning up Docker containers and volumes...
    docker-compose down -v
    docker system prune -f
    echo %SUCCESS% Cleanup completed
)
goto :eof

REM Main menu
:show_menu
echo.
echo openSIS Classic Docker Management
echo ================================
echo 1. Start/Setup openSIS
echo 2. Stop containers
echo 3. Restart containers
echo 4. Show container status
echo 5. Show logs (all)
echo 6. Show web server logs
echo 7. Show database logs
echo 8. Cleanup (remove all)
echo 9. Exit
echo.
goto :eof

REM Main execution
if "%~1"=="start" goto start_setup
if "%~1"=="stop" goto stop_only
if "%~1"=="restart" goto restart_only
if "%~1"=="status" goto status_only
if "%~1"=="logs" goto logs_only
if "%~1"=="cleanup" goto cleanup_only

REM Interactive menu
:menu_loop
call :show_menu
set /p "choice=Select an option (1-9): "

if "!choice!"=="1" goto start_setup
if "!choice!"=="2" goto stop_only
if "!choice!"=="3" goto restart_only
if "!choice!"=="4" goto status_only
if "!choice!"=="5" goto logs_all
if "!choice!"=="6" goto logs_web
if "!choice!"=="7" goto logs_db
if "!choice!"=="8" goto cleanup_only
if "!choice!"=="9" exit /b 0

echo %ERROR% Invalid option. Please select 1-9.
echo.
pause
goto menu_loop

:start_setup
call :check_docker
if errorlevel 1 exit /b 1
call :check_docker_compose
if errorlevel 1 exit /b 1
call :start_containers
if errorlevel 1 exit /b 1
call :wait_for_database
call :show_access_info
if "%~1"=="" (
    pause
    goto menu_loop
)
exit /b 0

:stop_only
call :stop_containers
if "%~1"=="" (
    pause
    goto menu_loop
)
exit /b 0

:restart_only
call :restart_containers
if "%~1"=="" (
    pause
    goto menu_loop
)
exit /b 0

:status_only
call :show_status
if "%~1"=="" (
    pause
    goto menu_loop
)
exit /b 0

:logs_only
call :show_logs
if "%~1"=="" (
    pause
    goto menu_loop
)
exit /b 0

:logs_all
call :show_logs
pause
goto menu_loop

:logs_web
call :show_logs opensis-web
pause
goto menu_loop

:logs_db
call :show_logs opensis-db
pause
goto menu_loop

:cleanup_only
call :cleanup
if "%~1"=="" (
    pause
    goto menu_loop
)
exit /b 0
