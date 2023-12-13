#if not CLEAN22
codeunit 148119 "Replace VAT Date Handler CZL"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Replace VAT Date Mgt. CZL", 'OnAfterIsEnabled', '', false, false)]
    local procedure EnableReplaceVATDateOnAfterIsEnabled(var FeatureEnabled: Boolean)
    begin
        FeatureEnabled := true;
    end;
}
#endif