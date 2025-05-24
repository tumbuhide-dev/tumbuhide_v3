"use client"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ArrowRight, Star, Users, LinkIcon, TrendingUp, Play, ExternalLink } from "lucide-react"
import { BRAND, FEATURES } from "@/lib/constants"
import { generateAvatarFromUsername } from "@/lib/avatar-generator"
import Image from "next/image"

export function HeroSection() {
  // Demo profiles untuk showcase
  const demoProfiles = [
    {
      username: "sarah_beauty",
      name: "Sarah Wijaya",
      tagline: "Beauty Content Creator & Makeup Artist",
      plan: "pro",
      avatar: generateAvatarFromUsername("sarah_beauty"),
      cover: "/placeholder.svg?height=200&width=600&text=Beauty+Content",
      followers: {
        instagram: 150000,
        youtube: 45000,
        tiktok: 280000,
      },
      links: [
        { title: "Skincare Routine", type: "video", platform: "youtube" },
        { title: "Makeup Tutorial", type: "video", platform: "instagram" },
        { title: "Product Review", type: "link", url: "#" },
        { title: "Brand Collaboration", type: "link", url: "#" },
      ],
    },
    {
      username: "rizki_tech",
      name: "Rizki Pratama",
      tagline: "Tech Reviewer & Gadget Enthusiast",
      plan: "basic",
      avatar: generateAvatarFromUsername("rizki_tech"),
      cover: "/placeholder.svg?height=200&width=600&text=Tech+Reviews",
      followers: {
        instagram: 89000,
        youtube: 120000,
        tiktok: 65000,
      },
      links: [
        { title: "Latest Phone Review", type: "video", platform: "youtube" },
        { title: "Tech Tips", type: "link", url: "#" },
        { title: "Gadget Store", type: "link", url: "#" },
      ],
    },
  ]

  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-purple-50 via-white to-yellow-50 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800">
      {/* Background Pattern */}
      <div className="absolute inset-0 bg-grid-slate-100 [mask-image:linear-gradient(0deg,white,rgba(255,255,255,0.6))] dark:bg-grid-slate-700/25 dark:[mask-image:linear-gradient(0deg,rgba(255,255,255,0.1),rgba(255,255,255,0.5))]" />

      <div className="relative max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-16 sm:pt-24 sm:pb-20">
        <div className="text-center">
          {/* Badge */}
          <Badge
            variant="secondary"
            className="mb-4 px-4 py-2 bg-gradient-to-r from-purple-100 to-yellow-100 text-purple-800 border-purple-200"
          >
            <Star className="w-4 h-4 mr-2" />
            Platform #1 untuk Content Creator Indonesia
          </Badge>

          {/* Main Heading */}
          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold text-gray-900 dark:text-white mb-6">
            Satu Link untuk
            <span className="bg-gradient-to-r from-purple-600 to-yellow-500 bg-clip-text text-transparent">
              {" "}
              Semua Konten{" "}
            </span>
            Anda
          </h1>

          {/* Subtitle */}
          <p className="text-xl text-gray-600 dark:text-gray-300 mb-8 max-w-3xl mx-auto">
            Platform link-in-bio terbaik untuk content creator Indonesia. Kelola semua link sosial media, showcase video
            viral, dan dapatkan analytics mendalam dalam satu halaman yang menarik.
          </p>

          {/* Stats */}
          <div className="flex flex-wrap justify-center gap-8 mb-10 text-sm text-gray-600 dark:text-gray-400">
            <div className="flex items-center gap-2">
              <Users className="w-5 h-5 text-purple-600" />
              <span>
                <strong>10,000+</strong> Content Creator
              </span>
            </div>
            <div className="flex items-center gap-2">
              <LinkIcon className="w-5 h-5 text-yellow-600" />
              <span>
                <strong>500,000+</strong> Link Clicks
              </span>
            </div>
            <div className="flex items-center gap-2">
              <TrendingUp className="w-5 h-5 text-green-600" />
              <span>
                <strong>95%</strong> Peningkatan Engagement
              </span>
            </div>
          </div>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center items-center mb-12">
            {FEATURES.REGISTRATION ? (
              <Button
                asChild
                size="lg"
                className="px-8 py-3 text-lg bg-gradient-to-r from-purple-600 to-yellow-500 hover:from-purple-700 hover:to-yellow-600"
              >
                <Link href="/auth/register" className="flex items-center gap-2">
                  Mulai Gratis Sekarang
                  <ArrowRight className="w-5 h-5" />
                </Link>
              </Button>
            ) : (
              <Button disabled size="lg" className="px-8 py-3 text-lg">
                Segera Hadir
              </Button>
            )}

            <Button
              variant="outline"
              size="lg"
              asChild
              className="px-8 py-3 text-lg border-purple-200 text-purple-700 hover:bg-purple-50"
            >
              <Link href="#demo">Lihat Demo</Link>
            </Button>
          </div>

          {/* Demo Preview - Real Profiles */}
          <div id="demo" className="grid grid-cols-1 lg:grid-cols-2 gap-8 max-w-6xl mx-auto">
            {demoProfiles.map((profile, index) => (
              <div
                key={index}
                className="relative rounded-2xl overflow-hidden shadow-2xl bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700"
              >
                {/* Browser Bar */}
                <div className="bg-gray-50 dark:bg-gray-900 px-4 py-3 border-b border-gray-200 dark:border-gray-700">
                  <div className="flex items-center gap-2">
                    <div className="w-3 h-3 rounded-full bg-red-500"></div>
                    <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
                    <div className="w-3 h-3 rounded-full bg-green-500"></div>
                    <div className="ml-4 text-sm text-gray-500 dark:text-gray-400">
                      {BRAND.DOMAIN}/{profile.username}
                    </div>
                  </div>
                </div>

                {/* Profile Content */}
                <div className="relative">
                  {/* Cover Photo */}
                  <div className="h-32 bg-gradient-to-r from-purple-400 to-yellow-400 relative">
                    <Image
                      src={profile.cover || "/placeholder.svg"}
                      alt={`${profile.name} cover`}
                      fill
                      className="object-cover opacity-80"
                    />
                    {profile.plan === "pro" && (
                      <Badge className="absolute top-2 right-2 bg-purple-600">Creator Pro</Badge>
                    )}
                  </div>

                  {/* Profile Info */}
                  <div className="p-6 -mt-8 relative">
                    <div className="flex items-end gap-4 mb-4">
                      <div className="w-16 h-16 rounded-full border-4 border-white shadow-lg overflow-hidden bg-white">
                        <Image
                          src={profile.avatar || "/placeholder.svg"}
                          alt={profile.name}
                          width={64}
                          height={64}
                          className="w-full h-full object-cover"
                        />
                      </div>
                      <div className="flex-1 text-left">
                        <h3 className="text-lg font-bold text-gray-900 dark:text-white">{profile.name}</h3>
                        <p className="text-sm text-gray-600 dark:text-gray-400">@{profile.username}</p>
                      </div>
                    </div>

                    <p className="text-gray-700 dark:text-gray-300 mb-4 text-left">{profile.tagline}</p>

                    {/* Social Stats */}
                    <div className="grid grid-cols-3 gap-2 mb-4">
                      <div className="bg-gradient-to-r from-pink-50 to-purple-50 dark:from-gray-700 dark:to-gray-600 rounded-lg p-2 text-center">
                        <div className="text-xs font-medium text-gray-900 dark:text-white">Instagram</div>
                        <div className="text-xs text-gray-500 dark:text-gray-400">
                          {profile.followers.instagram.toLocaleString()}
                        </div>
                      </div>
                      <div className="bg-gradient-to-r from-red-50 to-pink-50 dark:from-gray-700 dark:to-gray-600 rounded-lg p-2 text-center">
                        <div className="text-xs font-medium text-gray-900 dark:text-white">YouTube</div>
                        <div className="text-xs text-gray-500 dark:text-gray-400">
                          {profile.followers.youtube.toLocaleString()}
                        </div>
                      </div>
                      <div className="bg-gradient-to-r from-gray-50 to-blue-50 dark:from-gray-700 dark:to-gray-600 rounded-lg p-2 text-center">
                        <div className="text-xs font-medium text-gray-900 dark:text-white">TikTok</div>
                        <div className="text-xs text-gray-500 dark:text-gray-400">
                          {profile.followers.tiktok.toLocaleString()}
                        </div>
                      </div>
                    </div>

                    {/* Links Preview */}
                    <div className="space-y-2">
                      {profile.links.slice(0, 3).map((link, linkIndex) => (
                        <div
                          key={linkIndex}
                          className="bg-gray-50 dark:bg-gray-700 rounded-lg p-2 flex items-center justify-between"
                        >
                          <div className="flex items-center gap-2">
                            {link.type === "video" ? (
                              <Play className="w-3 h-3 text-purple-600" />
                            ) : (
                              <ExternalLink className="w-3 h-3 text-yellow-600" />
                            )}
                            <span className="text-xs font-medium text-gray-900 dark:text-white">{link.title}</span>
                          </div>
                          {link.platform && (
                            <Badge variant="secondary" className="text-xs">
                              {link.platform}
                            </Badge>
                          )}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}
