"""
SkillCompass ortak küçük modeller
"""
from pydantic import BaseModel, Field
from typing import List

class Location(BaseModel):
    city: str = Field(..., alias="city")
    country: str = Field(..., alias="country")
    livingAreaType: str = Field(..., alias="livingAreaType")

class Education(BaseModel):
    highestDegree: str = Field(..., alias="highestDegree")
    major: str = Field(..., alias="major")
    currentlyStudent: bool = Field(..., alias="currentlyStudent")
    strongSubjects: List[str] = Field(..., alias="strongSubjects")
    certificates: List[str] = Field(default_factory=list, alias="certificates") 