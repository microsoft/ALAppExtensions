namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Purchases;

codeunit 8113 "Create Sub. Bill. Supplier"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateVendor: Codeunit "Create Vendor";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertUsageDataSupplier(Generic(), GenericLbl, Enum::"Usage Data Supplier Type"::Generic, false, Enum::"Vendor Invoice Per"::Import, CreateVendor.DomesticWorldImporter());
    end;

    var
        GenericTok: Label 'GENERIC', MaxLength = 20;
        GenericLbl: Label 'Generic', MaxLength = 80;

    procedure Generic(): Code[20]
    begin
        exit(GenericTok);
    end;
}