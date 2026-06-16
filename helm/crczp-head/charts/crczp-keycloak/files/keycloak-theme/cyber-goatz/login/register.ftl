<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("registerTitle")}</title>
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
          <p class="cg-eyebrow">Account registration</p>
          <h1>Create a user account for secure lab access.</h1>
          <p>Register once to join exercises, track mission outcomes, and keep training activity tied to your profile.</p>
        </div>
        <div></div>
      </section>

      <section class="cg-form-panel" aria-label="Register">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell cg-register-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">Create account</p>
            <h2>Set up your account</h2>
            <p>Use your contact details so training records stay accurate.</p>
          </div>

          <form id="kc-register-form" class="cg-form" action="${url.registrationAction}" method="post">
            <#if !realm.registrationEmailAsUsername>
              <div class="cg-field-group">
                <label class="cg-field" for="username">
                  <span>${msg("username")} *</span>
                  <div class="cg-input-wrap">
                    <i class="cg-input-icon" aria-hidden="true">ID</i>
                    <input id="username" name="username" type="text" value="${(register.formData.username!'')}" autocomplete="username" autofocus placeholder="username">
                  </div>
                </label>
                <#if messagesPerField?? && messagesPerField.existsError('username')>
                  <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('username'))?no_esc}</div>
                </#if>
              </div>
            </#if>

            <div class="cg-field-grid">
              <div class="cg-field-group">
                <label class="cg-field" for="firstName">
                  <span>${msg("firstName")} *</span>
                  <div class="cg-input-wrap">
                    <i class="cg-input-icon" aria-hidden="true">FN</i>
                    <input id="firstName" name="firstName" type="text" value="${(register.formData.firstName!'')}" autocomplete="given-name" placeholder="Jane">
                  </div>
                </label>
                <#if messagesPerField?? && messagesPerField.existsError('firstName')>
                  <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('firstName'))?no_esc}</div>
                </#if>
              </div>
              <div class="cg-field-group">
                <label class="cg-field" for="lastName">
                  <span>${msg("lastName")} *</span>
                  <div class="cg-input-wrap">
                    <i class="cg-input-icon" aria-hidden="true">LN</i>
                    <input id="lastName" name="lastName" type="text" value="${(register.formData.lastName!'')}" autocomplete="family-name" placeholder="Doe">
                  </div>
                </label>
                <#if messagesPerField?? && messagesPerField.existsError('lastName')>
                  <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('lastName'))?no_esc}</div>
                </#if>
              </div>
            </div>

            <div class="cg-field-group">
              <label class="cg-field" for="email">
                <span>${msg("email")} *</span>
                <div class="cg-input-wrap">
                  <i class="cg-input-icon" aria-hidden="true">@</i>
                  <input id="email" name="email" type="email" value="${(register.formData.email!'')}" autocomplete="email" placeholder="jane.doe@company.com">
                </div>
              </label>
              <#if messagesPerField?? && messagesPerField.existsError('email')>
                <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('email'))?no_esc}</div>
              </#if>
            </div>

            <#if !passwordRequired?? || passwordRequired>
              <div class="cg-field-group">
                <label class="cg-field" for="password">
                  <span>${msg("password")} *</span>
                  <div class="cg-input-wrap">
                    <i class="cg-input-icon" aria-hidden="true">*</i>
                    <input id="password" name="password" type="password" autocomplete="new-password" placeholder="Create password">
                    <button class="cg-password-toggle" type="button" data-password-toggle="password" aria-controls="password" aria-label="Show password">
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
                <#if messagesPerField?? && messagesPerField.existsError('password')>
                  <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('password'))?no_esc}</div>
                </#if>
              </div>

              <div class="cg-field-group">
                <label class="cg-field" for="password-confirm">
                  <span>${msg("passwordConfirm")} *</span>
                  <div class="cg-input-wrap">
                    <i class="cg-input-icon" aria-hidden="true">*</i>
                    <input id="password-confirm" name="password-confirm" type="password" autocomplete="new-password" placeholder="Confirm password">
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
              </div>
            </#if>

            <#if recaptchaRequired??>
              <div class="g-recaptcha" data-size="compact" data-sitekey="${recaptchaSiteKey}"></div>
            </#if>

            <label class="cg-terms-check" for="termsAccepted">
              <input id="termsAccepted" name="termsAccepted" type="checkbox" required>
              <span>
                I agree to the <a href="#" target="_blank" rel="noreferrer">Terms of Service</a>
                and <a href="#" target="_blank" rel="noreferrer">Privacy Policy</a>
              </span>
            </label>

            <button class="cg-primary" type="submit">
              <span>${msg("doRegister")}</span>
            </button>
          </form>

          <#if social?? && social.providers?? && social.providers?size gt 0>
            <div class="cg-divider"><span>Or continue with</span></div>
            <div class="cg-social-list">
              <#list social.providers as p>
                <#assign providerName=(p.displayName!p.alias)>
                <a class="cg-social" href="${p.loginUrl}">
                  <#if providerName?lower_case?contains("google")>
                    <svg class="cg-google-icon" viewBox="0 0 24 24" aria-hidden="true">
                      <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"></path>
                      <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"></path>
                      <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"></path>
                      <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"></path>
                    </svg>
                  <#else>
                    <span class="cg-social-mark">${providerName?substring(0,1)?upper_case}</span>
                  </#if>
                  <span>${providerName}</span>
                </a>
              </#list>
            </div>
          </#if>

          <p class="cg-alt-action">
            <span>Already have an account?</span>
            <a href="${url.loginUrl}">Sign in</a>
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
