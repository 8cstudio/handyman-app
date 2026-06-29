export type UserRole = "super_admin" | "company_admin" | "provider" | "customer";

export type BookingStatus =
  | "pending"
  | "assigned"
  | "accepted"
  | "rejected"
  | "in_progress"
  | "completed"
  | "cancelled";

export type ProviderStatus = "pending" | "approved" | "rejected" | "suspended";

export interface ThemeColors {
  scaffoldBackground: string;
  surface: string;
  textPrimary: string;
  textSecondary: string;
  error: string;
  success: string;
  drawerBackground: string;
}

export interface ThemeConfig {
  preset_id?: string;
  primary: string;
  secondary: string;
  light: ThemeColors;
  dark: ThemeColors;
}

export interface PlatformSettings {
  id: string;
  platform_name: string;
  theme_config: ThemeConfig;
  updated_at: string;
  updated_by?: string;
}

export interface Company {
  id: string;
  name: string;
  description?: string;
  email?: string;
  phone?: string;
  address?: string;
  logo_url?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface Profile {
  id: string;
  role: UserRole;
  full_name: string;
  phone?: string;
  avatar_url?: string;
  company_id?: string;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  company_id: string;
  name: string;
  description?: string;
  image_url?: string;
  is_active: boolean;
  sort_order: number;
  created_at: string;
  updated_at: string;
}

export interface Service {
  id: string;
  company_id: string;
  category_id: string;
  name: string;
  description?: string;
  price: number;
  duration_minutes: number;
  image_url?: string;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  categories?: { name: string };
}

export interface Provider {
  id: string;
  user_id: string;
  company_id: string;
  skills: string[];
  experience_years: number;
  bio?: string;
  status: ProviderStatus;
  approved_at?: string;
  profiles?: Profile & { email?: string };
}

export interface Booking {
  id: string;
  company_id: string;
  service_id: string;
  customer_id: string;
  provider_id?: string;
  scheduled_at: string;
  address: string;
  notes?: string;
  status: BookingStatus;
  created_at: string;
  updated_at: string;
  services?: Service;
  customers?: { profiles: Profile };
  providers?: { profiles: Profile };
}

export interface Message {
  id: string;
  chat_room_id: string;
  sender_id: string;
  message_type: "text" | "image";
  content: string;
  read_at?: string;
  created_at: string;
  profiles?: Profile;
}

export interface Review {
  id: string;
  booking_id: string;
  customer_id: string;
  provider_id: string;
  rating: number;
  comment?: string;
  created_at: string;
}

export const DEFAULT_THEME_CONFIG: ThemeConfig = {
  preset_id: "blue",
  primary: "#2563EB",
  secondary: "#64748B",
  light: {
    scaffoldBackground: "#F8FAFC",
    surface: "#FFFFFF",
    textPrimary: "#0F172A",
    textSecondary: "#64748B",
    error: "#EF4444",
    success: "#22C55E",
    drawerBackground: "#FFFFFF",
  },
  dark: {
    scaffoldBackground: "#0F172A",
    surface: "#1E293B",
    textPrimary: "#F8FAFC",
    textSecondary: "#94A3B8",
    error: "#F87171",
    success: "#4ADE80",
    drawerBackground: "#1E293B",
  },
};

export const BOOKING_STATUS_LABELS: Record<BookingStatus, string> = {
  pending: "Pending",
  assigned: "Assigned",
  accepted: "Accepted",
  rejected: "Rejected",
  in_progress: "In Progress",
  completed: "Completed",
  cancelled: "Cancelled",
};

export const PROVIDER_STATUS_LABELS: Record<ProviderStatus, string> = {
  pending: "Pending Approval",
  approved: "Approved",
  rejected: "Rejected",
  suspended: "Suspended",
};
