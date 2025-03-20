#Minimum Viable product focus

#User Authentication
#Creating a User Model In models.py
#start
from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('doctor', 'Doctor'),
        ('patient', 'Patient'),
    ]
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='patient')
#end


#Setting Up Serializers for Registration and Login for serializers.py:
#start
from rest_framework import serializers
from .models import User
from rest_framework_simplejwt.tokens import RefreshToken

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'role', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        from django.contrib.auth import authenticate
        user = authenticate(**data)
        if user and user.is_active:
            refresh = RefreshToken.for_user(user)
            return {
                'refresh': str(refresh),
                'access': str(refresh.access_token),
            }
        raise serializers.ValidationError("Invalid credentials")
#end


#Create Views for Authentication In views.py:
#start
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import UserSerializer, LoginSerializer

class RegisterView(APIView):
    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
#end


#Adding Routes in urls.py
#start
from django.urls import path
from .views import RegisterView, LoginView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
]
#end




#Appointment Booking
#Create Appointment Model In models.py:
#start
class Appointment(models.Model):
    patient = models.ForeignKey(User, related_name='appointments', on_delete=models.CASCADE, limit_choices_to={'role': 'patient'})
    doctor = models.ForeignKey(User, related_name='doctor_appointments', on_delete=models.CASCADE, limit_choices_to={'role': 'doctor'})
    date = models.DateField()
    time = models.TimeField()
    status = models.CharField(max_length=10, default='Pending')  # Pending, Confirmed, Cancelled
#end

#Create Serializer In serializers.py:
#starts
class AppointmentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Appointment
        fields = '__all__'
#ends

#Create API Views In views.py:
#start
from .models import Appointment
from .serializers import AppointmentSerializer
from rest_framework.permissions import IsAuthenticated

class AppointmentView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        if request.user.role == 'doctor':
            appointments = Appointment.objects.filter(doctor=request.user)
        elif request.user.role == 'patient':
            appointments = Appointment.objects.filter(patient=request.user)
        else:  # Admin
            appointments = Appointment.objects.all()
        serializer = AppointmentSerializer(appointments, many=True)
        return Response(serializer.data)

    def post(self, request):
        serializer = AppointmentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
#ends

#Add Routes in urls.py
#start
urlpatterns += [
    path('appointments/', AppointmentView.as_view(), name='appointments'),
]
#end

#------------------------------------------------------------------------------------------#
# Setting Up the Appointment Booking Screen
#Backend Endpoint for Doctors
#In views.py:
#starts
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import User
from .serializers import UserSerializer

class DoctorListView(APIView):
    def get(self, request):
        doctors = User.objects.filter(role='doctor')
        serializer = UserSerializer(doctors, many=True)
        return Response(serializer.data)
#ends

#In urls.py:
#starts
urlpatterns += [
    path('doctors/', DoctorListView.as_view(), name='doctor-list'),
]
#ends

#----------------------------------------------------------------------------------------------#

# Real-Time Updates
#Update Settings In settings.py, add:
#starts
INSTALLED_APPS += ['channels']
ASGI_APPLICATION = 'your_project_name.asgi.application'

CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels.layers.InMemoryChannelLayer',
    },
}
#ends

#Create ASGI Configuration In asgi.py:
#starts
import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from hospital.routing import websocket_urlpatterns

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'your_project_name.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})
#ends

#Define WebSocket Routing In hospital/routing.py:
#starts
from django.urls import path
from .consumers import AppointmentConsumer

websocket_urlpatterns = [
    path('ws/appointments/', AppointmentConsumer.as_asgi()),
]
#ends


#Create a Consumer In hospital/consumers.py:
#starts
import json
from channels.generic.websocket import AsyncWebsocketConsumer

class AppointmentConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add('appointments', self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard('appointments', self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        await self.channel_layer.group_send(
            'appointments',
            {
                'type': 'appointment_update',
                'message': data['message'],
            }
        )

    async def appointment_update(self, event):
        message = event['message']
        await self.send(text_data=json.dumps({'message': message}))
#end

#Broadcast Updates Modify your appointment creation logic to broadcast updates via the channel_layer:
#starts
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer

channel_layer = get_channel_layer()

# When an appointment is booked
async_to_sync(channel_layer.group_send)(
    'appointments',
    {
        'type': 'appointment_update',
        'message': 'New appointment booked!',
    }
)
#ends

#Send Notifications via Backend Use Firebase Admin SDK in your Django backend to trigger notifications:
import firebase_admin
from firebase_admin import messaging, credentials

cred = credentials.Certificate('path/to/firebase/credentials.json')
firebase_admin.initialize_app(cred)

def send_notification(title, body, token):
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body,
        ),
        token=token,
    )
    response = messaging.send(message)
    print('Notification sent:', response)
