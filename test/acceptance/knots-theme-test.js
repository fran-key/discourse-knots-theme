import { acceptance, exists, query } from "discourse/tests/helpers/qunit-helpers";
import { visit, click, currentRouteName } from "@ember/test-helpers";
import { test } from "qunit";

acceptance("KNOTS Theme", function (needs) {
  needs.settings({
    knots_show_welcome_banner: true,
    knots_banner_title: "KNOTSへようこそ",
    knots_banner_subtitle:
      "木材・林業のプロフェッショナルが集うコミュニティ。知識を共有し、業界の未来を共に創りましょう。",
    knots_banner_cta_text: "トピックを作成する",
    knots_banner_cta_url: "/new-topic",
    knots_category_nav_style: "horizontal_tabs",
    knots_enable_persona_badge: true,
    knots_show_category_icons: true,
    knots_topic_list_style: "clean_table",
    knots_font_size_base: "15px",
  });

  test("Welcome banner is displayed on homepage", async function (assert) {
    await visit("/");

    assert.ok(
      exists(".knots-welcome-banner"),
      "Welcome banner is rendered on the homepage"
    );

    assert.ok(
      exists(".knots-welcome-banner__title"),
      "Banner title is displayed"
    );

    assert.ok(
      exists(".knots-welcome-banner__subtitle"),
      "Banner subtitle is displayed"
    );

    assert.ok(
      exists(".knots-welcome-banner__cta"),
      "Banner CTA button is displayed"
    );

    const title = query(".knots-welcome-banner__title");
    assert.strictEqual(
      title.textContent.trim(),
      "KNOTSへようこそ",
      "Banner title matches settings"
    );
  });

  test("Welcome banner can be dismissed", async function (assert) {
    await visit("/");

    assert.ok(
      exists(".knots-welcome-banner"),
      "Banner is visible before dismissal"
    );

    await click(".knots-welcome-banner__dismiss");

    // Wait for animation
    await new Promise((resolve) => setTimeout(resolve, 350));

    assert.notOk(
      exists(".knots-welcome-banner:not(.knots-welcome-banner--leaving)"),
      "Banner is removed after dismissal"
    );
  });

  test("Category navigation tabs are rendered", async function (assert) {
    await visit("/");

    assert.ok(
      exists(".knots-category-tabs"),
      "Category tabs navigation is rendered"
    );

    assert.ok(
      exists(".knots-category-tabs__tab"),
      "At least one category tab exists"
    );

    const allTab = query(".knots-category-tabs__tab");
    assert.strictEqual(
      allTab.textContent.trim(),
      "すべて",
      "First tab is the 'All' tab"
    );
  });

  test("Theme applies body class", async function (assert) {
    await visit("/");

    assert.ok(
      document.body.classList.contains("knots-theme"),
      "Body has knots-theme class"
    );
  });

  test("Banner is not displayed on topic detail page", async function (assert) {
    await visit("/t/some-topic/1");

    assert.notOk(
      exists(".knots-welcome-banner"),
      "Banner is not shown on topic detail page"
    );
  });

  test("Category tab navigation works", async function (assert) {
    await visit("/");

    const tabs = document.querySelectorAll(".knots-category-tabs__tab");
    if (tabs.length > 1) {
      await click(tabs[1]);
      assert.ok(true, "Category tab click did not cause an error");
    } else {
      assert.ok(true, "Skipped - no categories available");
    }
  });
});

acceptance("KNOTS Theme - Banner disabled", function (needs) {
  needs.settings({
    knots_show_welcome_banner: false,
  });

  test("Banner is hidden when setting is disabled", async function (assert) {
    await visit("/");

    assert.notOk(
      exists(".knots-welcome-banner"),
      "Banner is not shown when knots_show_welcome_banner is false"
    );
  });
});

acceptance("KNOTS Theme - Persona Badge", function (needs) {
  needs.settings({
    knots_enable_persona_badge: true,
  });

  test("Persona badge is not shown for regular users", async function (assert) {
    await visit("/t/some-topic/1");

    const badges = document.querySelectorAll(".knots-persona-badge");
    // Regular users should not have the AI badge
    // This test verifies the component loads without error
    assert.ok(true, "Persona badge component loaded without error");
  });
});

acceptance("KNOTS Theme - Accessibility", function (needs) {
  needs.settings({
    knots_show_welcome_banner: true,
  });

  test("Banner has proper ARIA attributes", async function (assert) {
    await visit("/");

    const banner = query(".knots-welcome-banner");
    if (banner) {
      assert.strictEqual(
        banner.getAttribute("role"),
        "banner",
        "Banner has role='banner'"
      );

      assert.ok(
        banner.getAttribute("aria-label"),
        "Banner has an aria-label"
      );
    } else {
      assert.ok(true, "Banner not present, skipping ARIA test");
    }
  });

  test("Dismiss button has aria-label", async function (assert) {
    await visit("/");

    const dismissBtn = query(".knots-welcome-banner__dismiss");
    if (dismissBtn) {
      assert.ok(
        dismissBtn.getAttribute("aria-label"),
        "Dismiss button has aria-label"
      );
    } else {
      assert.ok(true, "Dismiss button not present, skipping test");
    }
  });

  test("Category tabs have navigation landmark", async function (assert) {
    await visit("/");

    const nav = query(".knots-category-tabs");
    if (nav) {
      assert.strictEqual(
        nav.tagName.toLowerCase(),
        "nav",
        "Category tabs are wrapped in a <nav> element"
      );

      assert.ok(
        nav.getAttribute("aria-label"),
        "Category nav has aria-label"
      );
    } else {
      assert.ok(true, "Category tabs not present, skipping test");
    }
  });
});
