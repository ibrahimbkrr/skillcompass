from pydantic import BaseModel
from typing import List, Optional

class Location(BaseModel):
    city: str
    country: str
    livingAreaType: str

class Education(BaseModel):
    highestDegree: str
    major: str
    currentlyStudent: bool
    strongSubjects: List[str]
    certificates: List[str]

class WorkExperience(BaseModel):
    currentlyWorking: bool
    yearsExperience: str
    sectorsWorked: List[str]
    positions: List[str]
    managerialExperience: bool
    freelanceExperience: bool

class Skills(BaseModel):
    technicalSkills: List[str]
    socialSkills: List[str]
    problemSolving: int
    englishLevel: str
    otherLanguages: List[str]

class InterestsAndGoals(BaseModel):
    interestedSectors: List[str]
    interestedRoles: List[str]
    careerGoal1Year: str
    careerGoal5Year: str
    entrepreneurshipInterest: bool
    startupCultureInterest: bool
    internationalCareerGoal: bool

class WorkingStyleAndMotivation(BaseModel):
    workPreference: str
    workingLocationPreference: str
    workingHoursPreference: str
    preferredCompanySize: str
    projectTypePreference: str
    mainMotivation: str

class SelfAssessment(BaseModel):
    strengths: List[str]
    weaknesses: List[str]
    lifeChallenges: str
    stressHandling: str
    learningDesire: int

class LearningPreferences(BaseModel):
    learningStyle: str
    onlineLearningFrequency: str
    mentorshipInterest: bool

class Consents(BaseModel):
    dataProcessingConsent: bool
    aiCareerAdviceConsent: bool

class UserData(BaseModel):
    fullName: str
    birthYear: int
    gender: Optional[str]
    location: Location
    education: Education
    workExperience: WorkExperience
    skills: Skills
    interestsAndGoals: InterestsAndGoals
    workingStyleAndMotivation: WorkingStyleAndMotivation
    selfAssessment: SelfAssessment
    learningPreferences: LearningPreferences
    consents: Consents
