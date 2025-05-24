"use client"
import Link from "next/link"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { User, LinkIcon, Share2, Video, BarChart3, Crown, ArrowUpRight } from "lucide-react"

interface QuickActionsProps {
  profile: {
    plan: string
    username: string
  }
}

export function QuickActions({ profile }: QuickActionsProps) {
  const isBasicPlan = profile.plan === "basic"

  const actions = [
    {
      title: "Edit Profil",
      description: "Ubah foto, bio, dan informasi dasar",
      icon: User,
      href: "/dashboard/profile",
      available: true,
    },
    {
      title: "Kelola Social Links",
      description: "Tambah dan edit link media sosial",
      icon: Share2,
      href: "/dashboard/social-links",
      available: true,
    },
    {
      title: "Kelola Custom Links",
      description: "Tambah link website, produk, atau konten",
      icon: LinkIcon,
      href: "/dashboard/custom-links",
      available: true,
    },
    {
      title: "Video Showcase",
      description: "Tampilkan video terbaik Anda",
      icon: Video,
      href: "/dashboard/showcase",
      available: !isBasicPlan,
      proOnly: true,
    },
    {
      title: "Analytics",
      description: "Lihat statistik detail profil Anda",
      icon: BarChart3,
      href: "/dashboard/analytics",
      available: true,
    },
  ]

  return (
    <div className="space-y-6">
      {/* Upgrade Banner for Basic Plan */}
      {isBasicPlan && (
        <Alert className="border-purple-200 bg-purple-50 dark:bg-purple-950/20">
          <Crown className="h-4 w-4 text-purple-600" />
          <AlertDescription className="text-purple-800 dark:text-purple-200">
            <div className="flex items-center justify-between">
              <div>
                <strong>Upgrade ke Creator Pro</strong>
                <br />
                Dapatkan fitur showcase video dan analytics advanced!
              </div>
              <Button size="sm" className="bg-purple-600 hover:bg-purple-700">
                Upgrade Sekarang
              </Button>
            </div>
          </AlertDescription>
        </Alert>
      )}

      {/* Quick Actions Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {actions.map((action) => (
          <Card
            key={action.title}
            className={`transition-all hover:shadow-md ${!action.available ? "opacity-60" : ""}`}
          >
            <CardHeader className="pb-3">
              <div className="flex items-center justify-between">
                <action.icon className="h-6 w-6 text-blue-600" />
                {action.proOnly && (
                  <Badge variant="secondary" className="text-xs">
                    <Crown className="w-3 h-3 mr-1" />
                    Pro
                  </Badge>
                )}
              </div>
              <CardTitle className="text-lg">{action.title}</CardTitle>
              <CardDescription>{action.description}</CardDescription>
            </CardHeader>
            <CardContent>
              {action.available ? (
                <Button asChild className="w-full">
                  <Link href={action.href} className="flex items-center justify-center gap-2">
                    Kelola
                    <ArrowUpRight className="w-4 h-4" />
                  </Link>
                </Button>
              ) : (
                <Button disabled className="w-full">
                  Perlu Upgrade
                </Button>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Profile Link */}
      <Card className="bg-gradient-to-r from-blue-50 to-purple-50 dark:from-blue-950/20 dark:to-purple-950/20 border-blue-200">
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Share2 className="h-5 w-5" />
            Link Profil Anda
          </CardTitle>
          <CardDescription>Bagikan link ini untuk menampilkan profil Anda</CardDescription>
        </CardHeader>
        <CardContent>
          <div className="flex items-center gap-3">
            <div className="flex-1 p-3 bg-white dark:bg-gray-800 rounded-lg border">
              <code className="text-sm">tumbuhide.com/{profile.username}</code>
            </div>
            <Button asChild>
              <Link href={`/${profile.username}`} target="_blank">
                Lihat Profil
              </Link>
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
