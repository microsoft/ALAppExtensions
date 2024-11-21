codeunit 11168 "Create Purch. Payable Setup AT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateNoSeriesAT: Codeunit "Create No. Series AT";
    begin
        UpdatePurchasePayableSetup(CreateNoSeriesAT.PurchaseDeliveryReminder(), CreateNoSeriesAT.PurchaseIssueDeliveryReminder());
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