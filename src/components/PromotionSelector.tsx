import React, { useState, useEffect } from 'react'
import { Tag, Percent, X } from 'lucide-react'
import { Promotion } from '@/lib/supabase'
import { getActivePromotions, formatPromotionText, isPromotionValid } from '@/lib/promotions'

interface PromotionSelectorProps {
  subtotal: number
  selectedPromotion: Promotion | null
  onPromotionSelect: (promotion: Promotion | null) => void
}

export default function PromotionSelector({
  subtotal,
  selectedPromotion,
  onPromotionSelect
}: PromotionSelectorProps) {
  const [promotions, setPromotions] = useState<Promotion[]>([])
  const [loading, setLoading] = useState(false)
  const [isOpen, setIsOpen] = useState(false)

  useEffect(() => {
    loadPromotions()
  }, [])

  const loadPromotions = async () => {
    setLoading(true)
    try {
      const data = await getActivePromotions()
      setPromotions(data)
    } catch (error) {
      console.error('Error loading promotions:', error)
    } finally {
      setLoading(false)
    }
  }

  const getApplicablePromotions = () => {
    return promotions.filter(promo => 
      isPromotionValid(promo) && 
      subtotal >= promo.min_amount
    )
  }

  const calculatePromotionDiscount = (promotion: Promotion) => {
    if (promotion.type === 'percentage') {
      return subtotal * (promotion.value / 100)
    } else {
      return promotion.value
    }
  }

  const applicablePromotions = getApplicablePromotions()

  return (
    <div className="space-y-4">
      {/* Current Promotion Display */}
      {selectedPromotion && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <Tag className="h-4 w-4 text-green-600" />
              <span className="text-sm font-medium text-green-800">
                {selectedPromotion.name}
              </span>
            </div>
            <button
              onClick={() => onPromotionSelect(null)}
              className="text-green-600 hover:text-green-800"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
          <p className="text-xs text-green-600 mt-1">
            {formatPromotionText(selectedPromotion)} - 
            ลดได้ ฿{calculatePromotionDiscount(selectedPromotion).toFixed(2)}
          </p>
        </div>
      )}

      {/* Promotion Selector Button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`w-full flex items-center justify-between p-3 border rounded-lg transition-colors ${
          selectedPromotion
            ? 'border-green-300 bg-green-50 text-green-700'
            : 'border-gray-300 bg-white text-gray-700 hover:bg-gray-50'
        }`}
      >
        <div className="flex items-center space-x-2">
          <Percent className="h-4 w-4" />
          <span className="text-sm font-medium">
            {selectedPromotion ? 'เปลี่ยนโปรโมชั่น' : 'เลือกโปรโมชั่น'}
          </span>
        </div>
        <span className="text-xs text-gray-500">
          {applicablePromotions.length} รายการ
        </span>
      </button>

      {/* Promotions List */}
      {isOpen && (
        <div className="border border-gray-200 rounded-lg bg-white shadow-sm max-h-64 overflow-y-auto">
          {loading ? (
            <div className="p-4 text-center text-gray-500">
              กำลังโหลด...
            </div>
          ) : applicablePromotions.length === 0 ? (
            <div className="p-4 text-center text-gray-500">
              ไม่มีโปรโมชั่นที่ใช้ได้
              {subtotal > 0 && (
                <div className="text-xs mt-1">
                  ยอดขั้นต่ำสำหรับโปรโมชั่นที่มี: ฿{Math.min(...promotions.map(p => p.min_amount))}
                </div>
              )}
            </div>
          ) : (
            <div className="divide-y divide-gray-100">
              {/* No Promotion Option */}
              <button
                onClick={() => {
                  onPromotionSelect(null)
                  setIsOpen(false)
                }}
                className={`w-full p-3 text-left hover:bg-gray-50 transition-colors ${
                  !selectedPromotion ? 'bg-blue-50 border-l-4 border-blue-500' : ''
                }`}
              >
                <div className="text-sm font-medium text-gray-700">
                  ไม่ใช้โปรโมชั่น
                </div>
                <div className="text-xs text-gray-500">
                  ราคาปกติ
                </div>
              </button>

              {/* Promotion Options */}
              {applicablePromotions.map((promotion) => (
                <button
                  key={promotion.id}
                  onClick={() => {
                    onPromotionSelect(promotion)
                    setIsOpen(false)
                  }}
                  className={`w-full p-3 text-left hover:bg-gray-50 transition-colors ${
                    selectedPromotion?.id === promotion.id 
                      ? 'bg-green-50 border-l-4 border-green-500' 
                      : ''
                  }`}
                >
                  <div className="flex items-center justify-between">
                    <div className="flex-1">
                      <div className="text-sm font-medium text-gray-900">
                        {promotion.name}
                      </div>
                      <div className="text-xs text-gray-600 mt-1">
                        {formatPromotionText(promotion)}
                      </div>
                      {promotion.description && (
                        <div className="text-xs text-gray-500 mt-1">
                          {promotion.description}
                        </div>
                      )}
                    </div>
                    <div className="text-right ml-3">
                      <div className="text-sm font-semibold text-green-600">
                        -฿{calculatePromotionDiscount(promotion).toFixed(2)}
                      </div>
                      {promotion.type === 'percentage' && (
                        <div className="text-xs text-gray-500">
                          ({promotion.value}% ลด)
                        </div>
                      )}
                    </div>
                  </div>
                </button>
              ))}
            </div>
          )}
        </div>
      )}

      {/* Promotion Summary */}
      {subtotal > 0 && promotions.length > 0 && (
        <div className="text-xs text-gray-500 space-y-1">
          <div>โปรโมชั่นทั้งหมด: {promotions.length} รายการ</div>
          <div>ใช้ได้กับยอดนี้: {applicablePromotions.length} รายการ</div>
          {applicablePromotions.length > 0 && (
            <div>
              ลดสูงสุด: ฿{Math.max(...applicablePromotions.map(calculatePromotionDiscount)).toFixed(2)}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
