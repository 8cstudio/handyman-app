-- Seed data for local development
-- Note: Super admin user must be created via auth-register edge function or Supabase dashboard
-- Demo company for testing

INSERT INTO companies (id, name, description, email, phone, address, is_active)
VALUES (
  'a0000000-0000-4000-8000-000000000001',
  'Demo Handyman Co',
  'Demo company for development and testing',
  'demo@handyman.local',
  '+1234567890',
  '123 Main St, Demo City',
  true
) ON CONFLICT DO NOTHING;

INSERT INTO categories (id, company_id, name, description, sort_order)
VALUES
  ('b0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'Plumbing', 'Plumbing services', 1),
  ('b0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'Electrical', 'Electrical services', 2),
  ('b0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'Carpentry', 'Carpentry services', 3)
ON CONFLICT DO NOTHING;

INSERT INTO services (id, company_id, category_id, name, description, price, duration_minutes)
VALUES
  ('c0000000-0000-4000-8000-000000000001', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Pipe Repair', 'Fix leaking or broken pipes', 75.00, 60),
  ('c0000000-0000-4000-8000-000000000002', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000001', 'Drain Cleaning', 'Clear clogged drains', 50.00, 45),
  ('c0000000-0000-4000-8000-000000000003', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000002', 'Outlet Installation', 'Install new electrical outlets', 85.00, 90),
  ('c0000000-0000-4000-8000-000000000004', 'a0000000-0000-4000-8000-000000000001', 'b0000000-0000-4000-8000-000000000003', 'Door Repair', 'Fix or adjust doors', 65.00, 60)
ON CONFLICT DO NOTHING;
