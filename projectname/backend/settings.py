INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',  # Если используется django-cors-headers
]

# Firebase Credentials
import os
from decouple import config

FIREBASE_CREDENTIALS = config('FIREBASE_CREDENTIALS', default='path/to/firebase-credentials.json')

# CORS Settings
CORS_ALLOWED_ORIGINS = [
    'http://localhost:3000',  # нету его
    'http://127.0.0.1:3000',
]
