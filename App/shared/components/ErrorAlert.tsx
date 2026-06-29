interface ErrorAlertProps {
  message: string;
  detail?: string;
  onDismiss?: () => void;
  className?: string;
}

export function ErrorAlert({
  message,
  detail,
  onDismiss,
  className = "",
}: ErrorAlertProps) {
  return (
    <div
      role="alert"
      className={`glass-panel rounded-xl border-red-300/40 bg-red-500/10 p-4 text-red-800 dark:text-red-200 ${className}`}
    >
      <div className="flex items-start justify-between gap-3">
        <div>
          <p className="text-sm font-semibold">Something went wrong</p>
          <p className="mt-1 text-sm">{message}</p>
          {detail && process.env.NODE_ENV === "development" && (
            <p className="mt-2 text-xs opacity-80">Technical detail: {detail}</p>
          )}
        </div>
        {onDismiss && (
          <button
            type="button"
            onClick={onDismiss}
            className="shrink-0 rounded-lg px-2 py-1 text-xs font-medium hover:bg-red-500/10"
            aria-label="Dismiss error"
          >
            Dismiss
          </button>
        )}
      </div>
    </div>
  );
}
