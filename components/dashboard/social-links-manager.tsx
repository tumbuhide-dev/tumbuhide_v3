"use client"
import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Badge } from "@/components/ui/badge"
import { Trash2, Plus, ExternalLink, GripVertical, Crown } from "lucide-react"
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs"
import { SECURITY } from "@/lib/constants"
import { validateURL, sanitizeInput } from "@/lib/security"

interface SocialLink {
  id: string
  platform: string
  username: string
  url: string
  follower_count: number
  is_featured: boolean
  display_order: number
}

interface SocialLinksManagerProps {
  userId: string
  userPlan: string
}

const SOCIAL_PLATFORMS = [
  { value: "instagram", label: "Instagram", placeholder: "@username" },
  { value: "youtube", label: "YouTube", placeholder: "Channel URL" },
  { value: "tiktok", label: "TikTok", placeholder: "@username" },
  { value: "twitter", label: "Twitter/X", placeholder: "@username" },
  { value: "facebook", label: "Facebook", placeholder: "Page URL" },
  { value: "linkedin", label: "LinkedIn", placeholder: "Profile URL" },
  { value: "github", label: "GitHub", placeholder: "@username" },
  { value: "website", label: "Website", placeholder: "https://website.com" },
  { value: "spotify", label: "Spotify", placeholder: "Artist URL" },
  { value: "twitch", label: "Twitch", placeholder: "@username" },
]

