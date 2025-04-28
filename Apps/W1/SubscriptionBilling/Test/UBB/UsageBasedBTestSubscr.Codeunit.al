namespace Microsoft.SubscriptionBilling;

codeunit 139893 "Usage Based B. Test Subscr."
{
    EventSubscriberInstance = Manual;
    Access = Internal;

    var
        TestContext: Text;

    #region Procedures

    procedure SetTestContext(NewTestContext: Text)
    begin
        TestContext := NewTestContext;
    end;

    #endregion Procedures

    #region Subscribers

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contract Test Library", OnCreateSubPackageLineTemplateOnBeforeInsert, '', false, false)]
    local procedure SetUsageBasedServiceCommitment(var SubPackageLineTemplate: Record "Sub. Package Line Template")
    begin
        if TestContext = '' then
            exit;

        SubPackageLineTemplate."Usage Based Billing" := true;
        SubPackageLineTemplate."Usage Based Pricing" := Enum::"Usage Based Pricing"::"Fixed Quantity";
    end;

    #endregion Subscribers
}
