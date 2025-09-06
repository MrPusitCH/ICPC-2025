<div align="center">

  <!-- Minecraft-styled animated banner -->
  <img src="https://capsule-render.vercel.app/api?type=waving&color=0:2ecc71,50:27ae60,100:145A32&height=220&section=header&text=ICPC%202025%20%E2%80%93%20Neighbor%20App&fontSize=36&fontColor=ffffff&animation=twinkling" alt="ICPC 2025 Minecraft Banner" width="100%" />

  <!-- Typing animation (Minecraft vibe) -->
  <img src="https://readme-typing-svg.demolab.com?font=Minecraft&size=26&duration=2800&pause=900&color=34D399&center=true&vCenter=true&width=800&lines=Full-stack+Neighbor+App+%26+Backend;Next.js+15+%7C+Flutter+%7C+Prisma+%7C+MySQL;Crafted+with+%E2%9D%A4%EF%B8%8F+and+Blocks" alt="Typing Animation" />

  <p>
    <a href="#features"><img alt="Features" src="https://img.shields.io/badge/Features-Next.js%2015%20%7C%20Flutter%20%7C%20Prisma%20%7C%20Docker-1E88E5?style=for-the-badge"/></a>
    <a href="#quickstart"><img alt="Quickstart" src="https://img.shields.io/badge/Quickstart-1%20Command-43A047?style=for-the-badge"/></a>
    <a href="#scripts"><img alt="Scripts" src="https://img.shields.io/badge/Scripts-yarn%20%7C%20npm%20%7C%20flutter-F57C00?style=for-the-badge"/></a>
  </p>

  <p><em>Build, run, and contribute to a full-stack app for volunteering & neighbors helping neighbors.</em> 🧱🟩</p>

  <!-- Grass block divider -->
  <img src="https://capsule-render.vercel.app/api?type=rect&color=145A32&height=10&section=footer&reversal=true" width="100%" alt="divider"/>
</div>

---

## ✨ Features

- **Backend**: Next.js 15 (App Router), TypeScript, Prisma, MySQL
- **Frontend (Mobile)**: Flutter app (`neighbor_app`)
- **Auth**: Login/Register routes, JWT (extensible)
- **Posts**: Volunteer posts (create, list, get by id, delete)
- **Dev Tools**: Docker (MySQL), Prisma Migrate/Studio, seeds

## 🚀 Quickstart

### 1) Backend

```bash
cd backend
# copy env if needed
cp .env.example .env

# install deps & run
npm install
npm run dev

# prisma
npx prisma generate
npx prisma migrate dev
npx prisma db seed
```

API base: `http://localhost:3000/api`

Key routes:
- GET `/api/post_volunteer/get_post_all`
- GET `/api/post_volunteer/get_post_byid/id/[id]`
- POST `/api/post_volunteer/post`
- DELETE `/api/post_volunteer/delete_post/[id]`

### 2) Flutter app

```bash
cd frontend/neighbor_app
flutter pub get
flutter run --debug
```

The app points to `http://localhost:3000/api` by default (configure in `lib/services/posts_api_service.dart`).

## 🧪 Mock data via curl

```bash
curl -X POST "http://localhost:3000/api/post_volunteer/post" \
  -H "Content-Type: application/json" \
  -d '{
    "title":"Help with groceries",
    "description":"Need help carrying groceries",
    "dateTime":"2024-01-20T10:00:00Z",
    "reward":"$10",
    "userId":1
  }'
```

## 📱 App Structure

```
frontend/neighbor_app
  ├─ lib/
  │  ├─ screens/volunteer/
  │  │  ├─ volunteer_list_screen.dart
  │  │  └─ volunteer_detail_screen.dart
  │  ├─ services/
  │  │  └─ posts_api_service.dart
  │  └─ models/
  │     └─ volunteer_item.dart
backend
  └─ src/app/api/post_volunteer/*
```

## 🛠 Scripts

Backend:
```bash
npm run dev       # start next dev server
npm run build     # build
```

Flutter:
```bash
flutter run --debug
flutter build apk
```

## 🤝 Contributing

1. Fork & create a feature branch
2. Commit with clear messages
3. Open a PR describing the change

## 📄 License

MIT

<div align="center">
  <sub>Made with ❤️ for ICPC 2025</sub>
</div>


