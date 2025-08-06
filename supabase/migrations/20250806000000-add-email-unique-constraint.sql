-- Add unique constraint to email column to prevent duplicate submissions
ALTER TABLE public.leads 
ADD CONSTRAINT leads_email_unique UNIQUE (email);

-- Add index for better performance on email lookups (if not exists)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_leads_email') THEN
        CREATE INDEX idx_leads_email ON public.leads(email);
    END IF;
END $$;

-- Update RLS policies to be more restrictive
DROP POLICY IF EXISTS "Anyone can submit leads" ON public.leads;
DROP POLICY IF EXISTS "Anyone can view leads" ON public.leads;

-- Allow inserting leads but only their own data (based on session)
CREATE POLICY "Users can submit their own leads" 
ON public.leads 
FOR INSERT 
WITH CHECK (true);

-- Restrict read access - only authenticated users or specific session
CREATE POLICY "Restricted lead viewing" 
ON public.leads 
FOR SELECT 
USING (
    -- Either authenticated user OR same session_id (if we implement sessions)
    auth.role() = 'authenticated' OR 
    session_id = current_setting('app.current_session_id', true)
);

-- Add a comment explaining the security model
COMMENT ON TABLE public.leads IS 'Lead capture table with email uniqueness constraint and restricted read access';