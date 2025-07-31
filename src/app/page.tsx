import Link from 'next/link'
import { ShoppingCart, Package, Users, BarChart3, CreditCard } from 'lucide-react'

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Header */}
      <header className="bg-white shadow-lg">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-6">
            <div className="flex items-center">
              <ShoppingCart className="h-8 w-8 text-blue-600 mr-3" />
              <h1 className="text-3xl font-bold text-gray-900">POS CHAMA</h1>
            </div>
            <div className="flex items-center space-x-4">
              <button className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium transition-colors">
                เข้าสู่ระบบ
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-12">
          <h2 className="text-4xl font-bold text-gray-900 mb-4">
            ระบบขายหน้าร้านแบบครบครัน
          </h2>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto">
            จัดการร้านค้าของคุณได้อย่างมีประสิทธิภาพด้วยระบบ POS ที่ทันสมัย 
            พร้อมการจัดการสินค้า สต็อก และรายงานการขายแบบเรียลไทม์
          </p>
        </div>

        {/* Feature Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8 mb-12">
          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <CreditCard className="h-8 w-8 text-green-600 mr-3" />
              <h3 className="text-xl font-semibold text-gray-900">ขายสินค้า</h3>
            </div>
            <p className="text-gray-600 mb-4">
              ระบบขายที่รวดเร็ว รองรับการสแกนบาร์โค้ด และการชำระเงินหลายรูปแบบ
            </p>
            <Link 
              href="/sales" 
              className="inline-flex items-center text-green-600 hover:text-green-700 font-medium"
            >
              เริ่มขาย →
            </Link>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <Package className="h-8 w-8 text-blue-600 mr-3" />
              <h3 className="text-xl font-semibold text-gray-900">จัดการสินค้า</h3>
            </div>
            <p className="text-gray-600 mb-4">
              เพิ่ม แก้ไข และจัดการข้อมูลสินค้า รวมถึงการติดตามสต็อกสินค้า
            </p>
            <Link 
              href="/products" 
              className="inline-flex items-center text-blue-600 hover:text-blue-700 font-medium"
            >
              จัดการสินค้า →
            </Link>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <BarChart3 className="h-8 w-8 text-purple-600 mr-3" />
              <h3 className="text-xl font-semibold text-gray-900">รายงาน</h3>
            </div>
            <p className="text-gray-600 mb-4">
              ดูรายงานการขาย กำไร และสถิติต่างๆ เพื่อการตัดสินใจทางธุรกิจ
            </p>
            <Link 
              href="/reports" 
              className="inline-flex items-center text-purple-600 hover:text-purple-700 font-medium"
            >
              ดูรายงาน →
            </Link>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <Users className="h-8 w-8 text-orange-600 mr-3" />
              <h3 className="text-xl font-semibold text-gray-900">ลูกค้า</h3>
            </div>
            <p className="text-gray-600 mb-4">
              จัดการข้อมูลลูกค้า โปรโมชั่น และระบบสะสมแต้ม
            </p>
            <Link 
              href="/customers" 
              className="inline-flex items-center text-orange-600 hover:text-orange-700 font-medium"
            >
              จัดการลูกค้า →
            </Link>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 hover:shadow-xl transition-shadow">
            <div className="flex items-center mb-4">
              <Package className="h-8 w-8 text-red-600 mr-3" />
              <h3 className="text-xl font-semibold text-gray-900">สต็อกสินค้า</h3>
            </div>
            <p className="text-gray-600 mb-4">
              ติดตามสต็อกสินค้า แจ้งเตือนเมื่อสินค้าใกล้หมด
            </p>
            <Link 
              href="/inventory" 
              className="inline-flex items-center text-red-600 hover:text-red-700 font-medium"
            >
              ดูสต็อก →
            </Link>
          </div>
        </div>

        {/* Quick Start */}
        <div className="bg-white rounded-xl shadow-lg p-8 text-center">
          <h3 className="text-2xl font-bold text-gray-900 mb-4">
            เริ่มต้นใช้งานได้ทันที
          </h3>
          <p className="text-gray-600 mb-6">
            ระบบพร้อมใช้งาน เชื่อมต่อกับฐานข้อมูล Supabase และ Deploy บน Vercel
          </p>
          <div className="flex justify-center space-x-4">
            <Link
              href="/sales"
              className="bg-green-600 hover:bg-green-700 text-white px-8 py-3 rounded-lg font-medium transition-colors"
            >
              เริ่มขายเลย
            </Link>
            <Link
              href="/products"
              className="bg-blue-600 hover:bg-blue-700 text-white px-8 py-3 rounded-lg font-medium transition-colors"
            >
              จัดการสินค้า
            </Link>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-gray-800 text-white py-8 mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <p>&copy; 2025 POS CHAMA. สร้างด้วย Next.js + Supabase</p>
        </div>
      </footer>
    </div>
  )
}
