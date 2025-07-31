'use client'

import { useState, useEffect } from 'react'
import { Plus, Edit, Trash2, Calendar, Percent, DollarSign, Tag, Users } from 'lucide-react'
import Navigation from '@/components/Navigation'
import { supabase, Promotion } from '@/lib/supabase'

export default function PromotionsPage() {
  const [promotions, setPromotions] = useState<Promotion[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [showForm, setShowForm] = useState(false)
  const [editingPromotion, setEditingPromotion] = useState<Promotion | null>(null)
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    type: 'percentage' as 'percentage' | 'fixed',
    value: 0,
    min_amount: 0,
    start_date: '',
    end_date: '',
    max_usage: undefined as number | undefined,
    is_active: true
  })

  useEffect(() => {
    fetchPromotions()
  }, [])

  const fetchPromotions = async () => {
    try {
      const { data, error } = await supabase
        .from('promotions')
        .select('*')
        .order('created_at', { ascending: false })

      if (error) throw error
      setPromotions(data || [])
    } catch (error) {
      console.error('Error fetching promotions:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    
    try {
      if (editingPromotion) {
        // Update existing promotion
        const { error } = await supabase
          .from('promotions')
          .update(formData)
          .eq('id', editingPromotion.id)

        if (error) throw error
        alert('อัปเดตโปรโมชั่นสำเร็จ!')
      } else {
        // Create new promotion
        const { error } = await supabase
          .from('promotions')
          .insert([formData])

        if (error) throw error
        alert('เพิ่มโปรโมชั่นสำเร็จ!')
      }

      setShowForm(false)
      setEditingPromotion(null)
      resetForm()
      fetchPromotions()
    } catch (error) {
      console.error('Error saving promotion:', error)
      alert('เกิดข้อผิดพลาดในการบันทึกโปรโมชั่น')
    }
  }

  const handleEdit = (promotion: Promotion) => {
    setEditingPromotion(promotion)
    setFormData({
      name: promotion.name,
      description: promotion.description || '',
      type: promotion.type,
      value: promotion.value,
      min_amount: promotion.min_amount,
      start_date: promotion.start_date,
      end_date: promotion.end_date || '',
      max_usage: promotion.max_usage || undefined,
      is_active: promotion.is_active
    })
    setShowForm(true)
  }

  const handleDelete = async (id: string) => {
    if (!confirm('คุณแน่ใจหรือไม่ที่จะลบโปรโมชั่นนี้?')) return

    try {
      const { error } = await supabase
        .from('promotions')
        .delete()
        .eq('id', id)

      if (error) throw error
      alert('ลบโปรโมชั่นสำเร็จ!')
      fetchPromotions()
    } catch (error) {
      console.error('Error deleting promotion:', error)
      alert('เกิดข้อผิดพลาดในการลบโปรโมชั่น')
    }
  }

  const toggleActive = async (promotion: Promotion) => {
    try {
      const { error } = await supabase
        .from('promotions')
        .update({ is_active: !promotion.is_active })
        .eq('id', promotion.id)

      if (error) throw error
      fetchPromotions()
    } catch (error) {
      console.error('Error toggling promotion status:', error)
    }
  }

  const resetForm = () => {
    setFormData({
      name: '',
      description: '',
      type: 'percentage',
      value: 0,
      min_amount: 0,
      start_date: '',
      end_date: '',
      max_usage: undefined,
      is_active: true
    })
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('th-TH', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  const getPromotionStatus = (promotion: Promotion) => {
    if (!promotion.is_active) return { text: 'ปิดใช้งาน', color: 'bg-gray-100 text-gray-800' }
    
    const now = new Date()
    const startDate = new Date(promotion.start_date)
    const endDate = promotion.end_date ? new Date(promotion.end_date) : null
    
    if (now < startDate) return { text: 'ยังไม่เริ่ม', color: 'bg-yellow-100 text-yellow-800' }
    if (endDate && now > endDate) return { text: 'หมดอายุ', color: 'bg-red-100 text-red-800' }
    if (promotion.max_usage && promotion.usage_count >= promotion.max_usage) {
      return { text: 'ใช้ครบแล้ว', color: 'bg-red-100 text-red-800' }
    }
    
    return { text: 'ใช้งานได้', color: 'bg-green-100 text-green-800' }
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <Navigation />
      
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-8">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900">จัดการโปรโมชั่น</h1>
            <button
              onClick={() => {
                setShowForm(true)
                setEditingPromotion(null)
                resetForm()
              }}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 flex items-center"
            >
              <Plus className="h-4 w-4 mr-2" />
              เพิ่มโปรโมชั่น
            </button>
          </div>
        </div>

        {/* Promotion Form Modal */}
        {showForm && (
          <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-lg p-6 w-full max-w-md max-h-screen overflow-y-auto">
              <h2 className="text-xl font-bold mb-4">
                {editingPromotion ? 'แก้ไขโปรโมชั่น' : 'เพิ่มโปรโมชั่นใหม่'}
              </h2>
              
              <form onSubmit={handleSubmit} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ชื่อโปรโมชั่น
                  </label>
                  <input
                    type="text"
                    required
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.name}
                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    คำอธิบาย
                  </label>
                  <textarea
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    rows={3}
                    value={formData.description}
                    onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ประเภทส่วนลด
                  </label>
                  <select
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.type}
                    onChange={(e) => setFormData({ ...formData, type: e.target.value as 'percentage' | 'fixed' })}
                  >
                    <option value="percentage">เปอร์เซ็นต์ (%)</option>
                    <option value="fixed">จำนวนเงิน (บาท)</option>
                  </select>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ค่าส่วนลด {formData.type === 'percentage' ? '(%)' : '(บาท)'}
                  </label>
                  <input
                    type="number"
                    min="0"
                    max={formData.type === 'percentage' ? "100" : undefined}
                    step={formData.type === 'percentage' ? "0.01" : "1"}
                    required
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.value}
                    onChange={(e) => setFormData({ ...formData, value: parseFloat(e.target.value) || 0 })}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    ยอดขั้นต่ำ (บาท)
                  </label>
                  <input
                    type="number"
                    min="0"
                    step="1"
                    required
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.min_amount}
                    onChange={(e) => setFormData({ ...formData, min_amount: parseFloat(e.target.value) || 0 })}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    วันที่เริ่ม
                  </label>
                  <input
                    type="date"
                    required
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.start_date}
                    onChange={(e) => setFormData({ ...formData, start_date: e.target.value })}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    วันที่สิ้นสุด (ไม่จำกัด หากไม่ระบุ)
                  </label>
                  <input
                    type="date"
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.end_date}
                    onChange={(e) => setFormData({ ...formData, end_date: e.target.value })}
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    จำนวนครั้งที่ใช้ได้ (ไม่จำกัด หากไม่ระบุ)
                  </label>
                  <input
                    type="number"
                    min="1"
                    className="w-full border border-gray-300 rounded-lg px-3 py-2 focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                    value={formData.max_usage || ''}
                    onChange={(e) => setFormData({ 
                      ...formData, 
                      max_usage: e.target.value ? parseInt(e.target.value) : undefined 
                    })}
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
                    เปิดใช้งาน
                  </label>
                </div>

                <div className="flex space-x-3 pt-4">
                  <button
                    type="submit"
                    className="flex-1 bg-blue-600 text-white py-2 px-4 rounded-lg hover:bg-blue-700"
                  >
                    {editingPromotion ? 'อัปเดต' : 'เพิ่ม'}
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      setShowForm(false)
                      setEditingPromotion(null)
                      resetForm()
                    }}
                    className="flex-1 bg-gray-300 text-gray-700 py-2 px-4 rounded-lg hover:bg-gray-400"
                  >
                    ยกเลิก
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}

        {/* Promotions List */}
        <div className="bg-white rounded-lg shadow">
          {isLoading ? (
            <div className="p-8 text-center">กำลังโหลด...</div>
          ) : promotions.length === 0 ? (
            <div className="p-8 text-center text-gray-500">ยังไม่มีโปรโมชั่น</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full">
                <thead className="bg-gray-50">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      โปรโมชั่น
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      ส่วนลด
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      ระยะเวลา
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      การใช้งาน
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      สถานะ
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                      จัดการ
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                  {promotions.map((promotion) => {
                    const status = getPromotionStatus(promotion)
                    return (
                      <tr key={promotion.id} className="hover:bg-gray-50">
                        <td className="px-6 py-4">
                          <div>
                            <div className="text-sm font-medium text-gray-900">
                              {promotion.name}
                            </div>
                            {promotion.description && (
                              <div className="text-sm text-gray-500">
                                {promotion.description}
                              </div>
                            )}
                            <div className="text-xs text-gray-400 mt-1">
                              ยอดขั้นต่ำ: ฿{promotion.min_amount}
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <div className="flex items-center">
                            {promotion.type === 'percentage' ? (
                              <Percent className="h-4 w-4 text-green-600 mr-1" />
                            ) : (
                              <DollarSign className="h-4 w-4 text-blue-600 mr-1" />
                            )}
                            <span className="text-sm font-medium">
                              {promotion.type === 'percentage' 
                                ? `${promotion.value}%` 
                                : `฿${promotion.value}`}
                            </span>
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          <div className="flex items-center">
                            <Calendar className="h-4 w-4 mr-1" />
                            <div>
                              <div>{formatDate(promotion.start_date)}</div>
                              {promotion.end_date && (
                                <div>ถึง {formatDate(promotion.end_date)}</div>
                              )}
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-gray-500">
                          <div className="flex items-center">
                            <Users className="h-4 w-4 mr-1" />
                            <div>
                              <div>{promotion.usage_count} ครั้ง</div>
                              {promotion.max_usage && (
                                <div className="text-xs">จาก {promotion.max_usage} ครั้ง</div>
                              )}
                            </div>
                          </div>
                        </td>
                        <td className="px-6 py-4">
                          <span className={`inline-flex px-2 py-1 text-xs font-semibold rounded-full ${status.color}`}>
                            {status.text}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-sm font-medium space-x-2">
                          <button
                            onClick={() => toggleActive(promotion)}
                            className={`${
                              promotion.is_active 
                                ? 'text-red-600 hover:text-red-900' 
                                : 'text-green-600 hover:text-green-900'
                            }`}
                          >
                            {promotion.is_active ? 'ปิด' : 'เปิด'}
                          </button>
                          <button
                            onClick={() => handleEdit(promotion)}
                            className="text-blue-600 hover:text-blue-900"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleDelete(promotion.id)}
                            className="text-red-600 hover:text-red-900"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </td>
                      </tr>
                    )
                  })}
                </tbody>
              </table>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
