# Handyman SaaS Platform - MVP Requirements (Phase 1)

## User Roles

### 1. Super Admin

* Login
* Dashboard
* Create Company
* Edit Company
* Activate/Deactivate Company
* View Companies
* View Platform Statistics

---

## 2. Company Admin

### Authentication

* Login
* Forgot Password

### Company Management

* Manage Company Profile
* Upload Company Logo

### Category Management

* Add Category
* Edit Category
* Delete Category

### Service Management

* Add Service
* Edit Service
* Delete Service

### Handyman Management

* Add Handyman
* Approve/Reject Handyman Registration
* Verify ID Card / License
* Edit Handyman
* Suspend Handyman
* Delete Handyman

### Customer Management

* View Customers
* View Customer Details

### Booking Management

* View Bookings
* Assign Handyman
* Reassign Handyman
* Update Booking Status
* Cancel Booking

### Chat Management

* View Customer ↔ Handyman Chats
* Resolve Chat Complaints (Optional)

---

## 3. Handyman

### Authentication

* Register
* Login
* Forgot Password

### Verification

* Upload Profile Picture
* Upload ID Card
* Upload License (if required)
* Wait for Approval

### Profile

* Edit Profile
* Skills
* Experience

### Bookings

* View Assigned Bookings
* Accept Booking
* Reject Booking
* Start Job
* Complete Job
* View Booking History

### Chat

* Chat with Customer
* Send Images
* View Chat History

---

## 4. Customer

### Authentication

* Register
* Login
* Forgot Password

### Services

* Browse Categories
* Search Services
* View Service Details

### Booking

* Book Service
* Select Date & Time
* Add Address
* Add Notes
* Cancel Booking
* View Booking History

### Chat

* Chat with Assigned Handyman
* Send Images
* View Chat History

### Reviews

* Rate Handyman
* Write Review

### Profile

* Edit Profile

---

# Core Modules

## Authentication

* Login
* Register
* Forgot Password

## Company

* Company Profile

## Categories

* CRUD Categories

## Services

* CRUD Services

## Handyman Verification

* ID Verification
* License Verification
* Approval Workflow

## Booking

* Create Booking
* Assign Booking
* Booking Status
* Booking History

## Chat

* One-to-One Chat
* Image Sharing
* Message Read Status
* Chat History

## Reviews

* Ratings
* Comments

## Profiles

* Customer Profile
* Handyman Profile
* Company Profile

---

# Booking Workflow

Customer Books Service
↓
Company Admin Receives Booking
↓
Company Admin Assigns Handyman
↓
Customer & Handyman Can Chat
↓
Handyman Accepts Booking
↓
Handyman Starts Job
↓
Handyman Completes Job
↓
Customer Rates & Reviews

---

# Features Excluded from MVP (Phase 2)

* Online Payments
* Wallet
* Commission System
* Subscription Plans
* Live Location Tracking
* Push Notifications
* Coupons
* Multi-Branch Support
* Analytics & Reports
* Staff Roles (Dispatcher, Accountant, etc.)
* White Label Mobile Apps
* Multi-Language
* Video Calling
* Voice Calling
* Group Chats



Tech Stack
Mobile Apps
Flutter
Customer App
Service Provider App
Web Panels
Next.js
Super Admin Panel
Company Admin Panel
Backend (Recommended)

I recommend Supabase.

Why?

PostgreSQL (production-grade relational database)
Authentication
Realtime (perfect for chat)
Storage (profile images, CNIC, licenses, service photos)
Row Level Security (great for multi-tenant SaaS)
Edge Functions (server-side business logic)
Scheduled Jobs (cron)
Database Functions
Easy integration with AI later

You already mentioned in a previous conversation that you prefer Supabase, and I think it fits this project well.

Use Firebase Only For
Firebase Cloud Messaging (Push Notifications)
Firebase Crashlytics (Crash Reporting)

Don't use Firestore as your primary database.

Backend Architecture
Flutter Apps
        │
        │
Next.js Admin Panels
        │
        │
 REST API / Edge Functions
        │
        ▼
Supabase
├── PostgreSQL
├── Auth
├── Storage
├── Realtime
├── Edge Functions
└── Row Level Security
Why Not Firebase?

Firebase is excellent for simple apps, but for a SaaS marketplace:

Complex relationships (Companies → Customers → Providers → Bookings → Chats → Reviews)
Advanced filtering
Reporting
Analytics
Multi-tenant data isolation

These are much easier with PostgreSQL than with Firestore.

AI Ready Architecture

In the future, you can add:

Flutter / Next.js
        │
        ▼
Supabase
        │
        ▼
AI Service
(OpenAI, Anthropic, Gemini, etc.)

Possible AI features:

AI customer support chatbot
AI booking assistant
AI quote generation
AI service description writer
AI review summarizer
AI fraud detection
AI ticket classification
AI multilingual translation
AI voice assistant

No major architecture changes would be required.

Recommended Backend Structure
backend/
│
├── auth/
├── companies/
├── users/
├── providers/
├── categories/
├── services/
├── bookings/
├── chat/
├── reviews/
├── notifications/
├── storage/
├── ai/          (Future)
├── admin/
└── shared/
Database

Use PostgreSQL.

Example tables:

companies
users
company_users
providers
customers
categories
services
bookings
booking_status_history
chat_rooms
messages
reviews
documents
notifications
Storage

Use Supabase Storage for:

Company logos
Provider profile pictures
Customer profile pictures
CNIC/ID cards
Licenses
Service images
Chat attachments
Authentication

Use Supabase Auth.

Roles:

Super Admin
Company Admin
Provider
Customer
Realtime

Use Supabase Realtime for:

Chat
Booking status updates
New booking notifications
Typing indicators (optional later)
Read receipts
Deployment

Frontend

Flutter Android
Flutter iOS
Next.js on Vercel

Backend

Supabase Cloud
Final Recommended Stack
Layer	Technology
Customer App	Flutter
Provider App	Flutter
Super Admin Panel	Next.js
Company Admin Panel	Next.js
Backend	Supabase (PostgreSQL + Auth + Storage + Realtime + Edge Functions)
Push Notifications	Firebase Cloud Messaging
Crash Reporting	Firebase Crashlytics
Maps	Google Maps
File Storage	Supabase Storage
Realtime Chat	Supabase Realtime
AI (Future)	OpenAI/Gemini/Anthropic via Edge Functions
Deployment	Vercel (Next.js) + Supabase

I would also make one architectural change before you write any code: keep all business logic in the backend (Edge Functions or API layer), not in Flutter or Next.js. The mobile apps and web panels should primarily handle UI and API calls. That makes it much easier to add more clients, expose public APIs, or integrate AI later without rewriting your applications.