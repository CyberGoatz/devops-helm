<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
  <#if section = "header">
    ${kcSanitize(msg("errorTitle"))?no_esc}
  <#elseif section = "form">
    <div id="kc-error-message" class="cg-message-card">
      <p>${kcSanitize(message.summary)?no_esc}</p>
    </div>

    <#if !skipLink??>
      <div class="cg-action-stack">
        <#if client?? && client.baseUrl?? && client.baseUrl?has_content>
          <a id="backToApplication" class="cg-primary cg-link-button" href="${client.baseUrl}">
            ${kcSanitize(msg("backToApplication"))?no_esc}
          </a>
        <#else>
          <a class="cg-primary cg-link-button" href="${url.loginUrl}">Back to login</a>
        </#if>
      </div>
    </#if>
  </#if>
</@layout.registrationLayout>
