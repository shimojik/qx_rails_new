# README

## RuboCopの実行方法
`bundle exec rubocop`

## RSpecの実行方法
`bundle exec rspec`

## ローカルでRuboCopとRSpecを自動実行するための設定方法
1. `.git/hooks`ディレクトリに移動します：
`cd ~/my_project`
2. `pre-commit.sample`というファイルを`pre-commit`という名前に変更します：
`mv pre-commit.sample pre-commit`
3. `pre-commit`ファイルを開き、以下を追記します：
```
#!/bin/sh
bundle exec rubocop
bundle exec rspec
```
#!/bin/shのすぐ下に追記
4. `.git/hooks`ディレクトリで以下を実行し、フックスクリプトに実行権限を与えます
`chmod +x pre-commit`

## Tailwindのビルド
`rails tailwindcss:watch`