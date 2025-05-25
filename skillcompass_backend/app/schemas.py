from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum
from datetime import date

class EnglishLevel(str, Enum):
    beginner = "Beginner"
    intermediate = "Intermediate"
    advanced = "Advanced"
    fluent = "Fluent"

class WorkingHoursPreference(str, Enum):
    flexible = "Flexible"
    regular = "Regular"
    part_time = "Part-time"
    remote = "Remote"

class Location(BaseModel):
    city: str = Field(..., example="İstanbul")
    country: str = Field(..., example="Turkey")
    livingAreaType: str = Field(..., example="Urban")

class Education(BaseModel):
    highestDegree: str = Field(..., example="Bachelor's Degree")
    major: str = Field(..., example="Computer Engineering")
    currentlyStudent: bool = Field(..., example=False)
    strongSubjects: List[str] = Field(..., example=["Algorithms", "Databases"])
    certificates: List[str] = Field(default_factory=list, example=["AWS Certified Developer"])

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
    highlightedSkill: Optional[str]

class InterestsAndGoals(BaseModel):
    interestedSectors: List[str]
    interestedRoles: List[str]
    careerGoal1Year: str
    careerGoal5Year: str
    entrepreneurshipInterest: bool
    startupCultureInterest: bool
    internationalCareerGoal: bool
    desiredImpactArea: Optional[str]
    careerGoalsClarity: Optional[int]
    careerPriorities: Optional[List[str]]
    customCareerPriority: Optional[str]
    careerProgress: Optional[int]

class WorkingStyleAndMotivation(BaseModel):
    workPreference: str
    workingLocationPreference: str
    workingHoursPreference: str
    preferredCompanySize: str
    projectTypePreference: str
    mainMotivation: List[str]
    customMotivation: Optional[str]

class SelfAssessment(BaseModel):
    strengths: List[str]
    weaknesses: List[str]
    lifeChallenges: str
    stressHandling: str
    learningDesire: int
    identityStory: Optional[str]
    technicalConfidence: Optional[int]

class LearningPreferences(BaseModel):
    learningStyle: List[str]
    customLearningStyle: Optional[str]
    onlineLearningFrequency: str
    mentorshipInterest: bool
    learningResources: List[str]
    customLearningResource: Optional[str]
    learningMotivation: Optional[str]
    learningBarriers: Optional[str]

class Consents(BaseModel):
    dataProcessingConsent: bool
    aiCareerAdviceConsent: bool

class UserData(BaseModel):
    firstName: str
    lastName: str
    email: str
    uid: str
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
    createdAt: Optional[str]

    class Config:
        schema_extra = {
            "example": {
                "fullName": "Ahmet Yılmaz",
                "birthYear": "1995-05-20",
                "gender": "Male",
                "location": {
                    "city": "İstanbul",
                    "country": "Turkey",
                    "livingAreaType": "Urban"
                },
                "education": {
                    "highestDegree": "Bachelor's Degree",
                    "major": "Computer Engineering",
                    "currentlyStudent": False,
                    "strongSubjects": ["Algorithms", "Databases"],
                    "certificates": ["AWS Certified Developer"]
                },
                "workExperience": {
                    "currentlyWorking": True,
                    "yearsExperience": "3-5 years",
                    "sectorsWorked": ["IT", "Finance"],
                    "positions": ["Developer", "Team Lead"],
                    "managerialExperience": True,
                    "freelanceExperience": False
                },
                "skills": {
                    "technicalSkills": ["Python", "React"],
                    "socialSkills": ["Teamwork", "Leadership"],
                    "problemSolving": 8,
                    "englishLevel": "Fluent",
                    "otherLanguages": ["Spanish", "German"],
                    "highlightedSkill": "Python"
                },
                "interestsAndGoals": {
                    "interestedSectors": ["Technology", "AI"],
                    "interestedRoles": ["Software Engineer", "Data Scientist"],
                    "careerGoal1Year": "Complete senior developer promotion",
                    "careerGoal5Year": "Lead a technical team",
                    "entrepreneurshipInterest": True,
                    "startupCultureInterest": True,
                    "internationalCareerGoal": False
                },
                "workingStyleAndMotivation": {
                    "workPreference": "Remote",
                    "workingLocationPreference": "Hybrid",
                    "workingHoursPreference": "Flexible",
                    "preferredCompanySize": "Medium",
                    "projectTypePreference": "Long-term",
                    "mainMotivation": ["Continuous Learning"]
                },
                "selfAssessment": {
                    "strengths": ["Analytical Thinking", "Adaptability"],
                    "weaknesses": ["Time Management", "Public Speaking"],
                    "lifeChallenges": "Balancing work-life responsibilities",
                    "stressHandling": "Moderate stress resilience",
                    "learningDesire": 9,
                    "technicalConfidence": 8
                },
                "learningPreferences": {
                    "learningStyle": ["Visual", "Practical"],
                    "customLearningStyle": "Mixed",
                    "onlineLearningFrequency": "Weekly",
                    "mentorshipInterest": True,
                    "learningResources": ["Books", "Online Courses"],
                    "customLearningResource": "YouTube Videos",
                    "learningMotivation": "Curiosity",
                    "learningBarriers": "Time Management"
                },
                "consents": {
                    "dataProcessingConsent": True,
                    "aiCareerAdviceConsent": True
                }
            }
        }
