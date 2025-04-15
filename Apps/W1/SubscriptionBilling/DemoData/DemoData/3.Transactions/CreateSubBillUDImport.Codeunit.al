namespace Microsoft.SubscriptionBilling;

using System.Reflection;
using Microsoft.DemoTool.Helpers;

codeunit 8119 "Create Sub. Bill. UD Import"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoUtilities: Codeunit "Contoso Utilities";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
        CreateSubBillSupplier: Codeunit "Create Sub. Bill. Supplier";
        TypeHelper: Codeunit "Type Helper";
    begin
        ContosoSubscriptionBilling.InsertUsageDataImport(CreateSubBillSupplier.Generic(), SampleLbl, GenericDataHeaderTxt + TypeHelper.CRLFSeparator() + GenericDataLineTxt, GenericFileNameLbl, ContosoUtilities.AdjustDate(19020101D));
    end;

    var
        SampleLbl: Label 'Sample', MaxLength = 80;
        GenericDataHeaderTxt: Label 'CustomerId;CustomerName;SubscriptionId;ProductId;ProductName;SubscriptionStartDate;SubscriptionEndDate;ChargeStartDate;ChargeEndDate;Quantity;UnitCost;UnitPrice;CostAmount;Amount;Currency';
        GenericDataLineTxt: Label '5741f4d2-be5a-4fc7-a874-5822b152d568;Alpine Ski House;sub-1105-001;prd-wwi-1105-001;Usage data - Usage Qty.;01-01-2025;12-31-2025;01-01-2025;01-31-2025;3;10;0;30;0;USD';
        GenericFileNameLbl: Label 'ReconFile_Generic.csv', MaxLength = 250;
}