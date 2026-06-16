<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false displayWide=false>
<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("loginTitle",(realm.displayName!realm.name))}</title>
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
  <body class="cg-auth-page ${bodyClass}">
    <main class="cg-auth-frame">
      <section class="cg-visual-panel" aria-label="CyberGoatz platform overview">
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
          <p class="cg-eyebrow">Account security</p>
          <h1>Keep your CyberGoatz account protected.</h1>
          <p>Complete the requested security step to continue to your training workspace.</p>
        </div>

        <div></div>
      </section>

      <section class="cg-form-panel" aria-label="Account action">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">Secure account</p>
            <h2><#nested "header"></h2>
            <#if displayRequiredFields>
              <p>* Required fields</p>
            <#else>
              <p>Finish this step to continue securely.</p>
            </#if>
          </div>

          <#if displayMessage && message?has_content && (message.type != "warning" || !isAppInitiatedAction??)>
            <div class="cg-alert cg-alert-${message.type}">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>

          <#nested "form">
          <#nested "socialProviders">

          <#if displayInfo>
            <div class="cg-template-info">
              <#nested "info">
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
</#macro>
