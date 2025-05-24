"use client"
import Image from "next/image"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import {
  MapPin,
  Calendar,
  ExternalLink,
  Crown,
  Instagram,
  Youtube,
  Twitter,
  Facebook,
  Linkedin,
  Github,
  Globe,
} from "lucide-react"
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs"

interface PublicProfileBasicProps {
  profile: {
    id: string
    username: string
    full_name: string
    tagline?: string
    location?: string
    birth_date?: string
    pronouns?: string
    avatar_url: string
    cover_url: string
    social_links: any[]
    custom_links: any[]
  }
}

const socialIcons: Record<string, any> = {
  instagram: Instagram,
  youtube: Youtube,
  twitter: Twitter,
  facebook: Facebook,
  linkedin: Linkedin,
  github: Github,
  website: Globe,
}

export function PublicProfileBasic({ profile }: PublicProfileBasicProps) {
  const supabase = createClientComponentClient()

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const getAge = (birthDate: string) => {
    if (!birthDate) return null
    const birth = new Date(birthDate)
    const today = new Date()
    let age = today.getFullYear() - birth.getFullYear()
    const monthDiff = today.getMonth() - birth.getMonth()
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
      age--
    }
    return age
  }

  const trackLinkClick = async (linkId: string, linkType: string, url: string) => {
    try {
      await supabase.from("analytics").insert({
        user_id: profile.id,
        event_type: "link_click",
        metadata: {
          link_id: linkId,
          link_type: linkType,
          url: url,
          username: profile.username,
        },
      })
    } catch (error) {
      console.error("Error tracking link click:", error)
    }
  }

  const handleLinkClick = (linkId: string, linkType: string, url: string) => {
    trackLinkClick(linkId, linkType, url)
    window.open(url, "_blank")
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Cover Photo */}
      <div className="relative h-48 md:h-64 bg-gradient-to-r from-blue-400 to-purple-500">
        <Image
          src={profile.cover_url || "/placeholder.svg"}
          alt={`${profile.full_name} cover`}
          fill
          className="object-cover"
          onError={(e) => {
            const target = e.target as HTMLImageElement
            target.src = `/placeholder.svg?height=256&width=800&text=${encodeURIComponent(profile.full_name)}`
          }}
        />
      </div>

      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Profile Header */}
        <div className="relative -mt-16 sm:-mt-20 mb-8">
          <div className="flex flex-col sm:flex-row items-center sm:items-end space-y-4 sm:space-y-0 sm:space-x-6">
            <Avatar className="w-32 h-32 border-4 border-white shadow-lg">
              <AvatarImage src={profile.avatar_url || "/placeholder.svg"} alt={profile.full_name} />
              <AvatarFallback className="text-2xl">{getInitials(profile.full_name)}</AvatarFallback>
            </Avatar>

            <div className="text-center sm:text-left flex-1">
              <h1 className="text-3xl font-bold text-gray-900 dark:text-white">{profile.full_name}</h1>
              {profile.tagline && <p className="text-lg text-gray-600 dark:text-gray-400 mt-1">{profile.tagline}</p>}

              <div className="flex flex-wrap items-center justify-center sm:justify-start gap-4 mt-3 text-sm text-gray-500 dark:text-gray-400">
                {profile.location && (
                  <div className="flex items-center gap-1">
                    <MapPin className="w-4 h-4" />
                    <span>{profile.location}</span>
                  </div>
                )}
                {profile.birth_date && (
                  <div className="flex items-center gap-1">
                    <Calendar className="w-4 h-4" />
                    <span>{getAge(profile.birth_date)} tahun</span>
                  </div>
                )}
                {profile.pronouns && (
                  <Badge variant="secondary" className="text-xs">
                    {profile.pronouns}
                  </Badge>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Upgrade Banner */}
        <Alert className="mb-8 border-purple-200 bg-purple-50 dark:bg-purple-950/20">
          <Crown className="h-4 w-4 text-purple-600" />
          <AlertDescription className="text-purple-800 dark:text-purple-200">
            <div className="flex items-center justify-between">
              <div>
                <strong>Ingin fitur lebih lengkap?</strong>
                <br />
                Upgrade ke Creator Pro untuk showcase video dan analytics advanced!
              </div>
              <Button size="sm" className="bg-purple-600 hover:bg-purple-700">
                Pelajari Lebih Lanjut
              </Button>
            </div>
          </AlertDescription>
        </Alert>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8 pb-12">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-6">
            {/* Social Links */}
            {profile.social_links.length > 0 && (
              <Card>
                <CardContent className="p-6">
                  <h2 className="text-xl font-semibold mb-4">Media Sosial</h2>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    {profile.social_links.slice(0, 6).map((link) => {
                      const Icon = socialIcons[link.platform] || Globe
                      return (
                        <Button
                          key={link.id}
                          variant="outline"
                          className="justify-start h-auto p-4"
                          onClick={() => handleLinkClick(link.id, "social", link.url)}
                        >
                          <Icon className="w-5 h-5 mr-3" />
                          <div className="text-left">
                            <div className="font-medium">{link.platform}</div>
                            {link.follower_count && (
                              <div className="text-xs text-gray-500">
                                {link.follower_count.toLocaleString()} followers
                              </div>
                            )}
                          </div>
                          <ExternalLink className="w-4 h-4 ml-auto" />
                        </Button>
                      )
                    })}
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Custom Links */}
            {profile.custom_links.length > 0 && (
              <Card>
                <CardContent className="p-6">
                  <h2 className="text-xl font-semibold mb-4">Link Penting</h2>
                  <div className="space-y-3">
                    {profile.custom_links.slice(0, 10).map((link) => (
                      <Button
                        key={link.id}
                        variant="outline"
                        className="w-full justify-between h-auto p-4"
                        onClick={() => handleLinkClick(link.id, "custom", link.url)}
                      >
                        <div className="text-left">
                          <div className="font-medium">{link.title}</div>
                          {link.description && <div className="text-sm text-gray-500">{link.description}</div>}
                        </div>
                        <ExternalLink className="w-4 h-4" />
                      </Button>
                    ))}
                  </div>
                </CardContent>
              </Card>
            )}
          </div>

          {/* Sidebar */}
          <div className="space-y-6">
            {/* Branding */}
            <Card>
              <CardContent className="p-6 text-center">
                <div className="w-12 h-12 bg-gradient-to-r from-blue-500 to-purple-600 rounded-lg flex items-center justify-center mx-auto mb-3">
                  <span className="text-white font-bold">T</span>
                </div>
                <h3 className="font-semibold text-gray-900 dark:text-white">Dibuat dengan Tumbuhide.id</h3>
                <p className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                  Platform link-in-bio untuk content creator Indonesia
                </p>
                <Button asChild className="w-full mt-4" size="sm">
                  <Link href="/">Buat Profil Gratis</Link>
                </Button>
              </CardContent>
            </Card>
          </div>
        </div>
      </div>
    </div>
  )
}
