<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false displayWide=false>
<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${msg("loginTitle",(realm.displayName!realm.name))}</title>
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
