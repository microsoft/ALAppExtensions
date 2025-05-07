namespace Microsoft.SubscriptionBilling;

using Microsoft.DemoData.Sales;
using Microsoft.DemoTool.Helpers;

codeunit 8120 "Create Sub. Bill. UD Subscr."
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateCustomer: Codeunit "Create Customer";
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillServObj: Codeunit "Create Sub. Bill. Serv. Obj.";
        CreateSubBillSupplier: Codeunit "Create Sub. Bill. Supplier";
    begin
        ContosoSubscriptionBilling.InsertUsageDataSubscription(CreateSubBillSupplier.Generic(), CreateCustomer.DomesticRelecloud(), CustomerIDTok, CreateSubBillServObj.SUB100004(), ProductIDTok, ProductNameLbl, 3,
            ContosoUtilities.AdjustDate(19020101D), ContosoUtilities.AdjustDate(19021231D), SubscriptionReferenceTok);
    end;

    var
        SubscriptionReferenceTok: Label 'sub-1105-001', MaxLength = 20, Locked = true;
        CustomerIDTok: Label '5741f4d2-be5a-4fc7-a874-5822b152d568', MaxLength = 80, Locked = true;
        ProductIDTok: Label 'prd-wwi-1105-001', MaxLength = 80, Locked = true;
        ProductNameLbl: Label 'Usage data - Usage Qty.', MaxLength = 100;
}