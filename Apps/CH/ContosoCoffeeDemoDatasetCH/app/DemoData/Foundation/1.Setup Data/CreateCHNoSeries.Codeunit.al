codeunit 11608 "Create CH No. Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(PurchaseDeliveryReminder(), DeliveryReminderLbl, '1001', '2999', '2995', '', 1, Enum::"No. Series Implementation"::Normal, false);
        ContosoNoSeries.InsertNoSeries(PurchaseIssueDeliveryReminder(), IssueDeliveryReminderLbl, '104001', '105999', '105995', '', 1, Enum::"No. Series Implementation"::Normal, false);
    end;

    procedure PurchaseDeliveryReminder(): Code[20]
    begin
        exit('P-DELREM');
    end;

    procedure PurchaseIssueDeliveryReminder(): Code[20]
    begin
        exit('P-DELREM+');
    end;

    var
        DeliveryReminderLbl: Label 'Purchase Delivery Reminder', MaxLength = 100;
        IssueDeliveryReminderLbl: Label 'Issued Purch. Deliv. Reminder', MaxLength = 100;
}