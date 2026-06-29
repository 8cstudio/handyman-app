const AUTH_MESSAGES: Record<string, string> = {
  "Invalid login credentials":
    "Email or password is incorrect. Please check your details and try again.",
  "Email not confirmed":
    "Your email is not confirmed yet. Check your inbox or ask an admin to confirm your account.",
  "User already registered":
    "An account with this email already exists.",
  "Password should be at least 6 characters":
    "Password must be at least 6 characters long.",
  "Unable to validate email address: invalid format":
    "Please enter a valid email address.",
  "Signup requires a valid password":
    "Please enter a valid password.",
};

const API_MESSAGES: Record<string, string> = {
  "Missing authorization header":
    "Your session expired. Please sign in again.",
  Unauthorized: "Your session expired. Please sign in again.",
  Forbidden: "You don't have permission to perform this action.",
  "Not found": "The requested item could not be found.",
};

export function formatAuthError(raw: string): string {
  const trimmed = raw.trim();
  if (AUTH_MESSAGES[trimmed]) return AUTH_MESSAGES[trimmed];

  if (trimmed.includes("Invalid login credentials")) {
    return AUTH_MESSAGES["Invalid login credentials"];
  }

  if (trimmed.includes("Email not confirmed")) {
    return AUTH_MESSAGES["Email not confirmed"];
  }

  return trimmed || "Sign-in failed. Please try again.";
}

export function formatApiError(raw: string): string {
  const trimmed = raw.trim();
  if (API_MESSAGES[trimmed]) return API_MESSAGES[trimmed];

  if (trimmed.includes("JWT expired") || trimmed.includes("invalid JWT")) {
    return "Your session expired. Please sign in again.";
  }

  if (trimmed.includes("Failed to fetch") || trimmed.includes("NetworkError")) {
    return "Can't reach the server. Check your internet connection and try again.";
  }

  if (trimmed.includes("Edge Function returned a non-2xx status code")) {
    return "The server could not complete this request. You may need to sign in again or check your permissions.";
  }

  if (trimmed.startsWith("PGRST") || trimmed.includes("JSON object requested")) {
    return "We couldn't find the data needed for this action. It may have been removed.";
  }

  return trimmed || "Something went wrong. Please try again.";
}

export function formatProfileError(raw: string): string {
  if (raw.includes("JSON object requested") || raw.includes("0 rows")) {
    return (
      "Your account signed in, but no admin profile was found. " +
      "Ask a Super Admin to create your profile in Supabase."
    );
  }

  return formatApiError(raw);
}

export function formatRoleError(role: string | null | undefined): string {
  if (!role) {
    return "Your account has no role assigned. Contact a Super Admin for access.";
  }

  return (
    `Your account role is "${role}", which cannot access this admin panel. ` +
    "Only Super Admin and Company Admin accounts can sign in here."
  );
}
