import type { Metadata } from "next"
import { notFound } from "next/navigation"
import { PublicProfile } from "@/components/public/public-profile"
import { createServerComponentClient } from "@supabase/auth-helpers-nextjs"
import { cookies } from "next/headers"
import { generateProfileSEO } from "@/lib/seo"

interface PageProps {
  params: {
    username: string
  }
}

export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const supabase = createServerComponentClient({ cookies })

  const { data: profile } = await supabase
    .from("profiles")
    .select("full_name, username, tagline, avatar_url, location")
    .eq("username", params.username.toLowerCase())
    .single()

  if (!profile) {
    return {
      title: "Profil Tidak Ditemukan - Tumbuhide.id",
      robots: { index: false, follow: false },
    }
  }

  return generateProfileSEO(profile)
}

export default async function ProfilePage({ params }: PageProps) {
  const supabase = createServerComponentClient({ cookies })

  // Get profile data
  const { data: profile, error } = await supabase
    .from("profiles")
    .select(`
      *,
      social_links(*),
      custom_links(*),
      showcase_items(*)
    `)
    .eq("username", params.username.toLowerCase())
    .single()

  if (error || !profile) {
    notFound()
  }

  // Track profile view
  try {
    await supabase.from("analytics").insert({
      user_id: profile.id,
      event_type: "profile_view",
      metadata: {
        username: params.username,
        user_agent: "server",
      },
    })
  } catch (error) {
    console.error("Error tracking profile view:", error)
  }

  return <PublicProfile profile={profile} />
}
