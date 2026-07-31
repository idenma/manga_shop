#!/usr/bin/env bash
# エラーが発生したら処理を中断する
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
# データベースのマイグレーションを実行
bundle exec rails db:migrate