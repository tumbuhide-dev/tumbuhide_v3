import { DEFAULTS } from "./constants"

export interface AvatarOptions {
  seed?: string
  style?: "avataaars" | "personas" | "initials" | "bottts" | "identicon"
  backgroundColor?: string
  size?: number
}

export function generateAvatar(options: AvatarOptions = {}): string {
  const { seed = "default", style = "avataaars", backgroundColor = "random", size = 200 } = options

  // Primary API - DiceBear
  const diceBearUrl = `${DEFAULTS.AVATAR_API}?seed=${encodeURIComponent(seed)}&size=${size}&backgroundColor=${backgroundColor}`

  // Backup API - UI Avatars
  const uiAvatarsUrl = `${DEFAULTS.AVATAR_API_BACKUP}/?name=${encodeURIComponent(seed)}&size=${size}&background=random&color=fff&bold=true`

  // Return primary with fallback
  return diceBearUrl
}

export function generateAvatarFromName(name: string): string {
  return generateAvatar({
    seed: name,
    style: "avataaars",
    backgroundColor: "random",
  })
}

export function generateAvatarFromUsername(username: string): string {
  return generateAvatar({
    seed: username,
    style: "personas",
    backgroundColor: "random",
  })
}

// Fallback untuk UI Avatars jika DiceBear gagal
export function getFallbackAvatar(name: string, size = 200): string {
  const initials = name
    .split(" ")
    .map((n) => n[0])
    .join("")
    .toUpperCase()
    .slice(0, 2)

  return `${DEFAULTS.AVATAR_API_BACKUP}/?name=${encodeURIComponent(initials)}&size=${size}&background=8B5CF6&color=fff&bold=true`
}

// Generate random avatar untuk demo
export function generateRandomAvatar(): string {
  const randomSeed = Math.random().toString(36).substring(7)
  return generateAvatar({
    seed: randomSeed,
    style: "avataaars",
  })
}
