import type { Metadata } from "next"
import { BRAND, SEO } from "./constants"

interface SEOProps {
  title?: string
  description?: string
  keywords?: string[]
  image?: string
  url?: string
  type?: "website" | "article" | "profile"
  noIndex?: boolean
  canonical?: string
}

export function generateSEO({
  title,
  description = BRAND.APP_DESCRIPTION,
  keywords = [],
  image,
  url,
  type = "website",
  noIndex = false,
  canonical,
}: SEOProps = {}): Metadata {
  // Gunakan fallback yang aman
  const siteUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://tumbuhide.com"
  const baseUrl = "https://tumbuhide.com" // fallback yang aman

  const fullTitle = title ? `${title} | ${BRAND.APP_NAME}` : `${BRAND.APP_NAME} - ${BRAND.TAGLINE}`
  const fullUrl = url ? `${baseUrl}${url}` : baseUrl
  const imageUrl = image ? (image.startsWith("http") ? image : `${baseUrl}${image}`) : `${baseUrl}/og-image.jpg`

  const allKeywords = [...SEO.KEYWORDS, ...keywords].join(", ")

  return {
    title: fullTitle,
    description,
    keywords: allKeywords,
    authors: [{ name: SEO.AUTHOR }],
    creator: SEO.AUTHOR,
    publisher: SEO.AUTHOR,
    metadataBase: new URL(baseUrl),
    alternates: {
      canonical: canonical || fullUrl,
    },
    openGraph: {
      type,
      locale: SEO.LANGUAGE,
      url: fullUrl,
      title: fullTitle,
      description,
      siteName: BRAND.APP_NAME,
      images: [
        {
          url: imageUrl,
          width: 1200,
          height: 630,
          alt: fullTitle,
        },
      ],
    },
    twitter: {
      card: "summary_large_image",
      title: fullTitle,
      description,
      images: [imageUrl],
      creator: "@tumbuhide",
      site: "@tumbuhide",
    },
    robots: {
      index: !noIndex,
      follow: !noIndex,
      googleBot: {
        index: !noIndex,
        follow: !noIndex,
        "max-video-preview": -1,
        "max-image-preview": "large",
        "max-snippet": -1,
      },
    },
    other: {
      "geo.region": SEO.REGION,
      "geo.country": SEO.REGION,
      language: SEO.LANGUAGE,
      "google-site-verification": process.env.GOOGLE_SITE_VERIFICATION || "",
    },
  }
}

export function generateProfileSEO(profile: {
  full_name: string
  username: string
  tagline?: string
  avatar_url?: string
  location?: string
}) {
  const title = `${profile.full_name} (@${profile.username})`
  const description = profile.tagline
    ? `${profile.tagline} | Profil ${profile.full_name} di ${BRAND.APP_NAME}`
    : `Profil ${profile.full_name} di ${BRAND.APP_NAME} - Platform link-in-bio untuk content creator Indonesia`

  const keywords = [
    profile.full_name,
    profile.username,
    "content creator",
    "influencer",
    "link in bio",
    "social media",
    ...(profile.location ? [profile.location] : []),
    ...(profile.tagline ? profile.tagline.split(" ").filter((word) => word.length > 3) : []),
  ]

  return generateSEO({
    title,
    description,
    keywords,
    image: profile.avatar_url,
    url: `/${profile.username}`,
    type: "profile",
  })
}

// Structured Data untuk SEO
export function generateStructuredData(profile?: {
  full_name: string
  username: string
  tagline?: string
  avatar_url?: string
  location?: string
}) {
  const baseUrl = process.env.NEXT_PUBLIC_SITE_URL || "https://tumbuhide.com"

  if (profile) {
    // Person Schema untuk profile
    return {
      "@context": "https://schema.org",
      "@type": "Person",
      name: profile.full_name,
      alternateName: profile.username,
      description: profile.tagline || `Profil ${profile.full_name} di ${BRAND.APP_NAME}`,
      image: profile.avatar_url,
      url: `${baseUrl}/${profile.username}`,
      sameAs: [], // Will be populated with social links
      worksFor: {
        "@type": "Organization",
        name: BRAND.COMPANY_NAME,
      },
      ...(profile.location && {
        address: {
          "@type": "PostalAddress",
          addressLocality: profile.location,
          addressCountry: "ID",
        },
      }),
    }
  }

  // Organization Schema untuk homepage
  return {
    "@context": "https://schema.org",
    "@type": "Organization",
    name: BRAND.COMPANY_NAME,
    alternateName: BRAND.APP_NAME,
    description: BRAND.APP_DESCRIPTION,
    url: baseUrl,
    logo: `${baseUrl}${BRAND.ASSETS.LOGO}`,
    sameAs: [
      BRAND.SOCIAL.TWITTER,
      BRAND.SOCIAL.INSTAGRAM,
      BRAND.SOCIAL.LINKEDIN,
      BRAND.SOCIAL.TIKTOK,
      BRAND.SOCIAL.YOUTUBE,
    ],
    contactPoint: {
      "@type": "ContactPoint",
      email: BRAND.EMAIL.PARTNERSHIPS,
      contactType: "partnerships",
    },
    address: {
      "@type": "PostalAddress",
      addressCountry: "ID",
    },
  }
}
