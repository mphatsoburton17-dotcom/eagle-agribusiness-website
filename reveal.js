// ===========================================================
// Eagle Agribusiness — scroll-reveal animation
// Fades + rises elements with class="reveal" into view as the
// user scrolls down. Respects prefers-reduced-motion (handled
// in CSS) and degrades gracefully if IntersectionObserver isn't
// available (elements just show immediately).
//
// Call window.eagleReveal.refresh() after adding new elements
// to the page dynamically (e.g. after loading products from the
// database), so newly-added .reveal items get observed too.
//
// Note: uses Array.prototype.forEach.call(nodeList, fn) instead of
// nodeList.forEach() directly — NodeList.forEach isn't supported on
// some older phone browsers/WebViews, even though the rest of this
// syntax (arrow functions, etc.) generally is.
// ===========================================================
(function () {
  var observer = null;

  function each(nodeList, fn) {
    Array.prototype.forEach.call(nodeList, fn);
  }

  function getObserver() {
    if (observer) return observer;
    if (!('IntersectionObserver' in window)) return null;
    observer = new IntersectionObserver(function (entries) {
      each(entries, function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('in-view');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15, rootMargin: '0px 0px -40px 0px' });
    return observer;
  }

  function refresh() {
    var items = document.querySelectorAll('.reveal:not(.in-view)');
    var obs = getObserver();
    if (!obs) {
      each(items, function (el) { el.classList.add('in-view'); });
      return;
    }
    each(items, function (el) { obs.observe(el); });
  }

  window.eagleReveal = { refresh: refresh };

  // Multiple triggers, since relying on just one event can be unreliable
  // in some in-app browsers (e.g. opening the link from inside WhatsApp
  // or Facebook). None of these should ever leave content invisible.
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', refresh);
  } else {
    refresh();
  }
  window.addEventListener('load', refresh);

  // Final safety net: whatever happens with the above, make sure nothing
  // is left invisible for more than 2.5s — content must never disappear
  // permanently just because an animation trigger didn't fire.
  setTimeout(function () {
    each(document.querySelectorAll('.reveal:not(.in-view)'), function (el) {
      el.classList.add('in-view');
    });
  }, 2500);
})();
