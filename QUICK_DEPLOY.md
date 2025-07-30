# 🚀 วิธี Deploy POS CHAMA บน Vercel แบบง่ายๆ

## ขั้นตอนที่ 1: เตรียม GitHub Repository

```bash
# หากยังไม่มี repository บน GitHub ให้สร้างก่อน
# ไปที่ https://github.com และสร้าง repository ใหม่ชื่อ "POSCHAMARODFAI"

# Push โค้ดไป GitHub
git branch -M main
git remote add origin https://github.com/chamarodfai/POSCHAMARODFAI.git
git push -u origin main
```

## ขั้นตอนที่ 2: Deploy บน Vercel (วิธีง่าย)

### วิธีที่ 1: ใช้ Vercel Website (แนะนำ)

1. ไปที่ [vercel.com](https://vercel.com)
2. คลิก **"Sign up"** หรือ **"Login"** ด้วย GitHub
3. คลิก **"New Project"**
4. เลือก repository **"POSCHAMARODFAI"**
5. คลิก **"Import"**
6. ตั้งค่า Environment Variables (ดูรายละเอียดด้านล่าง)
7. คลิก **"Deploy"**

### วิธีที่ 2: ใช้ PowerShell Script (Windows)

```powershell
# รันในโฟลเดอร์โปรเจค
.\deploy.ps1
```

## ขั้นตอนที่ 3: ตั้งค่า Environment Variables

หลังจาก Deploy แล้ว:

1. ไปที่ **Vercel Dashboard**
2. เลือกโปรเจค **pos-chama**
3. ไปที่ **Settings > Environment Variables**
4. เพิ่ม Variables เหล่านี้:

```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
NEXTAUTH_URL=https://your-app.vercel.app
NEXTAUTH_SECRET=your_secret_key
APP_NAME=POS CHAMA
APP_URL=https://your-app.vercel.app
```

## ขั้นตอนที่ 4: ตั้งค่า Custom Domain (Optional)

1. ไปที่ **Settings > Domains**
2. เพิ่ม **POSCHAMA.vercel.app**
3. รอการ verify

## 🎉 เสร็จแล้ว!

ระบบ POS CHAMA ของคุณพร้อมใช้งานแล้วที่ URL ที่ Vercel ให้มา!

## ❗ สิ่งสำคัญ

- อย่าลืมตั้งค่า Supabase database ตามไฟล์ `database/schema.sql`
- ตั้งค่า Environment Variables ให้ถูกต้อง
- ทดสอบระบบหลัง deploy

## 🔗 ลิงก์ที่มีประโยชน์

- [Vercel Dashboard](https://vercel.com/dashboard)
- [Supabase Dashboard](https://supabase.com/dashboard)
- [คู่มือการใช้งาน](./README.md)
- [คำแนะนำ Vercel Setup](./VERCEL_SETUP.md)
