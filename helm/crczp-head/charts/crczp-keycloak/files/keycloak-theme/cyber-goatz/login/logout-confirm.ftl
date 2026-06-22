<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
  <#if section = "header">
    ${msg("logoutConfirmTitle")}
  <#elseif section = "form">
    <div id="kc-logout-confirm" class="cg-message-card">
      <p>${msg("logoutConfirmHeader")}</p>
    </div>

    <form class="cg-form cg-action-stack" action="${url.logoutConfirmAction}" method="post">
      <input type="hidden" name="session_code" value="${logoutConfirm.code}">
      <button class="cg-primary" name="confirmLogout" id="kc-logout" type="submit" value="true">
        ${msg("doLogout")}
      </button>
    </form>

    <#if !logoutConfirm.skipLink>
      <#if client?? && client.baseUrl?? && client.baseUrl?has_content>
        <p class="cg-alt-action">
          <a href="${client.baseUrl}">${kcSanitize(msg("backToApplication"))?no_esc}</a>
        </p>
      </#if>
    </#if>
  </#if>
</@layout.registrationLayout>
