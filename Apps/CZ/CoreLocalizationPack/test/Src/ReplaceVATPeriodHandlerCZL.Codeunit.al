#if not CLEAN28
codeunit 148131 "Replace VAT Period Handler CZL"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Replace VAT Period Mgt. CZL", OnAfterIsEnabled, '', false, false)]
    local procedure EnableFeatureOnAfterIsEnabled(var FeatureEnabled: Boolean)
    begin
        FeatureEnabled := true;
    end;
}
#endif