import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET() {
  try {
    // For now return empty array since we don't have customers table yet
    // In future, we can implement customer management
    const customers: any[] = [];

    return NextResponse.json(customers);
  } catch (error) {
    console.error('Error fetching customers:', error);
    return NextResponse.json(
      { error: 'Failed to fetch customers' },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    
    // For now, just return success response
    // In future, we can implement customer creation
    const newCustomer = {
      id: Date.now(),
      name: body.name,
      phone: body.phone,
      email: body.email,
      created_at: new Date().toISOString()
    };
    
    return NextResponse.json(newCustomer, { status: 201 });
  } catch (error) {
    console.error('Error creating customer:', error);
    return NextResponse.json(
      { error: 'Failed to create customer' },
      { status: 500 }
    );
  }
}
