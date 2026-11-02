// ==UserScript==
// @name         FeedOnly
// @description  Instagram without Reels, Explore, suggested posts or ads
// @match        *://www.instagram.com/*
// @run-at       document-start
// ==/UserScript==
//
// Injected by the app into every instagram.com page before it renders.
// The header above also lets the same file run in Safari through the
// "Userscripts" extension.

(() => {
  if (window.__feedOnly) return;
  window.__feedOnly = true;

  // true also hides videos/reels posted by accounts you follow.
  const HIDE_FEED_VIDEOS = false;

  // Labels Instagram puts on posts you did not ask for (English + French UI).
  const SUGGESTED_LABELS = new Set([
    'Suggested for you', 'Sponsored', 'Paid partnership',
    'Suggestions pour vous', 'Sponsorisé', 'Partenariat rémunéré',
  ]);
  // After this header, every post in the home feed is a recommendation.
  const SUGGESTED_HEADERS = new Set(['Suggested posts', 'Publications suggérées']);

  // Returns where a blocked path should go instead, or null if it is allowed.
  function rewrite(path) {
    // A single reel someone sent you: open it as a normal post.
    const shared = path.match(/^\/reels\/([A-Za-z0-9_-]+)\/?$/);
    if (shared && shared[1] !== 'audio') return `/reel/${shared[1]}/`;
    // The endless Reels feed (and audio pages, which are reel feeds too).
    if (/^\/reels(\/|$)/.test(path)) return '/';
    // Explore grid, tags and locations: keep only the search box.
    if (/^\/explore(\/|$)/.test(path) && !/^\/explore\/search(\/|$)/.test(path)) {
      return '/explore/search/';
    }
    return null;
  }
  window.__feedOnlyRewrite = rewrite;

  function guard() {
    const target = rewrite(location.pathname);
    if (target) location.replace(target);
  }

  // Instagram is a single-page app: catch in-app navigation before it renders.
  for (const fn of ['pushState', 'replaceState']) {
    const original = history[fn];
    history[fn] = function (state, title, url) {
      if (url != null) {
        const target = rewrite(new URL(url, location.href).pathname);
        if (target) {
          location.replace(target);
          return;
        }
      }
      return original.apply(this, arguments);
    };
  }
  addEventListener('popstate', guard);
  guard();

  const style = document.createElement('style');
  style.textContent = `
    a[href="/reels/"], a[href^="/reels/?"] { display: none !important; }
  `;
  document.documentElement.appendChild(style);

  function leafTexts(root) {
    const texts = [];
    for (const el of root.querySelectorAll('span, div, h2, h3')) {
      if (el.childElementCount === 0) texts.push(el.textContent.trim());
    }
    return texts;
  }

  function hideNoise() {
    const header = [...document.querySelectorAll('span, div, h2, h3')].find(
      (el) => el.childElementCount === 0 && SUGGESTED_HEADERS.has(el.textContent.trim()),
    );

    for (const article of document.querySelectorAll('article')) {
      if (article.style.display === 'none') continue;
      const afterHeader =
        header && header.compareDocumentPosition(article) & Node.DOCUMENT_POSITION_FOLLOWING;
      const labelled = leafTexts(article).some((t) => SUGGESTED_LABELS.has(t));
      const video = HIDE_FEED_VIDEOS && article.querySelector('video, a[href*="/reel/"]');
      if (afterHeader || labelled || video) article.style.display = 'none';
    }
  }

  let scheduled = false;
  new MutationObserver(() => {
    if (scheduled) return;
    scheduled = true;
    setTimeout(() => {
      scheduled = false;
      hideNoise();
    }, 300);
  }).observe(document.documentElement, { childList: true, subtree: true });
})();
