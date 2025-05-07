namespace Microsoft.SubscriptionBilling;

codeunit 8104 "Create Sub. Bill. Contr. Types"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertContractType(MaintenanceCode(), MaintenanceLbl);
        ContosoSubscriptionBilling.InsertContractType(MiscellaneousCode(), MiscellaneousLbl);
        ContosoSubscriptionBilling.InsertContractType(SupportCode(), SupportLbl);
        ContosoSubscriptionBilling.InsertContractType(UsageDataCode(), UsageDataLbl);
    end;

    procedure MaintenanceCode(): Code[10]
    begin
        exit(MaintenanceTok);
    end;

    procedure MiscellaneousCode(): Code[10]
    begin
        exit(MiscellaneousTok);
    end;

    procedure SupportCode(): Code[10]
    begin
        exit(SupportTok);
    end;

    procedure UsageDataCode(): Code[10]
    begin
        exit(UsageDataTok);
    end;

    var
        MaintenanceTok: Label 'MAINT', MaxLength = 10;
        MaintenanceLbl: Label 'Maintenance', MaxLength = 50;
        MiscellaneousTok: Label 'MISC', MaxLength = 10;
        MiscellaneousLbl: Label 'Misc. subscriptions', MaxLength = 50;
        SupportTok: Label 'SUPPORT', MaxLength = 10;
        SupportLbl: Label 'Support', MaxLength = 50;
        UsageDataTok: Label 'UD', MaxLength = 10;
        UsageDataLbl: Label 'Usage data', MaxLength = 50;
}