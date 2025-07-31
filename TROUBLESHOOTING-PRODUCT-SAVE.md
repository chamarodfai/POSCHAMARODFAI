## การแก้ไขปัญหาการบันทึกสินค้าเชิงลึก

### สิ่งที่ได้ทำการแก้ไข:

#### 1. ✅ แก้ไข Product Type Definition
- เปลี่ยน `cost` เป็น `cost_price` 
- เพิ่ม `sku`, `unit` fields
- อัพเดท TypeScript interface ให้ตรงกับฐานข้อมูล

#### 2. ✅ เพิ่ม Form Fields ที่ขาดหายไป
- เพิ่ม input field สำหรับ SKU (รหัสสินค้า)
- เพิ่ม dropdown สำหรับ Unit (หน่วย)
- ปรับปรุง validation ทั้งหมด

#### 3. ✅ Enhanced Error Handling & Debugging
- เพิ่ม console.log เพื่อ debug
- แสดง error message ที่ละเอียดกว่า
- เพิ่ม validation สำหรับ required fields
- ตรวจสอบข้อมูลก่อนส่งไปฐานข้อมูล

#### 4. ✅ Data Transformation & Validation
- แปลงข้อมูลให้เป็น type ที่ถูกต้อง (parseFloat, parseInt)
- trim ข้อมูล string
- ใส่ default values สำหรับฟิลด์ที่เป็น optional
- ตรวจสอบว่าราคาขายต้องมากกว่า 0

#### 5. ✅ อัพเดทฐานข้อมูล Schema
- รัน SQL script เพื่อเพิ่มคอลัมน์ใหม่
- เพิ่ม `sku`, `barcode`, `cost_price`, `unit`, `is_active`
- อัพเดท existing records ให้มี default values

### ขั้นตอนสำหรับทดสอบ:

1. **ไปที่เว็บ**: https://poschamarodfai-drab.vercel.app/products
2. **เปิด Developer Console** (F12) เพื่อดู debug logs
3. **กดปุ่มเพิ่มสินค้าใหม่**
4. **กรอกข้อมูล**:
   - ชื่อสินค้า (required)
   - ราคาขาย (required, > 0)
   - หมวดหมู่ (required)
   - ข้อมูลอื่นๆ ตามต้องการ
5. **ตรวจสอบ Console** เพื่อดู logs ว่าข้อมูลถูกส่งอย่างไร
6. **กดบันทึก** และดูผลลัพธ์

### Debug Information:
- เช็ค Console เพื่อดู "Submitting form data" และ "Prepared data for database"
- ถ้ามี error จะแสดงรายละเอียดใน Console
- Error message จะบอกสาเหตุที่ชัดเจนกว่าเดิม

### การรัน SQL (หากยังไม่ได้รัน):
ไปที่ Supabase SQL Editor และรัน script จากไฟล์ `simple-table-check.sql`
