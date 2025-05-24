// Brand & Company Constants - Semua menggunakan fallback values
export const BRAND = {
  COMPANY_NAME: "Tumbuh Ide",
  COMPANY_SHORT: "Tumbuh Ide",
  APP_NAME: "Tumbuhide.id",
  APP_DESCRIPTION: "Agensi Kreatif untuk Content Creator & Brand Partnership",
  TAGLINE: "Agensi Kreatif untuk Content Creator & Brand Partnership",
  DOMAIN: "tumbuhide.com",
  EMAIL: {
    PARTNERSHIPS: "partnerships@tumbuhide.com",
    SUPPORT: "support@tumbuhide.com",
    NOREPLY: "noreply@tumbuhide.com",
  },
  SOCIAL: {
    TWITTER: "https://twitter.com/tumbuhide",
    INSTAGRAM: "https://instagram.com/tumbuhide",
    LINKEDIN: "https://linkedin.com/company/tumbuhide",
    TIKTOK: "https://tiktok.com/@tumbuhide",
    YOUTUBE: "https://youtube.com/@tumbuhide",
  },
  ASSETS: {
    LOGO: "/logo.svg",
    LOGO_DARK: "/logo-dark.svg",
    FAVICON: "/favicon.ico",
    DEFAULT_AVATAR: "https://api.dicebear.com/7.x/avataaars/svg",
    DEFAULT_COVER: "/placeholder-cover.jpg",
  },
  COLORS: {
    PRIMARY: "#8B5CF6", // Purple
    SECONDARY: "#F59E0B", // Yellow/Amber
    ACCENT: "#FFFFFF", // White
  },
} as const

// SEO Constants
export const SEO = {
  KEYWORDS: [
    "content creator",
    "brand partnership",
    "influencer",
    "social media",
    "link in bio",
    "indonesia",
    "agensi kreatif",
  ],
  AUTHOR: "Tumbuh Ide",
  LANGUAGE: "id-ID",
  REGION: "ID",
  SITE_TYPE: "website",
} as const

// Security Constants
export const SECURITY = {
  RATE_LIMIT: {
    MAX_REQUESTS: 100,
    WINDOW_MS: 900000, // 15 minutes
  },
  CONTENT_LIMITS: {
    MAX_BIO_LENGTH: 500,
    MAX_USERNAME_LENGTH: 30,
    MAX_CUSTOM_LINKS_BASIC: 50,
    MAX_CUSTOM_LINKS_PRO: -1, // unlimited
    MAX_SOCIAL_LINKS_BASIC: 10,
    MAX_SOCIAL_LINKS_PRO: -1, // unlimited
    MAX_SHOWCASE_ITEMS_BASIC: 0,
    MAX_SHOWCASE_ITEMS_PRO: 20,
  },
} as const

// Feature Flags - Semua default enabled untuk demo
export const FEATURES = {
  ANALYTICS: true,
  TESTIMONIALS: true,
  COLLABORATION_FORM: true,
  DARK_MODE: true,
  REGISTRATION: true,
  MAINTENANCE_MODE: false,
  REAL_TIME_FOLLOWERS: false, // disabled untuk demo
} as const

// Default Values
export const DEFAULTS = {
  AVATAR_API: "https://api.dicebear.com/7.x/avataaars/svg",
  AVATAR_API_BACKUP: "https://ui-avatars.com/api",
  COVER_PLACEHOLDER: "/placeholder.svg?height=200&width=800",
  INVITATION_CODES: ["CREATOR2024", "TUMBUHIDE2024", "INFLUENCER2024"],
  MIN_AGE: 17,
  MAX_AGE: 80,
} as const

// Theme Configuration - Purple & Yellow
export const THEME = {
  PRIMARY_COLOR: BRAND.COLORS.PRIMARY,
  SECONDARY_COLOR: BRAND.COLORS.SECONDARY,
  ACCENT_COLOR: BRAND.COLORS.ACCENT,
} as const

// PWA Configuration
export const PWA = {
  NAME: "Tumbuhide.id",
  SHORT_NAME: "Tumbuhide",
  DESCRIPTION: "Agensi Kreatif untuk Content Creator",
} as const

// Social Media APIs (disabled untuk demo)
export const SOCIAL_APIS = {
  INSTAGRAM: {
    ENABLED: false,
    API_KEY: "",
  },
  YOUTUBE: {
    ENABLED: false,
    API_KEY: "",
  },
  TIKTOK: {
    ENABLED: false,
    API_KEY: "",
  },
} as const
