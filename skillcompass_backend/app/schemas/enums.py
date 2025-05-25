"""
SkillCompass Enum tanımları
"""
from enum import Enum

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