namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

codeunit 139694 "Contracts Test Subscriber"
{
    EventSubscriberInstance = Manual;
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contract Test Library", OnCreateServiceObjectOnBeforeModify, '', false, false)]
    local procedure ModifyServiceObject(var ServiceObject: Record "Service Object")
    begin
        if CallerName = 'VendorDeferralsTest - CreatePurchaseDocumentsFromVendorContractWithDeferrals' then
            ServiceObject.Validate("Quantity Decimal", 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contract Test Library", OnCreateBasicItemOnBeforeModify, '', false, false)]
    local procedure ModifyBasicItem(var Item: Record Item)
    begin
        if CallerName = 'VendorDeferralsTest - CreatePurchaseDocumentsFromVendorContractWithDeferrals' then
            Item.Validate("Unit Cost", 1200);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Contract Test Library", OnCreateServiceCommitmentTemplateOnBeforeInsert, '', false, false)]
    local procedure SetDiscountInServiceCommitmentTemplate(var ServiceCommitmentTemplate: Record "Service Commitment Template")
    begin
        if CallerName = 'RecurringDiscountTest - TestServiceAmountInDiscountSalesServiceCommitments' then
            ServiceCommitmentTemplate.Validate(Discount, true);
    end;

    procedure SetCallerName(CurrentCallerName: Text)
    begin
        CallerName := CurrentCallerName;
    end;

    var
        CallerName: Text;
}