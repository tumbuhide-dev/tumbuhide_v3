import type { Metadata } from "next"
import { AnalyticsDashboard } from "@/components/dashboard/analytics-dashboard"
import { DashboardHeader } from "@/components/dashboard/dashboard-header"
import { createServerComponentClient } from "@supabase/auth-helpers-nextjs"
import { cookies } from "next/headers"
import { redirect } from "next/navigation"

export const metadata: Metadata = {
  title: "Analytics - Dashboard Tumbuhide.id",
  description: "Lihat statistik dan analytics profil Anda",
}

export default async function AnalyticsPage() {
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

      <main className="max-w-7xl mx-auto py-6 px-4 sm:px-6 lg:px-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Analytics</h1>
          <p className="text-gray-600 dark:text-gray-400">Pantau performa profil dan link Anda dengan data real-time</p>
        </div>

        <AnalyticsDashboard userId={user.id} userPlan={profile.plan} />
      </main>
    </div>
  )
}
