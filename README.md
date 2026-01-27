# KNOTS Discourse Theme

木材・林業プロフェッショナル向けのDiscourseカスタムテーマです。Asana Forumスタイルのクリーン・モダン・プロフェッショナルなデザインを提供します。

## 対象

- **フォーラム**: community.knot-wood.jp
- **Discourse**: v3.0以上
- **対象ユーザー**: 木材・林業業界の専門家

## 機能

- **ウッドブラウンカラースキーム**: ライト・ダークモード対応
- **ウェルカムバナー**: 管理者設定で内容変更・表示切替可能
- **水平カテゴリタブ**: Asana風の横スクロール対応ナビゲーション
- **AIペルソナバッジ**: AI生成投稿にバッジ表示
- **日本語最適化**: Hiragino Sans / Noto Sans JP フォント、行間1.85
- **レスポンシブ対応**: モバイル・タブレット・デスクトップ
- **アクセシビリティ**: ARIA属性、キーボード操作、`prefers-reduced-motion`対応

## インストール

1. Discourse管理画面 > テーマ > インストール
2. リポジトリURL: `https://github.com/knot-wood/discourse-knots-theme`
3. カラースキームから「KNOTS Wood Brown」を選択

## 管理者設定

| 設定 | 説明 | デフォルト |
|------|------|-----------|
| `knots_show_welcome_banner` | バナー表示 | true |
| `knots_banner_title` | バナータイトル | KNOTSへようこそ |
| `knots_banner_subtitle` | バナーサブタイトル | 木材・林業の... |
| `knots_banner_cta_text` | CTAボタンテキスト | トピックを作成する |
| `knots_banner_cta_url` | CTAリンク先 | /new-topic |
| `knots_category_nav_style` | ナビスタイル | horizontal_tabs |
| `knots_enable_persona_badge` | AIバッジ | true |
| `knots_show_category_icons` | カテゴリアイコン | true |
| `knots_topic_list_style` | トピック一覧スタイル | clean_table |
| `knots_font_size_base` | 基本フォントサイズ | 15px |

## ディレクトリ構成

```
discourse-knots-theme/
  about.json              # テーマメタデータ・カラースキーム
  settings.yml            # 管理者設定
  LICENSE
  locales/
    ja.yml                # 日本語翻訳
  common/
    common.scss           # メインスタイルシート（全パーシャルimport）
  stylesheets/
    _variables.scss       # デザイントークン
    _header.scss          # ヘッダー
    _navigation.scss      # 水平タブナビゲーション
    _category.scss        # カテゴリボックス
    _topic-list.scss      # トピック一覧
    _topic-detail.scss    # トピック詳細
    _buttons.scss         # ボタン
    _sidebar.scss         # サイドバー
    _banner.scss          # ウェルカムバナー
    _user-card.scss       # ユーザーカード
    _forms.scss           # フォーム入力
    _tags.scss            # タグ
    _responsive.scss      # レスポンシブ
  desktop/
    desktop.scss          # デスクトップ専用
  mobile/
    mobile.scss           # モバイル専用
  javascripts/
    discourse/
      api-initializers/
        knots-theme-init.gjs  # Glimmerコンポーネント登録
      components/
        knots-category-tabs.gjs  # カテゴリタブコンポーネント
  test/
    acceptance/
      knots-theme-test.js  # QUnit受け入れテスト
```

## ライセンス

MIT License
