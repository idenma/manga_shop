#!/usr/bin/env bash
# エラーが発生したら処理を中断する
set -o errexit
set -o pipefail

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Build 時に DATABASE_URL が未設定のケースでは migrate をスキップする
if [ -n "${DATABASE_URL:-}" ]; then
	bundle exec rails db:migrate
else
	echo "[render-build] DATABASE_URL が未設定のため db:migrate をスキップしました。"
	echo "[render-build] Render の Pre-Deploy Command で 'bundle exec rails db:migrate' を実行してください。"
fi