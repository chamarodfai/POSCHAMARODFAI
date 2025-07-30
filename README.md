# POS CHAMA - ระบบขายหน้าร้านแบบครบครัน

ระบบ Point of Sale (POS) ที่ทันสมัยและปลอดภัย สร้างด้วย Next.js 15, TypeScript, และ Supabase

## ✨ ฟีเจอร์หลัก

- 🛒 **ระบบขายสินค้า** - รองรับบาร์โค้ด, การชำระเงินหลายรูปแบบ
- 📦 **จัดการสินค้า** - เพิ่ม แก้ไข ลบสินค้า พร้อมระบบสต็อก
- 👥 **จัดการลูกค้า** - ข้อมูลลูกค้า, ระบบสะสมแต้ม
- 📊 **รายงานการขาย** - รายงานเรียลไทม์, กราฟ, สถิติ
- ⚡ **เรียลไทม์** - อัปเดตข้อมูลทันทีด้วย Supabase
- 🔐 **ความปลอดภัย** - Row Level Security, Authentication
- 📱 **Responsive** - ใช้งานได้ทั้งเดสก์ท็อปและมือถือ

## 🛠️ เทคโนโลยีที่ใช้

### Frontend
- **Next.js 15** - React Framework with App Router
- **TypeScript** - Type Safety
- **Tailwind CSS** - Modern CSS Framework
- **Lucide React** - Beautiful Icons
- **TanStack Query** - Server State Management
- **Zustand** - Client State Management

### Backend & Database
- **Supabase** - PostgreSQL + Real-time + Auth
- **Prisma** - Type-safe Database Client
- **Row Level Security** - Database Security

### Deployment
- **Vercel** - Hosting Platform
- **Edge Runtime** - Fast Performance

## 🚀 การติดตั้งและใช้งาน

### 1. Clone โปรเจค

```bash
git clone https://github.com/chamarodfai/POSCHAMARODFAI.git
cd POSCHAMARODFAI
```

### 2. ติดตั้ง Dependencies

```bash
npm install
```

### 3. ตั้งค่า Environment Variables

สร้างไฟล์ `.env.local` และเพิ่มข้อมูลต่อไปนี้:

```env
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

# Database
DATABASE_URL="postgresql://username:password@host:port/database?schema=public"

# NextAuth
NEXTAUTH_URL=http://localhost:3000
NEXTAUTH_SECRET=your_nextauth_secret

# App Configuration
APP_NAME="POS CHAMA"
APP_URL=http://localhost:3000
```

### 4. ตั้งค่า Supabase Database

1. สร้างโปรเจคใหม่ใน [Supabase](https://supabase.com)
2. ไปที่ SQL Editor และรันคำสั่งใน `database/schema.sql`
3. คัดลอก Project URL และ API Keys มาใส่ใน `.env.local`

### 5. รันระบบ

```bash
npm run dev
```

เปิดเบราว์เซอร์ไปที่ [http://localhost:3000](http://localhost:3000)

## 🌐 Deploy บน Vercel

### 1. Push โค้ดไป GitHub

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

### 2. เชื่อมต่อกับ Vercel

1. ไปที่ [Vercel Dashboard](https://vercel.com/dashboard)
2. คลิก "New Project"
3. เลือก GitHub repository
4. ตั้งค่า Environment Variables ใน Project Settings
5. Deploy

### 3. ตั้งค่า Custom Domain (ไม่จำเป็น)

1. ไปที่ Project Settings > Domains
2. เพิ่ม `POSCHAMA.vercel.app` (หรือ domain ที่ต้องการ)

## 📋 Database Schema

ระบบใช้ PostgreSQL ผ่าน Supabase มีตารางหลัก:

- `products` - ข้อมูลสินค้า
- `categories` - หมวดหมู่สินค้า
- `customers` - ข้อมูลลูกค้า
- `sales` - รายการขาย
- `sale_items` - รายการสินค้าในแต่ละการขาย
- `inventory_movements` - การเคลื่อนไหวของสต็อก

## 🔧 การพัฒนา

### รัน Development Server

```bash
npm run dev
```

### Build สำหรับ Production

```bash
npm run build
npm start
```

### Lint และ Type Check

```bash
npm run lint
```

## 📖 การใช้งาน

### 1. ขายสินค้า
- ไปที่หน้า "ขายสินค้า"
- ค้นหาสินค้าและเพิ่มลงตะกร้า
- ตรวจสอบรายการและชำระเงิน

### 2. จัดการสินค้า
- ไปที่หน้า "จัดการสินค้า"
- เพิ่ม แก้ไข หรือลบสินค้า
- ติดตามสต็อกสินค้า

### 3. ดูรายงาน
- ไปที่หน้า "รายงาน"
- ดูยอดขาย กำไร และสถิติต่างๆ

## 🔐 ความปลอดภัย

- ใช้ Row Level Security (RLS) ใน Supabase
- JWT Token Authentication
- Input validation และ sanitization
- HTTPS เท่านั้น (ใน Production)

## 📱 Mobile Support

ระบบออกแบบมาให้ใช้งานได้ดีบนมือถือ:
- Responsive Design
- Touch-friendly UI
- Mobile Navigation

## 🤝 การสนับสนุน

หากพบปัญหาหรือต้องการความช่วยเหลือ:
- เปิด Issue ใน GitHub
- ติดต่อผู้พัฒนา: chamarodfai

## 📄 License

MIT License - ดูรายละเอียดใน `LICENSE` file

## 🎯 Roadmap

- [ ] ระบบ Authentication
- [ ] Receipt Printing
- [ ] Barcode Scanner Integration
- [ ] Payment Gateway Integration
- [ ] Multi-location Support
- [ ] Advanced Reporting
- [ ] Mobile App

---

**สร้างด้วย ❤️ โดย POS CHAMA Team**
