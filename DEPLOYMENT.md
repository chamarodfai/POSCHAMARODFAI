# การ Deploy POS CHAMA บน Vercel

## ขั้นตอนการ Deploy

### 1. เตรียม Supabase Database

1. สร้างโปรเจคใหม่ใน [Supabase](https://supabase.com)
2. ไปที่ **SQL Editor**
3. Copy และ paste โค้ดจากไฟล์ `database/schema.sql`
4. รันคำสั่ง SQL เพื่อสร้างตารางและข้อมูลตัวอย่าง
5. ไปที่ **Settings > API** เพื่อคัดลอก:
   - Project URL
   - API Key (anon public)
   - Service Role Key

### 2. Push โค้ดไป GitHub

```bash
git init
git add .
git commit -m "Initial POS CHAMA system"
git branch -M main
git remote add origin https://github.com/chamarodfai/POSCHAMARODFAI.git
git push -u origin main
```

### 3. Deploy บน Vercel

1. ไปที่ [Vercel Dashboard](https://vercel.com/dashboard)
2. คลิก **"New Project"**
3. เลือก repository **POSCHAMARODFAI**
4. ตั้งค่า Environment Variables:

```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
NEXTAUTH_URL=https://POSCHAMA.vercel.app
NEXTAUTH_SECRET=your_random_secret_key
APP_NAME=POS CHAMA
APP_URL=https://POSCHAMA.vercel.app
```

5. คลิก **"Deploy"**

### 4. ตั้งค่า Custom Domain (Optional)

1. ไปที่ **Project Settings > Domains**
2. เพิ่ม domain: `POSCHAMA.vercel.app`
3. รอการ verify

### 5. ทดสอบระบบ

1. เปิดเว็บไซต์ที่ deploy แล้ว
2. ทดสอบการเพิ่มสินค้า
3. ทดสอบการขาย
4. ตรวจสอบการอัปเดตสต็อก

## ⚠️ สิ่งสำคัญ

### Database Security
- ตรวจสอบ RLS Policies ใน Supabase
- อย่าแชร์ Service Role Key
- ใช้ Environment Variables เท่านั้น

### Performance
- ตรวจสอบ Vercel Analytics
- Monitor database performance
- ใช้ Next.js caching

### Backup
- Export database เป็นประจำ
- Backup environment variables
- เก็บ git history

## 🛠️ คำสั่งที่มีประโยชน์

```bash
# Build local
npm run build

# Deploy ไป Vercel
npm run deploy

# ดู database
npm run db:studio

# Check lint
npm run lint
```

## 📱 การใช้งานหลัง Deploy

1. **เข้าใช้งาน**: https://POSCHAMA.vercel.app
2. **เพิ่มสินค้า**: ไปที่หน้า "จัดการสินค้า"
3. **เริ่มขาย**: ไปที่หน้า "ขายสินค้า"
4. **ดูรายงาน**: ไปที่หน้า "รายงาน"

## 🔧 Troubleshooting

### Error: ไม่สามารถเชื่อมต่อ Database
- ตรวจสอบ Supabase URL และ API Key
- ตรวจสอบ RLS Policies
- ตรวจสอบ Network/Firewall

### Error: Build Failed
- ตรวจสอบ TypeScript errors
- ตรวจสอบ Missing dependencies
- ดู Vercel build logs

### Error: Functions Timeout
- ตรวจสอบ Database queries
- ใช้ Database indexing
- Optimize ข้อมูลขนาดใหญ่

---

**Happy Deployment! 🚀**
