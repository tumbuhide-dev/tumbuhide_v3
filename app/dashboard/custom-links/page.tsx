import type { Metadata } from "next"
import { CustomLinksManager } from "@/components/dashboard/custom-links-manager"
import { DashboardHeader } from "@/components/dashboard/dashboard-header"
import { createServerComponentClient } from "@supabase/auth-helpers-nextjs"
import { cookies } from "next/headers"
import { redirect } from "next/navigation"

export const metadata: Metadata = {
  title: "Kelola Custom Links - Dashboard Tumbuhide.id",
  description: "Kelola semua custom links dan website Anda",
}

export default async function CustomLinksPage() {
  const supabase = createServerComponentClient({ cookies })

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect("/auth/login")
  }

  const { data: profile } = await supabase.from("profiles").select("*").eq("id", user.id).single()

  if (!profile?.username) {
    redirect("/complete-profile")
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <DashboardHeader profile={profile} />

      <main className="max-w-4xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Kelola Custom Links</h1>
          <p className="text-gray-600 dark:text-gray-400">
            Tambah dan kelola link website, produk, atau konten penting Anda
          </p>
        </div>

        <CustomLinksManager userId={user.id} userPlan={profile.plan} />
      </main>
    </div>
  )
}
