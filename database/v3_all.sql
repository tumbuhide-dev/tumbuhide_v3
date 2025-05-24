-- =============================================
-- TUMBUHIDE.ID V3 - COMPLETE DATABASE SCHEMA
-- =============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =============================================
-- 1. PROFILES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS profiles (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    username VARCHAR(30) UNIQUE,
    full_name TEXT,
    bio TEXT,
    avatar_url TEXT,
    cover_url TEXT,
    location TEXT,
    age INTEGER,
    role VARCHAR(20) DEFAULT 'content_creator' CHECK (role IN ('content_creator', 'brand_account', 'admin')),
    plan VARCHAR(20) DEFAULT 'basic' CHECK (plan IN ('basic', 'pro')),
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    profile_completed BOOLEAN DEFAULT FALSE,
    plan_selected BOOLEAN DEFAULT FALSE,
    total_views INTEGER DEFAULT 0,
    total_clicks INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 2. SOCIAL LINKS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS social_links (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    platform VARCHAR(50) NOT NULL,
    username VARCHAR(100),
    url TEXT,
    is_visible BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 3. CUSTOM LINKS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS custom_links (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    is_visible BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    click_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 4. SHOWCASE ITEMS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS showcase_items (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    title VARCHAR(100) NOT NULL,
    description TEXT,
    image_url TEXT,
    link_url TEXT,
    category VARCHAR(50),
    is_visible BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 5. ANALYTICS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS analytics (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    event_type VARCHAR(50) NOT NULL, -- 'profile_view', 'link_click', 'social_click'
    event_data JSONB,
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    country VARCHAR(2),
    city VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 6. INVITATION CODES TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS invitation_codes (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    max_uses INTEGER DEFAULT 1,
    current_uses INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 7. USER INVITATIONS TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS user_invitations (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
    invitation_code_id UUID REFERENCES invitation_codes(id),
    used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =============================================
-- 8. RATE LIMITING TABLE
-- =============================================

CREATE TABLE IF NOT EXISTS rate_limits (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    identifier VARCHAR(255) NOT NULL, -- IP address or user ID
    action VARCHAR(100) NOT NULL, -- 'login', 'register', 'profile_view'
    count INTEGER DEFAULT 1,
    window_start TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(identifier, action, window_start)
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

-- =============================================
-- RLS POLICIES - PROFILES
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
-- RLS POLICIES - SOCIAL LINKS
-- =============================================

DROP POLICY IF EXISTS "Users can view all social links" ON social_links;
DROP POLICY IF EXISTS "Users can manage their own social links" ON social_links;

CREATE POLICY "Users can view all social links" ON social_links
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own social links" ON social_links
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - CUSTOM LINKS
-- =============================================

DROP POLICY IF EXISTS "Users can view all custom links" ON custom_links;
DROP POLICY IF EXISTS "Users can manage their own custom links" ON custom_links;

CREATE POLICY "Users can view all custom links" ON custom_links
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own custom links" ON custom_links
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - SHOWCASE ITEMS
-- =============================================

DROP POLICY IF EXISTS "Users can view all showcase items" ON showcase_items;
DROP POLICY IF EXISTS "Users can manage their own showcase items" ON showcase_items;

CREATE POLICY "Users can view all showcase items" ON showcase_items
    FOR SELECT USING (true);

CREATE POLICY "Users can manage their own showcase items" ON showcase_items
    FOR ALL USING (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - ANALYTICS
-- =============================================

DROP POLICY IF EXISTS "Users can view their own analytics" ON analytics;
DROP POLICY IF EXISTS "Anyone can insert analytics" ON analytics;

CREATE POLICY "Users can view their own analytics" ON analytics
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Anyone can insert analytics" ON analytics
    FOR INSERT WITH CHECK (true);

-- =============================================
-- RLS POLICIES - INVITATION CODES
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
-- RLS POLICIES - USER INVITATIONS
-- =============================================

DROP POLICY IF EXISTS "Users can view their own invitations" ON user_invitations;
DROP POLICY IF EXISTS "Users can insert their own invitations" ON user_invitations;

CREATE POLICY "Users can view their own invitations" ON user_invitations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own invitations" ON user_invitations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =============================================
-- RLS POLICIES - RATE LIMITS
-- =============================================

DROP POLICY IF EXISTS "Service role can manage rate limits" ON rate_limits;

CREATE POLICY "Service role can manage rate limits" ON rate_limits
    FOR ALL USING (true);

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

-- Apply updated_at triggers
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

-- Function to handle profile creation after user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, role)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        'content_creator'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for automatic profile creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to increment link clicks
CREATE OR REPLACE FUNCTION increment_link_clicks(link_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE custom_links 
    SET click_count = click_count + 1 
    WHERE id = link_id;
    
    -- Also update user's total clicks
    UPDATE profiles 
    SET total_clicks = total_clicks + 1 
    WHERE id = (SELECT user_id FROM custom_links WHERE id = link_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to increment profile views
CREATE OR REPLACE FUNCTION increment_profile_views(profile_user_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE profiles 
    SET total_views = total_views + 1 
    WHERE id = profile_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- INDEXES FOR PERFORMANCE
-- =============================================

CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);
CREATE INDEX IF NOT EXISTS idx_profiles_plan ON profiles(plan);
CREATE INDEX IF NOT EXISTS idx_profiles_is_active ON profiles(is_active);

CREATE INDEX IF NOT EXISTS idx_social_links_user_id ON social_links(user_id);
CREATE INDEX IF NOT EXISTS idx_social_links_platform ON social_links(platform);

CREATE INDEX IF NOT EXISTS idx_custom_links_user_id ON custom_links(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_links_is_visible ON custom_links(is_visible);

CREATE INDEX IF NOT EXISTS idx_showcase_items_user_id ON showcase_items(user_id);
CREATE INDEX IF NOT EXISTS idx_showcase_items_is_visible ON showcase_items(is_visible);

CREATE INDEX IF NOT EXISTS idx_analytics_user_id ON analytics(user_id);
CREATE INDEX IF NOT EXISTS idx_analytics_event_type ON analytics(event_type);
CREATE INDEX IF NOT EXISTS idx_analytics_created_at ON analytics(created_at);

CREATE INDEX IF NOT EXISTS idx_invitation_codes_code ON invitation_codes(code);
CREATE INDEX IF NOT EXISTS idx_invitation_codes_is_active ON invitation_codes(is_active);

CREATE INDEX IF NOT EXISTS idx_rate_limits_identifier ON rate_limits(identifier);
CREATE INDEX IF NOT EXISTS idx_rate_limits_action ON rate_limits(action);

-- =============================================
-- SAMPLE DATA
-- =============================================

-- Insert sample invitation codes
INSERT INTO invitation_codes (code, description, max_uses, is_active) 
VALUES 
    ('CREATOR2024', 'Default Creator Pro invitation code', 1000, true),
    ('BETA2024', 'Beta tester invitation code', 100, true),
    ('VIP2024', 'VIP invitation code', 50, true)
ON CONFLICT (code) DO NOTHING;

-- Insert sample admin user (will be created when first admin registers)
-- This is handled by the trigger, so no manual insert needed

-- =============================================
-- SECURITY FUNCTIONS
-- =============================================

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
    AND current_uses < max_uses;
    
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
    INSERT INTO user_invitations (user_id, invitation_code_id)
    VALUES (user_id, code_record.id);
    
    -- Increment usage count
    UPDATE invitation_codes
    SET current_uses = current_uses + 1
    WHERE id = code_record.id;
    
    -- Upgrade user to pro
    UPDATE profiles
    SET plan = 'pro', plan_selected = true
    WHERE id = user_id;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- GRANT PERMISSIONS
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

-- =============================================
-- COMPLETION MESSAGE
-- =============================================

DO $$
BEGIN
    RAISE NOTICE '✅ Tumbuhide.id V3 Database Schema Created Successfully!';
    RAISE NOTICE '📊 Tables: profiles, social_links, custom_links, showcase_items, analytics, invitation_codes, user_invitations, rate_limits';
    RAISE NOTICE '🔒 RLS Policies: Configured for all tables';
    RAISE NOTICE '🎯 Sample Data: Invitation codes inserted';
    RAISE NOTICE '⚡ Indexes: Created for performance optimization';
    RAISE NOTICE '🔧 Functions: Profile creation, analytics, invitation system';
    RAISE NOTICE '🚀 Ready for production use!';
END $$;
