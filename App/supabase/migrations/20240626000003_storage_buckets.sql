-- Storage buckets

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('company-logos', 'company-logos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('provider-documents', 'provider-documents', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']),
  ('profile-avatars', 'profile-avatars', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('service-images', 'service-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('chat-attachments', 'chat-attachments', false, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Storage policies
CREATE POLICY "company_logos_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'company-logos');

CREATE POLICY "company_logos_upload" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'company-logos'
    AND (is_super_admin() OR is_company_admin())
  );

CREATE POLICY "profile_avatars_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-avatars');

CREATE POLICY "profile_avatars_upload" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'profile-avatars'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "service_images_public_read" ON storage.objects
  FOR SELECT USING (bucket_id = 'service-images');

CREATE POLICY "service_images_upload" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'service-images'
    AND (is_super_admin() OR is_company_admin())
  );

CREATE POLICY "provider_documents_read" ON storage.objects
  FOR SELECT TO authenticated USING (
    bucket_id = 'provider-documents'
    AND (
      is_super_admin()
      OR is_company_admin()
      OR (storage.foldername(name))[1] = auth.uid()::text
    )
  );

CREATE POLICY "provider_documents_upload" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (
    bucket_id = 'provider-documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
  );

CREATE POLICY "chat_attachments_read" ON storage.objects
  FOR SELECT TO authenticated USING (bucket_id = 'chat-attachments');

CREATE POLICY "chat_attachments_upload" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id = 'chat-attachments');
