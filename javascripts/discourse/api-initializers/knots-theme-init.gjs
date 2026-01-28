import { apiInitializer } from "discourse/lib/api";
import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import DiscourseURL from "discourse/lib/url";

// =============================================================================
// KNOTS Welcome Banner Component
// =============================================================================
class KnotsWelcomeBanner extends Component {
  @service router;
  @service currentUser;
  @service siteSettings;

  get shouldShow() {
    const showBanner =
      this.args.outletArgs?.model?.theme_settings?.knots_show_welcome_banner ??
      true;
    if (!showBanner) {
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

  <template>
    {{#if this.shouldShow}}
      <div
        class="knots-welcome-banner knots-welcome-banner--entering"
        role="banner"
        aria-label={{this.bannerTitle}}
      >
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
      .filter(
        (cat) =>
          !cat.parent_category_id &&
          !cat.isUncategorized &&
          cat.slug !== "uncategorized" &&
          cat.id !== 1
      )
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0))
      .slice(0, 12);
  }

  get currentCategoryPath() {
    const route = this.router.currentRoute;
    if (route?.params?.category_slug_path_with_id) {
      return route.params.category_slug_path_with_id;
    }
    return null;
  }

  @action
  isActive(category) {
    const path = this.currentCategoryPath;
    if (!path) {
      return false;
    }
    const slug = category.slug || `${category.id}-category`;
    return path === `${slug}/${category.id}` || path.startsWith(`${slug}/${category.id}/`);
  }

  safeColor(color) {
    if (!color || !/^[0-9A-Fa-f]{3,6}$/.test(color)) {
      return "transparent";
    }
    return `#${color}`;
  }

  categoryUrl(category) {
    if (category.url) {
      return category.url;
    }
    const slug = category.slug || `${category.id}-category`;
    return `/c/${slug}/${category.id}`;
  }

  @action
  navigateToCategory(category, event) {
    event.preventDefault();
    DiscourseURL.routeTo(this.categoryUrl(category));
  }

  @action
  navigateToAll(event) {
    event.preventDefault();
    DiscourseURL.routeTo("/latest");
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
      <div class="knots-category-tabs-wrapper">
        <button
          class="knots-category-tabs__scroll-left"
          {{on "click" this.scrollLeft}}
          aria-label="左にスクロール"
          type="button"
        >
          ‹
        </button>

        <nav class="knots-category-tabs" aria-label="カテゴリナビゲーション">
          <a
            class="knots-category-tabs__tab
              {{unless this.currentCategoryPath 'knots-category-tabs__tab--active'}}"
            href="/"
            {{on "click" this.navigateToAll}}
          >
            すべて
          </a>

          {{#each this.categories as |category|}}
            <a
              class="knots-category-tabs__tab
                {{if (this.isActive category) 'knots-category-tabs__tab--active'}}"
              href={{this.categoryUrl category}}
              {{on "click" (fn this.navigateToCategory category)}}
            >
              <span
                class="category-color-dot"
                style="background-color: {{this.safeColor category.color}}"
              ></span>
              {{category.name}}
            </a>
          {{/each}}
        </nav>

        <button
          class="knots-category-tabs__scroll-right"
          {{on "click" this.scrollRight}}
          aria-label="右にスクロール"
          type="button"
        >
          ›
        </button>
      </div>
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

  // Add body class for theme detection + override logo home link
  api.onPageChange(() => {
    document.body.classList.add("knots-theme");

    // Force logo click to do a full page navigation to landing page
    const logoLink = document.querySelector(".d-header .title a");
    if (logoLink && !logoLink.dataset.knotsOverride) {
      logoLink.setAttribute("href", "/");
      logoLink.dataset.knotsOverride = "true";
      logoLink.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();
        window.location.href = "/";
      });
    }
  });
});
