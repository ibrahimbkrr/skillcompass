import os
from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, Request, HTTPException
from skillcompass_backend.app.routes import router
from skillcompass_backend.app.utils.exceptions import (
    custom_http_exception_handler,
    global_exception_handler
)
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.middleware import SlowAPIMiddleware
from slowapi.errors import RateLimitExceeded
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import logging
import time

# Rate limiter kurulumu
limiter = Limiter(key_func=get_remote_address)

app = FastAPI()

# Rate limiter middleware'i
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)

# Güvenli CORS ayarları
allowed_origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Logging yapılandırması
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    logger.info(f"Başlayan İstek: {request.method} {request.url}")
    response = await call_next(request)
    process_time = (time.time() - start_time) * 1000
    logger.info(
        f"Biten İstek: {request.method} {request.url} "
        f"Durum Kodu: {response.status_code} "
        f"Süre: {process_time:.2f} ms"
    )
    return response

# Exception handlerlar
app.add_exception_handler(HTTPException, custom_http_exception_handler)
app.add_exception_handler(Exception, global_exception_handler)

@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded):
    logger.warning(f"Rate limit aşıldı: {request.client.host}")
    return JSONResponse(
        status_code=429,
        content={"detail": "Çok fazla istek yaptınız. Lütfen daha sonra tekrar deneyin."},
        headers={"Content-Type": "application/json; charset=utf-8"}
    )

# Sadece tek bir ana router ekle
app.include_router(router)
