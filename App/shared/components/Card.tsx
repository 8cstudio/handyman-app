import { ReactNode } from "react";

interface CardProps {
  title?: string;
  children: ReactNode;
  className?: string;
}

export function Card({ title, children, className = "" }: CardProps) {
  return (
    <div className={`glass-card ${className}`}>
      {title && (
        <h3 className="mb-4 text-lg font-semibold text-[var(--color-text)]">{title}</h3>
      )}
      {children}
    </div>
  );
}
