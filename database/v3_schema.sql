-- =============================================
-- TUMBUHIDE.ID V3 DATABASE SCHEMA
-- =============================================

-- Enable RLS
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create custom types
CREATE TYPE user_role AS ENUM ('content_creator', 'brand_account', 'admin_developer', 'admin_operations');
CREATE TYPE user_plan AS ENUM ('basic', 'pro');
CREATE TYPE link_status AS ENUM ('active', 'inactive', 'scheduled');
CREATE TYPE analytics_event AS ENUM ('profile_view', 'link_click', 'social_click', 'showcase_click');

-- =============================================
-- PROFILES TABLE (Enhanced)
-- =============================================
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  username TEXT UNIQUE,
  full_name TEXT,
  tagline TEXT,
  bio TEXT,
  location TEXT,
  birth_date DATE,
  pronouns TEXT,
  avatar_url TEXT,
  cover_url TEXT,
  role user_role DEFAULT 'content_creator',
  plan user_plan DEFAULT 'basic',
  invitation_code TEXT,
  niche TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  profile_views INTEGER DEFAULT 0,
  total_clicks INTEGER DEFAULT 0,
  last_active_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- SOCIAL LINKS TABLE (Enhanced)
-- =============================================
CREATE TABLE IF NOT EXISTS social_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  platform TEXT NOT NULL,
  username TEXT,
  url TEXT NOT NULL,
  follower_count INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  status link_status DEFAULT 'active',
  click_count INTEGER DEFAULT 0,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- CUSTOM LINKS TABLE (Enhanced)
-- =============================================
CREATE TABLE IF NOT EXISTS custom_links (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  icon_url TEXT,
  is_featured BOOLEAN DEFAULT FALSE,
  status link_status DEFAULT 'active',
  click_count INTEGER DEFAULT 0,
  display_order INTEGER DEFAULT 0,
  scheduled_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- SHOWCASE ITEMS TABLE (Enhanced)
-- =============================================
CREATE TABLE IF NOT EXISTS showcase_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  platform TEXT NOT NULL,
  view_count INTEGER DEFAULT 0,
  like_count INTEGER DEFAULT 0,
  click_count INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT FALSE,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- ANALYTICS TABLE (Enhanced)
-- =============================================
CREATE TABLE IF NOT EXISTS analytics (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  event_type analytics_event NOT NULL,
  metadata JSONB DEFAULT '{}',
  ip_address INET,
  user_agent TEXT,
  referrer TEXT,
  country TEXT,
  city TEXT,
  device_type TEXT,
  browser TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- INVITATION CODES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS invitation_codes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  plan user_plan NOT NULL,
  niche TEXT,
  max_uses INTEGER DEFAULT 1,
  current_uses INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  expires_at TIMESTAMP WITH TIME ZONE,
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- USER SUBSCRIPTIONS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  plan user_plan NOT NULL,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT TRUE,
  invitation_code_used TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- RATE LIMITING TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS rate_limits (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  identifier TEXT NOT NULL,
  request_count INTEGER DEFAULT 1,
  window_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(identifier, window_start)
);

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_plan ON profiles(plan);
CREATE INDEX IF NOT EXISTS idx_profiles_active ON profiles(is_active);

CREATE INDEX IF NOT EXISTS idx_social_links_user_id ON social_links(user_id);
CREATE INDEX IF NOT EXISTS idx_social_links_platform ON social_links(platform);
CREATE INDEX IF NOT EXISTS idx_social_links_status ON social_links(status);
CREATE INDEX IF NOT EXISTS idx_social_links_order ON social_links(user_id, display_order);

CREATE INDEX IF NOT EXISTS idx_custom_links_user_id ON custom_links(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_links_status ON custom_links(status);
CREATE INDEX IF NOT EXISTS idx_custom_links_order ON custom_links(user_id, display_order);

CREATE INDEX IF NOT EXISTS idx_showcase_user_id ON showcase_items(user_id);
CREATE INDEX IF NOT EXISTS idx_showcase_order ON showcase_items(user_id, display_order);

CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_user_date ON analytics(user_id, created_at);

CREATE INDEX IF NOT EXISTS idx_invitation_codes_code ON invitation_codes(code);
CREATE INDEX IF NOT EXISTS idx_invitation_codes_active ON invitation_codes(is_active);

CREATE INDEX IF NOT EXISTS idx_rate_limits_identifier ON rate_limits(identifier);
CREATE INDEX IF NOT EXISTS idx_rate_limits_window ON rate_limits(window_start);

-- =============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE showcase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitation_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Public profiles are viewable by everyone" ON profiles
  FOR SELECT USING (is_active = true);

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Social links policies
CREATE POLICY "Social links are viewable by everyone" ON social_links
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = social_links.user_id 
      AND profiles.is_active = true
    )
  );

CREATE POLICY "Users can manage own social links" ON social_links
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = social_links.user_id 
      AND profiles.id = auth.uid()
    )
  );

