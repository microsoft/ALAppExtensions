codeunit 11100 "Create DE Purch. Payable Setup"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateDENoSeries: Codeunit "Create DE No. Series";
    begin
        UpdatePurchasePayableSetup(CreateDENoSeries.PurchaseDeliveryReminder(), CreateDENoSeries.PurchaseIssueDeliveryReminder());
    end;

    local procedure UpdatePurchasePayableSetup(DeliveryReminderNos: Code[20]; IssuedDeliveryReminderNos: Code[20])
    var
        PurchPayableSetup: Record "Purchases & Payables Setup";
    begin
        if PurchPayableSetup.Get() then begin
            PurchPayableSetup.Validate("Delivery Reminder Nos.", DeliveryReminderNos);
            PurchPayableSetup.Validate("Issued Delivery Reminder Nos.", IssuedDeliveryReminderNos);
            PurchPayableSetup.Modify(true);
        end;
    end;
}