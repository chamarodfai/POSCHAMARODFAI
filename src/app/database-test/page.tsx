'use client'

import { useState, useEffect } from 'react'
import { Database, CheckCircle, XCircle, AlertCircle, RefreshCw } from 'lucide-react'
import { testDatabaseConnection, checkEnvironmentVariables, initializeSampleData } from '@/lib/database-test'

interface TestResult {
  success: boolean
  error?: string
  details?: string
  data?: any
}

export default function DatabaseTestPage() {
  const [connectionStatus, setConnectionStatus] = useState<TestResult | null>(null)
  const [envCheck, setEnvCheck] = useState<any>(null)
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    // Check environment variables on load
    const envStatus = checkEnvironmentVariables()
    setEnvCheck(envStatus)
  }, [])

  const runConnectionTest = async () => {
    setIsLoading(true)
    try {
      const result = await testDatabaseConnection()
      setConnectionStatus(result)
    } catch (error) {
      setConnectionStatus({
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error'
      })
    } finally {
      setIsLoading(false)
    }
  }

  const runInitializeSampleData = async () => {
    setIsLoading(true)
    try {
      await initializeSampleData()
      // Re-run connection test after initialization
      await runConnectionTest()
    } catch (error) {
      console.error('Error initializing sample data:', error)
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header */}
        <div className="text-center mb-8">
          <Database className="h-16 w-16 text-blue-600 mx-auto mb-4" />
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            POS CHAMA - Database Connection Test
          </h1>
          <p className="text-gray-600">
            ทดสอบการเชื่อมต่อกับ Supabase Database
          </p>
        </div>

        {/* Environment Variables Check */}
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <AlertCircle className="h-5 w-5 mr-2 text-orange-500" />
            Environment Variables Status
          </h2>
          
          {envCheck && (
            <div className="space-y-3">
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
                <span className="font-medium">SUPABASE_URL</span>
                {envCheck.SUPABASE_URL ? (
                  <CheckCircle className="h-5 w-5 text-green-500" />
                ) : (
                  <XCircle className="h-5 w-5 text-red-500" />
                )}
              </div>
              
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
                <span className="font-medium">SUPABASE_ANON_KEY</span>
                {envCheck.SUPABASE_ANON_KEY ? (
                  <CheckCircle className="h-5 w-5 text-green-500" />
                ) : (
                  <XCircle className="h-5 w-5 text-red-500" />
                )}
              </div>
              
              <div className="flex items-center justify-between p-3 bg-gray-50 rounded">
                <span className="font-medium">SERVICE_ROLE_KEY</span>
                {envCheck.SERVICE_ROLE_KEY ? (
                  <CheckCircle className="h-5 w-5 text-green-500" />
                ) : (
                  <XCircle className="h-5 w-5 text-red-500" />
                )}
              </div>
            </div>
          )}

          {envCheck && (!envCheck.SUPABASE_URL || !envCheck.SUPABASE_ANON_KEY) && (
            <div className="mt-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg">
              <h3 className="font-medium text-yellow-800 mb-2">
                ⚠️ Environment Variables ไม่ครบ
              </h3>
              <p className="text-yellow-700 text-sm mb-3">
                กรุณาตั้งค่า Supabase credentials ในไฟล์ .env.local
              </p>
              <div className="text-xs text-yellow-600 bg-yellow-100 p-2 rounded font-mono">
                NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co<br/>
                NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key<br/>
                SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
              </div>
            </div>
          )}
        </div>

        {/* Connection Test */}
        <div className="bg-white rounded-lg shadow-lg p-6 mb-6">
          <h2 className="text-xl font-semibold text-gray-900 mb-4 flex items-center">
            <Database className="h-5 w-5 mr-2 text-blue-500" />
            Database Connection Test
          </h2>

          <div className="flex space-x-4 mb-6">
            <button
              onClick={runConnectionTest}
              disabled={isLoading}
              className="flex items-center px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
            >
              {isLoading ? (
                <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
              ) : (
                <Database className="h-4 w-4 mr-2" />
              )}
              ทดสอบการเชื่อมต่อ
            </button>

            <button
              onClick={runInitializeSampleData}
              disabled={isLoading}
              className="flex items-center px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 disabled:opacity-50"
            >
              {isLoading ? (
                <RefreshCw className="h-4 w-4 mr-2 animate-spin" />
              ) : (
                <Database className="h-4 w-4 mr-2" />
              )}
              เริ่มต้นข้อมูลตัวอย่าง
            </button>
          </div>

          {/* Connection Results */}
          {connectionStatus && (
            <div className={`p-4 rounded-lg border ${
              connectionStatus.success 
                ? 'bg-green-50 border-green-200' 
                : 'bg-red-50 border-red-200'
            }`}>
              <div className="flex items-center mb-2">
                {connectionStatus.success ? (
                  <CheckCircle className="h-5 w-5 text-green-500 mr-2" />
                ) : (
                  <XCircle className="h-5 w-5 text-red-500 mr-2" />
                )}
                <h3 className={`font-medium ${
                  connectionStatus.success ? 'text-green-800' : 'text-red-800'
                }`}>
                  {connectionStatus.success ? 'เชื่อมต่อสำเร็จ!' : 'เชื่อมต่อไม่สำเร็จ'}
                </h3>
              </div>

              {connectionStatus.success && connectionStatus.data && (
                <div className="text-green-700 text-sm space-y-1">
                  <p>📦 จำนวนสินค้า: {connectionStatus.data.products}</p>
                  <p>🏷️ จำนวนหมวดหมู่: {connectionStatus.data.categories}</p>
                  {connectionStatus.data.sampleProducts && connectionStatus.data.sampleProducts.length > 0 && (
                    <div className="mt-2">
                      <p className="font-medium">สินค้าตัวอย่าง:</p>
                      <ul className="list-disc list-inside ml-4">
                        {connectionStatus.data.sampleProducts.map((product: any) => (
                          <li key={product.id}>{product.name}</li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              )}

              {!connectionStatus.success && (
                <div className="text-red-700 text-sm">
                  <p><strong>Error:</strong> {connectionStatus.error}</p>
                  {connectionStatus.details && (
                    <p><strong>Details:</strong> {connectionStatus.details}</p>
                  )}
                </div>
              )}
            </div>
          )}
        </div>

        {/* Instructions */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-6">
          <h3 className="font-medium text-blue-900 mb-3">📋 วิธีตั้งค่า Supabase:</h3>
          <ol className="list-decimal list-inside text-blue-800 text-sm space-y-2">
            <li>ไปที่ <a href="https://supabase.com" target="_blank" rel="noopener noreferrer" className="underline">supabase.com</a> และสร้างโปรเจคใหม่</li>
            <li>ไปที่ SQL Editor และรันโค้ดจากไฟล์ <code className="bg-blue-100 px-1 rounded">database/schema.sql</code></li>
            <li>ไปที่ Settings &gt; API และคัดลอก Project URL และ API Keys</li>
            <li>อัปเดตไฟล์ <code className="bg-blue-100 px-1 rounded">.env.local</code> ด้วยค่าที่ถูกต้อง</li>
            <li>Restart development server (<code className="bg-blue-100 px-1 rounded">npm run dev</code>)</li>
            <li>กลับมาทดสอบการเชื่อมต่ออีกครั้ง</li>
          </ol>
        </div>
      </div>
    </div>
  )
}
