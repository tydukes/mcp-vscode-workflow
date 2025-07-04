#!/bin/bash

# Debug script to help troubleshoot auto-merge issues
# Usage: ./debug-auto-merge.sh [PR_NUMBER]

set -e

PR_NUMBER="${1:-}"

echo "=== AUTO-MERGE DEBUG SCRIPT ==="
echo "Date: $(date)"
echo "Repository: $(git remote get-url origin)"
echo "Current branch: $(git branch --show-current)"
echo ""

if [ -z "$PR_NUMBER" ]; then
    echo "❌ Please provide a PR number: $0 <PR_NUMBER>"
    exit 1
fi

echo "🔍 Checking PR #$PR_NUMBER..."

# Check if GitHub CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed. Please install it to use this script."
    echo "   brew install gh"
    exit 1
fi

# Check if user is authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI. Please run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is available and authenticated"
echo ""

# Get PR details
echo "📋 PR Details:"
gh pr view "$PR_NUMBER" --json title,author,headRefName,baseRefName,state,mergeable,mergeStateStatus,reviewDecision,statusCheckRollup

echo ""
echo "📋 PR Title Check:"
TITLE=$(gh pr view "$PR_NUMBER" --json title --jq '.title')
echo "Title: $TITLE"

if [[ "$TITLE" == *"[auto-merge]"* ]]; then
    echo "✅ Title contains [auto-merge] trigger"
else
    echo "❌ Title does NOT contain [auto-merge] trigger"
    echo "💡 Add [auto-merge] to the PR title to enable auto-merge"
fi

echo ""
echo "📋 Changed Files:"
gh pr view "$PR_NUMBER" --json files --jq '.files[].path'

echo ""
echo "📋 Workflow Runs:"
gh run list --workflow=auto-merge.yml --limit=5

echo ""
echo "📋 Recent Auto-merge Workflow Runs for this PR:"
gh run list --workflow=auto-merge.yml --json headBranch,conclusion,status,createdAt,url | jq -r '.[] | select(.headBranch != null) | "\(.createdAt) - \(.status) - \(.conclusion) - \(.url)"' | head -3

echo ""
echo "🔧 Troubleshooting Steps:"
echo "1. Check if PR title contains [auto-merge]"
echo "2. Verify repository has auto-merge enabled in settings"
echo "3. Check if all required status checks are passing"
echo "4. Look at auto-merge workflow run logs"
echo "5. Ensure changed files match safe patterns"
echo ""

echo "💡 To enable auto-merge manually:"
echo "   gh pr edit \"$PR_NUMBER\" --title \"$TITLE [auto-merge]\""
echo ""
echo "=== END DEBUG ==="
