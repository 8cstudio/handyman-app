-- Platform name and theme are public branding — readable without login
CREATE POLICY "platform_settings_select_anon" ON platform_settings
  FOR SELECT TO anon USING (true);
