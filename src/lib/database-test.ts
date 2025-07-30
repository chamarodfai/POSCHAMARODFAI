// Database Connection Test Utility
import { supabase } from './supabase'

export async function testDatabaseConnection() {
  try {
    console.log('🔍 Testing Supabase connection...')
    
    // Test 1: Basic connection
    const { data: connectionTest, error: connectionError } = await supabase
      .from('products')
      .select('count')
      .limit(1)

    if (connectionError) {
      console.error('❌ Connection failed:', connectionError.message)
      return {
        success: false,
        error: connectionError.message,
        details: 'Failed to connect to Supabase'
      }
    }

    // Test 2: Check if tables exist and have data
    const { data: products, error: productsError } = await supabase
      .from('products')
      .select('id, name')
      .limit(5)

    if (productsError) {
      console.error('❌ Products table error:', productsError.message)
      return {
        success: false,
        error: productsError.message,
        details: 'Products table not accessible'
      }
    }

    // Test 3: Check categories
    const { data: categories, error: categoriesError } = await supabase
      .from('categories')
      .select('id, name')
      .limit(5)

    if (categoriesError) {
      console.error('❌ Categories table error:', categoriesError.message)
      return {
        success: false,
        error: categoriesError.message,
        details: 'Categories table not accessible'
      }
    }

    console.log('✅ Database connection successful!')
    console.log(`📦 Found ${products?.length || 0} products`)
    console.log(`🏷️ Found ${categories?.length || 0} categories`)

    return {
      success: true,
      data: {
        products: products?.length || 0,
        categories: categories?.length || 0,
        sampleProducts: products,
        sampleCategories: categories
      }
    }

  } catch (error) {
    console.error('❌ Unexpected error:', error)
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error',
      details: 'Unexpected error during connection test'
    }
  }
}

export async function checkEnvironmentVariables() {
  const checks = {
    SUPABASE_URL: !!process.env.NEXT_PUBLIC_SUPABASE_URL && 
                  process.env.NEXT_PUBLIC_SUPABASE_URL !== 'https://placeholder.supabase.co',
    SUPABASE_ANON_KEY: !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY && 
                       process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY !== 'placeholder-anon-key',
    SERVICE_ROLE_KEY: !!process.env.SUPABASE_SERVICE_ROLE_KEY && 
                      process.env.SUPABASE_SERVICE_ROLE_KEY !== 'placeholder-service-role-key'
  }

  console.log('🔧 Environment Variables Check:')
  console.log('SUPABASE_URL:', checks.SUPABASE_URL ? '✅' : '❌')
  console.log('SUPABASE_ANON_KEY:', checks.SUPABASE_ANON_KEY ? '✅' : '❌')
  console.log('SERVICE_ROLE_KEY:', checks.SERVICE_ROLE_KEY ? '✅' : '❌')

  return checks
}

// Helper function to initialize sample data
export async function initializeSampleData() {
  try {
    console.log('📊 Initializing sample data...')

    // Check if data already exists
    const { data: existingProducts } = await supabase
      .from('products')
      .select('id')
      .limit(1)

    if (existingProducts && existingProducts.length > 0) {
      console.log('✅ Sample data already exists')
      return { success: true, message: 'Data already exists' }
    }

    // Insert sample data (this should be done via SQL, but keeping as backup)
    console.log('⚠️ No sample data found. Please run the SQL schema file.')
    return { 
      success: false, 
      message: 'Please run database/schema.sql in Supabase SQL Editor' 
    }

  } catch (error) {
    console.error('❌ Error initializing sample data:', error)
    return { 
      success: false, 
      error: error instanceof Error ? error.message : 'Unknown error' 
    }
  }
}
