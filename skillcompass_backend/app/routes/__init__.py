from fastapi import APIRouter
from .user import router as user_router
from .profile import router as profile_router
from .analysis import router as analysis_router

router = APIRouter()
router.include_router(user_router)
router.include_router(profile_router)
router.include_router(analysis_router) 