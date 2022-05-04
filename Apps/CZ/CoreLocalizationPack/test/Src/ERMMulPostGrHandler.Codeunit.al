#if not CLEAN20
#pragma warning disable AL0432
codeunit 148107 "ERM Mul. Post. Gr. Handler CZL"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncAllowAlterPostingGroupsInSalesSetup(var Rec: Record "Sales & Receivables Setup"; var xRec: Record "Sales & Receivables Setup")
    begin
        Rec."Allow Alter Posting Groups CZL" := Rec."Allow Multiple Posting Groups";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchases & Payables Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncAllowAlterPostingGroupsInPurchaseSetup(var Rec: Record "Purchases & Payables Setup"; var xRec: Record "Purchases & Payables Setup")
    begin
        Rec."Allow Alter Posting Groups CZL" := Rec."Allow Multiple Posting Groups";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Service Mgt. Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncAllowAlterPostingGroupsInServiceSetup(var Rec: Record "Service Mgt. Setup"; var xRec: Record "Service Mgt. Setup")
    begin
        Rec."Allow Alter Posting Groups CZL" := Rec."Allow Multiple Posting Groups";
    end;
}
#pragma warning restore AL0432
#endif