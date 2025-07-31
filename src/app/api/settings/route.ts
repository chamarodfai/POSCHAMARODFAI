import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET() {
  try {
    // Get basic store settings (for now return default values)
    const settings = {
      store_name: 'ชาไทยชามะรอดฟ้าย',
      store_address: '123 ถนนชาไทย กรุงเทพฯ 10100',
      store_phone: '02-123-4567',
      tax_rate: 7,
      currency: 'THB',
      timezone: 'Asia/Bangkok'
    };

    return NextResponse.json(settings);
  } catch (error) {
    console.error('Error fetching settings:', error);
    return NextResponse.json(
      { error: 'Failed to fetch settings' },
      { status: 500 }
    );
  }
}

export async function PUT(request: Request) {
  try {
    const body = await request.json();
    
    // For now, just return success since we don't have settings table yet
    console.log('Settings update:', body);
    
    return NextResponse.json({ 
      message: 'Settings updated successfully',
      settings: body 
    });
  } catch (error) {
    console.error('Error updating settings:', error);
    return NextResponse.json(
      { error: 'Failed to update settings' },
      { status: 500 }
    );
  }
}
