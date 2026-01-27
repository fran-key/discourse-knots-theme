import Component from "@glimmer/component";
import { service } from "@ember/service";
import { tracked } from "@glimmer/tracking";
import { action } from "@ember/object";
import { on } from "@ember/modifier";
import { fn } from "@ember/helper";
import didInsert from "@ember/render-modifiers/modifiers/did-insert";
import willDestroy from "@ember/render-modifiers/modifiers/will-destroy";

/**
 * KnotsCategoryTabs - Standalone horizontal category tab navigation.
 *
 * Fetches site categories and renders them as horizontal pill-style tabs.
 * Supports horizontal scrolling with arrow buttons on overflow.
 *
 * Usage in a .gjs template:
 *   <KnotsCategoryTabs />
 */
export default class KnotsCategoryTabs extends Component {
  @service site;
  @service router;
  @tracked canScrollLeft = false;
  @tracked canScrollRight = false;
  @tracked containerEl = null;

  get categories() {
    const siteCategories = this.site.categories ?? [];
    return siteCategories
      .filter((cat) => !cat.parent_category_id && !cat.read_restricted)
      .sort((a, b) => (a.position ?? 0) - (b.position ?? 0))
      .slice(0, 15);
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
  setupContainer(element) {
    this.containerEl = element;
    this.updateScrollIndicators();

    if (typeof ResizeObserver !== "undefined") {
      this._resizeObserver = new ResizeObserver(() => {
        this.updateScrollIndicators();
      });
      this._resizeObserver.observe(element);
    }

    element.addEventListener("scroll", this.handleScroll, { passive: true });
  }

  @action
  teardownContainer() {
    if (this._resizeObserver) {
      this._resizeObserver.disconnect();
    }
    if (this.containerEl) {
      this.containerEl.removeEventListener("scroll", this.handleScroll);
    }
  }

  @action
  handleScroll() {
    this.updateScrollIndicators();
  }

  updateScrollIndicators() {
    const el = this.containerEl;
    if (!el) {
      return;
    }
    const tolerance = 2;
    this.canScrollLeft = el.scrollLeft > tolerance;
    this.canScrollRight =
      el.scrollLeft + el.clientWidth < el.scrollWidth - tolerance;
  }

  @action
  navigateToCategory(category, event) {
    event.preventDefault();
    this.router.transitionTo("discovery.category", {
      category_slug_path_with_id: `${category.slug}/${category.id}`,
    });
  }

  @action
  navigateToAll(event) {
    event.preventDefault();
    this.router.transitionTo("discovery.latest");
  }

  @action
  scrollLeft() {
    if (this.containerEl) {
      this.containerEl.scrollBy({ left: -200, behavior: "smooth" });
    }
  }

  @action
  scrollRight() {
    if (this.containerEl) {
      this.containerEl.scrollBy({ left: 200, behavior: "smooth" });
    }
  }

  <template>
    {{#if this.categories.length}}
      <nav
        class="knots-category-tabs"
        aria-label="カテゴリナビゲーション"
        {{didInsert this.setupContainer}}
        {{willDestroy this.teardownContainer}}
      >
        {{#if this.canScrollLeft}}
          <button
            class="knots-category-tabs__scroll-left"
            {{on "click" this.scrollLeft}}
            aria-label="左にスクロール"
            type="button"
          >
            ‹
          </button>
        {{/if}}

        <a
          class="knots-category-tabs__tab
            {{unless this.currentCategorySlug 'knots-category-tabs__tab--active'}}"
          href="/"
          {{on "click" this.navigateToAll}}
        >
          すべて
        </a>

        {{#each this.categories as |category|}}
          <a
            class="knots-category-tabs__tab
              {{if (this.isActive category) 'knots-category-tabs__tab--active'}}"
            href={{category.url}}
            {{on "click" (fn this.navigateToCategory category)}}
            title={{category.description_excerpt}}
          >
            {{#if category.color}}
              <span
                class="category-color-dot"
                style="background-color: {{this.safeColor category.color}}"
              ></span>
            {{/if}}
            {{category.name}}
            {{#if category.topic_count}}
              <span class="knots-category-tabs__count">
                ({{category.topic_count}})
              </span>
            {{/if}}
          </a>
        {{/each}}

        {{#if this.canScrollRight}}
          <button
            class="knots-category-tabs__scroll-right"
            {{on "click" this.scrollRight}}
            aria-label="右にスクロール"
            type="button"
          >
            ›
          </button>
        {{/if}}
      </nav>
    {{/if}}
  </template>
}
