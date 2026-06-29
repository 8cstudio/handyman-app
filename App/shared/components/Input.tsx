import type { InputHTMLAttributes } from "react";

export type InputProps = InputHTMLAttributes<HTMLInputElement> & {
  label?: string;
  error?: string;
};

export function Input({ label, error, className = "", ...props }: InputProps) {
  return (
    <div className="space-y-1">
      {label && (
        <label className="block text-sm font-medium text-[var(--color-text)]">
          {label}
        </label>
      )}
      <input className={`glass-input ${className}`} {...props} />
      {error && <p className="text-sm text-[var(--color-error)]">{error}</p>}
    </div>
  );
}
