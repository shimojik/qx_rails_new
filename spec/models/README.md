# モデル仕様ドキュメント

## User (ユーザー)
- Deviseを使用した認証
- ChatRoomsとCreationsを持つ

## ChatRoom (チャットルーム)
- ユーザーに所属
- メッセージを持つ
- UidModuleを使用してUID生成

## Message (メッセージ)
- チャットルームに所属
- 内容と送信者タイプ（人間またはAI）を持つ
- 作成日時順に取得するスコープあり

## Creation (作成物)
- ユーザーに所属
- UidModuleを使用してUID生成
- AIサービスとAI評価サービスの名前を保持
