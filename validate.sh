#!/bin/bash
set -e

echo "🔄 Fetching all branches..."
git fetch --all --quiet

# Create local branches for all remotes (CI fix)
for r in $(git branch -r | grep -v '>'); do
  git branch --track "${r#origin/}" "$r" 2>/dev/null || true
done

BRANCHES=$(git branch --format='%(refname:short)' | tr '[:upper:]' '[:lower:]')

PATH_BRANCH=$(echo "$BRANCHES" | grep 'path' | head -n 1 || true)
TRUTH_BRANCH=$(echo "$BRANCHES" | grep 'truth' | head -n 1 || true)

[ -z "$PATH_BRANCH" ] && { echo "❌ No path branch found"; exit 1; }
[ -z "$TRUTH_BRANCH" ] && { echo "❌ No truth branch found"; exit 1; }

echo "✅ Found branches: $PATH_BRANCH , $TRUTH_BRANCH"

git checkout main >/dev/null 2>&1

FILES=$(ls | tr '[:upper:]' '[:lower:]')
echo "$FILES" | grep -qx "path.txt" || { echo "❌ path.txt missing"; exit 1; }
echo "$FILES" | grep -qx "truth.txt" || { echo "❌ truth.txt missing"; exit 1; }

MERGED=$(git branch --merged main | tr '[:upper:]' '[:lower:]')

echo "$MERGED" | grep -q "$PATH_BRANCH" || { echo "❌ path branch not merged"; exit 1; }
echo "$MERGED" | grep -q "$TRUTH_BRANCH" || { echo "❌ truth branch not merged"; exit 1; }

echo "🎉 LEVEL PASSED"
