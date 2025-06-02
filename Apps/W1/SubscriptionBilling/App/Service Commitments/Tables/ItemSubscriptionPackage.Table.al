namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Pricing;
using Microsoft.Sales.Document;

table 8058 "Item Subscription Package"
{
    Caption = 'Item Subscription Package';
    DataClassification = CustomerContent;
    DrillDownPageId = "Item Serv. Commitment Packages";
    LookupPageId = "Item Serv. Commitment Packages";

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
            TableRelation = "Subscription Package";
            trigger OnValidate()
            var
                ServiceCommitmentPackage: Record "Subscription Package";
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
            CalcFormula = lookup("Subscription Package".Description where(Code = field(Code)));
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

    trigger OnInsert()
    begin
        TestPackageLinesInvoicedViaContracts();
    end;

    var
        DiscountCannotBeAssignedErr: Label 'Subscription Package Lines, which are discounts can only be assigned to Subscription Items.';
        EmptyInvoicingItemNoInPackageLineErr: Label 'The %1 %2 can not be used with Item %3, because at least one of the Service Commitment Package lines is missing an %4.';

    internal procedure ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount(ServiceCommitmentPackageCode: Code[20])
    var
        Item: Record Item;
        ServiceCommitmentPackageLine: Record "Subscription Package Line";
    begin
        ServiceCommitmentPackageLine.SetRange("Subscription Package Code", ServiceCommitmentPackageCode);
        ServiceCommitmentPackageLine.SetRange(Discount, true);
        if ServiceCommitmentPackageLine.IsEmpty() then
            exit;
        if not Item.Get(Rec."Item No.") then
            exit;
        if Item."Subscription Option" <> Enum::"Item Service Commitment Type"::"Service Commitment Item" then
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
        ItemServCommitmentPackage: Record "Item Subscription Package";
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

    local procedure IsPackageAssignedToServiceObject(ServiceObjectNo: Code[20]; ItemServCommitmentPackageCode: Code[20]): Boolean
    var
        ServiceCommitment: Record "Subscription Line";
    begin
        if ServiceObjectNo = '' then
            exit;
        ServiceCommitment.SetRange("Subscription Header No.", ServiceObjectNo);
        ServiceCommitment.SetRange("Subscription Package Code", ItemServCommitmentPackageCode);
        exit(not ServiceCommitment.IsEmpty());
    end;

    internal procedure GetPackageFilterForItem(SalesLine: Record "Sales Line"; RemoveExistingPackageFromFilter: Boolean) PackageFilter: Text
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
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
        SalesServiceCommitment: Record "Sales Subscription Line";
    begin
        SalesServiceCommitment.FilterOnSalesLine(SalesLine);
        SalesServiceCommitment.SetRange("Subscription Package Code", ItemServCommitmentPackageCode);
        exit(not SalesServiceCommitment.IsEmpty());
    end;

    internal procedure GetAllStandardPackageFilterForItem(ItemNo: Code[20]; CustomerPriceGroup: Code[10]) PackageFilter: Text
    var
        ItemServCommitmentPackage: Record "Item Subscription Package";
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

    local procedure TestPackageLinesInvoicedViaContracts()
    var
        Item: Record Item;
    begin
        if Rec.IsTemporary then
            exit;
        if not Item.Get(Rec."Item No.") then
            exit;
        if Item."Subscription Option" <> "Item Service Commitment Type"::"Sales with Service Commitment" then
            exit;

        ErrorIfPackageLineInvoicedViaContractWithoutInvoicingItemExist();
    end;

    internal procedure ErrorIfPackageLineInvoicedViaContractWithoutInvoicingItemExist()
    var
        SubscriptionPackage: Record "Subscription Package";
        SubscriptionPackageLine: Record "Subscription Package Line";
        ErrorInfo: ErrorInfo;
        OpenSubscriptionPackageTxt: Label 'Open %1';
    begin
        if Rec.Code = '' then
            exit;

        SubscriptionPackage.Get(Rec.Code);
        if SubscriptionPackage.PackageLineInvoicedViaContractWithoutInvoicingItemExist() then begin
            ErrorInfo.Message(StrSubstNo(EmptyInvoicingItemNoInPackageLineErr, SubscriptionPackage.TableCaption, Rec.Code, Rec."Item No.", SubscriptionPackageLine.FieldCaption("Invoicing Item No.")));
            ErrorInfo.RecordId(SubscriptionPackage.RecordId);
            ErrorInfo.PageNo(Page::"Service Commitment Package");
            ErrorInfo.AddNavigationAction(StrSubstNo(OpenSubscriptionPackageTxt, SubscriptionPackage.TableCaption));
            Error(ErrorInfo);
        end
    end;
}
