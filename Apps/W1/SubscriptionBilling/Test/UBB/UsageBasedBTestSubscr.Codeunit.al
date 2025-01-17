namespace Microsoft.SubscriptionBilling;

codeunit 139893 "Usage Based B. Test Subscr."
{
    EventSubscriberInstance = Manual;
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contract Test Library", 'OnCreateServiceCommitmentTemplateOnBeforeInsert', '', false, false)]
    local procedure SetUsageBasedServiceCommitment(var ServiceCommitmentTemplate: Record "Service Commitment Template")
    begin
        if TestContext = '' then
            exit;

        ServiceCommitmentTemplate."Usage Based Billing" := true;
        ServiceCommitmentTemplate."Usage Based Pricing" := Enum::"Usage Based Pricing"::"Fixed Quantity";
    end;

    procedure SetTestContext(NewTestContext: Text)
    begin
        TestContext := NewTestContext;
    end;


    var
        TestContext: Text;
}