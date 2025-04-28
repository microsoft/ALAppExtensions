namespace Microsoft.SubscriptionBilling;

using Microsoft.Foundation.NoSeries;
using Microsoft.DemoTool.Helpers;

codeunit 8103 "Create Sub. Billing No. Series"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoNoSeries: Codeunit "Contoso No Series";
    begin
        ContosoNoSeries.InsertNoSeries(CustomerContractNoSeries(), CustomerContractNoSeriesDescriptionTok, CustomerContractStartingNoLbl, CustomerContractEndingNoLbl, '', CustomerContractLastUsedNoLbl, 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(VendorContractNoSeries(), VendorContractNoSeriesDescriptionTok, VendorContractStartingNoLbl, VendorContractEndingNoLbl, '', VendorContractLastUsedNoLbl, 1, Enum::"No. Series Implementation"::Normal, true);
        ContosoNoSeries.InsertNoSeries(ServiceObjectNoSeries(), ServiceObjectNoSeriesDescriptionTok, ServiceObjectStartingNoLbl, ServiceObjectEndingNoLbl, '', ServiceObjectLastUsedNoLbl, 1, Enum::"No. Series Implementation"::Normal, true);
    end;

    procedure CustomerContractNoSeries(): Code[20]
    begin
        exit(CustomerContractNoSeriesTok);
    end;

    procedure VendorContractNoSeries(): Code[20]
    begin
        exit(VendorContractNoSeriesTok);
    end;

    procedure ServiceObjectNoSeries(): Code[20]
    begin
        exit(ServiceObjectNoSeriesTok);
    end;

    var
        CustomerContractNoSeriesTok: Label 'CUSTSUBCONTR', MaxLength = 20;
        CustomerContractNoSeriesDescriptionTok: Label 'Customer Subscription Contracts', MaxLength = 100;
        CustomerContractStartingNoLbl: Label 'CSC100001', MaxLength = 20;
        CustomerContractEndingNoLbl: Label 'CSC999999', MaxLength = 20;
        CustomerContractLastUsedNoLbl: Label 'CSC100004', MaxLength = 20;
        VendorContractNoSeriesTok: Label 'VENDSUBCONTR', MaxLength = 20;
        VendorContractNoSeriesDescriptionTok: Label 'Vendor Subscription Contracts', MaxLength = 100;
        VendorContractStartingNoLbl: Label 'VSC100001', MaxLength = 20;
        VendorContractLastUsedNoLbl: Label 'VSC100002', MaxLength = 20;
        VendorContractEndingNoLbl: Label 'VSC999999', MaxLength = 20;
        ServiceObjectNoSeriesTok: Label 'SUBSCRIPTION', MaxLength = 20;
        ServiceObjectNoSeriesDescriptionTok: Label 'Subscriptions', MaxLength = 100;
        ServiceObjectStartingNoLbl: Label 'SUB100001', MaxLength = 20;
        ServiceObjectLastUsedNoLbl: Label 'SUB100004', MaxLength = 20;
        ServiceObjectEndingNoLbl: Label 'SUB999999', MaxLength = 20;
}