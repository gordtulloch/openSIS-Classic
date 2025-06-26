#!/bin/bash

# openSIS Classic Docker Setup Script
# This script helps set up and manage the openSIS Docker environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is installed and running
check_docker() {
    print_status "Checking Docker installation..."
    
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker is not running. Please start Docker first."
        exit 1
    fi
    
    print_success "Docker is installed and running"
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    print_status "Checking Docker Compose installation..."
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    print_success "Docker Compose is installed"
}

# Function to check if ports are available
check_ports() {
    print_status "Checking if required ports are available..."
    
    local ports=(8080 8081 3306)
    local busy_ports=()
    
    for port in "${ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            busy_ports+=($port)
        fi
    done
    
    if [ ${#busy_ports[@]} -gt 0 ]; then
        print_warning "The following ports are in use: ${busy_ports[*]}"
        print_warning "You may need to modify the port mappings in docker-compose.yml"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "All required ports are available"
    fi
}

# Function to build and start containers
start_containers() {
    print_status "Building and starting Docker containers..."
    
    if docker-compose up -d --build; then
        print_success "Containers started successfully"
    else
        print_error "Failed to start containers"
        exit 1
    fi
}

# Function to wait for database to be ready
wait_for_database() {
    print_status "Waiting for database to be ready..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker-compose exec -T opensis-db mysql -u opensis_user -popensis_pass -e "SELECT 1" opensis &> /dev/null; then
            print_success "Database is ready"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    print_error "Database failed to start within expected time"
    return 1
}

# Function to display access information
show_access_info() {
    echo
    print_success "openSIS Classic Docker environment is ready!"
    echo
    echo "Access URLs:"
    echo "  openSIS Application: http://localhost:8080"
    echo "  phpMyAdmin:         http://localhost:8081"
    echo
    echo "Database Information:"
    echo "  Host:     opensis-db (from container) / localhost (from host)"
    echo "  Port:     3306"
    echo "  Database: opensis"
    echo "  Username: opensis_user"
    echo "  Password: opensis_pass"
    echo "  Root Password: root_password"
    echo
    echo "Next Steps:"
    echo "1. Open http://localhost:8080 in your browser"
    echo "2. Follow the openSIS installation wizard"
    echo "3. Use the database information above when prompted"
    echo
}

# Function to show container status
show_status() {
    print_status "Container Status:"
    docker-compose ps
}

# Function to show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        print_status "Showing all container logs:"
        docker-compose logs
    else
        print_status "Showing logs for $service:"
        docker-compose logs "$service"
    fi
}

# Function to stop containers
stop_containers() {
    print_status "Stopping Docker containers..."
    docker-compose down
    print_success "Containers stopped"
}

# Function to restart containers
restart_containers() {
    print_status "Restarting Docker containers..."
    docker-compose restart
    print_success "Containers restarted"
}

# Function to clean up (remove containers and volumes)
cleanup() {
    print_warning "This will remove all containers and database data!"
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Cleaning up Docker containers and volumes..."
        docker-compose down -v
        docker system prune -f
        print_success "Cleanup completed"
    fi
}

# Main menu
show_menu() {
    echo
    echo "openSIS Classic Docker Management"
    echo "================================"
    echo "1. Start/Setup openSIS"
    echo "2. Stop containers"
    echo "3. Restart containers"
    echo "4. Show container status"
    echo "5. Show logs (all)"
    echo "6. Show web server logs"
    echo "7. Show database logs"
    echo "8. Cleanup (remove all)"
    echo "9. Exit"
    echo
}

# Main execution
main() {
    case "${1:-menu}" in
        "start"|"setup")
            check_docker
            check_docker_compose
            check_ports
            start_containers
            wait_for_database
            show_access_info
            ;;
        "stop")
            stop_containers
            ;;
        "restart")
            restart_containers
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs "${2:-}"
            ;;
        "cleanup")
            cleanup
            ;;
        "menu"|*)
            while true; do
                show_menu
                read -p "Select an option (1-9): " choice
                case $choice in
                    1) main "start" ;;
                    2) main "stop" ;;
                    3) main "restart" ;;
                    4) main "status" ;;
                    5) main "logs" ;;
                    6) main "logs" "opensis-web" ;;
                    7) main "logs" "opensis-db" ;;
                    8) main "cleanup" ;;
                    9) exit 0 ;;
                    *) print_error "Invalid option. Please select 1-9." ;;
                esac
                echo
                read -p "Press Enter to continue..."
            done
            ;;
    esac
}

# Run main function with all arguments
main "$@"
