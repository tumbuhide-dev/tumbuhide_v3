import type { Metadata } from "next"
import { LandingHeader } from "@/components/landing/landing-header"
import { FooterSection } from "@/components/landing/footer-section"
import { generateSEO } from "@/lib/seo"

export const metadata: Metadata = generateSEO({
  title: "Demo Platform - Lihat Contoh Profil Creator",
  description:
    "Lihat demo platform Tumbuhide.id dan contoh profil content creator yang sudah menggunakan layanan kami.",
})

export default function DemoPage() {
  return (
    <div className="min-h-screen">
      <LandingHeader />
      <main className="py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h1 className="text-4xl font-bold mb-6">Demo Platform</h1>
          <p className="text-xl text-gray-600 mb-8">
            Lihat contoh profil content creator yang menggunakan Tumbuhide.id
          </p>
          <div className="bg-gray-100 rounded-lg p-12">
            <p className="text-gray-500">Demo interaktif akan segera hadir!</p>
          </div>
        </div>
      </main>
      <FooterSection />
    </div>
  )
}
