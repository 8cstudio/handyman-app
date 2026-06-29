-- Break infinite RLS recursion between customers <-> bookings policies.
-- SECURITY DEFINER helpers read underlying rows without re-entering RLS.

CREATE OR REPLACE FUNCTION is_my_customer_id(p_customer_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM customers
    WHERE id = p_customer_id AND user_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION company_admin_can_view_customer(p_customer_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM bookings b
    WHERE b.customer_id = p_customer_id
      AND b.company_id = get_user_company_id()
  );
$$;

CREATE OR REPLACE FUNCTION is_booking_customer(p_booking_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM bookings b
    JOIN customers c ON c.id = b.customer_id
    WHERE b.id = p_booking_id AND c.user_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION is_booking_provider(p_booking_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM bookings b
    JOIN providers p ON p.id = b.provider_id
    WHERE b.id = p_booking_id AND p.user_id = auth.uid()
  );
$$;

CREATE OR REPLACE FUNCTION can_access_booking(p_booking_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT
    is_super_admin()
    OR (
      is_company_admin()
      AND EXISTS (
        SELECT 1 FROM bookings b
        WHERE b.id = p_booking_id AND b.company_id = get_user_company_id()
      )
    )
    OR is_booking_customer(p_booking_id)
    OR is_booking_provider(p_booking_id);
$$;

CREATE OR REPLACE FUNCTION can_access_chat_room(p_chat_room_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM chat_rooms cr
    WHERE cr.id = p_chat_room_id
      AND can_access_booking(cr.booking_id)
  );
$$;

DROP POLICY IF EXISTS "customers_select" ON customers;
CREATE POLICY "customers_select" ON customers
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR user_id = auth.uid()
    OR (is_company_admin() AND company_admin_can_view_customer(id))
  );

DROP POLICY IF EXISTS "bookings_select" ON bookings;
CREATE POLICY "bookings_select" ON bookings
  FOR SELECT TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR is_booking_customer(id)
    OR is_booking_provider(id)
  );

DROP POLICY IF EXISTS "bookings_insert" ON bookings;
CREATE POLICY "bookings_insert" ON bookings
  FOR INSERT TO authenticated WITH CHECK (is_my_customer_id(customer_id));

DROP POLICY IF EXISTS "bookings_update" ON bookings;
CREATE POLICY "bookings_update" ON bookings
  FOR UPDATE TO authenticated USING (
    is_super_admin()
    OR (is_company_admin() AND company_id = get_user_company_id())
    OR is_booking_provider(id)
    OR is_booking_customer(id)
  );

DROP POLICY IF EXISTS "booking_status_history_select" ON booking_status_history;
CREATE POLICY "booking_status_history_select" ON booking_status_history
  FOR SELECT TO authenticated USING (can_access_booking(booking_id));

DROP POLICY IF EXISTS "chat_rooms_select" ON chat_rooms;
CREATE POLICY "chat_rooms_select" ON chat_rooms
  FOR SELECT TO authenticated USING (can_access_booking(booking_id));

DROP POLICY IF EXISTS "messages_select" ON messages;
CREATE POLICY "messages_select" ON messages
  FOR SELECT TO authenticated USING (can_access_chat_room(chat_room_id));

DROP POLICY IF EXISTS "messages_update" ON messages;
CREATE POLICY "messages_update" ON messages
  FOR UPDATE TO authenticated USING (
    sender_id = auth.uid()
    OR can_access_chat_room(chat_room_id)
  );

DROP POLICY IF EXISTS "reviews_insert" ON reviews;
CREATE POLICY "reviews_insert" ON reviews
  FOR INSERT TO authenticated WITH CHECK (is_my_customer_id(customer_id));
