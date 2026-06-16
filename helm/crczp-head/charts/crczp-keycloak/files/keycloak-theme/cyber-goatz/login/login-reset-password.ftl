<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("emailForgotTitle")}</title>
    <script>
      (function () {
        var queryTheme = new URLSearchParams(window.location.search).get("ui_theme");
        var theme = queryTheme === "dark" || queryTheme === "light" ? queryTheme : "light";

        document.documentElement.dataset.theme = theme;
        document.documentElement.classList.toggle("dark", theme === "dark");
      })();
    </script>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico">
    <link rel="stylesheet" href="${url.resourcesPath}/css/cyber-goatz.css">
  </head>
  <body class="cg-auth-page">
    <main class="cg-auth-frame">
      <section class="cg-visual-panel" aria-label="CyberGoatz account recovery">
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
          <p class="cg-eyebrow">Account recovery</p>
          <h1>Reset access to your training workspace.</h1>
          <p>Enter your username or email and Keycloak will send recovery instructions if the account exists.</p>
        </div>

        <div class="cg-status-grid" aria-hidden="true">
        </div>
      </section>

      <section class="cg-form-panel" aria-label="Reset password">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">Password reset</p>
            <h2>Recover your account</h2>
            <p>Enter your username or email address to receive reset instructions.</p>
          </div>

          <#if message?has_content>
            <div class="cg-alert cg-alert-${message.type}">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>

          <form id="kc-reset-password-form" class="cg-form" action="${url.loginAction}" method="post">
            <label class="cg-field" for="username">
              <span>
                <#if !realm.loginWithEmailAllowed>
                  ${msg("username")}
                <#elseif !realm.registrationEmailAsUsername>
                  ${msg("usernameOrEmail")}
                <#else>
                  ${msg("email")}
                </#if>
              </span>
              <div class="cg-input-wrap">
                <i class="cg-input-icon" aria-hidden="true">@</i>
                <input id="username" name="username" type="text" value="${(auth.attemptedUsername!'')}" autocomplete="username" placeholder="you@company.com">
              </div>
            </label>

            <#if messagesPerField?? && messagesPerField.existsError('username')>
              <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('username'))?no_esc}</div>
            </#if>

            <button class="cg-primary" type="submit">
              <span>${msg("doSubmit")}</span>
            </button>
          </form>

          <p class="cg-alt-action">
            <span>Remembered your password?</span>
            <a href="${url.loginUrl}">Back to login</a>
          </p>
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
