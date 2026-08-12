#!/usr/bin/env bash

set -euo pipefail

# Ensure required tools are available (NixOS-friendly)
info() { echo -e "\033[1;34m>\033[0m $*"; }
ok()   { echo -e "\033[1;32m✓\033[0m $*"; }
fail() { echo -e "\033[1;31m✗\033[0m $*" >&2; }

if ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    info "Dropping into nix-shell for missing dependencies (curl, jq)..."
    exec nix-shell -p curl jq --run "bash \"$0\""
fi

info "Locating repository root..."
REPO_ROOT="$(git rev-parse --show-toplevel)"
ENV_FILE="${REPO_ROOT}/.env"

if [ ! -f "$ENV_FILE" ]; then
    fail ".env file not found at ${ENV_FILE}"
    exit 1
fi

set -a
source "$ENV_FILE"
set +a

if [ -z "${OPENAI_API_KEY:-}" ]; then
    fail "OPENAI_API_KEY is not set in .env"
    exit 1
fi

info "Staging all changes..."
git add -A

info "Reading staged changes..."
DIFF=$(git diff --staged)

if [ -z "$DIFF" ]; then
    fail "No staged changes found. Stage files with 'git add' first."
    exit 1
fi
DIFF_SIZE=$(echo "$DIFF" | wc -c)
DIFF_TRUNCATED=$(echo "$DIFF" | head -c 30000)
ok "Staged diff captured (${DIFF_SIZE} bytes)"

info "Sending diff to ${OPENAI_MODEL} for commit message generation..."
RESPONSE=$(curl -s --max-time 120 "${OPENAI_BASE_URL}/chat/completions" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${OPENAI_API_KEY}" \
    -d "$(jq -n \
        --arg model "${OPENAI_MODEL}" \
        --arg diff "$DIFF_TRUNCATED" \
        '{
            model: $model,
            messages: [
                {
                    role: "system",
                    content: "You are a commit message generator. Generate a concise commit message following the Conventional Commits specification (e.g., \"feat: add user login\"). Output ONLY the commit message, no explanations, no quotes, no markdown."
                },
                {
                    role: "user",
                    content: ("Generate a commit message for this diff:\n\n" + $diff)
                }
            ],
            temperature: 0.3
        }')")

COMMIT_MSG=$(echo "$RESPONSE" | jq -r '.choices[0].message.content // empty')

if [ -z "$COMMIT_MSG" ]; then
    fail "Failed to generate commit message."
    echo "API Response: $RESPONSE"
    exit 1
fi

ok "Commit message generated"
echo ""
echo "  $COMMIT_MSG"
echo ""

info "Committing..."
git commit -m "$COMMIT_MSG"
ok "Done"
