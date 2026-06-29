"use client";

import type { ThemeConfig } from "../types";
import {
  CUSTOM_THEME_PRESET_ID,
  THEME_PRESET_OPTIONS,
  configFromPreset,
  applyPresetId,
} from "../constants/theme-presets";

interface ThemePresetPickerProps {
  selectedPresetId: string;
  themeConfig: ThemeConfig;
  onSelectPreset: (presetId: string, config: ThemeConfig) => void;
}

export function ThemePresetPicker({
  selectedPresetId,
  themeConfig,
  onSelectPreset,
}: ThemePresetPickerProps) {
  return (
    <div className="space-y-4">
      <div>
        <h3 className="text-sm font-semibold text-[var(--color-text)]">Theme Presets</h3>
        <p className="text-sm text-[var(--color-text-secondary)]">
          Pick a preset to apply across admin and mobile apps instantly.
        </p>
      </div>

      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 lg:grid-cols-4">
        {THEME_PRESET_OPTIONS.map((preset) => {
          const isSelected = selectedPresetId === preset.id;
          return (
            <button
              key={preset.id}
              type="button"
              onClick={() => onSelectPreset(preset.id, configFromPreset(preset.id))}
              className={`rounded-xl border-2 p-3 text-left transition ${
                isSelected
                  ? "border-[var(--color-primary)] ring-2 ring-[var(--color-primary)]/20"
                  : "border-[var(--color-surface)] hover:border-[var(--color-primary)]/40"
              }`}
              style={{ backgroundColor: "var(--color-surface)" }}
            >
              <div className="mb-2 flex gap-1">
                {preset.swatches.map((color) => (
                  <span
                    key={color}
                    className="h-6 w-6 rounded-full border border-black/10"
                    style={{ backgroundColor: color }}
                  />
                ))}
              </div>
              <p className="text-sm font-medium text-[var(--color-text)]">{preset.label}</p>
              <p className="text-xs text-[var(--color-text-secondary)]">{preset.description}</p>
            </button>
          );
        })}

        <button
          type="button"
          onClick={() => onSelectPreset(CUSTOM_THEME_PRESET_ID, applyPresetId(themeConfig, CUSTOM_THEME_PRESET_ID))}
          className={`rounded-xl border-2 border-dashed p-3 text-left transition ${
            selectedPresetId === CUSTOM_THEME_PRESET_ID
              ? "border-[var(--color-primary)] ring-2 ring-[var(--color-primary)]/20"
              : "border-[var(--color-text-secondary)]/40 hover:border-[var(--color-primary)]/40"
          }`}
          style={{ backgroundColor: "var(--color-surface)" }}
        >
          <div className="mb-2 flex gap-1">
            {[themeConfig.primary, themeConfig.secondary, themeConfig.light.scaffoldBackground].map(
              (color, index) => (
                <span
                  key={`${color}-${index}`}
                  className="h-6 w-6 rounded-full border border-black/10"
                  style={{ backgroundColor: color }}
                />
              )
            )}
          </div>
          <p className="text-sm font-medium text-[var(--color-text)]">Custom</p>
          <p className="text-xs text-[var(--color-text-secondary)]">Define your own colors</p>
        </button>
      </div>
    </div>
  );
}
