"use client";

import { useEffect, useState } from "react";
import {
  invokeFunction,
  Button,
  Input,
  Card,
  ErrorAlert,
  ThemePresetPicker,
  DEFAULT_THEME_CONFIG,
  CUSTOM_THEME_PRESET_ID,
  resolvePresetId,
  applyPresetId,
  notifyPlatformSettingsUpdated,
  useTheme,
} from "@handyman/shared";
import type { PlatformSettings, ThemeConfig } from "@handyman/shared";

export default function ThemePage() {
  const { refreshTheme } = useTheme();
  const [platformName, setPlatformName] = useState("Handyman SaaS");
  const [themeConfig, setThemeConfig] = useState<ThemeConfig>(DEFAULT_THEME_CONFIG);
  const [selectedPresetId, setSelectedPresetId] = useState(DEFAULT_THEME_CONFIG.preset_id ?? "blue");
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState("");
  const [error, setError] = useState("");

  useEffect(() => {
    invokeFunction<{ settings: PlatformSettings }>("admin-platform-settings", { method: "GET" })
      .then((data) => {
        setPlatformName(data.settings.platform_name);
        const config = data.settings.theme_config;
        setThemeConfig(config);
        setSelectedPresetId(resolvePresetId(config));
      })
      .catch((err: Error) => setError(err.message));
  }, []);

  async function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaving(true);
    setMessage("");
    setError("");
    try {
      const payload: ThemeConfig = applyPresetId(themeConfig, selectedPresetId);
      await invokeFunction("admin-platform-settings", {
        method: "PUT",
        body: { platform_name: platformName, theme_config: payload },
      });
      setThemeConfig(payload);
      await refreshTheme();
      notifyPlatformSettingsUpdated();
      setMessage("Theme saved! Changes will apply to all apps.");
    } catch (err) {
      setError((err as Error).message);
    }
    setSaving(false);
  }

  function handleSelectPreset(presetId: string, config: ThemeConfig) {
    setSelectedPresetId(presetId);
    setThemeConfig(config);
  }

  function updateColor(path: string, value: string) {
    const parts = path.split(".");
    setThemeConfig((prev) => {
      const next = JSON.parse(JSON.stringify(prev)) as ThemeConfig;
      if (parts.length === 1) {
        (next as Record<string, unknown>)[parts[0]] = value;
      } else {
        (next[parts[0] as keyof ThemeConfig] as Record<string, string>)[parts[1]] = value;
      }
      return applyPresetId(next, CUSTOM_THEME_PRESET_ID);
    });
    setSelectedPresetId(CUSTOM_THEME_PRESET_ID);
  }

  const colorFields = [
    { label: "Primary", path: "primary" },
    { label: "Secondary", path: "secondary" },
    { label: "Light Background", path: "light.scaffoldBackground" },
    { label: "Light Surface", path: "light.surface" },
    { label: "Light Text", path: "light.textPrimary" },
    { label: "Dark Background", path: "dark.scaffoldBackground" },
    { label: "Dark Surface", path: "dark.surface" },
    { label: "Dark Text", path: "dark.textPrimary" },
  ];

  const isCustom = selectedPresetId === CUSTOM_THEME_PRESET_ID;

  return (
    <div>
      <h1 className="glass-page-title mb-6 text-[var(--color-text)]">Theme Settings</h1>
      <p className="mb-4 text-sm text-[var(--color-text-secondary)]">
        Choose a preset or build a custom theme. Changes apply to Company Admin and mobile apps.
      </p>

      <form onSubmit={handleSave} className="grid grid-cols-1 gap-6 lg:grid-cols-2">
        <Card title="Platform" className="lg:col-span-2">
          <Input
            label="Platform Name"
            value={platformName}
            onChange={(e) => setPlatformName(e.target.value)}
          />
        </Card>

        <Card title="Theme Presets" className="lg:col-span-2">
          <ThemePresetPicker
            selectedPresetId={selectedPresetId}
            themeConfig={themeConfig}
            onSelectPreset={handleSelectPreset}
          />
        </Card>

        <Card title="Preview">
          <div
            className="rounded-lg p-4"
            style={{ backgroundColor: themeConfig.light.scaffoldBackground }}
          >
            <div
              className="rounded-lg p-4"
              style={{ backgroundColor: themeConfig.light.surface }}
            >
              <p style={{ color: themeConfig.light.textPrimary }} className="font-bold">
                {platformName}
              </p>
              <button
                type="button"
                className="mt-2 rounded-lg px-4 py-2 text-white"
                style={{ backgroundColor: themeConfig.primary }}
              >
                Sample Button
              </button>
            </div>
          </div>
        </Card>

        <Card title="Dark Preview">
          <div
            className="rounded-lg p-4"
            style={{ backgroundColor: themeConfig.dark.scaffoldBackground }}
          >
            <div
              className="rounded-lg p-4"
              style={{ backgroundColor: themeConfig.dark.surface }}
            >
              <p style={{ color: themeConfig.dark.textPrimary }} className="font-bold">
                {platformName}
              </p>
              <button
                type="button"
                className="mt-2 rounded-lg px-4 py-2 text-white"
                style={{ backgroundColor: themeConfig.primary }}
              >
                Sample Button
              </button>
            </div>
          </div>
        </Card>

        {isCustom && (
          <Card title="Custom Colors" className="lg:col-span-2">
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-4">
              {colorFields.map((field) => {
                const parts = field.path.split(".");
                const value = parts.length === 1
                  ? (themeConfig as Record<string, string>)[parts[0]]
                  : (themeConfig[parts[0] as keyof ThemeConfig] as Record<string, string>)[parts[1]];

                return (
                  <div key={field.path} className="space-y-1">
                    <label className="text-sm font-medium">{field.label}</label>
                    <div className="flex items-center gap-2">
                      <input
                        type="color"
                        value={value}
                        onChange={(e) => updateColor(field.path, e.target.value)}
                        className="h-10 w-10 cursor-pointer rounded border"
                      />
                      <input
                        type="text"
                        value={value}
                        onChange={(e) => updateColor(field.path, e.target.value)}
                        className="flex-1 rounded border px-2 py-1 text-sm"
                      />
                    </div>
                  </div>
                );
              })}
            </div>
          </Card>
        )}

        <div className="lg:col-span-2">
          <Button type="submit" disabled={saving}>
            {saving ? "Saving..." : "Save Theme"}
          </Button>
          {error && (
            <div className="mt-4">
              <ErrorAlert message={error} onDismiss={() => setError("")} />
            </div>
          )}
          {message && <p className="mt-2 text-sm text-green-600">{message}</p>}
        </div>
      </form>
    </div>
  );
}
