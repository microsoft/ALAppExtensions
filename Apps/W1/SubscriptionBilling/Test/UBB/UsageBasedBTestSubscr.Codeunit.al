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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contract Test Library", OnCreateServiceCommitmentTemplateOnBeforeInsert, '', false, false)]
    local procedure SetUsageBasedServiceCommitment(var ServiceCommitmentTemplate: Record "Service Commitment Template")
    begin
        if TestContext = '' then
            exit;

        ServiceCommitmentTemplate."Usage Based Billing" := true;
        ServiceCommitmentTemplate."Usage Based Pricing" := Enum::"Usage Based Pricing"::"Fixed Quantity";
    end;

    #endregion Subscribers
}
