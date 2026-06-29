import type { ThemeConfig } from "../types";

export const CUSTOM_THEME_PRESET_ID = "custom" as const;
export const DEFAULT_THEME_PRESET_ID = "blue" as const;

export type ThemePresetId = typeof DEFAULT_THEME_PRESET_ID | typeof CUSTOM_THEME_PRESET_ID | string;

export interface ThemePresetOption {
  id: string;
  label: string;
  description: string;
  swatches: [string, string, string];
  config: Omit<ThemeConfig, "preset_id">;
}

function createPreset(
  primary: string,
  secondary: string,
  lightBg: string,
  lightSurface: string,
  darkBg: string,
  darkSurface: string
): Omit<ThemeConfig, "preset_id"> {
  return {
    primary,
    secondary,
    light: {
      scaffoldBackground: lightBg,
      surface: lightSurface,
      textPrimary: "#0F172A",
      textSecondary: secondary,
      error: "#EF4444",
      success: "#22C55E",
      drawerBackground: lightSurface,
    },
    dark: {
      scaffoldBackground: darkBg,
      surface: darkSurface,
      textPrimary: "#F8FAFC",
      textSecondary: "#94A3B8",
      error: "#F87171",
      success: "#4ADE80",
      drawerBackground: darkSurface,
    },
  };
}

export const THEME_PRESET_OPTIONS: ThemePresetOption[] = [
  {
    id: "blue",
    label: "Blue",
    description: "Clean professional blue",
    swatches: ["#2563EB", "#64748B", "#F8FAFC"],
    config: createPreset("#2563EB", "#64748B", "#F8FAFC", "#FFFFFF", "#0F172A", "#1E293B"),
  },
  {
    id: "violet",
    label: "Violet",
    description: "Bold violet accent",
    swatches: ["#7C3AED", "#8B5CF6", "#FAF5FF"],
    config: createPreset("#7C3AED", "#8B5CF6", "#FAF5FF", "#FFFFFF", "#1E1033", "#2E1065"),
  },
  {
    id: "ocean",
    label: "Ocean",
    description: "Calm teal and cyan",
    swatches: ["#0891B2", "#06B6D4", "#ECFEFF"],
    config: createPreset("#0891B2", "#06B6D4", "#ECFEFF", "#FFFFFF", "#042F2E", "#134E4A"),
  },
  {
    id: "forest",
    label: "Forest",
    description: "Natural green tones",
    swatches: ["#059669", "#10B981", "#ECFDF5"],
    config: createPreset("#059669", "#10B981", "#ECFDF5", "#FFFFFF", "#052E16", "#14532D"),
  },
  {
    id: "sunset",
    label: "Sunset",
    description: "Warm orange glow",
    swatches: ["#EA580C", "#F97316", "#FFF7ED"],
    config: createPreset("#EA580C", "#F97316", "#FFF7ED", "#FFFFFF", "#431407", "#7C2D12"),
  },
  {
    id: "rose",
    label: "Rose",
    description: "Soft pink palette",
    swatches: ["#E11D48", "#FB7185", "#FFF1F2"],
    config: createPreset("#E11D48", "#FB7185", "#FFF1F2", "#FFFFFF", "#4C0519", "#881337"),
  },
  {
    id: "coral",
    label: "Coral",
    description: "Vibrant coral red",
    swatches: ["#F43F5E", "#FB923C", "#FFF1F2"],
    config: createPreset("#F43F5E", "#FB923C", "#FFF1F2", "#FFFFFF", "#4C0519", "#881337"),
  },
  {
    id: "indigo",
    label: "Indigo",
    description: "Deep indigo contrast",
    swatches: ["#4F46E5", "#6366F1", "#EEF2FF"],
    config: createPreset("#4F46E5", "#6366F1", "#EEF2FF", "#FFFFFF", "#1E1B4B", "#312E81"),
  },
  {
    id: "teal",
    label: "Teal",
    description: "Modern teal accent",
    swatches: ["#0D9488", "#14B8A6", "#F0FDFA"],
    config: createPreset("#0D9488", "#14B8A6", "#F0FDFA", "#FFFFFF", "#042F2E", "#134E4A"),
  },
  {
    id: "crimson",
    label: "Crimson",
    description: "Strong crimson red",
    swatches: ["#DC2626", "#EF4444", "#FEF2F2"],
    config: createPreset("#DC2626", "#EF4444", "#FEF2F2", "#FFFFFF", "#450A0A", "#7F1D1D"),
  },
  {
    id: "gold",
    label: "Gold",
    description: "Rich amber gold",
    swatches: ["#D97706", "#F59E0B", "#FFFBEB"],
    config: createPreset("#D97706", "#F59E0B", "#FFFBEB", "#FFFFFF", "#451A03", "#78350F"),
  },
];

export const THEME_PRESET_IDS = THEME_PRESET_OPTIONS.map((option) => option.id);

export function isThemePresetId(id: string): id is string {
  return THEME_PRESET_IDS.includes(id);
}

export function getThemePresetById(id: string): ThemePresetOption | undefined {
  return THEME_PRESET_OPTIONS.find((option) => option.id === id);
}

export function applyPresetId(config: ThemeConfig, presetId: string): ThemeConfig {
  return { ...config, preset_id: presetId };
}

export function configFromPreset(presetId: string): ThemeConfig {
  const preset = getThemePresetById(presetId);
  if (!preset) {
    return applyPresetId(
      THEME_PRESET_OPTIONS[0].config as ThemeConfig,
      DEFAULT_THEME_PRESET_ID
    );
  }
  return applyPresetId(preset.config as ThemeConfig, presetId);
}

export function resolvePresetId(config: ThemeConfig): string {
  if (config.preset_id) return config.preset_id;

  for (const preset of THEME_PRESET_OPTIONS) {
    if (preset.config.primary === config.primary && preset.config.secondary === config.secondary) {
      return preset.id;
    }
  }

  return CUSTOM_THEME_PRESET_ID;
}
