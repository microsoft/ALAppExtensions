namespace Microsoft.SubscriptionBilling;

codeunit 8106 "Create Sub. Bill. Templates"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateSubBillContrTypes: Codeunit "Create Sub. Bill. Contr. Types";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertBillingTemplate(CustomerTok, CustomerLbl, "Service Partner"::Customer, '');
        ContosoSubscriptionBilling.InsertBillingTemplate(MaintenanceTok, MaintenanceLbl, "Service Partner"::Customer, CreateSubBillContrTypes.MaintenanceCode());
        ContosoSubscriptionBilling.InsertBillingTemplate(SubscriptionsTok, SubscriptionsLbl, "Service Partner"::Customer, CreateSubBillContrTypes.MiscellaneousCode());
        ContosoSubscriptionBilling.InsertBillingTemplate(SupportTok, SupportLbl, "Service Partner"::Customer, CreateSubBillContrTypes.SupportCode());
        ContosoSubscriptionBilling.InsertBillingTemplate(UsageDataCustomerTok, UsageDataCustomerLbl, "Service Partner"::Customer, CreateSubBillContrTypes.UsageDataCode());
        ContosoSubscriptionBilling.InsertBillingTemplate(UsageDataVendorTok, UsageDataVendorLbl, "Service Partner"::Vendor, CreateSubBillContrTypes.UsageDataCode());
        ContosoSubscriptionBilling.InsertBillingTemplate(VendorTok, VendorLbl, "Service Partner"::Vendor, '');
    end;

    var
        CustomerTok: Label 'CUSTOMER', MaxLength = 20;
        CustomerLbl: Label 'Customer sample', MaxLength = 80;
        MaintenanceTok: Label 'MAINTENANCE', MaxLength = 20;
        MaintenanceLbl: Label 'Maintenance', MaxLength = 80;
        SubscriptionsTok: Label 'SUBSCRIPTIONS', MaxLength = 20;
        SubscriptionsLbl: Label 'Misc. subscriptions', MaxLength = 80;
        SupportTok: Label 'SUPPORT', MaxLength = 20;
        SupportLbl: Label 'Support', MaxLength = 80;
        UsageDataCustomerTok: Label 'UD-CUSTOMER', MaxLength = 20;
        UsageDataCustomerLbl: Label 'Usage data customer', MaxLength = 80;
        UsageDataVendorTok: Label 'UD-VENDOR', MaxLength = 20;
        UsageDataVendorLbl: Label 'Usage data vendor', MaxLength = 80;
        VendorTok: Label 'VENDOR', MaxLength = 20;
        VendorLbl: Label 'Vendor sample', MaxLength = 80;
}