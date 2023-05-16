function renderSurvey(ParentElementId, SurveyId, TenantId, FormsProEligibilityId, Locale) {
    var se = new SurveyEmbed(SurveyId, "https://customervoice.microsoft.com/", "https://mfpembedcdnmsit.azureedge.net/mfpembedcontmsit/", "true");
    var context = { "TenantId": TenantId, "FormsProEligibilityId": FormsProEligibilityId, "locale": Locale };
    se.renderInline(ParentElementId, context);
};