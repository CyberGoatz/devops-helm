<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("emailVerifyTitle")}</title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico">
    <link rel="stylesheet" href="${url.resourcesPath}/css/cyber-goatz.css">
  </head>
  <body class="cg-auth-page">
    <main class="cg-auth-frame">
      <section class="cg-visual-panel" aria-label="CyberGoatz email verification">
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
          <p class="cg-eyebrow">Email verification</p>
          <h1>Confirm your email to activate access.</h1>
          <p>We use verified email addresses to keep account recovery and training notifications reliable.</p>
        </div>
      </section>

      <section class="cg-form-panel" aria-label="Email verification">
        <div class="cg-mobile-brand">
          <div class="cg-mark">CG</div>
          <span>CyberGoatz</span>
        </div>

        <div class="cg-form-shell">
          <div class="cg-form-heading">
            <p class="cg-eyebrow">Verify email</p>
            <h2>Check your inbox</h2>
            <p>A verification email has been sent to your address.</p>
          </div>

          <#if message?has_content>
            <div class="cg-alert cg-alert-${message.type}">
              ${kcSanitize(message.summary)?no_esc}
            </div>
          </#if>

          <div class="cg-message-card">
            <p>
              <#if user?? && user.email??>
                We sent verification instructions to <strong>${user.email}</strong>.
              <#else>
                We sent verification instructions to your email address.
              </#if>
            </p>
            <p>Open the email and follow the link to finish activating your account.</p>
          </div>

          <form class="cg-form" action="${url.loginAction}" method="post">
            <button class="cg-secondary" type="submit">Resend verification email</button>
          </form>

          <p class="cg-alt-action">
            <span>Already verified?</span>
            <a href="${url.loginUrl}">Back to login</a>
          </p>
        </div>
      </section>
    </main>
  </body>
</html>
