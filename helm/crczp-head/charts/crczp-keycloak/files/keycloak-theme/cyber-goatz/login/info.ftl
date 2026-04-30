<!doctype html>
<html lang="${(locale.currentLanguageTag)!'en'}">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><#if messageHeader??>${messageHeader}<#elseif message?has_content>${message.summary}<#else>CyberGoatz</#if></title>
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
  </body>
</html>
