# ICPC Backend

Next.js 15 + Prisma + MySQL backend for the ICPC Flutter application.

## Setup

1. Create environment file and configure database:
   ```bash
   cp env.example .env
   ```
   The `.env` file is already configured with your MySQL Docker settings. No changes needed unless you want to modify the database connection.

2. Install dependencies:
   ```bash
   npm install
   ```

3. Generate Prisma client:
   ```bash
   npm run prisma:generate
   ```

4. Run database migrations:
   ```bash
   npm run prisma:migrate
   ```

5. Start development server:
   ```bash
   npm run dev
   ```

## Health Check

Test the API health endpoint:
```bash
GET http://localhost:3000/api/health
```

Expected response:
```json
{
  "ok": true,
  "time": "2024-01-01T00:00:00.000Z"
}
```

## Database Schema

The database includes the following main models:
- **User**: Core user authentication and profile data
- **UserProfile**: Extended user profile information
- **HealthInfo**: User health conditions
- **EmergencyContact**: Emergency contact information
- **Interest**: Available interests/topics
- **UserInterest**: Many-to-many relationship between users and interests
- **VolunteerAvailability**: Volunteer scheduling information
- **LoginHistory**: User login tracking

## Flutter Integration

- Base URL: `http://localhost:3000` (or your server URL)
- All endpoints return JSON with CORS enabled
- Future API endpoints will follow REST conventions

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run start` - Start production server
- `npm run prisma:generate` - Generate Prisma client
- `npm run prisma:migrate` - Run database migrations