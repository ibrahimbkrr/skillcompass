"""
SkillCompass kullanıcı ana modelleri
"""
from pydantic import BaseModel, Field
from typing import Optional
from skillcompass_backend.app.schemas.common import Location, Education
from skillcompass_backend.app.schemas.profile_schemas import (
    WorkExperience, Skills, InterestsAndGoals, WorkingStyleAndMotivation, SelfAssessment, LearningPreferences, Consents
)

class UserData(BaseModel):
    firstName: str = Field(..., alias="firstName")
    lastName: str = Field(..., alias="lastName")
    email: str = Field(..., alias="email")
    uid: str = Field(..., alias="uid")
    birthYear: int = Field(..., alias="birthYear")
    gender: Optional[str] = Field(None, alias="gender")
    location: Location = Field(..., alias="location")
    education: Education = Field(..., alias="education")
    workExperience: WorkExperience = Field(..., alias="workExperience")
    skills: Skills = Field(..., alias="skills")
    interestsAndGoals: InterestsAndGoals = Field(..., alias="interestsAndGoals")
    workingStyleAndMotivation: WorkingStyleAndMotivation = Field(..., alias="workingStyleAndMotivation")
    selfAssessment: SelfAssessment = Field(..., alias="selfAssessment")
    learningPreferences: LearningPreferences = Field(..., alias="learningPreferences")
    consents: Consents = Field(..., alias="consents")
    createdAt: Optional[str] = Field(None, alias="createdAt") 