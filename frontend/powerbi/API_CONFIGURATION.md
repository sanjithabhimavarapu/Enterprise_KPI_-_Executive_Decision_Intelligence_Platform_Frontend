# Enterprise KPI - Executive Decision Intelligence Platform
# Frontend (Power BI) Configuration Reference
# This file documents the expected API name and configuration for frontend-backend integration

# ===== API IDENTIFICATION =====
# IMPORTANT: The frontend must recognize the backend using this exact name
# This name is returned by both GET / and GET /api/health endpoints

API_NAME=Enterprise_KPI_Executive_Decision_Intelligence_Platform_API
API_VERSION=1.0.0
API_SERVICE=Backend API Server

# ===== FRONTEND TO BACKEND CONNECTION =====
# Power BI Desktop and other frontends should connect using these parameters:

BACKEND_URL=http://localhost:5000
BACKEND_PORT=5000
BACKEND_HOST=localhost

# ===== DATABASE CONNECTION (From Frontend) =====
# Power BI should use these credentials when connecting to SQL Server:

DATABASE_SERVER=localhost
DATABASE_PORT=1433
DATABASE_NAME=KPI_DataWarehouse
DATABASE_USER=sa
# PASSWORD: Store securely in Power BI Service - do not commit to repo

# ===== AVAILABLE ENDPOINTS =====
# The backend exposes the following endpoints that frontend can use:

ENDPOINT_HEALTH=/api/health
ENDPOINT_DB_STATUS=/api/db-status
ENDPOINT_TABLES=/api/tables
ENDPOINT_ETL_TRIGGER=/api/trigger-etl (POST)
ENDPOINT_ETL_STATUS=/api/etl-status
ENDPOINT_QUERY=/api/query (POST)
ENDPOINT_ROOT=/

# ===== POWER BI CONNECTION CONFIGURATION =====
# In Power BI Desktop, use these settings:

POWERBI_CONNECTION_MODE=Import
POWERBI_ENCRYPTION=Enabled
POWERBI_TIMEOUT_SECONDS=300
POWERBI_REFRESH_FREQUENCY=Daily

# ===== EXPECTED BACKEND RESPONSE FORMAT =====
# When frontend calls GET http://localhost:5000, it should receive:
# {
#   "name": "Enterprise_KPI_Executive_Decision_Intelligence_Platform_API",
#   "version": "1.0.0",
#   "status": "running",
#   "service": "Backend API Server",
#   "database": "KPI_DataWarehouse",
#   "endpoints": { ... },
#   "documentation": "See README.md"
# }

# ===== NOTES =====
# - Both frontend and backend use the same service name identifier
# - Frontend queries the /api/health endpoint to verify backend availability
# - Database connection is direct from frontend to SQL Server (not through API)
# - API is used for ETL triggering, queries, and status monitoring
