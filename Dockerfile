FROM postgres:16-alpine

RUN apk add --no-cache curl bash jq

# Install Supabase CLI via tarball (portable across Alpine versions)
RUN SUPABASE_VERSION=$(curl -s https://api.github.com/repos/supabase/cli/releases/latest | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/') \
    && curl -sSL "https://github.com/supabase/cli/releases/download/v${SUPABASE_VERSION}/supabase_linux_amd64.tar.gz" \
       -o /tmp/supabase.tar.gz \
    && tar -xzf /tmp/supabase.tar.gz -C /usr/local/bin supabase \
    && rm /tmp/supabase.tar.gz \
    && supabase --version

COPY entrypoint.sh /usr/local/bin/supabase-tools
COPY scripts/ /usr/local/lib/supabase-tools/
RUN chmod +x /usr/local/bin/supabase-tools /usr/local/lib/supabase-tools/*.sh

ENTRYPOINT ["supabase-tools"]
CMD ["--help"]