-- Custom links policies
CREATE POLICY "Custom links are viewable by everyone" ON custom_links
  FOR SELECT USING (
    status = 'active' AND
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = custom_links.user_id 
      AND profiles.is_active = true
    )
  );

CREATE POLICY "Users can manage own custom links" ON custom_links
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = custom_links.user_id 
      AND profiles.id = auth.uid()
    )
  );

-- Showcase items policies
CREATE POLICY "Showcase items are viewable by everyone" ON showcase_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = showcase_items.user_id 
      AND profiles.is_active = true
    )
  );

CREATE POLICY "Users can manage own showcase items" ON showcase_items
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = showcase_items.user_id 
      AND profiles.id = auth.uid()
    )
  );

-- Analytics policies
CREATE POLICY "Users can view own analytics" ON analytics
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = analytics.user_id 
      AND profiles.id = auth.uid()
    )
  );

CREATE POLICY "Analytics can be inserted by anyone" ON analytics
  FOR INSERT WITH CHECK (true);

-- Invitation codes policies
CREATE POLICY "Active invitation codes are viewable by everyone" ON invitation_codes
  FOR SELECT USING (is_active = true AND (expires_at IS NULL OR expires_at > NOW()));

-- User subscriptions policies
CREATE POLICY "Users can view own subscriptions" ON user_subscriptions
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles 
      WHERE profiles.id = user_subscriptions.user_id 
      AND profiles.id = auth.uid()
    )
  );

-- =============================================
-- FUNCTIONS AND TRIGGERS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_social_links_updated_at BEFORE UPDATE ON social_links
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_custom_links_updated_at BEFORE UPDATE ON custom_links
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_showcase_items_updated_at BEFORE UPDATE ON showcase_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment profile views
CREATE OR REPLACE FUNCTION increment_profile_views()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.event_type = 'profile_view' THEN
    UPDATE profiles 
    SET profile_views = profile_views + 1,
        last_active_at = NOW()
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER increment_profile_views_trigger
  AFTER INSERT ON analytics
  FOR EACH ROW EXECUTE FUNCTION increment_profile_views();

-- Function to increment click counts
CREATE OR REPLACE FUNCTION increment_click_counts()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.event_type = 'link_click' THEN
    -- Update total clicks in profile
    UPDATE profiles 
    SET total_clicks = total_clicks + 1
    WHERE id = NEW.user_id;
    
    -- Update specific link click count based on metadata
    IF (NEW.metadata->>'link_type') = 'social' THEN
      UPDATE social_links 
      SET click_count = click_count + 1
      WHERE id = (NEW.metadata->>'link_id')::UUID;
    ELSIF (NEW.metadata->>'link_type') = 'custom' THEN
      UPDATE custom_links 
      SET click_count = click_count + 1
      WHERE id = (NEW.metadata->>'link_id')::UUID;
    ELSIF (NEW.metadata->>'link_type') = 'showcase' THEN
      UPDATE showcase_items 
      SET click_count = click_count + 1
      WHERE id = (NEW.metadata->>'link_id')::UUID;
    END IF;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER increment_click_counts_trigger
  AFTER INSERT ON analytics
  FOR EACH ROW EXECUTE FUNCTION increment_click_counts();

-- =============================================
-- SEED DATA
-- =============================================

-- Insert default invitation codes
INSERT INTO invitation_codes (code, plan, niche, max_uses, is_active) VALUES
('CREATOR2024', 'pro', 'general', 1000, true),
('TUMBUHIDE2024', 'pro', 'general', 1000, true),
('INFLUENCER2024', 'pro', 'influencer', 500, true),
('BRAND2024', 'pro', 'brand', 100, true)
ON CONFLICT (code) DO NOTHING;

-- =============================================
-- CLEANUP OLD DATA (Optional)
-- =============================================

-- Clean up old analytics data (older than 1 year)
CREATE OR REPLACE FUNCTION cleanup_old_analytics()
RETURNS void AS $$
BEGIN
  DELETE FROM analytics 
  WHERE created_at < NOW() - INTERVAL '1 year';
END;
$$ language 'plpgsql';

-- Clean up old rate limit data (older than 1 day)
CREATE OR REPLACE FUNCTION cleanup_old_rate_limits()
RETURNS void AS $$
BEGIN
  DELETE FROM rate_limits 
  WHERE window_start < NOW() - INTERVAL '1 day';
END;
$$ language 'plpgsql';
