# Profile API Setup Guide

This guide will help you set up the profile API backend for the Neighbor app.

## Prerequisites

- Node.js (v18 or higher)
- MySQL database
- Docker (optional, for MySQL)

## Setup Instructions

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Database Setup

#### Option A: Using Docker (Recommended)

```bash
# Start MySQL with Docker
cd ../mysql(docker)
docker-compose up -d
```

#### Option B: Local MySQL

1. Install MySQL locally
2. Create a database named `neighbor_app`
3. Update the `DATABASE_URL` in your `.env` file

### 3. Environment Configuration

Create a `.env` file in the backend directory:

```env
DATABASE_URL="mysql://username:password@localhost:3306/neighbor_app"
```

### 4. Database Migration

```bash
# Generate Prisma client
npm run prisma:generate

# Run database migrations
npm run prisma:migrate

# Seed the database with test data
npm run prisma:seed
```

### 5. Start the Development Server

```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## API Endpoints

### Profile API

- **GET** `/api/profile?userId={id}` - Get user profile
- **PUT** `/api/profile` - Update user profile

### Example Usage

#### Get Profile
```bash
curl "http://localhost:3000/api/profile?userId=1"
```

#### Update Profile
```bash
curl -X PUT "http://localhost:3000/api/profile" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "name": "John Doe",
    "nickname": "John",
    "gender": "Male",
    "address": "123 Main St",
    "avatarUrl": "https://example.com/avatar.jpg",
    "diseases": [
      {"text": "Diabetes", "icon": "health_and_safety"}
    ],
    "livingSituation": [
      {"text": "Living alone", "icon": "person"}
    ]
  }'
```

## Database Schema

The profile system uses the following main tables:

- `users` - User accounts
- `user_profiles` - Profile information
- `health_info` - Health conditions/diseases
- `emergency_contacts` - Emergency contact information
- `interests` - Available interests
- `user_interests` - User interest associations

## Troubleshooting

### Common Issues

1. **Database Connection Error**
   - Check your `DATABASE_URL` in `.env`
   - Ensure MySQL is running
   - Verify database exists

2. **Prisma Client Error**
   - Run `npm run prisma:generate`
   - Check if migrations are up to date

3. **Port Already in Use**
   - Change the port in `package.json` scripts
   - Kill existing processes on port 3000

### Reset Database

```bash
# Reset and reseed database
npm run prisma:migrate reset
npm run prisma:seed
```

## Next Steps

1. Update the Flutter app's `ProfileService` base URL to match your backend
2. Implement proper authentication and user ID management
3. Add image upload functionality for profile pictures
4. Add validation and error handling improvements
