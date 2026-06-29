-- Row Level Security Policies

ALTER TABLE platform_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE company_admins ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE providers ENABLE ROW LEVEL SECURITY;
ALTER TABLE provider_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Platform settings: everyone can read, super admin can update
CREATE POLICY "platform_settings_select" ON platform_settings
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "platform_settings_update" ON platform_settings
  FOR UPDATE TO authenticated USING (is_super_admin());

-- Companies
CREATE POLICY "companies_select" ON companies
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND id = get_user_company_id())
    OR (get_user_role() IN ('provider', 'customer') AND is_active = true)
  );

CREATE POLICY "companies_insert" ON companies
  FOR INSERT TO authenticated WITH CHECK (is_super_admin());

CREATE POLICY "companies_update" ON companies
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND id = get_user_company_id())
  );

-- Profiles
CREATE POLICY "profiles_select" ON profiles
  FOR SELECT TO authenticated USING (
    id = auth.uid()
    OR is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

CREATE POLICY "profiles_update" ON profiles
  FOR UPDATE TO authenticated USING (
    id = auth.uid()
    OR is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

CREATE POLICY "profiles_insert" ON profiles
  FOR INSERT TO authenticated WITH CHECK (id = auth.uid());

-- Company admins
CREATE POLICY "company_admins_select" ON company_admins
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

-- Categories: customers/providers read active; company admin CRUD
CREATE POLICY "categories_select" ON categories
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR (get_user_role() IN ('customer', 'provider') AND is_active = true)
  );

CREATE POLICY "categories_insert" ON categories
  FOR INSERT TO authenticated WITH CHECK (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

CREATE POLICY "categories_update" ON categories
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

CREATE POLICY "categories_delete" ON categories
  FOR DELETE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

-- Services
CREATE POLICY "services_select" ON services
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR (get_user_role() IN ('customer', 'provider') AND is_active = true)
  );

CREATE POLICY "services_insert" ON services
  FOR INSERT TO authenticated WITH CHECK (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

CREATE POLICY "services_update" ON services
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

CREATE POLICY "services_delete" ON services
  FOR DELETE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
  );

-- Providers
CREATE POLICY "providers_select" ON providers
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR user_id = auth.uid()
  );

CREATE POLICY "providers_insert" ON providers
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "providers_update" ON providers
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR user_id = auth.uid()
  );

-- Provider documents
CREATE POLICY "provider_documents_select" ON provider_documents
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM providers p
      WHERE p.id = provider_documents.provider_id
      AND (p.user_id = auth.uid() OR (is_company_admin() AND p.company_id = get_user_company_id()))
    )
  );

CREATE POLICY "provider_documents_insert" ON provider_documents
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (
      SELECT 1 FROM providers p
      WHERE p.id = provider_documents.provider_id AND p.user_id = auth.uid()
    )
  );

CREATE POLICY "provider_documents_update" ON provider_documents
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR EXISTS (
      SELECT 1 FROM providers p
      WHERE p.id = provider_documents.provider_id
      AND is_company_admin() AND p.company_id = get_user_company_id()
    )
  );

-- Customers
CREATE POLICY "customers_select" ON customers
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR user_id = auth.uid()
    OR (is_company_admin() AND EXISTS (
      SELECT 1 FROM bookings b WHERE b.customer_id = customers.id AND b.company_id = get_user_company_id()
    ))
  );

CREATE POLICY "customers_insert" ON customers
  FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());

CREATE POLICY "customers_update" ON customers
  FOR UPDATE TO authenticated USING (user_id = auth.uid());

-- Bookings
CREATE POLICY "bookings_select" ON bookings
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR EXISTS (SELECT 1 FROM customers c WHERE c.id = bookings.customer_id AND c.user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM providers p WHERE p.id = bookings.provider_id AND p.user_id = auth.uid())
  );

CREATE POLICY "bookings_insert" ON bookings
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM customers c WHERE c.id = bookings.customer_id AND c.user_id = auth.uid())
  );

CREATE POLICY "bookings_update" ON bookings
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR EXISTS (SELECT 1 FROM providers p WHERE p.id = bookings.provider_id AND p.user_id = auth.uid())
    OR EXISTS (SELECT 1 FROM customers c WHERE c.id = bookings.customer_id AND c.user_id = auth.uid())
  );

-- Booking status history
CREATE POLICY "booking_status_history_select" ON booking_status_history
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM bookings b WHERE b.id = booking_status_history.booking_id
      AND (
        is_super_admin()
        OR (is_company_admin() AND b.company_id = get_user_company_id())
        OR EXISTS (SELECT 1 FROM customers c WHERE c.id = b.customer_id AND c.user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM providers p WHERE p.id = b.provider_id AND p.user_id = auth.uid())
      )
    )
  );

CREATE POLICY "booking_status_history_insert" ON booking_status_history
  FOR INSERT TO authenticated WITH CHECK (true);

-- Chat rooms
CREATE POLICY "chat_rooms_select" ON chat_rooms
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM bookings b WHERE b.id = chat_rooms.booking_id
      AND (
        is_super_admin()
        OR (is_company_admin() AND b.company_id = get_user_company_id())
        OR EXISTS (SELECT 1 FROM customers c WHERE c.id = b.customer_id AND c.user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM providers p WHERE p.id = b.provider_id AND p.user_id = auth.uid())
      )
    )
  );

CREATE POLICY "chat_rooms_insert" ON chat_rooms
  FOR INSERT TO authenticated WITH CHECK (true);

-- Messages
CREATE POLICY "messages_select" ON messages
  FOR SELECT TO authenticated USING (
    EXISTS (
      SELECT 1 FROM chat_rooms cr
      JOIN bookings b ON b.id = cr.booking_id
      WHERE cr.id = messages.chat_room_id
      AND (
        is_super_admin()
        OR (is_company_admin() AND b.company_id = get_user_company_id())
        OR EXISTS (SELECT 1 FROM customers c WHERE c.id = b.customer_id AND c.user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM providers p WHERE p.id = b.provider_id AND p.user_id = auth.uid())
      )
    )
  );

CREATE POLICY "messages_insert" ON messages
  FOR INSERT TO authenticated WITH CHECK (sender_id = auth.uid());

CREATE POLICY "messages_update" ON messages
  FOR UPDATE TO authenticated USING (
    EXISTS (
      SELECT 1 FROM chat_rooms cr
      JOIN bookings b ON b.id = cr.booking_id
      WHERE cr.id = messages.chat_room_id
      AND (
        sender_id = auth.uid()
        OR EXISTS (SELECT 1 FROM customers c WHERE c.id = b.customer_id AND c.user_id = auth.uid())
        OR EXISTS (SELECT 1 FROM providers p WHERE p.id = b.provider_id AND p.user_id = auth.uid())
      )
    )
  );

-- Reviews
CREATE POLICY "reviews_select" ON reviews
  FOR SELECT TO authenticated USING (true);

CREATE POLICY "reviews_insert" ON reviews
  FOR INSERT TO authenticated WITH CHECK (
    EXISTS (SELECT 1 FROM customers c WHERE c.id = reviews.customer_id AND c.user_id = auth.uid())
  );

-- Enable realtime for messages and platform_settings
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE platform_settings;
ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
