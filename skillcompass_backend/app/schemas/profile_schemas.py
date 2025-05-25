"""
SkillCompass profil kartı modelleri
"""
from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class WorkExperience(BaseModel):
    currentlyWorking: bool = Field(False, alias="currentlyWorking")
    yearsExperience: str = Field("", alias="yearsExperience")
    sectorsWorked: List[str] = Field(default_factory=list, alias="sectorsWorked")
    positions: List[str] = Field(default_factory=list, alias="positions")
    managerialExperience: bool = Field(False, alias="managerialExperience")
    freelanceExperience: bool = Field(False, alias="freelanceExperience")

class Skills(BaseModel):
    technicalSkills: List[str] = Field(default_factory=list, alias="technicalSkills")
    socialSkills: List[str] = Field(default_factory=list, alias="socialSkills")
    problemSolving: int = Field(0, alias="problemSolving")
    englishLevel: str = Field("", alias="englishLevel")
    otherLanguages: List[str] = Field(default_factory=list, alias="otherLanguages")
    highlightedSkill: Optional[str] = Field(None, alias="highlightedSkill")

class InterestsAndGoals(BaseModel):
    interestedSectors: List[str] = Field(default_factory=list, alias="interestedSectors")
    interestedRoles: List[str] = Field(default_factory=list, alias="interestedRoles")
    careerGoal1Year: str = Field("", alias="careerGoal1Year")
    careerGoal5Year: str = Field("", alias="careerGoal5Year")
    entrepreneurshipInterest: bool = Field(False, alias="entrepreneurshipInterest")
    startupCultureInterest: bool = Field(False, alias="startupCultureInterest")
    internationalCareerGoal: bool = Field(False, alias="internationalCareerGoal")
    desiredImpactArea: Optional[str] = Field(None, alias="desiredImpactArea")
    careerGoalsClarity: Optional[int] = Field(None, alias="careerGoalsClarity")
    careerPriorities: Optional[List[str]] = Field(None, alias="careerPriorities")
    customCareerPriority: Optional[str] = Field(None, alias="customCareerPriority")
    careerProgress: Optional[int] = Field(None, alias="careerProgress")

class WorkingStyleAndMotivation(BaseModel):
    workPreference: str = Field("", alias="workPreference")
    workingLocationPreference: str = Field("", alias="workingLocationPreference")
    workingHoursPreference: str = Field("", alias="workingHoursPreference")
    preferredCompanySize: str = Field("", alias="preferredCompanySize")
    projectTypePreference: str = Field("", alias="projectTypePreference")
    mainMotivation: List[str] = Field(default_factory=list, alias="mainMotivation")
    customMotivation: Optional[str] = Field(None, alias="customMotivation")

class SelfAssessment(BaseModel):
    strengths: List[str] = Field(default_factory=list, alias="strengths")
    weaknesses: List[str] = Field(default_factory=list, alias="weaknesses")
    lifeChallenges: str = Field("", alias="lifeChallenges")
    stressHandling: str = Field("", alias="stressHandling")
    learningDesire: int = Field(0, alias="learningDesire")
    identityStory: Optional[str] = Field(None, alias="identityStory")
    technicalConfidence: Optional[int] = Field(None, alias="technicalConfidence")

class LearningPreferences(BaseModel):
    learningStyle: List[str] = Field(default_factory=list, alias="learningStyle")
    customLearningStyle: Optional[str] = Field(None, alias="customLearningStyle")
    onlineLearningFrequency: str = Field("", alias="onlineLearningFrequency")
    mentorshipInterest: bool = Field(False, alias="mentorshipInterest")
    learningResources: List[str] = Field(default_factory=list, alias="learningResources")
    customLearningResource: Optional[str] = Field(None, alias="customLearningResource")
    learningMotivation: Optional[str] = Field(None, alias="learningMotivation")
    learningBarriers: Optional[str] = Field(None, alias="learningBarriers")

class Consents(BaseModel):
    dataProcessingConsent: bool = Field(False, alias="dataProcessingConsent")
    aiCareerAdviceConsent: bool = Field(False, alias="aiCareerAdviceConsent")

class IdentityStatus(BaseModel):
    developmentAreas: List[str] = []
    goal1Year: str = ""
    goal5YearsLevel: int = 0
    identity: str = ""
    otherArea: str = ""

class TechnicalProfile(BaseModel):
    skills: List[str] = []
    highlightSkill: str = ""
    learningApproach: str = ""
    confidence: int = 0

class LearningStyle(BaseModel):
    preference: str = ""
    customPreference: str = ""
    resources: List[str] = []
    customResource: str = ""
    motivation: str = ""
    barriers: str = ""

class CareerVision(BaseModel):
    shortTermGoal: str = ""
    longTermGoal: str = ""
    priorities: List[str] = []
    customPriority: str = ""
    progress: int = 0

class Networking(BaseModel):
    mentorship_need: str = ""
    current_connections: List[str] = []
    networking_goal: str = ""
    networking_challenges: str = ""

class PersonalBrand(BaseModel):
    current_profiles: List[str] = []
    brand_goal: str = ""
    content_types: List[str] = []
    brand_challenges: str = ""
    lastUpdated: str = ""

class ProjectExperience(BaseModel):
    past_projects: str = ""
    technologies: List[str] = []
    future_project: str = ""
    challenges: str = "" 