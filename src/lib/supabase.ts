import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://placeholder.supabase.co'
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'placeholder-anon-key'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Types for our database tables
export interface Product {
  id: string
  name: string
  description?: string
  price: number
  cost: number
  barcode?: string
  category: string
  stock_quantity: number
  stock: number // alias for stock_quantity
  min_stock_level: number
  image_url?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Category {
  id: string
  name: string
  description?: string
  color?: string
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Customer {
  id: string
  name: string
  email?: string
  phone?: string
  address?: string
  points: number
  total_spent: number
  is_active: boolean
  created_at: string
  updated_at: string
}

export interface Promotion {
  id: string
  name: string
  description?: string
  type: 'percentage' | 'fixed'
  value: number
  min_amount: number
  is_active: boolean
  start_date: string
  end_date?: string
  usage_count: number
  max_usage?: number
  created_at: string
  updated_at: string
}

export interface Sale {
  id: string
  customer_id?: string
  total_amount: number
  discount_amount: number
  tax_amount: number
  payment_method: 'cash' | 'card' | 'transfer' | 'qr'
  status: 'pending' | 'completed' | 'cancelled'
  promotion_id?: string
  promotion_name?: string
  discount_percentage?: number
  notes?: string
  created_at: string
  updated_at: string
}

export interface SaleItem {
  id: string
  sale_id: string
  product_id: string
  quantity: number
  unit_price: number
  total_price: number
  created_at: string
}

export interface InventoryMovement {
  id: string
  product_id: string
  movement_type: 'in' | 'out' | 'adjustment'
  quantity: number
  reason: string
  reference_id?: string
  notes?: string
  created_at: string
}

export interface DiscountCalculation {
  discount_amount: number
  discount_percentage: number
  promotion_name: string
}
