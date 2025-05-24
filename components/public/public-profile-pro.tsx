"use client"
import { useState } from "react"
import Image from "next/image"
import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import {
  MapPin,
  Calendar,
  ExternalLink,
  Play,
  Instagram,
  Youtube,
  Twitter,
  Facebook,
  Linkedin,
  Github,
  Globe,
} from "lucide-react"
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs"

interface PublicProfileProProps {
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
    showcase_items: any[]
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

export function PublicProfilePro({ profile }: PublicProfileProProps) {
  const [activeTab, setActiveTab] = useState("links")
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

  const hasContent =
    profile.social_links.length > 0 || profile.custom_links.length > 0 || profile.showcase_items.length > 0

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

      <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Profile Header */}
        <div className="relative -mt-16 sm:-mt-20 mb-8">
          <div className="flex flex-col sm:flex-row items-center sm:items-end space-y-4 sm:space-y-0 sm:space-x-6">
            <Avatar className="w-32 h-32 border-4 border-white shadow-lg">
              <AvatarImage src={profile.avatar_url || "/placeholder.svg"} alt={profile.full_name} />
              <AvatarFallback className="text-2xl">{getInitials(profile.full_name)}</AvatarFallback>
            </Avatar>

            <div className="text-center sm:text-left flex-1">
              <div className="flex items-center justify-center sm:justify-start gap-2 mb-2">
                <h1 className="text-3xl font-bold text-gray-900 dark:text-white">{profile.full_name}</h1>
                <Badge className="bg-purple-600">Creator Pro</Badge>
              </div>

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

        {/* Content Tabs */}
        {hasContent ? (
          <Tabs value={activeTab} onValueChange={setActiveTab} className="pb-12">
            <TabsList className="grid w-full grid-cols-3">
              <TabsTrigger value="links">Link</TabsTrigger>
              <TabsTrigger value="social">Social Media</TabsTrigger>
              {profile.showcase_items.length > 0 && <TabsTrigger value="showcase">Video Showcase</TabsTrigger>}
            </TabsList>

            {/* Links Tab */}
            <TabsContent value="links" className="mt-6">
              {profile.custom_links.length > 0 ? (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {profile.custom_links.map((link) => (
                    <Card key={link.id} className="hover:shadow-md transition-shadow">
                      <CardContent className="p-6">
                        <Button
                          variant="ghost"
                          className="w-full h-auto p-0 justify-start"
                          onClick={() => handleLinkClick(link.id, "custom", link.url)}
                        >
                          <div className="text-left w-full">
                            <div className="font-medium text-lg">{link.title}</div>
                            {link.description && <div className="text-sm text-gray-500 mt-1">{link.description}</div>}
                            <div className="flex items-center justify-between mt-3">
                              <span className="text-blue-600 text-sm">Kunjungi Link</span>
                              <ExternalLink className="w-4 h-4" />
                            </div>
                          </div>
                        </Button>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              ) : (
                <Card>
                  <CardContent className="p-12 text-center">
                    <p className="text-gray-500">Belum ada custom link yang ditambahkan</p>
                  </CardContent>
                </Card>
              )}
            </TabsContent>

            {/* Social Media Tab */}
            <TabsContent value="social" className="mt-6">
              {profile.social_links.length > 0 ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                  {profile.social_links.map((link) => {
                    const Icon = socialIcons[link.platform] || Globe
                    return (
                      <Card key={link.id} className="hover:shadow-md transition-shadow">
                        <CardContent className="p-6">
                          <Button
                            variant="ghost"
                            className="w-full h-auto p-0"
                            onClick={() => handleLinkClick(link.id, "social", link.url)}
                          >
                            <div className="text-center w-full">
                              <Icon className="w-8 h-8 mx-auto mb-3 text-blue-600" />
                              <div className="font-medium capitalize">{link.platform}</div>
                              {link.follower_count && (
                                <div className="text-sm text-gray-500 mt-1">
                                  {link.follower_count.toLocaleString()} followers
                                </div>
                              )}
                              <div className="flex items-center justify-center mt-3 text-blue-600">
                                <span className="text-sm mr-2">Kunjungi</span>
                                <ExternalLink className="w-4 h-4" />
                              </div>
                            </div>
                          </Button>
                        </CardContent>
                      </Card>
                    )
                  })}
                </div>
              ) : (
                <Card>
                  <CardContent className="p-12 text-center">
                    <p className="text-gray-500">Belum ada social media yang ditambahkan</p>
                  </CardContent>
                </Card>
              )}
            </TabsContent>

            {/* Showcase Tab */}
            {profile.showcase_items.length > 0 && (
              <TabsContent value="showcase" className="mt-6">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {profile.showcase_items.map((item) => (
                    <Card key={item.id} className="overflow-hidden hover:shadow-md transition-shadow">
                      <div className="relative aspect-video bg-gray-100">
                        {item.thumbnail_url ? (
                          <Image
                            src={item.thumbnail_url || "/placeholder.svg"}
                            alt={item.title}
                            fill
                            className="object-cover"
                          />
                        ) : (
                          <div className="flex items-center justify-center h-full">
                            <Play className="w-12 h-12 text-gray-400" />
                          </div>
                        )}
                        <Button
                          size="sm"
                          className="absolute inset-0 bg-black/50 hover:bg-black/60 text-white"
                          onClick={() => handleLinkClick(item.id, "showcase", item.video_url)}
                        >
                          <Play className="w-8 h-8" />
                        </Button>
                      </div>
                      <CardContent className="p-4">
                        <h3 className="font-medium">{item.title}</h3>
                        {item.description && <p className="text-sm text-gray-500 mt-1">{item.description}</p>}
                        <Badge variant="secondary" className="mt-2 text-xs">
                          {item.platform}
                        </Badge>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              </TabsContent>
            )}
          </Tabs>
        ) : (
          <Card className="mb-12">
            <CardContent className="p-12 text-center">
              <h3 className="text-xl font-semibold mb-2">Profil Sedang Dipersiapkan</h3>
              <p className="text-gray-500">
                {profile.full_name} sedang menyiapkan konten untuk profil ini. Silakan kembali lagi nanti!
              </p>
            </CardContent>
          </Card>
        )}

        {/* Footer Branding */}
        <div className="text-center py-8 border-t">
          <div className="flex items-center justify-center gap-2 text-gray-500">
            <div className="w-6 h-6 bg-gradient-to-r from-blue-500 to-purple-600 rounded flex items-center justify-center">
              <span className="text-white font-bold text-xs">T</span>
            </div>
            <span className="text-sm">Dibuat dengan Tumbuhide.id</span>
          </div>
        </div>
      </div>
    </div>
  )
}
