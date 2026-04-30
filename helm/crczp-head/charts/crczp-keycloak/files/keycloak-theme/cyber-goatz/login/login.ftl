<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("loginTitle",(realm.displayName!realm.name))}</title>
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
          <p class="cg-eyebrow">Secure user access</p>
          <h1>Access your security training workspace.</h1>
          <p>Sign in to continue labs, review mission progress, and manage activity in your CyberGoatz account.</p>
        </div>

        <div class="cg-status-grid" aria-hidden="true">
        </div>
      </section>

      <section class="cg-form-panel" aria-label="Sign in">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">User login</p>
            <h2>Welcome back</h2>
            <p>Sign in with your CyberGoatz account to continue.</p>
          </div>

          <#if message?has_content>
            <div class="cg-alert cg-alert-${message.type}">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>

          <form id="kc-form-login" class="cg-form" action="${url.loginAction}" method="post">
            <#if !usernameHidden??>
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
                  <input id="username" name="username" type="text" value="${(login.username!'')}" autocomplete="username" autofocus placeholder="you@company.com">
                </div>
              </label>
            </#if>

            <label class="cg-field" for="password">
              <div class="cg-label-row">
                <span>${msg("password")}</span>
                <#if realm.resetPasswordAllowed>
                  <a class="cg-inline-link" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                </#if>
              </div>
              <div class="cg-input-wrap">
                <i class="cg-input-icon" aria-hidden="true">*</i>
                <input id="password" name="password" type="password" autocomplete="current-password" placeholder="Enter password">
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

            <#if messagesPerField?? && messagesPerField.existsError('username','password')>
              <div class="cg-field-error">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</div>
            </#if>

            <#if realm.rememberMe && !usernameHidden??>
              <label class="cg-check">
                <input id="rememberMe" name="rememberMe" type="checkbox" <#if login.rememberMe??>checked</#if>>
                <span>${msg("rememberMe")}</span>
              </label>
            </#if>

            <#if auth?? && auth.selectedCredential?has_content>
              <input type="hidden" name="credentialId" value="${auth.selectedCredential}">
            </#if>

            <button class="cg-primary" type="submit">
              <span>${msg("doLogIn")}</span>
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

          <#if realm.registrationAllowed && !registrationDisabled??>
            <p class="cg-alt-action">
              <span>New to CyberGoatz?</span>
              <a href="${url.registrationUrl}">Create account</a>
            </p>
          </#if>
        </div>
      </section>
    </main>
    <script>
      (function () {
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