export function SocialLinksManager({ userId, userPlan }: SocialLinksManagerProps) {
  const [socialLinks, setSocialLinks] = useState<SocialLink[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState("")
  const [newLink, setNewLink] = useState({
    platform: "",
    username: "",
    url: "",
    follower_count: 0,
  })

  const supabase = createClientComponentClient()
  const maxLinks = userPlan === "pro" ? -1 : SECURITY.CONTENT_LIMITS.MAX_SOCIAL_LINKS_BASIC

  useEffect(() => {
    fetchSocialLinks()
  }, [])

  const fetchSocialLinks = async () => {
    try {
      const { data, error } = await supabase
        .from("social_links")
        .select("*")
        .eq("user_id", userId)
        .order("display_order")

      if (error) throw error
      setSocialLinks(data || [])
    } catch (error: any) {
      setError(error.message)
    } finally {
      setLoading(false)
    }
  }

  const addSocialLink = async () => {
    if (!newLink.platform || !newLink.url) {
      setError("Platform dan URL wajib diisi")
      return
    }

    if (!validateURL(newLink.url)) {
      setError("URL tidak valid")
      return
    }

    if (maxLinks !== -1 && socialLinks.length >= maxLinks) {
      setError(`Maksimal ${maxLinks} social links untuk paket Basic`)
      return
    }

    setSaving(true)
    setError("")

    try {
      const { data, error } = await supabase
        .from("social_links")
        .insert({
          user_id: userId,
          platform: newLink.platform,
          username: sanitizeInput(newLink.username),
          url: sanitizeInput(newLink.url),
          follower_count: newLink.follower_count,
          display_order: socialLinks.length,
        })
        .select()
        .single()

      if (error) throw error

      setSocialLinks([...socialLinks, data])
      setNewLink({ platform: "", username: "", url: "", follower_count: 0 })
    } catch (error: any) {
      setError(error.message)
    } finally {
      setSaving(false)
    }
  }

  const deleteSocialLink = async (id: string) => {
    setSaving(true)
    try {
      const { error } = await supabase.from("social_links").delete().eq("id", id)

      if (error) throw error

      setSocialLinks(socialLinks.filter((link) => link.id !== id))
    } catch (error: any) {
      setError(error.message)
    } finally {
      setSaving(false)
    }
  }

  const updateFollowerCount = async (id: string, count: number) => {
    try {
      const { error } = await supabase.from("social_links").update({ follower_count: count }).eq("id", id)

      if (error) throw error

      setSocialLinks(socialLinks.map((link) => (link.id === id ? { ...link, follower_count: count } : link)))
    } catch (error: any) {
      setError(error.message)
    }
  }

  if (loading) {
    return (
      <div className="space-y-4">
        {[...Array(3)].map((_, i) => (
          <Card key={i}>
            <CardContent className="p-6">
              <div className="animate-pulse space-y-3">
                <div className="h-4 bg-gray-200 rounded w-1/4"></div>
                <div className="h-10 bg-gray-200 rounded"></div>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {error && (
        <Alert variant="destructive">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {/* Plan Limit Info */}
      {userPlan === "basic" && (
        <Alert>
          <Crown className="h-4 w-4" />
          <AlertDescription>
            <div className="flex items-center justify-between">
              <span>
                Paket Basic: {socialLinks.length}/{maxLinks} social links
              </span>
              <Button size="sm" variant="outline">
                Upgrade ke Pro
              </Button>
            </div>
          </AlertDescription>
        </Alert>
      )}

      {/* Add New Link */}
      <Card>
        <CardHeader>
          <CardTitle>Tambah Social Link Baru</CardTitle>
          <CardDescription>Tambahkan link media sosial Anda</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="platform">Platform</Label>
              <Select value={newLink.platform} onValueChange={(value) => setNewLink({ ...newLink, platform: value })}>
                <SelectTrigger>
                  <SelectValue placeholder="Pilih platform" />
                </SelectTrigger>
                <SelectContent>
                  {SOCIAL_PLATFORMS.map((platform) => (
                    <SelectItem key={platform.value} value={platform.value}>
                      {platform.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-2">
              <Label htmlFor="username">Username (opsional)</Label>
              <Input
                id="username"
                placeholder={SOCIAL_PLATFORMS.find((p) => p.value === newLink.platform)?.placeholder || "@username"}
                value={newLink.username}
                onChange={(e) => setNewLink({ ...newLink, username: e.target.value })}
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="md:col-span-2 space-y-2">
              <Label htmlFor="url">URL *</Label>
              <Input
                id="url"
                type="url"
                placeholder="https://..."
                value={newLink.url}
                onChange={(e) => setNewLink({ ...newLink, url: e.target.value })}
                required
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="follower_count">Jumlah Followers</Label>
              <Input
                id="follower_count"
                type="number"
                placeholder="0"
                value={newLink.follower_count}
                onChange={(e) => setNewLink({ ...newLink, follower_count: Number.parseInt(e.target.value) || 0 })}
              />
            </div>
          </div>

          <Button
            onClick={addSocialLink}
            disabled={
              saving || !newLink.platform || !newLink.url || (maxLinks !== -1 && socialLinks.length >= maxLinks)
            }
            className="w-full"
          >
            <Plus className="w-4 h-4 mr-2" />
            Tambah Social Link
          </Button>
        </CardContent>
      </Card>

      {/* Existing Links */}
      <div className="space-y-4">
        <h3 className="text-lg font-semibold">Social Links Anda ({socialLinks.length})</h3>

        {socialLinks.length === 0 ? (
          <Card>
            <CardContent className="p-12 text-center">
              <p className="text-gray-500">Belum ada social links. Tambahkan yang pertama!</p>
            </CardContent>
          </Card>
        ) : (
          socialLinks.map((link) => (
            <Card key={link.id}>
              <CardContent className="p-6">
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-4">
                    <GripVertical className="w-5 h-5 text-gray-400 cursor-move" />
                    <div>
                      <div className="flex items-center gap-2">
                        <Badge variant="secondary" className="capitalize">
                          {link.platform}
                        </Badge>
                        {link.is_featured && <Badge variant="default">Featured</Badge>}
                      </div>
                      <div className="text-sm text-gray-600 dark:text-gray-400 mt-1">
                        {link.username && `@${link.username} • `}
                        {link.follower_count > 0 && `${link.follower_count.toLocaleString()} followers`}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center gap-2">
                    <Input
                      type="number"
                      placeholder="Followers"
                      value={link.follower_count}
                      onChange={(e) => updateFollowerCount(link.id, Number.parseInt(e.target.value) || 0)}
                      className="w-24"
                    />
                    <Button variant="outline" size="sm" asChild>
                      <a href={link.url} target="_blank" rel="noopener noreferrer">
                        <ExternalLink className="w-4 h-4" />
                      </a>
                    </Button>
                    <Button variant="outline" size="sm" onClick={() => deleteSocialLink(link.id)} disabled={saving}>
                      <Trash2 className="w-4 h-4" />
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ))
        )}
      </div>
    </div>
  )
}
