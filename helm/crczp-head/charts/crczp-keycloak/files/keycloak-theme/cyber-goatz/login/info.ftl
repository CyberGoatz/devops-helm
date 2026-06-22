<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><#if messageHeader??>${messageHeader}<#elseif message?has_content>${message.summary}<#else>CyberGoatz</#if></title>
    <script>
      (function () {
        var themeParamName = "ui_theme";
        var fallbackThemeParamName = "theme";
        var themeCookieName = "cybergoatz_theme";

        function isAllowedTheme(theme) {
          return theme === "dark" || theme === "light";
        }

        function getCookie(name) {
          var cookies = document.cookie ? document.cookie.split("; ") : [];
          for (var index = 0; index < cookies.length; index += 1) {
            var cookie = cookies[index];
            var separatorIndex = cookie.indexOf("=");
            var cookieName = separatorIndex > -1 ? cookie.slice(0, separatorIndex) : cookie;
            if (cookieName === name) {
              var cookieValue = separatorIndex > -1 ? cookie.slice(separatorIndex + 1) : "";
              return decodeURIComponent(cookieValue);
            }
          }
          return "";
        }

        function setThemeCookie(theme) {
          if (!isAllowedTheme(theme)) return;

          var cookie = themeCookieName + "=" + encodeURIComponent(theme)
            + "; Path=/; Max-Age=31536000; SameSite=Lax";
          if (window.location.protocol === "https:") cookie += "; Secure";
          document.cookie = cookie;
        }

        var params = new URLSearchParams(window.location.search);
        var queryTheme = params.get(themeParamName) || params.get(fallbackThemeParamName);
        var cookieTheme = getCookie(themeCookieName);
        var systemTheme = window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches
          ? "dark"
          : "light";
        var theme = isAllowedTheme(queryTheme)
          ? queryTheme
          : isAllowedTheme(cookieTheme)
            ? cookieTheme
            : systemTheme;

        if (isAllowedTheme(queryTheme)) setThemeCookie(queryTheme);

        document.documentElement.dataset.theme = theme;
        document.documentElement.classList.toggle("dark", theme === "dark");
      })();
    </script>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico">
    <link rel="stylesheet" href="${url.resourcesPath}/css/cyber-goatz.css">
  </head>
  <body class="cg-auth-page">
    <main class="cg-auth-frame">
      <section class="cg-visual-panel" aria-label="CyberGoatz account status">
        <div class="cg-visual-grid"></div>
        <div class="cg-visual-orbit" aria-hidden="true">
          <span></span>
          <span></span>
          <span></span>
        </div>

        <div class="cg-brand-lockup">
          <div class="cg-mark">CG</div>
          <div>
            <a class="cg-brand-name" href="${url.loginUrl}">CyberGoatz</a>
            <div class="cg-brand-kicker">Cyber range command center</div>
          </div>
        </div>

        <div class="cg-visual-copy">
          <p class="cg-eyebrow">Account status</p>
          <h1>Your account request has been processed.</h1>
          <p>Continue when the action is complete, or return to the application to sign in again.</p>
        </div>
        
        <div class="cg-status-grid" aria-hidden="true">
        </div>
      </section>

      <section class="cg-form-panel" aria-label="Account status">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">Status update</p>
            <h2>
              <#if messageHeader??>
                ${messageHeader}
              <#elseif message?has_content>
                ${kcSanitize(message.summary)?no_esc}
              <#else>
                Request complete
              </#if>
            </h2>
          </div>

          <#if message?has_content>
            <div class="cg-message-card">
              <p>${kcSanitize(message.summary)?no_esc}</p>
              <#if requiredActions??>
                <ul class="cg-message-list">
                  <#list requiredActions as reqActionItem>
                    <li>${msg("requiredAction.${reqActionItem}")}</li>
                  </#list>
                </ul>
              </#if>
            </div>
          </#if>

          <#if !skipLink??>
            <div class="cg-action-stack">
              <#if pageRedirectUri?? && pageRedirectUri?has_content>
                <a class="cg-primary cg-link-button" href="${pageRedirectUri}">${msg("backToApplication")}</a>
              <#elseif actionUri?? && actionUri?has_content>
                <a class="cg-primary cg-link-button" href="${actionUri}">${msg("proceedWithAction")}</a>
              <#elseif client?? && client.baseUrl?? && client.baseUrl?has_content>
                <a class="cg-primary cg-link-button" href="${client.baseUrl}">${msg("backToApplication")}</a>
              <#else>
                <a class="cg-primary cg-link-button" href="${url.loginUrl}">Back to login</a>
              </#if>
            </div>
          </#if>
        </div>
      </section>
    </main>
    <script>
      (function () {
        var themeParamName = "ui_theme";

        function appendTheme(urlValue, theme) {
          if (!urlValue || theme !== "dark" && theme !== "light") return urlValue;

          var normalizedUrlValue = String(urlValue).trim();
          if (
            normalizedUrlValue.charAt(0) === "#" ||
            normalizedUrlValue.indexOf("mailto:") === 0 ||
            normalizedUrlValue.indexOf("tel:") === 0 ||
            normalizedUrlValue.indexOf("javascript:") === 0
          ) return urlValue;

          try {
            var url = new URL(normalizedUrlValue, window.location.href);
            var isKeycloakAuthUrl = url.origin === window.location.origin
              && (url.pathname.indexOf("/realms/") !== -1 || url.pathname.indexOf("/login-actions/") !== -1);

            if (!isKeycloakAuthUrl) return urlValue;

            url.searchParams.set(themeParamName, theme);
            return url.href;
          } catch (error) {
            return urlValue;
          }
        }

        var theme = document.documentElement.dataset.theme;

        document.querySelectorAll("a[href]").forEach(function (link) {
          var href = link.getAttribute("href");
          var nextHref = appendTheme(href, theme);
          if (nextHref !== href) link.setAttribute("href", nextHref);
        });

        document.querySelectorAll("form[action]").forEach(function (form) {
          var action = form.getAttribute("action");
          var nextAction = appendTheme(action, theme);
          if (nextAction !== action) form.setAttribute("action", nextAction);
        });
      })();
    </script>
  </body>
</html>
