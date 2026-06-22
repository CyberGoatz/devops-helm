<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
  <#if section = "header">
    ${msg("pageExpiredTitle")}
  <#elseif section = "form">
    <div class="cg-message-card">
      <p>${msg("pageExpiredMsg1")}</p>
      <p>${msg("pageExpiredMsg2")}</p>
    </div>

    <div class="cg-action-stack">
      <a id="loginRestartLink" class="cg-primary cg-link-button" href="${url.loginRestartFlowUrl}">
        Restart sign in
      </a>
      <a id="loginContinueLink" class="cg-secondary cg-link-button" href="${url.loginAction}">
        Continue sign in
      </a>
    </div>
  </#if>
</@layout.registrationLayout>
