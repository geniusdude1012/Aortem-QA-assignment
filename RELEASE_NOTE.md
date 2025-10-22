# Release Notes - Version 0.0.12

## Overview

This release introduces a complete authentication system with user registration, login, and protected API endpoints. The application is now fully containerized and includes comprehensive testing infrastructure.

## New Features

### Authentication System

- **User Registration**: Create new accounts with email and password
- **Secure Login**: Authenticate with registered credentials
- **Token-based Authorization**: JWT-style tokens for API protection
- **Welcome Dashboard**: View user information and authentication tokens

### Developer Experience

- **Local Development**: Firebase Auth Emulator for safe testing
- **Containerized Deployment**: Docker and docker-compose setup
- **Health Monitoring**: Built-in health check endpoints
- **CORS Support**: Proper cross-origin request handling

## Security Improvements

- Password security with no sensitive data in logs
- Token validation for protected endpoints
- Environment-based configuration
- Multi-stage Docker builds for minimized attack surface

## Getting Started

### Quick Start

```bash
# Clone and run
docker compose up --build

# Access applications
# Frontend: http://localhost:8080
# Backend API: http://localhost:8081
```
