import { apiInitializer } from "discourse/lib/api";
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";

// =============================================================================
// KNOTS Welcome Banner Component
// =============================================================================
class KnotsWelcomeBanner extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;

  @tracked dismissed = false;
  @tracked leaving = false;

  STORAGE_KEY = "knots-banner-dismissed";

  constructor() {
    super(...arguments);
    this.dismissed = this.isDismissed;
  }

  get isDismissed() {
    if (typeof localStorage === "undefined") {
      return false;
    }
    try {
      return localStorage.getItem(this.STORAGE_KEY) === "true";
    } catch {
      return false;
    }
  }

  get shouldShow() {
    const showBanner =
      this.args.outletArgs?.model?.theme_settings?.knots_show_welcome_banner ??
      true;
    if (!showBanner) {
      return false;
    }
    if (this.dismissed) {
      return false;
    }
    const currentPath = this.router.currentRouteName;
    const isHomepage =
      currentPath === "discovery.latest" ||
      currentPath === "discovery.top" ||
      currentPath === "discovery.categories" ||
      currentPath === "index";
    return isHomepage;
  }

  get bannerTitle() {
    return (
      this.args.outletArgs?.model?.theme_settings?.knots_banner_title ??
      "KNOTSへようこそ"
    );
  }

  get bannerSubtitle() {
    return (
      this.args.outletArgs?.model?.theme_settings?.knots_banner_subtitle ??
      "木材・林業のプロフェッショナルが集うコミュニティ。知識を共有し、業界の未来を共に創りましょう。"
    );
  }

  get ctaText() {
    return (
      this.args.outletArgs?.model?.theme_settings?.knots_banner_cta_text ??
      "トピックを作成する"
    );
  }

  get ctaUrl() {
    return (
      this.args.outletArgs?.model?.theme_settings?.knots_banner_cta_url ??
      "/new-topic"
    );
  }

  @action
  dismiss() {
    this.leaving = true;
    setTimeout(() => {
      this.dismissed = true;
      try {
        localStorage.setItem(this.STORAGE_KEY, "true");
      } catch {
        // localStorage not available
      }
    }, 300);
  }

  <template>
    {{#if this.shouldShow}}
      <div
        class="knots-welcome-banner
          {{if this.leaving 'knots-welcome-banner--leaving' 'knots-welcome-banner--entering'}}"
        role="banner"
        aria-label={{this.bannerTitle}}
      >
        <button
          class="knots-welcome-banner__dismiss"
          {{on "click" this.dismiss}}
          aria-label="閉じる"
          type="button"
        >
          ✕
        </button>
        <div class="knots-welcome-banner__content">
          <h2 class="knots-welcome-banner__title">{{this.bannerTitle}}</h2>
          <p class="knots-welcome-banner__subtitle">{{this.bannerSubtitle}}</p>
          <a class="knots-welcome-banner__cta" href={{this.ctaUrl}}>
            {{this.ctaText}}
          </a>
        </div>
      </div>
    {{/if}}
  </template>
}

// =============================================================================
// KNOTS Category Nav Component
// =============================================================================
class KnotsCategoryNav extends Component {
  @service site;
  @service router;

  @tracked scrollable = false;

  get categories() {
    const siteCategories = this.site.categories ?? [];
    return siteCategories
      .filter((cat) => !cat.parent_category_id)
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0))
      .slice(0, 12);
  }

  get currentCategorySlug() {
    const route = this.router.currentRoute;
    if (route?.params?.category_slug_path_with_id) {
      return route.params.category_slug_path_with_id.split("/")[0];
    }
    return null;
  }

  @action
  isActive(category) {
    return category.slug === this.currentCategorySlug;
  }

  safeColor(color) {
    if (!color || !/^[0-9A-Fa-f]{3,6}$/.test(color)) {
      return "transparent";
    }
    return `#${color}`;
  }

  @action
  navigateToCategory(category, event) {
    event.preventDefault();
    this.router.transitionTo("discovery.category", {
      category_slug_path_with_id: `${category.slug}/${category.id}`,
    });
  }

  @action
  scrollLeft() {
    const container = document.querySelector(".knots-category-tabs");
    if (container) {
      container.scrollBy({ left: -200, behavior: "smooth" });
    }
  }

  @action
  scrollRight() {
    const container = document.querySelector(".knots-category-tabs");
    if (container) {
      container.scrollBy({ left: 200, behavior: "smooth" });
    }
  }

  <template>
    {{#if this.categories.length}}
      <nav class="knots-category-tabs" aria-label="カテゴリナビゲーション">
        <button
          class="knots-category-tabs__scroll-left"
          {{on "click" this.scrollLeft}}
          aria-label="左にスクロール"
          type="button"
        >
          ‹
        </button>

        <a
          class="knots-category-tabs__tab
            {{unless this.currentCategorySlug 'knots-category-tabs__tab--active'}}"
          href="/"
        >
          すべて
        </a>

        {{#each this.categories as |category|}}
          <a
            class="knots-category-tabs__tab
              {{if (this.isActive category) 'knots-category-tabs__tab--active'}}"
            href={{category.url}}
            {{on "click" (fn this.navigateToCategory category)}}
          >
            <span
              class="category-color-dot"
              style="background-color: {{this.safeColor category.color}}"
            ></span>
            {{category.name}}
          </a>
        {{/each}}

        <button
          class="knots-category-tabs__scroll-right"
          {{on "click" this.scrollRight}}
          aria-label="右にスクロール"
          type="button"
        >
          ›
        </button>
      </nav>
    {{/if}}
  </template>
}

// =============================================================================
// Persona AI Badge Component
// =============================================================================
class PersonaAiBadge extends Component {
  get isEnabled() {
    return (
      this.args.outletArgs?.model?.theme_settings?.knots_enable_persona_badge ??
      true
    );
  }

  get personaName() {
    return this.args.outletArgs?.post?.user?.name ?? "AI";
  }

  get isAiPost() {
    const user = this.args.outletArgs?.post?.user;
    if (!user) {
      return false;
    }
    return (
      user.groups?.some((g) => g.name === "ai-personas") ||
      user.username?.startsWith("ai-") ||
      user.title?.includes("AI")
    );
  }

  <template>
    {{#if this.isEnabled}}
      {{#if this.isAiPost}}
        <span class="knots-persona-badge" title="AIペルソナによる回答">
          <span class="knots-persona-badge__icon">
            ✨
          </span>
          <span class="knots-persona-badge__label">
            AI
          </span>
        </span>
      {{/if}}
    {{/if}}
  </template>
}

// =============================================================================
// API Initializer
// =============================================================================
export default apiInitializer("1.0.0", (api) => {
  // Register welcome banner at the top of the discovery list
  api.renderInOutlet("discovery-list-container-top", KnotsWelcomeBanner);

  // Register category navigation below header
  api.renderInOutlet("before-list-area", KnotsCategoryNav);

  // Register persona badge in post meta data
  api.renderInOutlet("post-meta-data", PersonaAiBadge);

  // Add body class for theme detection
  api.onPageChange(() => {
    document.body.classList.add("knots-theme");
  });
});
