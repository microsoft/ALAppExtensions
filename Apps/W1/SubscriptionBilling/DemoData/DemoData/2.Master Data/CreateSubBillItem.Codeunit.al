namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.DemoData.Common;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoTool;

codeunit 8110 "Create Sub. Bill. Item"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        CreateItemsForSubscriptionBilling();
    end;

    local procedure CreateItemsForSubscriptionBilling()
    var
        CommonPostingGroup: Codeunit "Create Common Posting Group";
        CreateVendor: Codeunit "Create Vendor";
        CommonUOM: Codeunit "Create Common Unit Of Measure";
        ContosoSubscriptionBilling: Codeunit "Contoso Subscription Billing";
    begin
        ContosoSubscriptionBilling.InsertItem(SB1100(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Service Commitment Item", DigitalNewspaperLbl, AdjustPrice(10), 5, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
            CreateVendor.DomesticNodPublisher());
        ContosoSubscriptionBilling.InsertItem(SB1101(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Service Commitment Item", SoftwareLicenceLbl, AdjustPrice(50), 35, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
             CreateVendor.ExportFabrikam());
        ContosoSubscriptionBilling.InsertItem(SB1102(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Service Commitment Item", SupportLbl, AdjustPrice(100), 70, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
             '');
        ContosoSubscriptionBilling.InsertItem(SB1103(), Enum::"Item Type"::Inventory, Enum::"Item Service Commitment Type"::"Sales with Service Commitment", HardwareLbl, AdjustPrice(800), 500, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), CommonPostingGroup.Resale(), CommonUOM.Piece(),
             CreateVendor.DomesticWorldImporter());
        ContosoSubscriptionBilling.InsertItem(SB1104(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Invoicing Item", MaintenanceLbl, AdjustPrice(0), 0, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
             '');
        ContosoSubscriptionBilling.InsertItem(SB1105(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Service Commitment Item", UDUsageQtyLbl, AdjustPrice(20), 10, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
             '');
        ContosoSubscriptionBilling.InsertItem(SB1106(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Service Commitment Item", UDSurchargeLbl, AdjustPrice(1), 1, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
             '');
        ContosoSubscriptionBilling.InsertItem(SB1107(), Enum::"Item Type"::"Non-Inventory", Enum::"Item Service Commitment Type"::"Service Commitment Item", UDFixedQtyLbl, AdjustPrice(500), 50, CommonPostingGroup.Retail(), CommonPostingGroup.NonTaxable(), '', CommonUOM.Piece(),
             '');
    end;

    var
        DigitalNewspaperLbl: Label 'Digital newspaper', MaxLength = 100;
        SoftwareLicenceLbl: Label 'Software licence (user)', MaxLength = 100;
        SupportLbl: Label 'Support (monthly)', MaxLength = 100;
        HardwareLbl: Label 'Hardware', MaxLength = 100;
        MaintenanceLbl: Label 'Maintenance', MaxLength = 100;
        UDUsageQtyLbl: Label 'Sample: Usage Data - Usage Qty.', MaxLength = 100;
        UDSurchargeLbl: Label 'Sample: Usage data - Surcharge', MaxLength = 100;
        UDFixedQtyLbl: Label 'Sample: Usage data - Fixed Qty.', MaxLength = 100;

    procedure SB1100(): Code[20]
    begin
        exit('SB1100');
    end;

    procedure SB1101(): Code[20]
    begin
        exit('SB1101');
    end;

    procedure SB1102(): Code[20]
    begin
        exit('SB1102');
    end;

    procedure SB1103(): Code[20]
    begin
        exit('SB1103');
    end;

    procedure SB1104(): Code[20]
    begin
        exit('SB1104');
    end;

    procedure SB1105(): Code[20]
    begin
        exit('SB1105');
    end;

    procedure SB1106(): Code[20]
    begin
        exit('SB1106');
    end;

    procedure SB1107(): Code[20]
    begin
        exit('SB1107');
    end;

    internal procedure AdjustPrice(UnitPrice: Decimal): Decimal
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if UnitPrice = 0 then
            exit(0);

        exit(Round(UnitPrice * ContosoCoffeeDemoDataSetup."Price Factor", ContosoCoffeeDemoDataSetup."Rounding Precision"));
    end;

}