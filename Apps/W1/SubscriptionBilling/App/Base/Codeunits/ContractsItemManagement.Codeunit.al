namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;
using Microsoft.Pricing.Calculation;
using Microsoft.Pricing.PriceList;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Inventory.BOM;

codeunit 8055 "Contracts Item Management"
{
    Access = Internal;
    SingleInstance = true;

    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterValidateEvent, Type, false, false)]
    local procedure ItemOnAfterValidateType(var Rec: Record Item)
    begin
        if Rec."Service Commitment Option" in [Enum::"Item Service Commitment Type"::"Service Commitment Item", Enum::"Item Service Commitment Type"::"Invoicing Item"] then
            if Rec.Type <> Rec.Type::"Non-Inventory" then
                Error(
                    NonInventoryTypeErr,
                    Rec.Type,
                    Enum::"Item Service Commitment Type"::"Sales without Service Commitment",
                    Enum::"Item Service Commitment Type"::"Sales with Service Commitment",
                    Rec.FieldCaption("Service Commitment Option"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnBeforeValidateEvent, "No.", false, false)]
    local procedure SalesLineOnBeforeValidateNo(var Rec: Record "Sales Line")
    begin
        if Rec.Type = Rec.Type::Item then begin
            if not Rec.IsLineAttachedToBillingLine() then
                PreventBillingItem(Rec."No.");
            //Service Commitment Item can only be used in either of three cases:
            //Quote for purposes of creating sales service commitments
            //Order for purposes of creating sales service commitments
            //Contract Invoice for billing purposes
            if not Rec.IsSalesDocumentTypeWithServiceCommitments() and (not Rec.IsLineAttachedToBillingLine()) then
                PreventServiceCommitmentItem(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnBeforeValidateEvent, "No.", false, false)]
    local procedure PurchaseLineOnBeforeValidateEvent(var Rec: Record "Purchase Line")
    begin
        if Rec.Type = Rec.Type::Item then begin
            if (not Rec.IsLineAttachedToBillingLine()) then
                PreventBillingItem(Rec."No.");
            if not (Rec."Document Type" = Enum::"Purchase Document Type"::Order) and (not Rec.IsLineAttachedToBillingLine()) then
                PreventServiceCommitmentItem(Rec."No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"BOM Component", OnBeforeValidateEvent, "No.", false, false)]
    local procedure BOMComponentOnAfterValidateNo(var Rec: Record "BOM Component")
    begin
        if Rec.Type = Rec.Type::Item then
            PreventBillingItem(Rec."No.");
    end;

    local procedure PreventServiceCommitmentItem(ItemNo: Code[20])
    begin
        if SessionStore.GetBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo') then
            exit;
        if IsServiceCommitmentItem(ItemNo) then
            Error(ServiceCommitmentItemErr);
    end;

    local procedure PreventBillingItem(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        if not GetItem(ItemNo, Item) then
            exit;
        if SessionStore.GetBooleanKey('CreateBillingDocumentsAllowInsertOfInvoicingItemNo') then
            exit;
        if Item."Service Commitment Option" = Enum::"Item Service Commitment Type"::"Invoicing Item" then
            Error(InvoicingItemErr);
    end;

    local procedure GetItem(ItemNo: Code[20]; var Item: Record Item): Boolean
    begin
        if ItemNo = '' then
            exit(false);
        if not Item.Get(ItemNo) then
            exit(false);
        exit(true);
    end;

    procedure IsServiceCommitmentItem(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if not GetItem(ItemNo, Item) then
            exit(false);

        exit(Item."Service Commitment Option" = "Item Service Commitment Type"::"Service Commitment Item");
    end;

    procedure IsItemWithServiceCommitments(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        if not GetItem(ItemNo, Item) then
            exit(false);

        exit(
            (Item."Service Commitment Option" in
             ["Item Service Commitment Type"::"Sales with Service Commitment",
              "Item Service Commitment Type"::"Service Commitment Item"]));
    end;

    internal procedure GetSalesPriceForItem(var UnitPrice: Decimal; ItemNo: Code[20]; Quantity: Decimal; CurrencyCode: Code[10]; SellToCustomerNo: Code[20]; BillToCustomerNo: Code[20])
    var
        TempSalesLine: Record "Sales Line" temporary;
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        //Currently BillToCustomer is not taken into consideration for price calculation
        //In the future (probably) the setup will be created, reference: IC221779
        UnitPrice := 0;
        if (SellToCustomerNo = '') or (ItemNo = '') then
            exit;
        CreateTempSalesHeader(TempSalesHeader, TempSalesHeader."Document Type"::Order, SellToCustomerNo, SellToCustomerNo, 0D, CurrencyCode);
        CreateTempSalesLine(TempSalesLine, TempSalesHeader, ItemNo, Quantity);
        UnitPrice := CalculateUnitPrice(TempSalesHeader, TempSalesLine);
    end;

    internal procedure CreateTempSalesHeader(var TempSalesHeader: Record "Sales Header" temporary; DocumentType: Enum "Sales Document Type"; SellToCustomerNo: Code[20]; BillToCustomerNo: Code[20]; OrderDate: Date; CurrencyCode: Code[10])
    begin
        TempSalesHeader.SetHideValidationDialog(true);
        TempSalesHeader.Init();
        TempSalesHeader.Validate("Document Type", DocumentType);
        TempSalesHeader.Validate(Status, TempSalesHeader.Status::Open);
        TempSalesHeader.InitRecord();
        if SellToCustomerNo <> '' then
            TempSalesHeader.Validate("Sell-to Customer No.", SellToCustomerNo);
        if BillToCustomerNo <> '' then
            TempSalesHeader.Validate("Bill-to Customer No.", BillToCustomerNo);
        TempSalesHeader.Validate("Currency Code", CurrencyCode);
        TempSalesHeader."Order Date" := OrderDate;
    end;

    internal procedure CreateTempSalesLine(var TempSalesLine: Record "Sales Line" temporary; var TempSalesHeader: Record "Sales Header" temporary; ItemNo: Code[20]; Quantity: Decimal)
    begin
        CreateTempSalesLine(TempSalesLine, TempSalesHeader, ItemNo, Quantity, 0D);
    end;

    internal procedure CreateTempSalesLine(var TempSalesLine: Record "Sales Line" temporary; var TempSalesHeader: Record "Sales Header" temporary; ItemNo: Code[20]; Quantity: Decimal; OrderDate: Date)
    begin
        TempSalesLine.Init();
        TempSalesLine.SetHideValidationDialog(true);
        TempSalesLine.SuspendStatusCheck(true);
        TempSalesLine.Validate("Document Type", TempSalesHeader."Document Type");
        TempSalesLine."Document No." := TempSalesHeader."No.";
        TempSalesLine.Type := TempSalesLine.Type::Item;
        TempSalesLine."Sell-to Customer No." := TempSalesHeader."Sell-to Customer No.";
        TempSalesLine."Bill-to Customer No." := TempSalesHeader."Bill-to Customer No.";
        TempSalesLine."Customer Price Group" := TempSalesHeader."Customer Price Group";
        TempSalesLine."VAT Bus. Posting Group" := TempSalesHeader."VAT Bus. Posting Group";
        TempSalesLine."No." := ItemNo;
        TempSalesLine.Quantity := Quantity;
        TempSalesLine."Currency Code" := TempSalesHeader."Currency Code";

        if OrderDate <> 0D then
            TempSalesLine."Posting Date" := OrderDate; //Field is empty in the temp table and affects whether the correct sales price will be picked. Field has to be forced either it will use WorkDate
    end;

    internal procedure CalculateUnitPrice(var TempSalesHeader: Record "Sales Header" temporary; var TempSalesLine: Record "Sales Line" temporary): Decimal
    var
        PriceCalculation: Interface "Price Calculation";
    begin
        TempSalesLine.GetPriceCalculationHandler("Price Type"::Sale, TempSalesHeader, PriceCalculation);
        TempSalesLine.ApplyDiscount(PriceCalculation);
        TempSalesLine.ApplyPrice(TempSalesLine.FieldNo("No."), PriceCalculation);
        exit(TempSalesLine."Unit Price");
    end;

    internal procedure CalculateUnitCost(ItemNo: Code[20]): Decimal
    var
        Item: Record Item;
    begin
        if ItemNo = '' then
            exit;
        Item.Get(ItemNo);
        exit(Item."Last Direct Cost");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterValidateEvent, "Allow Invoice Disc.", false, false)]
    local procedure ErrorIfAllowInvoiceDiscountForPriceListLineForServiceCommitmentItem(var Rec: Record "Price List Line")
    var
        Item: Record Item;
    begin
        if Rec."Price Type" <> Rec."Price Type"::Sale then
            exit;
        if Rec."Asset Type" <> Rec."Asset Type"::Item then
            exit;
        if Rec."Allow Invoice Disc." then
            if Item.Get(Rec."Asset No.") then
                if Item.IsServiceCommitmentItem() then
                    Error(Item.GetDoNotAllowInvoiceDiscountForServiceCommitmentItemErrorText());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterCopyFromForPriceAsset, '', false, false)]
    local procedure DisableInvoiceDiscountForServiceCommitmentItemAfterPriceAssetAssigned(var PriceListLine: Record "Price List Line")
    begin
        DisableInvoiceDiscountForServiceCommitmentItem(PriceListLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterValidateEvent, "Amount Type", false, false)]
    local procedure DisableInvoiceDiscountForServiceCommitmentItemAfterChangingAmountType(var Rec: Record "Price List Line")
    begin
        DisableInvoiceDiscountForServiceCommitmentItem(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Attribute Value Selection", OnInsertRecordOnBeforeItemAttrValueSelectionInsert, '', false, false)]
    local procedure CopyPrimaryFieldValueFromItemAttribute(var ItemAttributeValueSelection: Record "Item Attribute Value Selection"; TempItemAttributeValue: Record "Item Attribute Value" temporary)
    begin
        ItemAttributeValueSelection.Primary := TempItemAttributeValue.Primary;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Catalog Item Management", OnAfterCreateNewItem, '', false, false)]
    local procedure InsertItemServiceCommPackAfterCreateNewItem(var Item: Record Item; NonstockItem: Record "Nonstock Item"; var NewItem: Record Item)
    begin
        InsertItemServCommPackFromItemTemplServCommPack(Item, NonstockItem."Item Templ. Code");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Templ. Mgt.", OnAfterCreateItemFromTemplate, '', false, false)]
    local procedure InsertItemServiceCommPackAfterCreateItemFromTemplate(var Item: Record Item; ItemTempl: Record "Item Templ.")
    begin
        InsertItemServCommPackFromItemTemplServCommPack(Item, ItemTempl.Code);
    end;

    local procedure InsertItemServCommPackFromItemTemplServCommPack(Item: Record Item; ItemTemplCode: Code[20])
    var
        ItemTemplServCommPackage: Record "Item Templ. Serv. Comm. Pack.";
    begin
        ItemTemplServCommPackage.SetRange("Item Template Code", ItemTemplCode);
        if ItemTemplServCommPackage.FindSet() then
            repeat
                InsertItemServiceCommitmentPackage(Item, ItemTemplServCommPackage.Code, ItemTemplServCommPackage.Standard);
            until ItemTemplServCommPackage.Next() = 0;
    end;

    internal procedure InsertItemServiceCommitmentPackage(Item: Record Item; PackageCode: Code[20]; Standard: Boolean)
    var
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        ServiceCommitmentPackage: Record "Service Commitment Package";
    begin
        if not ItemServCommitmentPackage.Get(Item."No.", PackageCode) then begin
            ServiceCommitmentPackage.Get(PackageCode);
            ItemServCommitmentPackage.Init();
            ItemServCommitmentPackage."Item No." := Item."No.";
            ItemServCommitmentPackage.Code := PackageCode;
            ItemServCommitmentPackage.Standard := Standard;
            ItemServCommitmentPackage.ErrorIfInvoicingItemIsNotServiceCommitmentItemForDiscount(PackageCode);
            ItemServCommitmentPackage.Validate("Price Group", ServiceCommitmentPackage."Price Group");
            ItemServCommitmentPackage.Insert(false);
        end
    end;

    local procedure DisableInvoiceDiscountForServiceCommitmentItem(var PriceListLine: Record "Price List Line")
    var
        Item: Record Item;
    begin
        if Item.Get(PriceListLine."Asset No.") then
            if Item.IsServiceCommitmentItem() then
                PriceListLine."Allow Invoice Disc." := Item."Allow Invoice Disc.";
    end;

    var
        SessionStore: Codeunit "Session Store";
        NonInventoryTypeErr: Label 'The value "%1" can only be set if either "%2" or "%3" is selected in the field "%4".';
        InvoicingItemErr: Label 'Items that are marked as Invoicing Item may not be used here. Please choose another item.';
        ServiceCommitmentItemErr: Label 'Items that are marked as Service Commitment Item may not be used here. Please choose another item.';
}