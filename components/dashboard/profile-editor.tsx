"use client"
import { useState } from "react"
import type React from "react"

import { useRouter } from "next/navigation"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Loader2, Upload, Crown, ExternalLink } from "lucide-react"
import { createClientComponentClient } from "@supabase/auth-helpers-nextjs"
import { generateAvatarFromUsername } from "@/lib/avatar-generator"
import Link from "next/link"

interface ProfileEditorProps {
  profile: {
    id: string
    username: string
    full_name: string
    email: string
    tagline?: string
    bio?: string
    location?: string
    birth_date?: string
    pronouns?: string
    avatar_url?: string
    cover_url?: string
    plan: string
    is_verified: boolean
  }
}

export function ProfileEditor({ profile }: ProfileEditorProps) {
  const [formData, setFormData] = useState({
    full_name: profile.full_name || "",
    tagline: profile.tagline || "",
    bio: profile.bio || "",
    location: profile.location || "",
    pronouns: profile.pronouns || "",
  })
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")

  const router = useRouter()
  const supabase = createClientComponentClient()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setSuccess("")
    setLoading(true)

    try {
      const { error } = await supabase
        .from("profiles")
        .update({
          full_name: formData.full_name,
          tagline: formData.tagline || null,
          bio: formData.bio || null,
          location: formData.location || null,
          pronouns: formData.pronouns || null,
          updated_at: new Date().toISOString(),
        })
        .eq("id", profile.id)

      if (error) throw error

      setSuccess("Profil berhasil diperbarui!")
      router.refresh()
    } catch (error: any) {
      setError(error.message || "Terjadi kesalahan saat menyimpan profil")
    } finally {
      setLoading(false)
    }
  }

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .map((n) => n[0])
      .join("")
      .toUpperCase()
      .slice(0, 2)
  }

  const avatarUrl = profile.avatar_url || generateAvatarFromUsername(profile.username)

  return (
    <div className="space-y-6">
      {error && (
        <Alert variant="destructive">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {success && (
        <Alert className="border-green-200 bg-green-50 text-green-800">
          <AlertDescription>{success}</AlertDescription>
        </Alert>
      )}

      {/* Profile Overview */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>Informasi Profil</CardTitle>
              <CardDescription>Informasi dasar yang ditampilkan di profil publik Anda</CardDescription>
            </div>
            <Button variant="outline" asChild>
              <Link href={`/${profile.username}`} target="_blank" className="flex items-center gap-2">
                <ExternalLink className="w-4 h-4" />
                Lihat Profil
              </Link>
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Avatar & Basic Info */}
          <div className="flex items-center gap-6">
            <Avatar className="w-20 h-20">
              <AvatarImage src={avatarUrl || "/placeholder.svg"} alt={profile.full_name} />
              <AvatarFallback className="text-lg">{getInitials(profile.full_name)}</AvatarFallback>
            </Avatar>
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-2">
                <h3 className="text-lg font-semibold">{profile.full_name}</h3>
                {profile.is_verified && <Badge variant="secondary">Verified</Badge>}
                <Badge variant={profile.plan === "pro" ? "default" : "secondary"}>
                  {profile.plan === "pro" && <Crown className="w-3 h-3 mr-1" />}
                  {profile.plan === "pro" ? "Creator Pro" : "Basic"}
                </Badge>
              </div>
              <p className="text-gray-600 dark:text-gray-400">@{profile.username}</p>
              <p className="text-sm text-gray-500 dark:text-gray-500">{profile.email}</p>
            </div>
            <Button variant="outline" size="sm">
              <Upload className="w-4 h-4 mr-2" />
              Ubah Foto
            </Button>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            {/* Full Name */}
            <div className="space-y-2">
              <Label htmlFor="full_name">Nama Lengkap *</Label>
              <Input
                id="full_name"
                value={formData.full_name}
                onChange={(e) => setFormData((prev) => ({ ...prev, full_name: e.target.value }))}
                maxLength={100}
                required
              />
            </div>

            {/* Tagline */}
            <div className="space-y-2">
              <Label htmlFor="tagline">Tagline</Label>
              <Input
                id="tagline"
                placeholder="Ceritakan tentang diri Anda dalam satu kalimat"
                value={formData.tagline}
                onChange={(e) => setFormData((prev) => ({ ...prev, tagline: e.target.value }))}
                maxLength={150}
              />
            </div>

            {/* Bio */}
            <div className="space-y-2">
              <Label htmlFor="bio">Bio</Label>
              <Textarea
                id="bio"
                placeholder="Ceritakan lebih detail tentang diri Anda, pengalaman, dan passion"
                value={formData.bio}
                onChange={(e) => setFormData((prev) => ({ ...prev, bio: e.target.value }))}
                maxLength={500}
                rows={4}
              />
              <p className="text-xs text-gray-500">{formData.bio.length}/500 karakter</p>
            </div>

            {/* Location */}
            <div className="space-y-2">
              <Label htmlFor="location">Lokasi</Label>
              <Input
                id="location"
                placeholder="Kota, Indonesia"
                value={formData.location}
                onChange={(e) => setFormData((prev) => ({ ...prev, location: e.target.value }))}
                maxLength={100}
              />
            </div>

            {/* Pronouns */}
            <div className="space-y-2">
              <Label htmlFor="pronouns">Kata Ganti</Label>
              <Input
                id="pronouns"
                placeholder="dia/dia, ia/ia, mereka/mereka"
                value={formData.pronouns}
                onChange={(e) => setFormData((prev) => ({ ...prev, pronouns: e.target.value }))}
                maxLength={50}
              />
            </div>

            <Button type="submit" disabled={loading} className="w-full">
              {loading && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
              Simpan Perubahan
            </Button>
          </form>
        </CardContent>
      </Card>

      {/* Account Settings */}
      <Card>
        <CardHeader>
          <CardTitle>Pengaturan Akun</CardTitle>
          <CardDescription>Kelola pengaturan keamanan dan preferensi akun</CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <Label>Username</Label>
              <div className="flex items-center gap-2 mt-1">
                <Input value={profile.username} disabled />
                <Button variant="outline" size="sm" disabled>
                  Ubah
                </Button>
              </div>
              <p className="text-xs text-gray-500 mt-1">Username tidak dapat diubah saat ini</p>
            </div>

            <div>
              <Label>Email</Label>
              <div className="flex items-center gap-2 mt-1">
                <Input value={profile.email} disabled />
                <Button variant="outline" size="sm" disabled>
                  Ubah
                </Button>
              </div>
              <p className="text-xs text-gray-500 mt-1">Email tidak dapat diubah saat ini</p>
            </div>
          </div>

          <div className="pt-4 border-t">
            <Button variant="outline" className="text-red-600 hover:text-red-700 hover:bg-red-50">
              Hapus Akun
            </Button>
            <p className="text-xs text-gray-500 mt-1">
              Tindakan ini tidak dapat dibatalkan. Semua data Anda akan dihapus permanen.
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
