from django.conf import settings
from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework import serializers, viewsets
from rest_framework.permissions import IsAuthenticated
from django.db import models
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.authentication import BaseAuthentication
import firebase_admin
from firebase_admin import auth, credentials

# Firebase initialization
cred = credentials.Certificate('path/to/firebase-credentials.json')
firebase_admin.initialize_app(cred)

# Custom Firebase Authentication
class FirebaseAuthentication(BaseAuthentication):
    def authenticate(self, request):
        id_token = request.headers.get('Authorization')
        if not id_token:
            return None
        try:
            decoded_token = auth.verify_id_token(id_token)
            uid = decoded_token['uid']
            user, created = settings.AUTH_USER_MODEL.objects.get_or_create(username=uid)
            return (user, None)
        except Exception as e:
            return None

# Models
class FitnessCenter(models.Model):
    name = models.CharField(max_length=255)
    location = models.CharField(max_length=255)
    amenities = models.TextField()
    price_per_hour = models.DecimalField(max_digits=10, decimal_places=2)
    rating = models.FloatField(default=0.0)

class Booking(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    fitness_center = models.ForeignKey(FitnessCenter, on_delete=models.CASCADE)
    date = models.DateField()
    time_slot = models.TimeField()
    created_at = models.DateTimeField(auto_now_add=True)

# Serializers
class FitnessCenterSerializer(serializers.ModelSerializer):
    class Meta:
        model = FitnessCenter
        fields = '__all__'

class BookingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Booking
        fields = '__all__'

# ViewSets
class FitnessCenterViewSet(viewsets.ModelViewSet):
    queryset = FitnessCenter.objects.all()
    serializer_class = FitnessCenterSerializer
    permission_classes = [IsAuthenticated]
    authentication_classes = [FirebaseAuthentication]

class BookingViewSet(viewsets.ModelViewSet):
    queryset = Booking.objects.all()
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]
    authentication_classes = [FirebaseAuthentication]

    def get_queryset(self):
        return self.queryset.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

# Router
router = DefaultRouter()
router.register(r'fitness-centers', FitnessCenterViewSet, basename='fitness-center')
router.register(r'bookings', BookingViewSet, basename='booking')

# Firebase Token Verification API
class FirebaseTokenVerifyView(APIView):
    def post(self, request):
        id_token = request.data.get('id_token')
        if not id_token:
            return Response({"error": "No token provided"}, status=400)
        try:
            decoded_token = auth.verify_id_token(id_token)
            uid = decoded_token['uid']
            return Response({"uid": uid}, status=200)
        except Exception as e:
            return Response({"error": str(e)}, status=400)

# URLs
urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('api-auth/', include('rest_framework.urls')),  # For login/logout
    path('api/verify-token/', FirebaseTokenVerifyView.as_view(), name='verify-token'),
]
