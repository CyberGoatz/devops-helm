<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("emailForgotTitle")}</title>
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
                <input id="username" name="username" type="text" value="${(auth.attemptedUsername!'')}" autocomplete="username" autofocus placeholder="you@company.com">
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
  </body>
</html>
