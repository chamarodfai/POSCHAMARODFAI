'use client'

import { useState, useEffect } from 'react'
import { BarChart3, TrendingUp, Calendar, DollarSign, Package, Users, ArrowUpRight, ArrowDownRight } from 'lucide-react'
import { supabase } from '@/lib/supabase'

interface SalesData {
  date: string
  total_sales: number
  total_orders: number
  total_items: number
  avg_order_value: number
}

interface ProductSalesData {
  product_name: string
  quantity_sold: number
  total_revenue: number
}

interface ReportData {
  totalSales: number
  totalOrders: number
  totalItems: number
  avgOrderValue: number
  salesData: SalesData[]
  topProducts: ProductSalesData[]
}

export default function ReportsPage() {
  const [reportData, setReportData] = useState<ReportData>({
    totalSales: 0,
    totalOrders: 0,
    totalItems: 0,
    avgOrderValue: 0,
    salesData: [],
    topProducts: []
  })
  const [isLoading, setIsLoading] = useState(true)
  const [selectedPeriod, setSelectedPeriod] = useState<'daily' | 'weekly' | 'monthly' | 'yearly'>('daily')
  const [dateRange, setDateRange] = useState({
    startDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
    endDate: new Date().toISOString().split('T')[0]
  })

  useEffect(() => {
    fetchReportData()
  }, [selectedPeriod, dateRange])

  const fetchReportData = async () => {
    setIsLoading(true)
    try {
      // Fetch sales data based on selected period
      const { data: salesData, error: salesError } = await supabase
        .from('sales_summary_view') // We'll create this view
        .select('*')
        .gte('sale_date', dateRange.startDate)
        .lte('sale_date', dateRange.endDate)
        .order('sale_date', { ascending: true })

      if (salesError) {
        console.error('Sales data error:', salesError)
        // Fallback to basic sales query if view doesn't exist
        await fetchBasicSalesData()
        return
      }

      // Calculate totals
      const totalSales = salesData?.reduce((sum, item) => sum + (item.total_sales || 0), 0) || 0
      const totalOrders = salesData?.reduce((sum, item) => sum + (item.total_orders || 0), 0) || 0
      const totalItems = salesData?.reduce((sum, item) => sum + (item.total_items || 0), 0) || 0
      const avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0

      // Fetch top products
      const { data: topProducts, error: productsError } = await supabase
        .from('product_sales_summary_view')
        .select('*')
        .gte('sale_date', dateRange.startDate)
        .lte('sale_date', dateRange.endDate)
        .order('total_revenue', { ascending: false })
        .limit(10)

      if (productsError) {
        console.error('Products data error:', productsError)
      }

      setReportData({
        totalSales,
        totalOrders,
        totalItems,
        avgOrderValue,
        salesData: salesData || [],
        topProducts: topProducts || []
      })

    } catch (error) {
      console.error('Error fetching report data:', error)
      await fetchBasicSalesData()
    } finally {
      setIsLoading(false)
    }
  }

  const fetchBasicSalesData = async () => {
    try {
      // Basic sales query without views
      const { data: sales, error } = await supabase
        .from('sales')
        .select(`
          id,
          total_amount,
          sale_date,
          sale_items (
            quantity,
            unit_price,
            products (
              name
            )
          )
        `)
        .gte('sale_date', dateRange.startDate)
        .lte('sale_date', dateRange.endDate)

      if (error) throw error

      // Process data manually
      const processedData = processSalesData(sales || [])
      setReportData(processedData)

    } catch (error) {
      console.error('Error fetching basic sales data:', error)
      // Set empty data
      setReportData({
        totalSales: 0,
        totalOrders: 0,
        totalItems: 0,
        avgOrderValue: 0,
        salesData: [],
        topProducts: []
      })
    }
  }

  const processSalesData = (sales: any[]) => {
    // Group sales by date
    const salesByDate: { [key: string]: { sales: number, orders: number, items: number } } = {}
    const productSales: { [key: string]: { quantity: number, revenue: number } } = {}

    sales.forEach(sale => {
      const date = new Date(sale.sale_date).toISOString().split('T')[0]
      
      if (!salesByDate[date]) {
        salesByDate[date] = { sales: 0, orders: 0, items: 0 }
      }
      
      salesByDate[date].sales += sale.total_amount
      salesByDate[date].orders += 1
      
      sale.sale_items?.forEach((item: any) => {
        salesByDate[date].items += item.quantity
        
        const productName = item.products?.name || 'Unknown Product'
        if (!productSales[productName]) {
          productSales[productName] = { quantity: 0, revenue: 0 }
        }
        productSales[productName].quantity += item.quantity
        productSales[productName].revenue += item.quantity * item.unit_price
      })
    })

    // Convert to arrays
    const salesData: SalesData[] = Object.entries(salesByDate).map(([date, data]) => ({
      date,
      total_sales: data.sales,
      total_orders: data.orders,
      total_items: data.items,
      avg_order_value: data.orders > 0 ? data.sales / data.orders : 0
    }))

    const topProducts: ProductSalesData[] = Object.entries(productSales)
      .map(([name, data]) => ({
        product_name: name,
        quantity_sold: data.quantity,
        total_revenue: data.revenue
      }))
      .sort((a, b) => b.total_revenue - a.total_revenue)
      .slice(0, 10)

    // Calculate totals
    const totalSales = salesData.reduce((sum, item) => sum + item.total_sales, 0)
    const totalOrders = salesData.reduce((sum, item) => sum + item.total_orders, 0)
    const totalItems = salesData.reduce((sum, item) => sum + item.total_items, 0)
    const avgOrderValue = totalOrders > 0 ? totalSales / totalOrders : 0

    return {
      totalSales,
      totalOrders,
      totalItems,
      avgOrderValue,
      salesData,
      topProducts
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat('th-TH', {
      style: 'currency',
      currency: 'THB'
    }).format(amount)
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('th-TH', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }

  const getPeriodLabel = () => {
    switch (selectedPeriod) {
      case 'daily': return 'รายวัน'
      case 'weekly': return 'รายสัปดาห์'
      case 'monthly': return 'รายเดือน'
      case 'yearly': return 'รายปี'
      default: return 'รายวัน'
    }
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">กำลังโหลดข้อมูลรายงาน...</p>
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
              <BarChart3 className="h-8 w-8 text-blue-600 mr-3" />
              <h1 className="text-2xl font-bold text-gray-900">รายงานยอดขาย</h1>
            </div>
          </div>
        </div>
      </header>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Filters */}
        <div className="bg-white rounded-lg shadow-sm p-4 mb-6">
          <div className="flex flex-col sm:flex-row gap-4 items-start sm:items-center">
            <div className="flex flex-wrap gap-2">
              {(['daily', 'weekly', 'monthly', 'yearly'] as const).map((period) => (
                <button
                  key={period}
                  onClick={() => setSelectedPeriod(period)}
                  className={`px-4 py-2 rounded-lg font-medium transition-colors ${
                    selectedPeriod === period
                      ? 'bg-blue-600 text-white'
                      : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                  }`}
                >
                  {period === 'daily' && 'รายวัน'}
                  {period === 'weekly' && 'รายสัปดาห์'}
                  {period === 'monthly' && 'รายเดือน'}
                  {period === 'yearly' && 'รายปี'}
                </button>
              ))}
            </div>
            
            <div className="flex gap-2">
              <input
                type="date"
                value={dateRange.startDate}
                onChange={(e) => setDateRange({ ...dateRange, startDate: e.target.value })}
                className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
              <span className="flex items-center text-gray-500">ถึง</span>
              <input
                type="date"
                value={dateRange.endDate}
                onChange={(e) => setDateRange({ ...dateRange, endDate: e.target.value })}
                className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-500">ยอดขายรวม</p>
                <p className="text-2xl font-bold text-gray-900">
                  {formatCurrency(reportData.totalSales)}
                </p>
              </div>
              <div className="bg-green-100 p-3 rounded-lg">
                <DollarSign className="h-6 w-6 text-green-600" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-500">จำนวนออเดอร์</p>
                <p className="text-2xl font-bold text-gray-900">
                  {reportData.totalOrders.toLocaleString()}
                </p>
              </div>
              <div className="bg-blue-100 p-3 rounded-lg">
                <Package className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-500">สินค้าที่ขายได้</p>
                <p className="text-2xl font-bold text-gray-900">
                  {reportData.totalItems.toLocaleString()}
                </p>
              </div>
              <div className="bg-purple-100 p-3 rounded-lg">
                <TrendingUp className="h-6 w-6 text-purple-600" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-lg shadow-sm p-6">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-500">ยอดขายเฉลี่ย/ออเดอร์</p>
                <p className="text-2xl font-bold text-gray-900">
                  {formatCurrency(reportData.avgOrderValue)}
                </p>
              </div>
              <div className="bg-yellow-100 p-3 rounded-lg">
                <Users className="h-6 w-6 text-yellow-600" />
              </div>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Sales Chart */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              ยอดขาย{getPeriodLabel()}
            </h3>
            <div className="space-y-4">
              {reportData.salesData.length > 0 ? (
                reportData.salesData.map((item, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="w-2 h-2 bg-blue-600 rounded-full mr-3"></div>
                      <span className="text-sm text-gray-600">
                        {formatDate(item.date)}
                      </span>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium text-gray-900">
                        {formatCurrency(item.total_sales)}
                      </p>
                      <p className="text-xs text-gray-500">
                        {item.total_orders} ออเดอร์
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  ไม่มีข้อมูลยอดขายในช่วงที่เลือก
                </div>
              )}
            </div>
          </div>

          {/* Top Products */}
          <div className="bg-white rounded-lg shadow-sm p-6">
            <h3 className="text-lg font-semibold text-gray-900 mb-4">
              สินค้าขายดี Top 10
            </h3>
            <div className="space-y-4">
              {reportData.topProducts.length > 0 ? (
                reportData.topProducts.map((product, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center mr-3">
                        <span className="text-sm font-medium text-gray-600">
                          {index + 1}
                        </span>
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">
                          {product.product_name}
                        </p>
                        <p className="text-xs text-gray-500">
                          ขายได้ {product.quantity_sold} ชิ้น
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium text-gray-900">
                        {formatCurrency(product.total_revenue)}
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  ไม่มีข้อมูลสินค้าในช่วงที่เลือก
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Daily Sales Table */}
        <div className="bg-white rounded-lg shadow-sm mt-6 overflow-hidden">
          <div className="p-6 border-b border-gray-200">
            <h3 className="text-lg font-semibold text-gray-900">
              รายละเอียดยอดขาย{getPeriodLabel()}
            </h3>
          </div>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    วันที่
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    ยอดขาย
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    จำนวนออเดอร์
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    สินค้าที่ขาย
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    ยอดขายเฉลี่ย/ออเดอร์
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {reportData.salesData.map((item, index) => (
                  <tr key={index} className="hover:bg-gray-50">
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatDate(item.date)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                      {formatCurrency(item.total_sales)}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.total_orders}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {item.total_items}
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                      {formatCurrency(item.avg_order_value)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {reportData.salesData.length === 0 && (
            <div className="text-center py-12">
              <div className="text-gray-400 text-6xl mb-4">📊</div>
              <p className="text-gray-500">ไม่มีข้อมูลรายงานในช่วงที่เลือก</p>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
