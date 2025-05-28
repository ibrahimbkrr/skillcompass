from fastapi import Request, HTTPException
from fastapi.responses import JSONResponse
from fastapi.exception_handlers import http_exception_handler

async def custom_http_exception_handler(request: Request, exc: HTTPException):
    return await http_exception_handler(request, exc)

async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": f"Beklenmeyen bir hata oluştu: {str(exc)}"},
        headers={"Content-Type": "application/json; charset=utf-8"}
    ) 