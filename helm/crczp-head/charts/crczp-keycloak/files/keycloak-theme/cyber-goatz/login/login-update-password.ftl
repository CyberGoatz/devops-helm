<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("updatePasswordTitle")}</title>
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
      <section class="cg-visual-panel" aria-label="CyberGoatz account security">
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
          <p class="cg-eyebrow">Password update</p>
          <h1>Set a fresh password for your account.</h1>
          <p>Choose a new password to keep your CyberGoatz workspace protected.</p>
        </div>
        <div></div>
      </section>

      <section class="cg-form-panel" aria-label="Update password">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">Account security</p>
            <h2>Update password</h2>
            <p>Create a new password before continuing.</p>
          </div>

          <#if message?has_content && (!messagesPerField?? || !messagesPerField.existsError('password','password-confirm','password-new'))>
            <div class="cg-alert cg-alert-${message.type}">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>

          <form id="kc-passwd-update-form" class="cg-form" action="${url.loginAction}" method="post">
            <label class="cg-field" for="password-new">
              <span>${msg("passwordNew")}</span>
              <div class="cg-input-wrap">
                <i class="cg-input-icon" aria-hidden="true">*</i>
                <input id="password-new" name="password-new" type="password" autocomplete="new-password" placeholder="Enter new password">
                <button class="cg-password-toggle" type="button" data-password-toggle="password-new" aria-controls="password-new" aria-label="Show password">
                  <svg class="cg-eye cg-eye-open" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M2.25 12s3.5-6.25 9.75-6.25S21.75 12 21.75 12 18.25 18.25 12 18.25 2.25 12 2.25 12Z"></path>
                    <circle cx="12" cy="12" r="2.75"></circle>
                  </svg>
                  <svg class="cg-eye cg-eye-closed" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M3 3l18 18"></path>
                    <path d="M10.58 10.58A2.74 2.74 0 0 0 12 14.75c.76 0 1.45-.31 1.95-.8"></path>
                    <path d="M7.45 7.45C4.15 9.08 2.25 12 2.25 12s3.5 6.25 9.75 6.25c1.78 0 3.34-.5 4.66-1.23"></path>
                    <path d="M10.95 5.82c.34-.05.69-.07 1.05-.07 6.25 0 9.75 6.25 9.75 6.25a16.6 16.6 0 0 1-2.58 3.09"></path>
                  </svg>
                </button>
              </div>
            </label>

            <#if messagesPerField?? && messagesPerField.existsError('password','password-new')>
              <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('password','password-new'))?no_esc}</div>
            </#if>

            <label class="cg-field" for="password-confirm">
              <span>${msg("passwordConfirm")}</span>
              <div class="cg-input-wrap">
                <i class="cg-input-icon" aria-hidden="true">*</i>
                <input id="password-confirm" name="password-confirm" type="password" autocomplete="new-password" placeholder="Confirm new password">
                <button class="cg-password-toggle" type="button" data-password-toggle="password-confirm" aria-controls="password-confirm" aria-label="Show password">
                  <svg class="cg-eye cg-eye-open" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M2.25 12s3.5-6.25 9.75-6.25S21.75 12 21.75 12 18.25 18.25 12 18.25 2.25 12 2.25 12Z"></path>
                    <circle cx="12" cy="12" r="2.75"></circle>
                  </svg>
                  <svg class="cg-eye cg-eye-closed" viewBox="0 0 24 24" aria-hidden="true">
                    <path d="M3 3l18 18"></path>
                    <path d="M10.58 10.58A2.74 2.74 0 0 0 12 14.75c.76 0 1.45-.31 1.95-.8"></path>
                    <path d="M7.45 7.45C4.15 9.08 2.25 12 2.25 12s3.5 6.25 9.75 6.25c1.78 0 3.34-.5 4.66-1.23"></path>
                    <path d="M10.95 5.82c.34-.05.69-.07 1.05-.07 6.25 0 9.75 6.25 9.75 6.25a16.6 16.6 0 0 1-2.58 3.09"></path>
                  </svg>
                </button>
              </div>
            </label>

            <#if messagesPerField?? && messagesPerField.existsError('password-confirm')>
              <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('password-confirm'))?no_esc}</div>
            </#if>

            <#if isAppInitiatedAction??>
              <input type="submit" class="cg-secondary" name="cancel-aia" value="${msg("doCancel")}">
            </#if>

            <#if logoutSessions??>
              <label class="cg-check" for="logout-sessions">
                <input id="logout-sessions" name="logout-sessions" type="checkbox" value="on" checked>
                <span>${msg("logoutOtherSessions")}</span>
              </label>
            </#if>

            <button class="cg-primary" type="submit" name="login">
              <span>${msg("doSubmit")}</span>
            </button>
          </form>
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

        document.querySelectorAll("[data-password-toggle]").forEach(function (button) {
          var input = document.getElementById(button.getAttribute("data-password-toggle"));
          if (!input) return;

          button.addEventListener("click", function () {
            var shouldShow = input.type === "password";
            input.type = shouldShow ? "text" : "password";
            button.classList.toggle("is-visible", shouldShow);
            button.setAttribute("aria-label", shouldShow ? "Hide password" : "Show password");
          });
        });
      })();
    </script>
  </body>
</html>
