# 📱 คู่มือง่าย Flutter App

## 🎯 สร้างหน้าจอใหม่

### 1. สร้างไฟล์
**ไปที่โฟลเดอร์:** `neighbor_app/lib/screens/`
- สร้างโฟลเดอร์ใหม่ (เช่น `product/`)
- สร้างไฟล์ `.dart` ใหม่ (เช่น `product_screen.dart`)

### 2. เพิ่ม Route
**ไปที่ไฟล์:** `neighbor_app/lib/router/app_router.dart`
- เพิ่ม route constant
- เพิ่ม import
- เพิ่มใน routes map

### 3. เพิ่มใน MainAppScreen (ถ้าเป็นหน้าหลัก)
**ไปที่ไฟล์:** `neighbor_app/lib/screens/main_app_screen.dart`
- เพิ่ม import หน้าจอใหม่
- เพิ่มใน `_screens` list
- เพิ่ม Tab ใน `BottomNavigationBar`

### 4. ไปหน้าจอใหม่
**ใช้:** `AppRouter.pushNamed(context, AppRouter.ชื่อRoute)`

---

## 🎨 สร้าง Widget ใหม่

**ไปที่โฟลเดอร์:** `neighbor_app/lib/widgets/`
- สร้างไฟล์ `.dart` ใหม่

---

## 📊 สร้าง Model ใหม่

**ไปที่โฟลเดอร์:** `neighbor_app/lib/models/`
- สร้างไฟล์ `.dart` ใหม่

---

## 🔌 เพิ่ม API Service

**ไปที่ไฟล์:** `neighbor_app/lib/services/api_service.dart`
- เพิ่มเมธอดใน READ OPERATIONS
- เพิ่มเมธอดใน WRITE OPERATIONS

**ไปที่ไฟล์:** `neighbor_app/lib/services/mock_data_service.dart`
- เพิ่ม mock data

---

## 🎨 ใช้ Theme และสี

**ไปที่ไฟล์:** `neighbor_app/lib/theme/app_theme.dart`
- ดูสีและ TextStyle ที่มีอยู่

---

## 🧭 การนำทาง

**ใช้:** `AppRouter.pushNamed()` - ไปหน้าจอใหม่
**ใช้:** `AppRouter.pop()` - กลับหน้าจอเดิม

---

## 🔧 แก้ไขปัญหา

**ใช้:** `flutter analyze` - ตรวจสอบ errors

---

## 📝 สรุปโฟลเดอร์ที่ต้องไป

1. **หน้าจอ** → `neighbor_app/lib/screens/`
   - **auth/** - หน้าล็อกอิน/สมัครสมาชิก
   - **volunteer/** - หน้าอาสาสมัคร
   - **activity/** - หน้ากิจกรรมชุมชน
   - **community/** - หน้าชุมชน/โพสต์
   - **news/** - หน้าข่าวสาร
   - **profile/** - หน้าโปรไฟล์ผู้ใช้
   - **settings/** - หน้าตั้งค่า

2. **Route** → `neighbor_app/lib/router/app_router.dart`
   - จัดการการนำทาง ไปหน้าจอต่างๆ

3. **MainAppScreen** → `neighbor_app/lib/screens/main_app_screen.dart`
   - หน้าหลักที่มี Tab Bar (Volunteer, Activity, Community, News, Profile)
   - ถ้าสร้างหน้าหลักใหม่ต้องเพิ่มในนี้

4. **Model** → `neighbor_app/lib/models/`
   - เก็บโครงสร้างข้อมูลตัวแปร

5. **API** → `neighbor_app/lib/services/api_service.dart`
   - เชื่อมต่อกับ Backend, ดึงข้อมูล

6. **Widget** → `neighbor_app/lib/widgets/`
   - เก็บส่วนประกอบ UI ที่ใช้ซ้ำ

7. **Theme** → `neighbor_app/lib/theme/app_theme.dart`
   - เก็บสี, ฟอนต์, การออกแบบ

**เสร็จ! 🎉**
