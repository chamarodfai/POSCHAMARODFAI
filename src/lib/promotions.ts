// Promotion utilities
import { supabase, Promotion, DiscountCalculation } from './supabase'

export async function getActivePromotions(): Promise<Promotion[]> {
  try {
    const { data, error } = await supabase
      .from('active_promotions')
      .select('*')
      .order('min_amount', { ascending: true })

    if (error) throw error
    return data || []
  } catch (error) {
    console.error('Error fetching promotions:', error)
    return []
  }
}

export async function calculateDiscount(
  subtotal: number,
  promotionId?: string
): Promise<DiscountCalculation> {
  if (!promotionId) {
    return {
      discount_amount: 0,
      discount_percentage: 0,
      promotion_name: ''
    }
  }

  try {
    const { data, error } = await supabase
      .rpc('calculate_discount', {
        subtotal,
        promotion_id: promotionId
      })

    if (error) throw error
    
    return data[0] || {
      discount_amount: 0,
      discount_percentage: 0,
      promotion_name: ''
    }
  } catch (error) {
    console.error('Error calculating discount:', error)
    return {
      discount_amount: 0,
      discount_percentage: 0,
      promotion_name: ''
    }
  }
}

export function findBestPromotion(
  subtotal: number,
  promotions: Promotion[]
): Promotion | null {
  // Filter applicable promotions
  const applicablePromotions = promotions.filter(promo => 
    promo.is_active && 
    subtotal >= promo.min_amount &&
    (!promo.end_date || new Date(promo.end_date) > new Date()) &&
    (!promo.max_usage || promo.usage_count < promo.max_usage)
  )

  if (applicablePromotions.length === 0) return null

  // Calculate actual discount for each promotion
  const promotionsWithDiscount = applicablePromotions.map(promo => {
    let discount = 0
    if (promo.type === 'percentage') {
      discount = subtotal * (promo.value / 100)
    } else {
      discount = promo.value
    }
    return { ...promo, calculatedDiscount: discount }
  })

  // Return promotion with highest discount
  return promotionsWithDiscount.reduce((best, current) => 
    current.calculatedDiscount > best.calculatedDiscount ? current : best
  )
}

export function formatPromotionText(promotion: Promotion): string {
  if (promotion.type === 'percentage') {
    return `ลด ${promotion.value}% (ขั้นต่ำ ฿${promotion.min_amount})`
  } else {
    return `ลด ฿${promotion.value} (ขั้นต่ำ ฿${promotion.min_amount})`
  }
}

export function isPromotionValid(promotion: Promotion): boolean {
  const now = new Date()
  const startDate = new Date(promotion.start_date)
  const endDate = promotion.end_date ? new Date(promotion.end_date) : null
  
  return (
    promotion.is_active &&
    now >= startDate &&
    (!endDate || now <= endDate) &&
    (!promotion.max_usage || promotion.usage_count < promotion.max_usage)
  )
}

export async function applyPromotionToSale(
  saleId: string,
  promotionId: string,
  discountAmount: number,
  promotionName: string,
  discountPercentage: number
): Promise<boolean> {
  try {
    const { error } = await supabase
      .from('sales')
      .update({
        promotion_id: promotionId,
        promotion_name: promotionName,
        discount_amount: discountAmount,
        discount_percentage: discountPercentage
      })
      .eq('id', saleId)

    if (error) throw error
    return true
  } catch (error) {
    console.error('Error applying promotion to sale:', error)
    return false
  }
}
