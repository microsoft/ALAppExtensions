namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;
using Microsoft.Sales.Document;

table 8058 "Item Serv. Commitment Package"
{
    Caption = 'Item Service Commitment Package';
    DataClassification = CustomerContent;
    DrillDownPageId = "Item Serv. Commitment Packages";
    LookupPageId = "Item Serv. Commitment Packages";
    Access = Internal;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            NotBlank = true;
            TableRelation = Item;
        }
        field(2; Code; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            TableRelation = "Service Commitment Package";
            trigger OnValidate()
            var
                ServiceCommitmentPackage: Record "Service Commitment Package";
            begin
                if ServiceCommitmentPackage.Get(Code) then
                    "Price Group" := ServiceCommitmentPackage."Price Group";
                ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount(ServiceCommitmentPackage.Code);
            end;
        }
        field(3; Description; Text[100])
        {
            Caption = 'Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Service Commitment Package".Description where(Code = field(Code)));
            Editable = false;
        }
        field(4; Standard; Boolean)
        {
            Caption = 'Standard';
        }
        field(5; "Price Group"; Code[10])
        {
            Caption = 'Price Group';
            Editable = false;
            TableRelation = "Customer Price Group";
        }
    }
    keys
    {
        key(PK; "Item No.", Code)
        {
            Clustered = true;
        }
    }
    var
        DiscountCannotBeAssignedErr: Label 'Service Commitment Package lines, which are discounts can only be assigned to Service Commitment Items.';

    internal procedure ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount(ServiceCommitmentPackageCode: Code[20])
    var
        Item: Record Item;
        ServiceCommitmentPackageLine: Record "Service Comm. Package Line";
    begin
        ServiceCommitmentPackageLine.SetRange("Package Code", ServiceCommitmentPackageCode);
        ServiceCommitmentPackageLine.SetRange(Discount, true);
        if ServiceCommitmentPackageLine.IsEmpty() then
            exit;
        if not Item.Get(Rec."Item No.") then
            exit;
        if Item."Service Commitment Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
            Error(DiscountCannotBeAssignedErr);
    end;

    internal procedure GetPackageFilterForItem(ItemNo: Code[20]) PackageFilter: Text
    begin
        PackageFilter := GetPackageFilterForItem(ItemNo, '');
    end;

    internal procedure GetPackageFilterForItem(ItemNo: Code[20]; ServiceObjectNo: Code[20]) PackageFilter: Text
    begin
        PackageFilter := GetPackageFilterForItem(ItemNo, ServiceObjectNo, false);
    end;

    internal procedure GetPackageFilterForItem(ItemNo: Code[20]; ServiceObjectNo: Code[20]; OnlyNonStandardPackage: Boolean) PackageFilter: Text
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        TextManagement: Codeunit "Text Management";
    begin
        ItemServCommitmentPackage.SetRange("Item No.", ItemNo);

        if OnlyNonStandardPackage then
            ItemServCommitmentPackage.SetRange(Standard, false);

        if ItemServCommitmentPackage.FindSet() then
            repeat
                if not IsPackageAssignedToServiceObject(ServiceObjectNo, ItemServCommitmentPackage.Code) then
                    TextManagement.AppendText(PackageFilter, ItemServCommitmentPackage.Code, '|');
            until ItemServCommitmentPackage.Next() = 0;
        TextManagement.ReplaceInvalidFilterChar(PackageFilter);
    end;

    internal procedure IsPackageAssignedToServiceObject(ServiceObjectNo: Code[20]; ItemServCommitmentPackageCode: Code[20]): Boolean
    var
        ServiceCommitment: Record "Service Commitment";
    begin
        if ServiceObjectNo = '' then
            exit;
        ServiceCommitment.SetRange("Service Object No.", ServiceObjectNo);
        ServiceCommitment.SetRange("Package Code", ItemServCommitmentPackageCode);
        exit(not ServiceCommitment.IsEmpty());
    end;

    internal procedure GetPackageFilterForItem(SalesLine: Record "Sales Line"; RemoveExistingPackageFromFilter: Boolean) PackageFilter: Text
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        TextManagement: Codeunit "Text Management";
    begin
        if (SalesLine.Type <> Enum::"Sales Line Type"::Item) or (SalesLine."No." = '') then
            exit;
        ItemServCommitmentPackage.SetRange("Item No.", SalesLine."No.");
        if ItemServCommitmentPackage.FindSet() then
            repeat
                if RemoveExistingPackageFromFilter then begin
                    if not IsPackageAssignedToSalesLine(SalesLine, ItemServCommitmentPackage.Code) then
                        TextManagement.AppendText(PackageFilter, ItemServCommitmentPackage.Code, '|');
                end else
                    TextManagement.AppendText(PackageFilter, ItemServCommitmentPackage.Code, '|');
            until ItemServCommitmentPackage.Next() = 0;
        TextManagement.ReplaceInvalidFilterChar(PackageFilter);
    end;

    internal procedure IsPackageAssignedToSalesLine(SalesLine: Record "Sales Line"; ItemServCommitmentPackageCode: Code[20]): Boolean
    var
        SalesServiceCommitment: Record "Sales Service Commitment";
    begin
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.SetRange("Package Code", ItemServCommitmentPackageCode);
        exit(not SalesServiceCommitment.IsEmpty());
    end;

    internal procedure GetAllStandardPackageFilterForItem(ItemNo: Code[20]; CustomerPriceGroup: Code[10]) PackageFilter: Text
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        TextManagement: Codeunit "Text Management";
    begin
        ItemServCommitmentPackage.FilterAllStandardPackageFilterForItem(ItemNo, CustomerPriceGroup);
        if ItemServCommitmentPackage.FindSet() then
            repeat
                TextManagement.AppendText(PackageFilter, ItemServCommitmentPackage.Code, '|');
            until ItemServCommitmentPackage.Next() = 0;
        TextManagement.ReplaceInvalidFilterChar(PackageFilter);
    end;

    internal procedure FilterAllStandardPackageFilterForItem(ItemNo: Code[20]; CustomerPriceGroup: Code[10])
    begin
        Rec.SetRange("Item No.", ItemNo);
        Rec.SetRange(Standard, true);
        Rec.SetRange("Price Group", CustomerPriceGroup);
        if Rec.IsEmpty() then
            Rec.SetFilter("Price Group", '%1', '');
        if Rec.IsEmpty() then
            Rec.SetRange("Price Group");
    end;
}
