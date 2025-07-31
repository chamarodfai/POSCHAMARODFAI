'use client'

import { useState, useEffect } from 'react'
import { Plus, Minus, Trash2, Search, ShoppingCart, CreditCard } from 'lucide-react'
import Navigation from '@/components/Navigation'
import PromotionSelector from '@/components/PromotionSelector'
import { supabase, Product, Promotion } from '@/lib/supabase'
import { calculateDiscount } from '@/lib/promotions'

interface CartItem extends Product {
  quantity: number
  total: number
}

export default function SalesPage() {
  const [products, setProducts] = useState<Product[]>([])
  const [cart, setCart] = useState<CartItem[]>([])
  const [searchTerm, setSearchTerm] = useState('')
  const [isLoading, setIsLoading] = useState(true)
  const [selectedCategory, setSelectedCategory] = useState('all')
  const [selectedPromotion, setSelectedPromotion] = useState<Promotion | null>(null)
  const [discountData, setDiscountData] = useState({
    discount_amount: 0,
    discount_percentage: 0,
    promotion_name: ''
  })

  useEffect(() => {
    fetchProducts()
  }, [])

  // Calculate discount when promotion or cart changes
  useEffect(() => {
    const calculatePromotionDiscount = async () => {
      if (!selectedPromotion || cart.length === 0) {
        setDiscountData({
          discount_amount: 0,
          discount_percentage: 0,
          promotion_name: ''
        })
        return
      }

      const subtotal = cart.reduce((sum, item) => sum + item.total, 0)
      const discount = await calculateDiscount(subtotal, selectedPromotion.id)
      setDiscountData(discount)
    }

    calculatePromotionDiscount()
  }, [selectedPromotion, cart])

  const fetchProducts = async () => {
    try {
      const { data, error } = await supabase
        .from('products')
        .select('*')
        .eq('is_active', true)
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

  const addToCart = (product: Product) => {
    const existingItem = cart.find(item => item.id === product.id)
    
    if (existingItem) {
      setCart(cart.map(item =>
        item.id === product.id
          ? { ...item, quantity: item.quantity + 1, total: (item.quantity + 1) * item.selling_price }
          : item
      ))
    } else {
      setCart([...cart, { ...product, quantity: 1, total: product.selling_price }])
    }
  }

  const updateQuantity = (productId: string, quantity: number) => {
    if (quantity === 0) {
      removeFromCart(productId)
      return
    }

    setCart(cart.map(item =>
      item.id === productId
        ? { ...item, quantity, total: quantity * item.selling_price }
        : item
    ))
  }

  const removeFromCart = (productId: string) => {
    setCart(cart.filter(item => item.id !== productId))
  }

  const clearCart = () => {
    setCart([])
    setSelectedPromotion(null)
  }

  const getTotalAmount = () => {
    return cart.reduce((total, item) => total + item.total, 0)
  }

  const getDiscountedTotal = () => {
    const subtotal = getTotalAmount()
    return subtotal - discountData.discount_amount
  }

  const getCartItemCount = () => {
    return cart.reduce((total, item) => total + item.quantity, 0)
  }

  const categories = Array.from(new Set(products.map(p => p.category)))

  const handleCheckout = async () => {
    if (cart.length === 0) return

    try {
      // Create sale record
      const subtotal = getTotalAmount()
      const finalTotal = getDiscountedTotal()
      
      const { data: saleData, error: saleError } = await supabase
        .from('sales')
        .insert({
          total_amount: finalTotal,
          subtotal: subtotal,
          discount_amount: discountData.discount_amount,
          discount_percentage: discountData.discount_percentage,
          promotion_id: selectedPromotion?.id || null,
          promotion_name: discountData.promotion_name || null,
          payment_method: 'cash',
          status: 'completed'
        })
        .select()
        .single()

      if (saleError) throw saleError

      // Create sale items
      const saleItems = cart.map(item => ({
        sale_id: saleData.id,
        product_id: item.id,
        quantity: item.quantity,
        unit_price: item.selling_price,
        total_price: item.total
      }))

      const { error: itemsError } = await supabase
        .from('sale_items')
        .insert(saleItems)

      if (itemsError) throw itemsError

      // Update product stock
      for (const item of cart) {
        const { error: stockError } = await supabase
          .from('products')
          .update({ stock: item.stock - item.quantity })
          .eq('id', item.id)

        if (stockError) throw stockError
      }

      alert('ขายสำเร็จ!')
      clearCart()
    } catch (error) {
      console.error('Error during checkout:', error)
      alert('เกิดข้อผิดพลาดในการขาย')
    }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navigation />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Products Section */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow p-6">
              <h2 className="text-xl font-bold text-gray-900 mb-6">สินค้า</h2>
              
              {/* Search and Filter */}
              <div className="flex flex-col sm:flex-row gap-4 mb-6">
                <div className="flex-1 relative">
                  <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 h-4 w-4" />
                  <input
                    type="text"
                    placeholder="ค้นหาสินค้า หรือ บาร์โค้ด..."
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

              {/* Products Grid */}
              {isLoading ? (
                <div className="text-center py-12">กำลังโหลด...</div>
              ) : (
                <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
                  {filteredProducts.map((product) => (
                    <div
                      key={product.id}
                      className="border border-gray-200 rounded-lg p-4 hover:shadow-md transition-shadow cursor-pointer"
                      onClick={() => addToCart(product)}
                    >
                      <div className="aspect-square bg-gray-100 rounded-lg mb-2 flex items-center justify-center">
                        <span className="text-gray-400 text-xs">รูปภาพ</span>
                      </div>
                      <h3 className="font-medium text-sm text-gray-900 mb-1 line-clamp-2">
                        {product.name}
                      </h3>
                      <p className="text-lg font-bold text-blue-600">
                        ฿{product.price.toFixed(2)}
                      </p>
                      <p className="text-xs text-gray-500">
                        คงเหลือ: {product.stock}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Cart Section */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-lg shadow p-6 sticky top-8">
              <div className="flex items-center justify-between mb-6">
                <h2 className="text-xl font-bold text-gray-900 flex items-center">
                  <ShoppingCart className="h-5 w-5 mr-2" />
                  ตะกร้า ({getCartItemCount()})
                </h2>
                {cart.length > 0 && (
                  <button
                    onClick={clearCart}
                    className="text-red-600 hover:text-red-800 text-sm"
                  >
                    ล้างทั้งหมด
                  </button>
                )}
              </div>

              {/* Cart Items */}
              <div className="space-y-4 mb-6 max-h-60 overflow-y-auto">
                {cart.map((item) => (
                  <div key={item.id} className="flex items-center justify-between border-b border-gray-100 pb-4">
                    <div className="flex-1">
                      <h4 className="font-medium text-sm text-gray-900">{item.name}</h4>
                      <p className="text-sm text-gray-600">฿{item.price.toFixed(2)}</p>
                    </div>
                    <div className="flex items-center space-x-2">
                      <button
                        onClick={() => updateQuantity(item.id, item.quantity - 1)}
                        className="text-gray-500 hover:text-gray-700"
                      >
                        <Minus className="h-4 w-4" />
                      </button>
                      <span className="w-8 text-center">{item.quantity}</span>
                      <button
                        onClick={() => updateQuantity(item.id, item.quantity + 1)}
                        className="text-gray-500 hover:text-gray-700"
                      >
                        <Plus className="h-4 w-4" />
                      </button>
                      <button
                        onClick={() => removeFromCart(item.id)}
                        className="text-red-500 hover:text-red-700 ml-2"
                      >
                        <Trash2 className="h-4 w-4" />
                      </button>
                    </div>
                  </div>
                ))}
              </div>

              {/* Promotion Selector */}
              {cart.length > 0 && (
                <div className="mb-6">
                  <PromotionSelector
                    subtotal={getTotalAmount()}
                    selectedPromotion={selectedPromotion}
                    onPromotionSelect={setSelectedPromotion}
                  />
                </div>
              )}

              {/* Total */}
              <div className="space-y-2 mb-6">
                <div className="flex justify-between text-sm">
                  <span>ยอดรวม:</span>
                  <span>฿{getTotalAmount().toFixed(2)}</span>
                </div>
                
                {discountData.discount_amount > 0 && (
                  <>
                    <div className="flex justify-between text-sm text-green-600">
                      <span>ส่วนลด ({discountData.promotion_name}):</span>
                      <span>-฿{discountData.discount_amount.toFixed(2)}</span>
                    </div>
                    <div className="border-t border-gray-200 pt-2">
                      <div className="flex justify-between font-bold text-lg">
                        <span>ยอดชำระ:</span>
                        <span className="text-blue-600">฿{getDiscountedTotal().toFixed(2)}</span>
                      </div>
                    </div>
                  </>
                )}
                
                {discountData.discount_amount === 0 && (
                  <div className="flex justify-between font-bold text-lg">
                    <span>ยอดชำระ:</span>
                    <span className="text-blue-600">฿{getTotalAmount().toFixed(2)}</span>
                  </div>
                )}
              </div>

              {/* Checkout Button */}
              <button
                onClick={handleCheckout}
                disabled={cart.length === 0}
                className="w-full bg-blue-600 text-white py-3 px-4 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center justify-center"
              >
                <CreditCard className="h-5 w-5 mr-2" />
                ชำระเงิน
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
