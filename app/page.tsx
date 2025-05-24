import { HeroSection } from "@/components/landing/hero-section"
import { FeaturesSection } from "@/components/landing/features-section"
import { PricingSection } from "@/components/landing/pricing-section"
import { TestimonialsSection } from "@/components/landing/testimonials-section"
import { LandingHeader } from "@/components/landing/landing-header"
import { FooterSection } from "@/components/landing/footer-section"
import { generateSEO } from "@/lib/seo"
import type { Metadata } from "next"

export const metadata: Metadata = generateSEO({
  title: "Platform Link-in-Bio Terbaik untuk Content Creator Indonesia",
  description:
    "Kelola semua link sosial media dan showcase konten Anda dalam satu halaman. Gratis untuk content creator Indonesia!",
  keywords: ["link in bio", "content creator", "social media", "influencer", "indonesia"],
})

export default function HomePage() {
  return (
    <div className="min-h-screen">
      <LandingHeader />
      <main>
        <HeroSection />
        <FeaturesSection />
        <PricingSection />
        <TestimonialsSection />
      </main>
      <FooterSection />
    </div>
  )
}
