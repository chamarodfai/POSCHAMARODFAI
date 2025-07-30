# 🗄️ การตั้งค่า Supabase Database สำหรับ POS CHAMA

## ขั้นตอนการสร้าง Supabase Project

### 1. สร้าง Account และ Project
1. ไปที่ [supabase.com](https://supabase.com)
2. คลิก **"Start your project"**
3. Sign up ด้วย GitHub (แนะนำ)
4. คลิก **"New Project"**
5. เลือก Organization
6. ตั้งค่า:
   - **Name**: pos-chama-db
   - **Database Password**: สร้างรหัสผ่านที่แข็งแกร่ง (เก็บไว้ให้ดี!)
   - **Region**: Southeast Asia (Singapore)
7. คลิก **"Create new project"**
8. รอประมาณ 2-3 นาที

### 2. รัน Database Schema
1. ไปที่ **SQL Editor** (เมนูซ้าย)
2. คลิก **"New query"**
3. Copy โค้ดทั้งหมดจากไฟล์ `database/schema.sql`
4. Paste ลงใน SQL Editor
5. คลิก **"Run"** (Ctrl+Enter)
6. ตรวจสอบว่าไม่มี error

### 3. เอา API Keys
1. ไปที่ **Settings > API** (เมนูซ้าย)
2. คัดลอกข้อมูลเหล่านี้:
   - **Project URL** (https://xxx.supabase.co)
   - **anon public** key
   - **service_role** key (คลิก Reveal เพื่อดู)

### 4. อัปเดต Environment Variables
แทนที่ในไฟล์ `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### 5. ทดสอบการเชื่อมต่อ
```bash
npm run dev
```
ไปที่ http://localhost:3000/products และลองเพิ่มสินค้า

---

## 🔍 วิธีตรวจสอบว่าเชื่อมต่อสำเร็จ

### เครื่องหมายที่ต้องดู:
✅ ไม่มี error ใน browser console
✅ หน้า Products แสดงตารางได้
✅ สามารถเพิ่มสินค้าได้
✅ สินค้าที่เพิ่มแสดงใน list

### ถ้ามี Error:
❌ "Invalid API key" → ตรวจสอบ API keys
❌ "URL not found" → ตรวจสอบ Project URL
❌ "RLS policy" → ตรวจสอบ SQL schema

---

## 📊 ข้อมูลตัวอย่างที่จะมี:

หลังจากรัน schema จะได้:
- **5 หมวดหมู่สินค้า**: อาหาร, เครื่องใช้ไฟฟ้า, เสื้อผ้า, เครื่องเขียน, ของใช้ในบ้าน
- **5 สินค้าตัวอย่าง**: น้ำดื่ม, ข้าวกล่อง, ปากกา, เสื้อยืด, แก้วน้ำ
- **1 ลูกค้า**: ลูกค้าทั่วไป

---

## 🔐 ความปลอดภัย

Schema มี Row Level Security (RLS) ที่:
- อนุญาตให้ authenticated users ทำทุกอย่างได้
- อนุญาตให้ anon users ทำได้ (สำหรับ development)
- ใน production ควรจำกัดสิทธิ์มากขึ้น

---

**พร้อมแล้ว! ลองสร้าง Supabase project และทดสอบกันครับ 🚀**
