'use client'

import { forwardRef } from 'react'

interface ReceiptProps {
  saleData: {
    sale_number: string
    total_amount: number
    discount_amount: number
    sale_date: string
    promotion?: {
      name: string
      description?: string
    }
  }
  items: Array<{
    name: string
    quantity: number
    unit_price: number
    total_price: number
    toppings?: Array<{ name: string; selling_price: number }>
  }>
}

const Receipt = forwardRef<HTMLDivElement, ReceiptProps>(({ saleData, items }, ref) => {
  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleString('th-TH', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  }

  return (
    <div ref={ref} className="bg-white p-6 max-w-sm mx-auto font-mono text-sm">
      {/* Header */}
      <div className="text-center mb-4">
        <h1 className="text-lg font-bold">CHAMAROD FAI</h1>
        <p className="text-xs">POS SYSTEM</p>
        <div className="border-b border-gray-300 my-2"></div>
      </div>

      {/* Sale Info */}
      <div className="mb-4">
        <p><strong>เลขที่:</strong> {saleData.sale_number}</p>
        <p><strong>วันที่:</strong> {formatDate(saleData.sale_date)}</p>
        <div className="border-b border-gray-300 my-2"></div>
      </div>

      {/* Items */}
      <div className="mb-4">
        {items.map((item, index) => (
          <div key={index} className="mb-2">
            <div className="flex justify-between">
              <span className="flex-1">{item.name}</span>
              <span className="w-16 text-right">฿{item.unit_price.toFixed(2)}</span>
            </div>
            {item.toppings && item.toppings.length > 0 && (
              <div className="text-xs text-gray-600 ml-2">
                {item.toppings.map((topping, tIndex) => (
                  <div key={tIndex} className="flex justify-between">
                    <span>+ {topping.name}</span>
                    <span>฿{topping.selling_price.toFixed(2)}</span>
                  </div>
                ))}
              </div>
            )}
            <div className="flex justify-between text-xs">
              <span className="ml-2">จำนวน: {item.quantity}</span>
              <span><strong>฿{item.total_price.toFixed(2)}</strong></span>
            </div>
          </div>
        ))}
        <div className="border-b border-gray-300 my-2"></div>
      </div>

      {/* Totals */}
      <div className="mb-4">
        <div className="flex justify-between">
          <span>ยอดรวม:</span>
          <span>฿{(saleData.total_amount + saleData.discount_amount).toFixed(2)}</span>
        </div>
        {saleData.discount_amount > 0 && (
          <>
            <div className="flex justify-between text-red-600">
              <span>ส่วนลด:</span>
              <span>-฿{saleData.discount_amount.toFixed(2)}</span>
            </div>
            {saleData.promotion && (
              <div className="text-xs text-gray-600">
                ({saleData.promotion.name})
              </div>
            )}
          </>
        )}
        <div className="border-t border-gray-400 pt-1 mt-1">
          <div className="flex justify-between font-bold text-lg">
            <span>ยอดสุทธิ:</span>
            <span>฿{saleData.total_amount.toFixed(2)}</span>
          </div>
        </div>
      </div>

      {/* Footer */}
      <div className="text-center text-xs">
        <div className="border-b border-gray-300 my-2"></div>
        <p>ขอบคุณที่ใช้บริการ</p>
        <p className="mt-1">Thank you!</p>
      </div>
    </div>
  )
})

Receipt.displayName = 'Receipt'

export default Receipt
