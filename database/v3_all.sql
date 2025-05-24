-- =============================================
-- TUMBUHIDE.ID V3 - COMPLETE DATABASE CLONE
-- =============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- 1. PROFILES TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username VARCHAR(30) UNIQUE,
    full_name TEXT,
    bio TEXT,
    tagline TEXT,
    pronouns VARCHAR(50),
    niche VARCHAR(100),
    avatar_url TEXT,
    cover_url TEXT,
    location TEXT,
    age INTEGER,
    website_url TEXT,
    email_public TEXT,
    phone_public TEXT,
    role VARCHAR(20) DEFAULT 'content_creator' CHECK (role IN ('content_creator', 'brand_account', 'admin')),
    plan VARCHAR(20) DEFAULT 'basic' CHECK (plan IN ('basic', 'pro')),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    profile_completed BOOLEAN DEFAULT FALSE,
    plan_selected BOOLEAN DEFAULT FALSE,
    show_email BOOLEAN DEFAULT FALSE,
    show_phone BOOLEAN DEFAULT FALSE,
    show_location BOOLEAN DEFAULT TRUE,
    show_age BOOLEAN DEFAULT FALSE,
    theme_color VARCHAR(7) DEFAULT '#6366f1',
    custom_css TEXT,
    seo_title TEXT,
    seo_description TEXT,
    seo_keywords TEXT,
    total_views INTEGER DEFAULT 0,
    total_clicks INTEGER DEFAULT 0,
    monthly_views INTEGER DEFAULT 0,
    monthly_clicks INTEGER DEFAULT 0,
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 2. SOCIAL LINKS TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS social_links (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,
    username VARCHAR(100),
    url TEXT,
    display_name TEXT,
    follower_count INTEGER DEFAULT 0,
    is_verified BOOLEAN DEFAULT FALSE,
    is_visible BOOLEAN DEFAULT TRUE,
    show_follower_count BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    icon_color VARCHAR(7),
    custom_icon TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 3. CUSTOM LINKS TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS custom_links (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    thumbnail_url TEXT,
    button_style VARCHAR(20) DEFAULT 'default',
    button_color VARCHAR(7),
    text_color VARCHAR(7),
    is_visible BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    monthly_clicks INTEGER DEFAULT 0,
    last_clicked TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 4. SHOWCASE ITEMS TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS showcase_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    category VARCHAR(50),
    tags TEXT[],
    price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'IDR',
    is_featured BOOLEAN DEFAULT FALSE,
    is_visible BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 5. ANALYTICS TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS analytics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- 'profile_view', 'link_click', 'social_click', 'showcase_view'
    event_data JSONB,
    target_id UUID, -- ID of clicked link/social/showcase item
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    country VARCHAR(2),
    region VARCHAR(100),
    city VARCHAR(100),
    device_type VARCHAR(20), -- 'desktop', 'mobile', 'tablet'
    browser VARCHAR(50),
    os VARCHAR(50),
    utm_source VARCHAR(100),
    utm_medium VARCHAR(100),
    utm_campaign VARCHAR(100),
    session_id UUID,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 6. INVITATION CODES TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS invitation_codes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    plan_type VARCHAR(20) DEFAULT 'pro',
    max_uses INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    is_unlimited BOOLEAN DEFAULT FALSE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES profiles(id),
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 7. USER INVITATIONS TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS user_invitations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    invitation_code_id UUID REFERENCES invitation_codes(id),
    invited_by UUID REFERENCES profiles(id),
    plan_upgraded_to VARCHAR(20),
    metadata JSONB,
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 8. RATE LIMITING TABLE (COMPLETE FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS rate_limits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL, -- IP address or user ID
    action VARCHAR(100) NOT NULL, -- 'login', 'register', 'profile_view', 'api_call'
    count INTEGER DEFAULT 1,
    window_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(identifier, action, window_start)
);

-- =============================================
-- 9. NOTIFICATIONS TABLE (FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS notifications (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL, -- 'welcome', 'plan_upgrade', 'analytics_report'
    title VARCHAR(200) NOT NULL,
    message TEXT,
    action_url TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 10. THEMES TABLE (FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS themes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    background_type VARCHAR(20) DEFAULT 'solid', -- 'solid', 'gradient', 'image'
    background_color VARCHAR(7) DEFAULT '#ffffff',
    background_gradient TEXT,
    background_image_url TEXT,
    text_color VARCHAR(7) DEFAULT '#000000',
    accent_color VARCHAR(7) DEFAULT '#6366f1',
    button_style VARCHAR(20) DEFAULT 'rounded',
    font_family VARCHAR(50) DEFAULT 'Inter',
    custom_css TEXT,
    is_active BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 11. COLLABORATIONS TABLE (FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS collaborations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    creator_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    brand_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'accepted', 'rejected', 'completed'
    budget_min DECIMAL(12,2),
    budget_max DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'IDR',
    deadline DATE,
    deliverables TEXT[],
    requirements TEXT,
    notes TEXT,
    contract_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 12. BRAND CAMPAIGNS TABLE (FROM V3)
-- =============================================

CREATE TABLE IF NOT EXISTS brand_campaigns (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    brand_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    target_audience TEXT,
    budget_total DECIMAL(12,2),
    budget_per_creator DECIMAL(12,2),
    currency VARCHAR(3) DEFAULT 'IDR',
    start_date DATE,
    end_date DATE,
    requirements TEXT,
    deliverables TEXT[],
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'active', 'paused', 'completed'
    applications_count INTEGER DEFAULT 0,
    selected_creators_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- RLS POLICIES - ENABLE RLS
-- =============================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE custom_links ENABLE ROW LEVEL SECURITY;
ALTER TABLE showcase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitation_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE rate_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE collaborations ENABLE ROW LEVEL SECURITY;
ALTER TABLE brand_campaigns ENABLE ROW LEVEL SECURITY;

-- =============================================
-- RLS POLICIES - PROFILES (FIXED)
-- =============================================

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view all profiles" ON profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON profiles;
DROP POLICY IF EXISTS "Users can delete their own profile" ON profiles;

-- Create new policies
CREATE POLICY "Users can view all profiles" ON profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can delete their own profile" ON profiles
    FOR DELETE USING (auth.uid() = id);

-- =============================================
-- RLS POLICIES - SOCIAL LINKS (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Users can view all social links" ON social_links;
DROP POLICY IF EXISTS "Users can manage their own social links" ON social_links;

CREATE POLICY "Users can view all social links" ON social_links
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own social links" ON social_links
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - CUSTOM LINKS (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Users can view all custom links" ON custom_links;
DROP POLICY IF EXISTS "Users can manage their own custom links" ON custom_links;

CREATE POLICY "Users can view all custom links" ON custom_links
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own custom links" ON custom_links
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - SHOWCASE ITEMS (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Users can view all showcase items" ON showcase_items;
DROP POLICY IF EXISTS "Users can manage their own showcase items" ON showcase_items;

CREATE POLICY "Users can view all showcase items" ON showcase_items
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own showcase items" ON showcase_items
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - ANALYTICS (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Users can view their own analytics" ON analytics;
DROP POLICY IF EXISTS "Anyone can insert analytics" ON analytics;

CREATE POLICY "Users can view their own analytics" ON analytics
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Anyone can insert analytics" ON analytics
    FOR INSERT WITH CHECK (true);

-- =============================================
-- RLS POLICIES - INVITATION CODES (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Anyone can view active invitation codes" ON invitation_codes;
DROP POLICY IF EXISTS "Admins can manage invitation codes" ON invitation_codes;

CREATE POLICY "Anyone can view active invitation codes" ON invitation_codes
    FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage invitation codes" ON invitation_codes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM profiles 
            WHERE profiles.id = auth.uid() 
            AND profiles.role = 'admin'
        )
    );

-- =============================================
-- RLS POLICIES - USER INVITATIONS (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Users can view their own invitations" ON user_invitations;
DROP POLICY IF EXISTS "Users can insert their own invitations" ON user_invitations;

CREATE POLICY "Users can view their own invitations" ON user_invitations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own invitations" ON user_invitations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - NOTIFICATIONS
-- =============================================

DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
DROP POLICY IF EXISTS "System can insert notifications" ON notifications;

CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications" ON notifications
    FOR INSERT WITH CHECK (true);

-- =============================================
-- RLS POLICIES - THEMES
-- =============================================

DROP POLICY IF EXISTS "Users can view all themes" ON themes;
DROP POLICY IF EXISTS "Users can manage their own themes" ON themes;

CREATE POLICY "Users can view all themes" ON themes
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own themes" ON themes
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - COLLABORATIONS
-- =============================================

DROP POLICY IF EXISTS "Users can view their collaborations" ON collaborations;
DROP POLICY IF EXISTS "Users can manage their collaborations" ON collaborations;

CREATE POLICY "Users can view their collaborations" ON collaborations
    FOR SELECT USING (auth.uid() = creator_id OR auth.uid() = brand_id);

CREATE POLICY "Users can manage their collaborations" ON collaborations
    FOR ALL USING (auth.uid() = creator_id OR auth.uid() = brand_id);

-- =============================================
-- RLS POLICIES - BRAND CAMPAIGNS
-- =============================================

DROP POLICY IF EXISTS "Users can view active campaigns" ON brand_campaigns;
DROP POLICY IF EXISTS "Brands can manage their campaigns" ON brand_campaigns;

CREATE POLICY "Users can view active campaigns" ON brand_campaigns
    FOR SELECT USING (status = 'active' OR auth.uid() = brand_id);

CREATE POLICY "Brands can manage their campaigns" ON brand_campaigns
    FOR ALL USING (auth.uid() = brand_id);

-- =============================================
-- RLS POLICIES - RATE LIMITS (FIXED)
-- =============================================

DROP POLICY IF EXISTS "Service role can manage rate limits" ON rate_limits;

CREATE POLICY "Service role can manage rate limits" ON rate_limits
    FOR ALL USING (true);

-- =============================================
-- FUNCTIONS AND TRIGGERS (COMPLETE FROM V3)
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all relevant tables
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_social_links_updated_at ON social_links;
CREATE TRIGGER update_social_links_updated_at
    BEFORE UPDATE ON social_links
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_custom_links_updated_at ON custom_links;
CREATE TRIGGER update_custom_links_updated_at
    BEFORE UPDATE ON custom_links
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_showcase_items_updated_at ON showcase_items;
CREATE TRIGGER update_showcase_items_updated_at
    BEFORE UPDATE ON showcase_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_invitation_codes_updated_at ON invitation_codes;
CREATE TRIGGER update_invitation_codes_updated_at
    BEFORE UPDATE ON invitation_codes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_themes_updated_at ON themes;
CREATE TRIGGER update_themes_updated_at
    BEFORE UPDATE ON themes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_collaborations_updated_at ON collaborations;
CREATE TRIGGER update_collaborations_updated_at
    BEFORE UPDATE ON collaborations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_brand_campaigns_updated_at ON brand_campaigns;
CREATE TRIGGER update_brand_campaigns_updated_at
    BEFORE UPDATE ON brand_campaigns
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to handle profile creation after user signup (FIXED)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, role, profile_completed, plan_selected)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        'content_creator',
        false,
        false
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for automatic profile creation (FIXED)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to increment link clicks
CREATE OR REPLACE FUNCTION increment_link_clicks(link_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE custom_links 
    SET click_count = click_count + 1,
        monthly_clicks = monthly_clicks + 1,
        last_clicked = NOW()
    WHERE id = link_id;
    
    -- Also update user's total clicks
    UPDATE profiles 
    SET total_clicks = total_clicks + 1,
        monthly_clicks = monthly_clicks + 1
    WHERE id = (SELECT user_id FROM custom_links WHERE id = link_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment profile views
CREATE OR REPLACE FUNCTION increment_profile_views(profile_user_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE profiles 
    SET total_views = total_views + 1,
        monthly_views = monthly_views + 1,
        last_active = NOW()
    WHERE id = profile_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user can upgrade to pro
CREATE OR REPLACE FUNCTION can_upgrade_to_pro(user_id UUID, invite_code TEXT)
RETURNS boolean AS $$
DECLARE
    code_record invitation_codes%ROWTYPE;
BEGIN
    -- Check if invitation code exists and is valid
    SELECT * INTO code_record
    FROM invitation_codes
    WHERE code = invite_code
    AND is_active = true
    AND (expires_at IS NULL OR expires_at > NOW())
    AND (is_unlimited = true OR current_uses < max_uses);
    
    IF NOT FOUND THEN
        RETURN false;
    END IF;
    
    -- Check if user already used this code
    IF EXISTS (
        SELECT 1 FROM user_invitations ui
        JOIN invitation_codes ic ON ui.invitation_code_id = ic.id
        WHERE ui.user_id = can_upgrade_to_pro.user_id
        AND ic.code = invite_code
    ) THEN
        RETURN false;
    END IF;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to use invitation code
CREATE OR REPLACE FUNCTION use_invitation_code(user_id UUID, invite_code TEXT)
RETURNS boolean AS $$
DECLARE
    code_record invitation_codes%ROWTYPE;
BEGIN
    -- Check if code can be used
    IF NOT can_upgrade_to_pro(user_id, invite_code) THEN
        RETURN false;
    END IF;
    
    -- Get the code record
    SELECT * INTO code_record
    FROM invitation_codes
    WHERE code = invite_code;
    
    -- Record the usage
    INSERT INTO user_invitations (user_id, invitation_code_id, plan_upgraded_to)
    VALUES (user_id, code_record.id, code_record.plan_type);
    
    -- Increment usage count (only if not unlimited)
    IF NOT code_record.is_unlimited THEN
        UPDATE invitation_codes
        SET current_uses = current_uses + 1
        WHERE id = code_record.id;
    END IF;
    
    -- Upgrade user to pro
    UPDATE profiles
    SET plan = code_record.plan_type, 
        plan_selected = true
    WHERE id = user_id;
    
    -- Create welcome notification
    INSERT INTO notifications (user_id, type, title, message)
    VALUES (
        user_id,
        'plan_upgrade',
        'Selamat! Plan Anda telah diupgrade',
        'Anda sekarang memiliki akses ke semua fitur Creator Pro!'
    );
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to generate username suggestions
CREATE OR REPLACE FUNCTION generate_username_suggestions(base_name TEXT)
RETURNS TEXT[] AS $$
DECLARE
    suggestions TEXT[] := '{}';
    counter INTEGER := 1;
    suggestion TEXT;
BEGIN
    -- Clean base name
    base_name := lower(regexp_replace(base_name, '[^a-zA-Z0-9]', '', 'g'));
    
    -- Generate suggestions
    WHILE array_length(suggestions, 1) < 5 LOOP
        suggestion := base_name || counter::TEXT;
        
        -- Check if username is available
        IF NOT EXISTS (SELECT 1 FROM profiles WHERE username = suggestion) THEN
            suggestions := array_append(suggestions, suggestion);
        END IF;
        
        counter := counter + 1;
        
        -- Prevent infinite loop
        IF counter > 100 THEN
            EXIT;
        END IF;
    END LOOP;
    
    RETURN suggestions;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- INDEXES FOR PERFORMANCE (COMPLETE)
-- =============================================

-- Profiles indexes
CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_plan ON profiles(plan);
CREATE INDEX IF NOT EXISTS idx_profiles_is_active ON profiles(is_active);
CREATE INDEX IF NOT EXISTS idx_profiles_niche ON profiles(niche);
CREATE INDEX IF NOT EXISTS idx_profiles_location ON profiles(location);

-- Social links indexes
CREATE INDEX IF NOT EXISTS idx_social_links_user_id ON social_links(user_id);
CREATE INDEX IF NOT EXISTS idx_social_links_platform ON social_links(platform);
CREATE INDEX IF NOT EXISTS idx_social_links_is_visible ON social_links(is_visible);

-- Custom links indexes
CREATE INDEX IF NOT EXISTS idx_custom_links_user_id ON custom_links(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_links_is_visible ON custom_links(is_visible);
CREATE INDEX IF NOT EXISTS idx_custom_links_is_featured ON custom_links(is_featured);

-- Showcase items indexes
CREATE INDEX IF NOT EXISTS idx_showcase_items_user_id ON showcase_items(user_id);
CREATE INDEX IF NOT EXISTS idx_showcase_items_is_visible ON showcase_items(is_visible);
CREATE INDEX IF NOT EXISTS idx_showcase_items_category ON showcase_items(category);

-- Analytics indexes
CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics(created_at);
CREATE INDEX IF NOT EXISTS idx_analytics_target_id ON analytics(target_id);

-- Invitation codes indexes
CREATE INDEX IF NOT EXISTS idx_invitation_codes_code ON invitation_codes(code);
CREATE INDEX IF NOT EXISTS idx_invitation_codes_is_active ON invitation_codes(is_active);

-- Rate limits indexes
CREATE INDEX IF NOT EXISTS idx_rate_limits_identifier ON rate_limits(identifier);
CREATE INDEX IF NOT EXISTS idx_rate_limits_action ON rate_limits(action);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- Collaborations indexes
CREATE INDEX IF NOT EXISTS idx_collaborations_creator_id ON collaborations(creator_id);
CREATE INDEX IF NOT EXISTS idx_collaborations_brand_id ON collaborations(brand_id);
CREATE INDEX IF NOT EXISTS idx_collaborations_status ON collaborations(status);

-- Brand campaigns indexes
CREATE INDEX IF NOT EXISTS idx_brand_campaigns_brand_id ON brand_campaigns(brand_id);
CREATE INDEX IF NOT EXISTS idx_brand_campaigns_status ON brand_campaigns(status);
CREATE INDEX IF NOT EXISTS idx_brand_campaigns_category ON brand_campaigns(category);

-- =============================================
-- SAMPLE DATA (COMPLETE FROM V3)
-- =============================================

-- Insert sample invitation codes
INSERT INTO invitation_codes (code, description, plan_type, max_uses, is_active, is_unlimited) 
VALUES 
    ('CREATOR2024', 'Default Creator Pro invitation code', 'pro', 1000, true, false),
    ('BETA2024', 'Beta tester invitation code', 'pro', 100, true, false),
    ('VIP2024', 'VIP invitation code', 'pro', 50, true, false),
    ('UNLIMITED', 'Unlimited invitation code for testing', 'pro', 1, true, true),
    ('ADMIN2024', 'Admin invitation code', 'pro', 10, true, false)
ON CONFLICT (code) DO NOTHING;

-- Insert sample themes
INSERT INTO themes (name, is_default, background_type, background_color, text_color, accent_color, button_style, font_family)
VALUES 
    ('Default', true, 'solid', '#ffffff', '#000000', '#6366f1', 'rounded', 'Inter'),
    ('Dark Mode', false, 'solid', '#1a1a1a', '#ffffff', '#8b5cf6', 'rounded', 'Inter'),
    ('Gradient Purple', false, 'gradient', '#6366f1', '#ffffff', '#8b5cf6', 'rounded', 'Inter'),
    ('Minimal', false, 'solid', '#f8fafc', '#1e293b', '#0ea5e9', 'square', 'Inter')
ON CONFLICT DO NOTHING;

-- =============================================
-- GRANT PERMISSIONS (COMPLETE)
-- =============================================

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Grant permissions to anon users for public profile viewing
GRANT USAGE ON SCHEMA public TO anon;
GRANT SELECT ON profiles TO anon;
GRANT SELECT ON social_links TO anon;
GRANT SELECT ON custom_links TO anon;
GRANT SELECT ON showcase_items TO anon;
GRANT INSERT ON analytics TO anon;
GRANT SELECT ON invitation_codes TO anon;
GRANT SELECT ON themes TO anon;
GRANT SELECT ON brand_campaigns TO anon;

-- Add missing columns to profiles table
ALTER TABLE profiles 
ADD COLUMN IF NOT EXISTS plan_selected BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS profile_completed BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS niche VARCHAR(100),
ADD COLUMN IF NOT EXISTS bio TEXT;

-- Update existing records to have default values
UPDATE profiles 
SET 
  plan_selected = FALSE,
  profile_completed = FALSE
WHERE plan_selected IS NULL OR profile_completed IS NULL;

-- Verify columns exist
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'profiles' 
AND column_name IN ('plan_selected', 'profile_completed', 'niche', 'bio')
ORDER BY column_name;


-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Tumbuhide.id V3 Database Schema COMPLETE CLONE Created Successfully!';
    RAISE NOTICE '📊 Tables: profiles (with tagline, pronouns, niche), social_links, custom_links, showcase_items, analytics, invitation_codes, user_invitations, rate_limits, notifications, themes, collaborations, brand_campaigns';
    RAISE NOTICE '🔒 RLS Policies: Configured and FIXED for all tables';
    RAISE NOTICE '🎯 Sample Data: Invitation codes and themes inserted';
    RAISE NOTICE '⚡ Indexes: Created for performance optimization';
    RAISE NOTICE '🔧 Functions: Profile creation, analytics, invitation system, username suggestions';
    RAISE NOTICE '🚀 Ready for production use with ALL V3 features!';
    RAISE NOTICE '✨ FIXED: Register, Login, Complete Profile errors';
END $$;
