namespace Microsoft.SubscriptionBilling;

codeunit 8109 "Create Sub. Bill. Pr. U. Temp."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateSubBillContrTypes: Codeunit "Create Sub. Bill. Contr. Types";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertPriceUpdateTemplate(MaintenanceTok, MaintenanceLbl, "Service Partner"::Customer, CreateSubBillContrTypes.MaintenanceCode());
        ContosoSubscriptionBilling.InsertPriceUpdateTemplate(SupportTok, SupportLbl, "Service Partner"::Customer, CreateSubBillContrTypes.SupportCode());
    end;

    var
        MaintenanceTok: Label 'MAINTENANCE', MaxLength = 20;
        MaintenanceLbl: Label 'Maintenance', MaxLength = 80;
        SupportTok: Label 'SUPPORT', MaxLength = 20;
        SupportLbl: Label 'Support', MaxLength = 80;
}