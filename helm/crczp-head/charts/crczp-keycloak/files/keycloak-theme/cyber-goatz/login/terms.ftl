<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false; section>
  <#if section = "header">
    Terms and Privacy
  <#elseif section = "form">
    <#assign cyberGoatzPolicyBaseUrl = "">
    <#if client?? && client.baseUrl?? && client.baseUrl?has_content>
      <#assign cyberGoatzPolicyBaseUrl = client.baseUrl?remove_ending("/")>
    </#if>

    <div class="cg-message-card">
      <p>
        To continue, review and accept the CyberGoatz Terms of Service and Privacy Policy.
      </p>
      <p>
        <a href="${cyberGoatzPolicyBaseUrl}/terms" target="_blank" rel="noreferrer">Terms of Service</a>
        and
        <a href="${cyberGoatzPolicyBaseUrl}/privacy" target="_blank" rel="noreferrer">Privacy Policy</a>
      </p>
    </div>

    <form class="cg-form" action="${url.loginAction}" method="post">
      <button class="cg-primary" id="kc-accept" name="accept" type="submit">
        Accept
      </button>
      <button class="cg-secondary" id="kc-decline" name="cancel" type="submit">
        Decline
      </button>
    </form>
  </#if>
</@layout.registrationLayout>
