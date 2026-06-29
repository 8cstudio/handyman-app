"use client";

import { createContext, useContext, useEffect, useState, useCallback, ReactNode } from "react";
import { createClient } from "../lib/supabase/client";
import {
  fetchPlatformSettings,
  PLATFORM_SETTINGS_UPDATED_EVENT,
} from "../lib/platform-settings";
import type { PlatformSettings, ThemeConfig } from "../types";
import { DEFAULT_THEME_CONFIG } from "../types";

interface ThemeContextValue {
  themeConfig: ThemeConfig;
  platformName: string;
  isDark: boolean;
  setIsDark: (dark: boolean) => void;
  refreshTheme: () => Promise<void>;
}

const ThemeContext = createContext<ThemeContextValue>({
  themeConfig: DEFAULT_THEME_CONFIG,
  platformName: "Handyman SaaS",
  isDark: false,
  setIsDark: () => {},
  refreshTheme: async () => {},
});

function applyThemeVariables(themeConfig: ThemeConfig, isDark: boolean) {
  const colors = isDark ? themeConfig.dark : themeConfig.light;
  const root = document.documentElement;

  root.style.setProperty("--color-primary", themeConfig.primary);
  root.style.setProperty("--color-secondary", themeConfig.secondary);
  root.style.setProperty("--color-bg", colors.scaffoldBackground);
  root.style.setProperty("--color-surface", colors.surface);
  root.style.setProperty("--color-text", colors.textPrimary);
  root.style.setProperty("--color-text-secondary", colors.textSecondary);
  root.style.setProperty("--color-error", colors.error);
  root.style.setProperty("--color-success", colors.success);
}

function applySettings(settings: PlatformSettings) {
  return {
    themeConfig: settings.theme_config ?? DEFAULT_THEME_CONFIG,
    platformName: settings.platform_name ?? "Handyman SaaS",
  };
}

export function ThemeProvider({ children }: { children: ReactNode }) {
  const [themeConfig, setThemeConfig] = useState<ThemeConfig>(DEFAULT_THEME_CONFIG);
  const [platformName, setPlatformName] = useState("Handyman SaaS");
  const [isDark, setIsDark] = useState(false);

  const refreshTheme = useCallback(async () => {
    const settings = await fetchPlatformSettings();
    if (!settings) return;

    const next = applySettings(settings);
    setThemeConfig(next.themeConfig);
    setPlatformName(next.platformName);
  }, []);

  useEffect(() => {
    applyThemeVariables(themeConfig, isDark);
  }, [themeConfig, isDark]);

  useEffect(() => {
    const saved = localStorage.getItem("theme-mode");
    if (saved === "dark") setIsDark(true);

    void refreshTheme();

    const onSettingsUpdated = () => {
      void refreshTheme();
    };
    window.addEventListener(PLATFORM_SETTINGS_UPDATED_EVENT, onSettingsUpdated);

    const supabase = createClient();
    const channel = supabase
      .channel("platform_settings")
      .on(
        "postgres_changes",
        { event: "UPDATE", schema: "public", table: "platform_settings" },
        (payload) => {
          const settings = payload.new as PlatformSettings;
          const next = applySettings(settings);
          setThemeConfig(next.themeConfig);
          setPlatformName(next.platformName);
        }
      )
      .subscribe();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(() => {
      void refreshTheme();
    });

    return () => {
      window.removeEventListener(PLATFORM_SETTINGS_UPDATED_EVENT, onSettingsUpdated);
      supabase.removeChannel(channel);
      subscription.unsubscribe();
    };
  }, [refreshTheme]);

  return (
    <ThemeContext.Provider
      value={{ themeConfig, platformName, isDark, setIsDark, refreshTheme }}
    >
      <div className={isDark ? "dark" : ""}>{children}</div>
    </ThemeContext.Provider>
  );
}

export function useTheme() {
  return useContext(ThemeContext);
}
