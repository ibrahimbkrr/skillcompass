from fastapi import FastAPI
from app.routes import router

app = FastAPI()

# routes.py'deki API endpointlerini uygulamaya dahil ediyoruz
app.include_router(router)
