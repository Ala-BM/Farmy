# Farmy

A Flutter mobile app connecting farmers with buyers for direct crop sales.

---

## Overview

Farmy enables farmers to list their crops and communicate directly with buyers through an integrated messaging system. The app includes location-based discovery and real-time weather information.

---

## Technical Stack

- **Flutter** - Cross-platform mobile framework
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **BLoC Pattern** - State management
- **Geolocator** - Location services
- **Weather API** - Weather integration

---

## Features

### For Farmers
- Create and manage crop listings
- Chat with potential buyers
- View location-based weather updates
- Track crop inventory

### For Buyers
- Browse available crops
- Search by location and crop type //Not Fully implemented yet
- Direct messaging with farmers
- View farmer locations

### Core Functionality
- **Real-time chat system** between farmers and buyers
- **Location services** for proximity-based crop discovery
- **Weather integration** with animated displays
- **Role-based authentication** (Farmer/Buyer accounts)

---

## Architecture

### State Management
- **ChatBloc** - Handles messaging functionality
- **CropBloc** - Manages crop data operations
- Clean separation of business logic from UI

### Backend
- Firebase Authentication for user accounts
- Firestore for real-time data storage
- Push notifications for chat messages

---

## Developer

**Ala Ben Mohamed**  
alabenmed190@gmail.com

---

## License

MIT
