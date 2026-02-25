import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS options
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const url = new URL(req.url)
    const pathParts = url.pathname.split('/')
    let orderId = pathParts[pathParts.length - 1]

    // Check if query param exists
    if (!orderId || orderId === 'order-view') {
      orderId = url.searchParams.get('id') || ''
    }

    if (!orderId) {
      return new Response(JSON.stringify({ error: 'Order ID is required' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      })
    }

    // Create a Supabase client with the Auth context of the function
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    const supabase = createClient(supabaseUrl, supabaseKey)

    // 1. Fetch bill
    const { data: bill, error: billError } = await supabase
      .from('bills')
      .select('*')
      .eq('id', orderId)
      .single()

    if (billError || !bill) {
      return new Response(JSON.stringify({ error: 'Order not found' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 404,
      })
    }

    // 2. Fetch shop profile
    const { data: shopProfile } = await supabase
      .from('shop_profiles')
      .select('*')
      .eq('user_id', bill.user_id)
      .maybeSingle()

    // 3. Fetch bill items
    const { data: items } = await supabase
      .from('bill_items')
      .select('*')
      .eq('bill_id', orderId)

    // Map to JSON structure expected by frontend
    const responseData = {
      shop: {
        name: shopProfile?.shop_name || "Shop / Business Details",
        address: shopProfile?.shop_address || "",
        phone: shopProfile?.shop_phone || "",
        gst: shopProfile?.shop_gst_number || ""
      },
      order: {
        id: bill.bill_number || orderId.substring(0, 8).toUpperCase(),
        dateISO: bill.bill_date || bill.created_at,
        subtotal: bill.subtotal || bill.total_amount,
        discount: bill.discount || 0,
        gstAmount: bill.gst_amount || 0,
        gstPercent: bill.gst_percent || 0,
        total: bill.total_amount,
        paid: bill.amount_paid || 0,
        balance: bill.amount_remaining || bill.total_amount,
        paymentStatus: bill.payment_status || "draft",
        invoiceType: bill.invoice_type || "order_summary"
      },
      customer: {
        name: bill.customer_name || "Walk-in customer",
        phone: bill.customer_phone || ""
      },
      items: (items || []).map((i: any) => ({
        name: i.name,
        qty: i.quantity,
        rate: i.unit_price,
        amount: i.total_price
      }))
    }

    return new Response(JSON.stringify(responseData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})
