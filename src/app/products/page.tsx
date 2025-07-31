'use client'

import { useState, useEffect } from 'react'
import { Plus, Search, Edit, Trash2, Package, AlertTriangle } from 'lucide-react'
import { supabase, Product } from '@/lib/supabase'

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [showAddModal, setShowAddModal] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)

  useEffect(() => {
    fetchProducts()
  }, [])

  const fetchProducts = async () => {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .order('name')

      if (error) throw error
      setProducts(data || [])
    } catch (error) {
      console.error('Error fetching products:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const filteredProducts = products.filter(product => {
    const matchesSearch = product.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         product.barcode?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesCategory = selectedCategory === 'all' || product.category === selectedCategory
    return matchesSearch && matchesCategory
  })

  const categories = ['เครื่องดื่ม', 'ขนม', 'Topping']

  const deleteProduct = async (id: string) => {
    if (!confirm('ต้องการลบสินค้านี้หรือไม่?')) return

    try {
      const { error } = await supabase
        .from('products')
        .delete()
        .eq('id', id)

      if (error) throw error
      
      fetchProducts()
      alert('ลบสินค้าสำเร็จ!')
    } catch (error) {
      console.error('Error deleting product:', error)
      alert('เกิดข้อผิดพลาดในการลบสินค้า')
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">กำลังโหลดข้อมูลสินค้า...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center py-4">
            <div className="flex items-center">
              <Package className="h-8 w-8 text-blue-600 mr-3" />
              <h1 className="text-2xl font-bold text-gray-900">จัดการสินค้า</h1>
            </div>
            <button
              onClick={() => setShowAddModal(true)}
              className="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg font-medium flex items-center transition-colors"
            >
              <Plus className="h-5 w-5 mr-2" />
              เพิ่มสินค้าใหม่
            </button>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Search and Filter */}
        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="ค้นหาสินค้า หรือบาร์โค้ด..."
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
              />
            </div>
            <select
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              value={selectedCategory}
              onChange={(e) => setSelectedCategory(e.target.value)}
            >
              <option value="all">ทุกหมวดหมู่</option>
              {categories.map(category => (
                <option key={category} value={category}>{category}</option>
              ))}
            </select>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="flex items-center">
              <div className="bg-blue-100 p-2 rounded-lg">
                <Package className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-gray-500">จำนวนสินค้า</p>
                <p className="text-2xl font-bold text-gray-900">{products.length}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="flex items-center">
              <div className="bg-green-100 p-2 rounded-lg">
                <Package className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-gray-500">สินค้าพร้อมขาย</p>
                <p className="text-2xl font-bold text-gray-900">
                  {products.filter(p => p.is_active && p.stock_quantity > 0).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="flex items-center">
              <div className="bg-yellow-100 p-2 rounded-lg">
                <AlertTriangle className="h-6 w-6 text-yellow-600" />
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-gray-500">สินค้าใกล้หมด</p>
                <p className="text-2xl font-bold text-gray-900">
                  {products.filter(p => p.stock_quantity <= p.min_stock_level).length}
                </p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-4">
            <div className="flex items-center">
              <div className="bg-red-100 p-2 rounded-lg">
                <Package className="h-6 w-6 text-red-600" />
              </div>
              <div className="ml-3">
                <p className="text-sm font-medium text-gray-500">สินค้าหมด</p>
                <p className="text-2xl font-bold text-gray-900">
                  {products.filter(p => p.stock_quantity === 0).length}
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Products Table */}
        <div className="bg-white rounded-lg shadow-sm overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    สินค้า
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    หมวดหมู่
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    ราคา
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    ต้นทุน
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    สต็อก
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    สถานะ
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    การจัดการ
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {filteredProducts.map((product) => (
                  <tr key={product.id} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div className="h-10 w-10 bg-gray-100 rounded-lg flex items-center justify-center mr-3">
                          {product.image_url ? (
                            <img 
                              src={product.image_url} 
                              alt={product.name}
                              className="h-10 w-10 object-cover rounded-lg"
                            />
                          ) : (
                            <span className="text-gray-400">📦</span>
                          )}
                        </div>
                        <div>
                          <div className="text-sm font-medium text-gray-900">
                            {product.name}
                          </div>
                          {product.barcode && (
                            <div className="text-sm text-gray-500">
                              {product.barcode}
                            </div>
                          )}
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-blue-100 text-blue-800">
                        {product.category}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ฿{product.selling_price.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      ฿{product.cost_price.toLocaleString()}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <span className={`text-sm font-medium ${
                          product.stock_quantity === 0 
                            ? 'text-red-600' 
                            : product.stock_quantity <= product.min_stock_level 
                            ? 'text-yellow-600' 
                            : 'text-green-600'
                        }`}>
                          {product.stock_quantity}
                        </span>
                        {product.stock_quantity <= product.min_stock_level && (
                          <AlertTriangle className="h-4 w-4 text-yellow-500 ml-1" />
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${
                        product.is_active 
                          ? 'bg-green-100 text-green-800' 
                          : 'bg-red-100 text-red-800'
                      }`}>
                        {product.is_active ? 'ใช้งาน' : 'ปิดใช้งาน'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex space-x-2">
                        <button
                          onClick={() => setEditingProduct(product)}
                          className="text-indigo-600 hover:text-indigo-900"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => deleteProduct(product.id)}
                          className="text-red-600 hover:text-red-900"
                        >
                          <Trash2 className="h-4 w-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {filteredProducts.length === 0 && (
            <div className="text-center py-12">
              <div className="text-gray-400 text-6xl mb-4">📦</div>
              <p className="text-gray-500">ไม่พบสินค้าที่ค้นหา</p>
            </div>
          )}
        </div>
      </div>

      {/* Add/Edit Product Modal would go here */}
      {(showAddModal || editingProduct) && (
        <ProductModal
          product={editingProduct}
          onClose={() => {
            setShowAddModal(false)
            setEditingProduct(null)
          }}
          onSave={() => {
            fetchProducts()
            setShowAddModal(false)
            setEditingProduct(null)
          }}
        />
      )}
    </div>
  )
}

// Product Modal Component
function ProductModal({ 
  product, 
  onClose, 
  onSave 
}: { 
  product: Product | null
  onClose: () => void
  onSave: () => void
}) {
  const [formData, setFormData] = useState({
    name: product?.name || '',
    description: product?.description || '',
    selling_price: product?.selling_price || 0,
    cost_price: product?.cost_price || 0,
    barcode: product?.barcode || '',
    category: product?.category || 'อาหารและเครื่องดื่ม',
    stock_quantity: product?.stock_quantity || 0,
    min_stock_level: product?.min_stock_level || 5,
    image_url: product?.image_url || '',
    is_active: product?.is_active ?? true,
    sku: product?.sku || '',
    unit: product?.unit || 'ชิ้น'
  })
  const [isLoading, setIsLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)

    try {
      // Debug: log form data
      console.log('Submitting form data:', formData)
      
      // Validate required fields
      if (!formData.name.trim()) {
        alert('กรุณาใส่ชื่อสินค้า')
        return
      }
      
      if (!formData.selling_price || formData.selling_price <= 0) {
        alert('กรุณาใส่ราคาขายที่ถูกต้อง')
        return
      }

      // ตรวจสอบ SKU ซ้ำ (ถ้ามีการใส่ SKU)
      if (formData.sku?.trim()) {
        const { data: existingProduct, error: checkError } = await supabase
          .from('products')
          .select('id')
          .eq('sku', formData.sku.trim())
          .neq('id', product?.id || '') // ไม่นับตัวเอง (กรณีแก้ไข)
          .single()

        if (checkError && checkError.code !== 'PGRST116') { // PGRST116 = no rows returned
          console.error('Error checking SKU:', checkError)
          alert('เกิดข้อผิดพลาดในการตรวจสอบรหัสสินค้า')
          return
        }

        if (existingProduct) {
          alert('รหัสสินค้า (SKU) นี้มีอยู่แล้ว กรุณาใช้รหัสอื่น')
          return
        }
      }

      // ตรวจสอบ Barcode ซ้ำ (ถ้ามีการใส่ Barcode)
      if (formData.barcode?.trim()) {
        const { data: existingBarcodeProduct, error: barcodeCheckError } = await supabase
          .from('products')
          .select('id')
          .eq('barcode', formData.barcode.trim())
          .neq('id', product?.id || '') // ไม่นับตัวเอง (กรณีแก้ไข)
          .single()

        if (barcodeCheckError && barcodeCheckError.code !== 'PGRST116') { // PGRST116 = no rows returned
          console.error('Error checking Barcode:', barcodeCheckError)
          alert('เกิดข้อผิดพลาดในการตรวจสอบบาร์โค้ด')
          return
        }

        if (existingBarcodeProduct) {
          alert('บาร์โค้ดนี้มีอยู่แล้ว กรุณาใช้บาร์โค้ดอื่น')
          return
        }
      }

      // Prepare data for insertion/update
      const productData = {
        name: formData.name.trim(),
        description: formData.description?.trim() || '',
        selling_price: parseFloat(formData.selling_price.toString()),
        cost_price: parseFloat(formData.cost_price?.toString() || '0'),
        sku: formData.sku?.trim() || null, // ใช้ null แทน empty string
        barcode: formData.barcode?.trim() || null, // ใช้ null แทน empty string เพื่อหลีกเลี่ยง constraint error
        category: formData.category,
        stock_quantity: parseInt(formData.stock_quantity?.toString() || '0'),
        min_stock_level: parseInt(formData.min_stock_level?.toString() || '5'),
        unit: formData.unit?.trim() || 'ชิ้น',
        image_url: formData.image_url?.trim() || '',
        is_active: formData.is_active ?? true
      }

      console.log('Prepared data for database:', productData)

      if (product) {
        // Update existing product
        const { data, error } = await supabase
          .from('products')
          .update(productData)
          .eq('id', product.id)
          .select()

        if (error) {
          console.error('Update error:', error)
          throw error
        }
        console.log('Update successful:', data)
        alert('อัปเดตสินค้าสำเร็จ!')
      } else {
        // Create new product
        const { data, error } = await supabase
          .from('products')
          .insert([productData])
          .select()

        if (error) {
          console.error('Insert error:', error)
          throw error
        }
        console.log('Insert successful:', data)
        alert('เพิ่มสินค้าสำเร็จ!')
      }

      onSave()
    } catch (error: any) {
      console.error('Error saving product:', error)
      
      // More detailed error message
      let errorMessage = 'เกิดข้อผิดพลาดในการบันทึกสินค้า'
      
      if (error?.message) {
        errorMessage += ': ' + error.message
      }
      
      if (error?.details) {
        errorMessage += ' (' + error.details + ')'
      }
      
      alert(errorMessage)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="p-6">
          <h2 className="text-2xl font-bold text-gray-900 mb-6">
            {product ? 'แก้ไขสินค้า' : 'เพิ่มสินค้าใหม่'}
          </h2>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  ชื่อสินค้า *
                </label>
                <input
                  type="text"
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  หมวดหมู่ *
                </label>
                <select
                  required
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.category}
                  onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                >
                  <option value="">เลือกหมวดหมู่</option>
                  <option value="เครื่องดื่ม">เครื่องดื่ม</option>
                  <option value="ขนม">ขนม</option>
                  <option value="Topping">Topping</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  ราคาขาย *
                </label>
                <input
                  type="number"
                  required
                  min="0"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.selling_price}
                  onChange={(e) => setFormData({ ...formData, selling_price: parseFloat(e.target.value) || 0 })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  ต้นทุน *
                </label>
                <input
                  type="number"
                  required
                  min="0"
                  step="0.01"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.cost_price}
                  onChange={(e) => setFormData({ ...formData, cost_price: parseFloat(e.target.value) || 0 })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  บาร์โค้ด
                </label>
                <input
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.barcode}
                  onChange={(e) => setFormData({ ...formData, barcode: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  รหัสสินค้า (SKU)
                </label>
                <input
                  type="text"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.sku}
                  onChange={(e) => setFormData({ ...formData, sku: e.target.value })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  หน่วย
                </label>
                <select
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.unit}
                  onChange={(e) => setFormData({ ...formData, unit: e.target.value })}
                >
                  <option value="ชิ้น">ชิ้น</option>
                  <option value="แก้ว">แก้ว</option>
                  <option value="ถุง">ถุง</option>
                  <option value="กิโลกรัม">กิโลกรัม</option>
                  <option value="ลิตร">ลิตร</option>
                </select>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  จำนวนสต็อก *
                </label>
                <input
                  type="number"
                  required
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.stock_quantity}
                  onChange={(e) => setFormData({ ...formData, stock_quantity: parseInt(e.target.value) || 0 })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  สต็อกขั้นต่ำ *
                </label>
                <input
                  type="number"
                  required
                  min="0"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.min_stock_level}
                  onChange={(e) => setFormData({ ...formData, min_stock_level: parseInt(e.target.value) || 0 })}
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  URL รูปภาพ
                </label>
                <input
                  type="url"
                  className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  value={formData.image_url}
                  onChange={(e) => setFormData({ ...formData, image_url: e.target.value })}
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                คำอธิบาย
              </label>
              <textarea
                rows={3}
                className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                value={formData.description}
                onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              />
            </div>

            <div className="flex items-center">
              <input
                type="checkbox"
                id="is_active"
                className="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                checked={formData.is_active}
                onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
              />
              <label htmlFor="is_active" className="ml-2 block text-sm text-gray-900">
                เปิดใช้งานสินค้า
              </label>
            </div>

            <div className="flex justify-end space-x-3 pt-6">
              <button
                type="button"
                onClick={onClose}
                className="px-4 py-2 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition-colors"
              >
                ยกเลิก
              </button>
              <button
                type="submit"
                disabled={isLoading}
                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 transition-colors"
              >
                {isLoading ? 'กำลังบันทึก...' : 'บันทึก'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}
