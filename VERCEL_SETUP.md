# 🔧 การตั้งค่า Environment Variables ใน Vercel

หลังจาก Deploy โปรเจคแล้ว ต้องตั้งค่า Environment Variables เพื่อให้ระบบทำงานได้ถูกต้อง

## 📋 Environment Variables ที่ต้องตั้งค่า

### 1. ไปที่ Vercel Dashboard
- เข้า [Vercel Dashboard](https://vercel.com/dashboard)
- เลือกโปรเจค **pos-chama**
- ไปที่ **Settings > Environment Variables**

### 2. เพิ่ม Variables ต่อไปนี้:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here

# NextAuth Configuration
NEXTAUTH_URL=https://POSCHAMA.vercel.app
NEXTAUTH_SECRET=your_random_secret_key_here

# App Configuration
APP_NAME=POS CHAMA
APP_URL=https://POSCHAMA.vercel.app
```

### 3. วิธีหา Supabase Keys:

1. ไปที่ [Supabase Dashboard](https://supabase.com/dashboard)
2. เลือกโปรเจคของคุณ
3. ไปที่ **Settings > API**
4. คัดลอก:
   - **Project URL** → `NEXT_PUBLIC_SUPABASE_URL`
   - **anon public** key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - **service_role** key → `SUPABASE_SERVICE_ROLE_KEY`

### 4. สร้าง NEXTAUTH_SECRET:

```bash
# ใช้คำสั่งนี้เพื่อสร้าง random secret
openssl rand -base64 32
```

หรือใช้เว็บไซต์: https://generate-secret.vercel.app/32

## 🔄 การ Redeploy หลังตั้งค่า

หลังจากตั้งค่า Environment Variables แล้ว:

1. ไปที่ **Deployments** tab
2. คลิก **Redeploy** ที่ deployment ล่าสุด
3. รอให้ deployment เสร็จ

## 🌐 การตั้งค่า Custom Domain

### เพื่อใช้ POSCHAMA.vercel.app:

1. ไปที่ **Settings > Domains**
2. เพิ่ม domain: `POSCHAMA.vercel.app`
3. รอการ verify (ประมาณ 1-2 นาที)

## 🗄️ การตั้งค่า Supabase Database

### 1. สร้างโปรเจค Supabase ใหม่:
- ไปที่ [Supabase](https://supabase.com)
- คลิก **New Project**
- ตั้งชื่อโปรเจค: **pos-chama**

### 2. รัน Database Schema:
- ไปที่ **SQL Editor**
- Copy โค้ดจากไฟล์ `database/schema.sql`
- รันคำสั่ง SQL

### 3. ตั้งค่า Row Level Security:
- ไปที่ **Authentication > Policies**
- ตรวจสอบว่า Policies ถูกสร้างแล้ว

## ✅ การทดสอบหลัง Deploy

1. เปิดเว็บไซต์ที่ deploy แล้ว
2. ทดสอบการเพิ่มสินค้า
3. ทดสอบการขาย
4. ตรวจสอบการอัปเดตสต็อก

## 🚨 Troubleshooting

### หากเกิด Error:

1. **"Invalid Supabase URL"**:
   - ตรวจสอบ URL และ Keys ใน Environment Variables
   - ลองใช้ Supabase API ผ่าน Postman

2. **"Build Failed"**:
   - ตรวจสอบ Vercel build logs
   - ลอง build local ด้วย `npm run build`

3. **"Database Connection Error"**:
   - ตรวจสอบ Supabase database status
   - ตรวจสอบ RLS policies

## 📞 การติดต่อสำหรับความช่วยเหลือ

หากพบปัญหา:
- เปิด Issue ใน GitHub repository
- ตรวจสอบ Vercel และ Supabase logs
- ติดต่อทีมพัฒนา

---

**Happy Deployment! 🎉**
