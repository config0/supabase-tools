FROM postgres:16-alpine

RUN apk add --no-cache curl bash jq

# Install Supabase CLI
RUN curl -sSL https://github.com/supabase/cli/releases/latest/download/supabase_linux_amd64.apk \
      -o /tmp/supabase.apk \
    && apk add --allow-untrusted /tmp/supabase.apk \
    && rm /tmp/supabase.apk

COPY entrypoint.sh /usr/local/bin/supabase-tools
COPY scripts/ /usr/local/lib/supabase-tools/
RUN chmod +x /usr/local/bin/supabase-tools /usr/local/lib/supabase-tools/*.sh

ENTRYPOINT ["supabase-tools"]
CMD ["--help"]
