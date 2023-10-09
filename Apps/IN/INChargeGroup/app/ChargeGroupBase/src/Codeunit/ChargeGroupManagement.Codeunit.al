// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup.ChargeGroupBase;

using Microsoft.Finance.Currency;
using Microsoft.Purchases.Document;
using Microsoft.Sales.Document;
using System.Reflection;

codeunit 18502 "Charge Group Management"
{
    var
        BlankDocumentNoErr: Label 'Charge Group Code field cannot be blank on document %1.', Comment = '%1 = RecordId';
        EntryUpdatedErr: Label 'There is change in quantity or value in items. Explode the Charge Group again for Record %1.', Comment = '%1 = RecordId';
        ChargeGroupLineNotExistErr: Label 'Charge Group Line does not exist for Record %1. Please remove Charge Group Code or Explode Charge Group from line section.', Comment = '%1 = RecordId';

    procedure InsertChargeItemOnLine(VariantRec: Variant)
    var
        IsHandled: Boolean;
        LineExist: Boolean;
    begin
        OnBeforeInsertChargeItemOnline(VariantRec, IsHandled);
        if IsHandled then
            exit;

        CheckDocLineExist(VariantRec, LineExist);
        if not LineExist then
            exit;

        CheckChargeGroupExist(VariantRec);
        InsertChargeLinesOnDoc(VariantRec);

        OnAfterInsertChargeItemOnline(VariantRec);
    end;

    procedure GetLineNo(VariantRec: Variant; var LineNo: Integer)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number() of
            Database::"Sales Header":
                GetSalesLineLastLineNo(VariantRec, LineNo);
            Database::"Purchase Header":
                GetPurchaseLineLastLineNo(VariantRec, LineNo);
            else
                GetLineNoFromOtherTables(VariantRec, LineNo);
        end;
    end;

    procedure GetTotalAmount(VariantRec: Variant; var TotalItemLineAmt: Decimal; var TotalItemQty: Decimal)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                GetSalesTotal(VariantRec, TotalItemLineAmt, TotalItemQty);
            Database::"Purchase Header":
                GetPurchaseTotal(VariantRec, TotalItemLineAmt, TotalItemQty);
            else
                GetTotalAmountFromOtherRec(VariantRec, TotalItemLineAmt, TotalItemQty);
        end;
    end;

    procedure CheckChargeLinesOnDoc(VariantRec: Variant)
    var
        ChargeGroupLine: Record "Charge Group Line";
        ChargeGroupCode: Code[20];
        ChargeGroupLineExist: Boolean;
        EntryUpdated: Boolean;
    begin
        if not VariantRec.IsRecord() then
            exit;

        CheckChargeGroupLinesExist(VariantRec, ChargeGroupLineExist);

        if not ChargeGroupLineExist then
            Error(ChargeGroupLineNotExistErr, GetRecordIdFromVariantRec(VariantRec));

        FindChargeGroup(VariantRec, ChargeGroupCode);

        ChargeGroupLine.LoadFields("Charge Group Code");
        ChargeGroupLine.SetRange("Charge Group Code", ChargeGroupCode);
        if ChargeGroupLine.FindSet() then
            repeat
                CheckChargeGroupValuesOnItemUpdate(VariantRec, ChargeGroupLine, EntryUpdated);
                if EntryUpdated then
                    Error(EntryUpdatedErr, GetRecordIdFromVariantRec(VariantRec));
            until ChargeGroupLine.Next() = 0;
    end;

    procedure CalcLineAmount(ChargeGroupLine: Record "Charge Group Line"; TotalItemLineAmt: Decimal; TotalItemQty: Decimal; var LineAmount: Decimal)
    begin
        case ChargeGroupLine."Computation Method" of
            ChargeGroupLine."Computation Method"::" ":
                LineAmount := 0;
            ChargeGroupLine."Computation Method"::Percentage:
                LineAmount := (TotalItemLineAmt * ChargeGroupLine.Value) / 100;
            ChargeGroupLine."Computation Method"::"Fixed Value":
                LineAmount := ChargeGroupLine.Value;
            ChargeGroupLine."Computation Method"::"Amount Per Quantity":
                LineAmount := ChargeGroupLine.Value * TotalItemQty;
            else
                CalLineAmountForMoreComputationMethod(ChargeGroupLine, TotalItemLineAmt, TotalItemQty, LineAmount);
        end;
    end;

    local procedure CheckChargeGroupValuesOnItemUpdate(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line"; var EntryUpdated: Boolean)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                CheckChargeGroupValuesOnSaleItemUpdate(VariantRec, ChargeGroupLine, EntryUpdated);
            Database::"Purchase Header":
                CheckChargeGroupValuesOnPurchaseItemUpdate(VariantRec, ChargeGroupLine, EntryUpdated);
            else
                CheckChargeGroupValuesOnOtherItemUpdate(VariantRec, ChargeGroupLine, EntryUpdated);
        end;
    end;

    local procedure CheckChargeGroupValuesOnSaleItemUpdate(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line"; var EntryUpdated: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalItemLineAmt: Decimal;
        TotalItemQty: Decimal;
        DirectUnitCost: Decimal;
    begin
        SalesHeader := VariantRec;

        GetTotalAmount(VariantRec, TotalItemLineAmt, TotalItemQty);
        CalcLineAmount(ChargeGroupLine, TotalItemLineAmt, TotalItemQty, DirectUnitCost);

        SalesLine.LoadFields("Document Type", "Document No.", Type, "Charge Group Code", "No.", "Charge Group Line No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        case ChargeGroupLine.Type of
            ChargeGroupLine.Type::"Charge (Item)":
                SalesLine.SetRange(Type, SalesLine.Type::"Charge (Item)");
            ChargeGroupLine.Type::"G/L Account":
                SalesLine.SetRange(Type, SalesLine.Type::"G/L Account");
        end;
        SalesLine.SetRange("Charge Group Code", ChargeGroupLine."Charge Group Code");
        SalesLine.SetRange("No.", ChargeGroupLine."No.");
        SalesLine.SetRange("Charge Group Line No.", ChargeGroupLine."Line No.");
        if SalesLine.FindFirst() then
            if SalesLine."Unit Price" <> DirectUnitCost then
                EntryUpdated := true;
    end;

    local procedure CheckChargeGroupValuesOnPurchaseItemUpdate(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line"; var EntryUpdated: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TotalItemLineAmt: Decimal;
        TotalItemQty: Decimal;
        DirectUnitCost: Decimal;
    begin
        PurchaseHeader := VariantRec;
        GetTotalAmount(VariantRec, TotalItemLineAmt, TotalItemQty);
        CalcLineAmount(ChargeGroupLine, TotalItemLineAmt, TotalItemQty, DirectUnitCost);

        PurchaseLine.LoadFields("Document Type", "Document No.", Type, "Charge Group Code", "No.", "Charge Group Line No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        case ChargeGroupLine.Type of
            ChargeGroupLine.Type::"Charge (Item)":
                PurchaseLine.SetRange(Type, PurchaseLine.Type::"Charge (Item)");
            ChargeGroupLine.Type::"G/L Account":
                PurchaseLine.SetRange(Type, PurchaseLine.Type::"G/L Account");
        end;
        PurchaseLine.SetRange("Charge Group Code", ChargeGroupLine."Charge Group Code");
        PurchaseLine.SetRange("No.", ChargeGroupLine."No.");
        PurchaseLine.SetRange("Charge Group Line No.", ChargeGroupLine."Line No.");
        if PurchaseLine.FindFirst() then
            if PurchaseLine."Direct Unit Cost" <> DirectUnitCost then
                EntryUpdated := true;
    end;

    local procedure GetSalesLineLastLineNo(VariantRec: Variant; var LineNo: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader := VariantRec;
        SalesLine.LoadFields("Document Type", "Document No.", "Line No.");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        if SalesLine.Findlast() then
            LineNo := SalesLine."Line No." + 10000
        else
            LineNo := 10000;
    end;

    local Procedure GetPurchaseLineLastLineNo(VariantRec: Variant; var LineNo: Integer)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader := VariantRec;
        PurchaseLine.LoadFields("Document Type", "Document No.", "Line No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.Findlast() then
            LineNo := PurchaseLine."Line No." + 10000
        else
            LineNo := 10000;
    end;

    local procedure GetSalesTotal(VariantRec: Variant; var TotalItemLineAmt: Decimal; var TotalItemQty: Decimal)
    var
        SalesHeader: Record "Sales Header";
        TotalSalesLine: Record "Sales Line";
    begin
        SalesHeader := VariantRec;
        TotalSalesLine.LoadFields("Document Type", "Document No.", Type, "No.", "Line Amount", Quantity);
        TotalSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        TotalSalesLine.SetRange("Document No.", SalesHeader."No.");
        TotalSalesLine.SetRange(Type, TotalSalesLine.Type::Item);
        TotalSalesLine.setfilter("No.", '<>%1', '');
        TotalSalesLine.CalcSums("Line Amount", Quantity);
        TotalItemLineAmt := TotalSalesLine."Line Amount";
        TotalItemQty := TotalSalesLine.Quantity;
    end;

    local procedure GetPurchaseTotal(VariantRec: Variant; var TotalItemLineAmt: Decimal; var TotalItemQty: Decimal)
    var
        PurchaseHeader: Record "Purchase Header";
        TotalPurchaseLine: Record "Purchase Line";
        IsHandled: Boolean;
    begin
        OnBeforeGetPurchaseTotal(VariantRec, TotalItemLineAmt, TotalItemQty, IsHandled);
        if IsHandled then
            exit;

        PurchaseHeader := VariantRec;
        TotalPurchaseLine.LoadFields("Document Type", "Document No.", Type, "No.", "Line Amount", Quantity);
        TotalPurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        TotalPurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        TotalPurchaseLine.SetRange(Type, TotalPurchaseLine.Type::Item);
        TotalPurchaseLine.setfilter("No.", '<>%1', '');
        TotalPurchaseLine.CalcSums("Line Amount", Quantity);
        TotalItemLineAmt := TotalPurchaseLine."Line Amount";
        TotalItemQty := TotalPurchaseLine.Quantity;

        OnAfterGetPurchaseTotal(VariantRec, TotalItemLineAmt, TotalItemQty);
    end;

    local procedure CheckDocLineExist(VariantRec: Variant; var LineExist: boolean)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                SalesLineExist(VariantRec, LineExist);
            Database::"Purchase Header":
                PurchaseLineExist(VariantRec, LineExist);
            else
                CheckDocLineOnOtheTable(VariantRec, LineExist);
        end
    end;

    local procedure SalesLineExist(VariantRec: Variant; var LineExist: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := VariantRec;
        if SalesHeader.SalesLinesExist() then
            LineExist := true
    end;

    local procedure PurchaseLineExist(VariantRec: Variant; var LineExist: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader := VariantRec;
        if PurchaseHeader.PurchLinesExist() then
            LineExist := true
    end;

    local procedure InsertChargeLinesOnDoc(VariantRec: Variant)
    var
        ChargeGroupLine: Record "Charge Group Line";
        ChargeGroupCode: Code[20];
    begin
        if not VariantRec.IsRecord() then
            exit;

        RemoveChargeGroupEntriesIfExist(VariantRec);
        FindChargeGroup(VariantRec, ChargeGroupCode);

        ChargeGroupLine.LoadFields("Charge Group Code", "Third Party Invoice", "No.");
        ChargeGroupLine.SetRange("Charge Group Code", ChargeGroupCode);
        ChargeGroupLine.SetRange("Third Party Invoice", false);
        ChargeGroupLine.SetFilter("No.", '<>%1', '');
        if ChargeGroupLine.FindSet() then
            repeat
                InsertChargeGroupLines(VariantRec, ChargeGroupLine);
            until ChargeGroupLine.Next() = 0;
    end;

    local procedure RemoveChargeGroupEntriesIfExist(VariantRec: Variant)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                RemoveChargeGroupLinesOnSalesDoc(VariantRec);
            Database::"Purchase Header":
                RemoveChargeGroupLineOnPurchaseDoc(VariantRec);
            else
                RemoveChargeGroupLineOnOtherTable(VariantRec);
        end;
    end;

    local procedure RemoveChargeGroupLinesOnSalesDoc(VariantRec: Variant)
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := VariantRec;
        SalesHeader.RemoveOldChargeGroupEntriesOnSalesLine(SalesHeader);
    end;

    local procedure RemoveChargeGroupLineOnPurchaseDoc(VariantRec: Variant)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader := VariantRec;
        PurchaseHeader.RemoveOldChargeGroupEntriesOnPurchaseLine(PurchaseHeader);
    end;

    local procedure InsertChargeGroupLines(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line")
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                InsertChargeGroupLinesOnSalesDoc(VariantRec, ChargeGroupLine);
            Database::"Purchase Header":
                InsertChargeGroupLineOnPurchaseDoc(VariantRec, ChargeGroupLine);
            else
                InsertChargeGroupLineOnOtherTable(VariantRec, ChargeGroupLine);
        end;
    end;

    local procedure InsertChargeGroupLinesOnSalesDoc(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line")
    var
        SalesLine: Record "Sales Line";
        SalesHeader: Record "Sales Header";
        TotalLineAmt: Decimal;
        TotalQty: Decimal;
        LineAmount: decimal;
        LineNo: Integer;
    begin
        if not VariantRec.IsRecord() then
            exit;

        SalesHeader := VariantRec;

        SalesLine.Init();
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        GetLineNo(VariantRec, LineNo);
        SalesLine."Line No." := LineNo;

        case ChargeGroupLine.Type of
            ChargeGroupLine.Type::"Charge (Item)":
                SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
            ChargeGroupLine.Type::"G/L Account":
                SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        end;

        SalesLine.Validate("No.", ChargeGroupLine."No.");
        SalesLine.Validate(Quantity, 1);

        GetTotalAmount(VariantRec, TotalLineAmt, TotalQty);
        CalcLineAmount(ChargeGroupLine, TotalLineAmt, TotalQty, LineAmount);

        SalesLine.Validate("Unit Price", LineAmount);
        SalesLine.Validate("Charge Group Code", ChargeGroupLine."Charge Group Code");
        SalesLine.Validate("Charge Group Line No.", ChargeGroupLine."Line No.");
        SalesLine.Insert(true);

        if SalesLine.Type = SalesLine.Type::"Charge (Item)" then begin
            InsertItemChargeAssignmentSales(SalesHeader, SalesLine);
            SuggestItemChargeAssignmentSales(SalesLine, ChargeGroupLine);
        end;
    end;

    local procedure InsertChargeGroupLineOnPurchaseDoc(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        TotalLineAmt: Decimal;
        TotalQty: Decimal;
        LineAmount: decimal;
        LineNo: Integer;
    begin
        if not VariantRec.IsRecord() then
            exit;

        PurchaseHeader := VariantRec;

        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        GetLineNo(VariantRec, LineNo);
        PurchaseLine."Line No." := LineNo;

        case ChargeGroupLine.Type of
            ChargeGroupLine.Type::"Charge (Item)":
                PurchaseLine.Validate(Type, PurchaseLine.Type::"Charge (Item)");
            ChargeGroupLine.Type::"G/L Account":
                PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        end;

        PurchaseLine.Validate("No.", ChargeGroupLine."No.");
        PurchaseLine.Validate(Quantity, 1);
        GetTotalAmount(VariantRec, TotalLineAmt, TotalQty);
        CalcLineAmount(ChargeGroupLine, TotalLineAmt, TotalQty, LineAmount);
        PurchaseLine.Validate("Direct Unit Cost", LineAmount);
        PurchaseLine.Validate("Charge Group Code", ChargeGroupLine."Charge Group Code");
        PurchaseLine.Validate("Charge Group Line No.", ChargeGroupLine."Line No.");
        PurchaseLine.Insert(true);

        if PurchaseLine.Type = PurchaseLine.Type::"Charge (Item)" then begin
            InsertItemChargeAssignmentPurchase(PurchaseHeader, PurchaseLine);
            SuggestItemChargeAssignmentPurchase(PurchaseLine, ChargeGroupLine);
        end;
    end;

    local procedure CheckChargeGroupExist(VariantRec: Variant)
    var
        ChargeGroupCode: Code[20];
    begin
        if not VariantRec.IsRecord() then
            exit;

        FindChargeGroup(VariantRec, ChargeGroupCode);
        if ChargeGroupCode = '' then
            Error(BlankDocumentNoErr, GetRecordIdFromVariantRec(VariantRec));
    end;

    local procedure FindChargeGroup(VariantRec: Variant; var ChargeGroupCode: Code[20])
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                FindChargeGroupFromSalesHeader(VariantRec, ChargeGroupCode);
            Database::"Purchase Header":
                FindChargeGroupFromPurchaseHeader(VariantRec, ChargeGroupCode);
            else
                FindChargeGroupFromOthTable(VariantRec, ChargeGroupCode);
        end;
    end;

    local procedure FindChargeGroupFromSalesHeader(VariantRec: Variant; var ChargeGroupCode: Code[20])
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader := VariantRec;
        ChargeGroupCode := SalesHeader."Charge Group Code";
    end;

    local procedure FindChargeGroupFromPurchaseHeader(VariantRec: Variant; var ChargeGroupCode: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader := VariantRec;
        ChargeGroupCode := PurchaseHeader."Charge Group Code";
    end;

    local procedure CheckChargeGroupLinesExist(VariantRec: Variant; var IsExist: Boolean)
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        case RecRef.Number of
            Database::"Sales Header":
                CheckChargeGroupLinesExistOnSalesLine(VariantRec, IsExist);
            Database::"Purchase Header":
                CheckChargeGroupLinesExistOnPurchaseLine(VariantRec, IsExist);
            else
                CheckChargeGroupLinesExistOnOtherTable(VariantRec, IsExist);
        end;
    end;

    local procedure CheckChargeGroupLinesExistOnSalesLine(VariantRec: Variant; var IsExist: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        SalesHeader := VariantRec;

        SalesLine.LoadFields("Document Type", "Document No.", "Charge Group Code");
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange("Charge Group Code", SalesHeader."Charge Group Code");
        if not SalesLine.IsEmpty() then
            IsExist := true;
    end;

    local procedure CheckChargeGroupLinesExistOnPurchaseLine(VariantRec: Variant; var IsExist: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseHeader := VariantRec;

        PurchaseLine.LoadFields("Document Type", "Document No.", "Charge Group Code");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Charge Group Code", PurchaseHeader."Charge Group Code");
        if not PurchaseLine.IsEmpty() then
            IsExist := true;
    end;

    local procedure InsertItemChargeAssignmentPurchase(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    var
        Currency: Record Currency;
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";
        ItemChargeAssgntLineAmt: Decimal;
    begin
        if PurchaseLine.Type <> PurchaseLine.Type::"Charge (Item)" then
            exit;

        PurchaseLine.TestField(Quantity);

        if PurchaseHeader."Currency Code" = '' then
            Currency.InitRoundingPrecision()
        else
            Currency.Get(PurchaseHeader."Currency Code");

        if (PurchaseLine."Inv. Discount Amount" = 0) and
           (PurchaseLine."Line Discount Amount" = 0) and
           (not PurchaseHeader."Prices Including VAT")
        then
            ItemChargeAssgntLineAmt := PurchaseLine."Line Amount"
        else
            if PurchaseHeader."Prices Including VAT" then
                ItemChargeAssgntLineAmt :=
                  Round(PurchaseLine.CalcLineAmount() / (1 + PurchaseLine."VAT %" / 100), Currency."Amount Rounding Precision")
            else
                ItemChargeAssgntLineAmt := PurchaseLine.CalcLineAmount();

        ItemChargeAssignmentPurch.Reset();
        ItemChargeAssignmentPurch.LoadFields("Document Type", "Document No.", "Document Line No.", "Item Charge No.");
        ItemChargeAssignmentPurch.SetRange("Document Type", PurchaseLine."Document Type");
        ItemChargeAssignmentPurch.SetRange("Document No.", PurchaseLine."Document No.");
        ItemChargeAssignmentPurch.SetRange("Document Line No.", PurchaseLine."Line No.");
        ItemChargeAssignmentPurch.SetRange("Item Charge No.", PurchaseLine."No.");
        if not ItemChargeAssignmentPurch.FindLast() then begin
            ItemChargeAssignmentPurch."Document Type" := PurchaseLine."Document Type";
            ItemChargeAssignmentPurch."Document No." := PurchaseLine."Document No.";
            ItemChargeAssignmentPurch."Document Line No." := PurchaseLine."Line No.";
            ItemChargeAssignmentPurch."Item Charge No." := PurchaseLine."No.";
            ItemChargeAssignmentPurch."Unit Cost" :=
              Round(ItemChargeAssgntLineAmt / PurchaseLine.Quantity,
                Currency."Unit-Amount Rounding Precision");
        end;

        if PurchaseLine.IsCreditDocType() then
            ItemChargeAssgntPurch.CreateDocChargeAssgnt(ItemChargeAssignmentPurch, PurchaseLine."Return Shipment No.")
        else
            ItemChargeAssgntPurch.CreateDocChargeAssgnt(ItemChargeAssignmentPurch, PurchaseLine."Receipt No.");
    end;

    local procedure InsertItemChargeAssignmentSales(SalesHeader: Record "Sales Header"; SalesLine: Record "Sales Line")
    var
        Currency: Record Currency;
        ItemChargeAssgmntSales: Record "Item Charge Assignment (Sales)";
        ItemChargeAssigntSales: Codeunit "Item Charge Assgnt. (Sales)";
        ItemChargeAssgntLineAmt: Decimal;
        ItemChargeAssignmentErr: Label 'You can only assign Item Charges for Line Types of Charge (Item).';
    begin
        SalesLine.TestField("No.");
        SalesLine.TestField(Quantity);

        if SalesLine.Type <> SalesLine.Type::"Charge (Item)" then begin
            Message(ItemChargeAssignmentErr);
            exit;
        end;

        Currency.Initialize(SalesHeader."Currency Code");

        if (SalesLine."Inv. Discount Amount" = 0) and (SalesLine."Line Discount Amount" = 0) and
           (not SalesHeader."Prices Including VAT")
        then
            ItemChargeAssgntLineAmt := SalesLine."Line Amount"
        else
            if SalesHeader."Prices Including VAT" then
                ItemChargeAssgntLineAmt :=
                  Round(SalesLine.CalcLineAmount() / (1 + SalesLine."VAT %" / 100), Currency."Amount Rounding Precision")
            else
                ItemChargeAssgntLineAmt := SalesLine.CalcLineAmount();

        ItemChargeAssgmntSales.Reset();
        ItemChargeAssgmntSales.LoadFields("Document Type", "Document No.", "Document Line No.", "Item Charge No.");
        ItemChargeAssgmntSales.SetRange("Document Type", SalesLine."Document Type");
        ItemChargeAssgmntSales.SetRange("Document No.", SalesLine."Document No.");
        ItemChargeAssgmntSales.SetRange("Document Line No.", SalesLine."Line No.");
        ItemChargeAssgmntSales.SetRange("Item Charge No.", SalesLine."No.");
        if not ItemChargeAssgmntSales.FindLast() then begin
            ItemChargeAssgmntSales."Document Type" := SalesLine."Document Type";
            ItemChargeAssgmntSales."Document No." := SalesLine."Document No.";
            ItemChargeAssgmntSales."Document Line No." := SalesLine."Line No.";
            ItemChargeAssgmntSales."Item Charge No." := SalesLine."No.";
            ItemChargeAssgmntSales."Unit Cost" :=
              Round(ItemChargeAssgntLineAmt / SalesLine.Quantity, Currency."Unit-Amount Rounding Precision");
        end;

        ItemChargeAssgntLineAmt :=
          Round(ItemChargeAssgntLineAmt * (SalesLine."Qty. to Invoice" / SalesLine.Quantity), Currency."Amount Rounding Precision");

        if SalesLine.IsCreditDocType() then
            ItemChargeAssigntSales.CreateDocChargeAssgn(ItemChargeAssgmntSales, SalesLine."Return Receipt No.")
        else
            ItemChargeAssigntSales.CreateDocChargeAssgn(ItemChargeAssgmntSales, SalesLine."Shipment No.");
        SalesLine.CalcFields("Qty. to Assign");
    end;

    local procedure SuggestItemChargeAssignmentPurchase(PurchaseLine: Record "Purchase Line"; ChargeGroupLine: Record "Charge Group Line")
    var
        ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)";

    begin
        case ChargeGroupLine.Assignment of
            ChargeGroupLine.Assignment::Equally:
                ItemChargeAssgntPurch.AssignItemCharges(PurchaseLine, PurchaseLine.Quantity, PurchaseLine."Line Amount", ItemChargeAssgntPurch.AssignEquallyMenuText());
            ChargeGroupLine.Assignment::"By Amount":
                ItemChargeAssgntPurch.AssignItemCharges(PurchaseLine, PurchaseLine.Quantity, PurchaseLine."Line Amount", ItemChargeAssgntPurch.AssignByAmountMenuText());
            ChargeGroupLine.Assignment::"By Weight":
                ItemChargeAssgntPurch.AssignItemCharges(PurchaseLine, PurchaseLine.Quantity, PurchaseLine."Line Amount", ItemChargeAssgntPurch.AssignByWeightMenuText());
            ChargeGroupLine.Assignment::"By Volume":
                ItemChargeAssgntPurch.AssignItemCharges(PurchaseLine, PurchaseLine.Quantity, PurchaseLine."Line Amount", ItemChargeAssgntPurch.AssignByVolumeMenuText());
            else
                OnSuggestItemChargeAssignmentPurchase(PurchaseLine, ChargeGroupLine, ItemChargeAssgntPurch);
        end;
    end;

    local procedure SuggestItemChargeAssignmentSales(SalesLine: Record "Sales Line"; ChargeGroupLine: Record "Charge Group Line")
    var
        ItemChargeAssgntSales: Codeunit "Item Charge Assgnt. (Sales)";
    begin
        case ChargeGroupLine.Assignment of
            ChargeGroupLine.Assignment::Equally:
                ItemChargeAssgntSales.AssignItemCharges(SalesLine, SalesLine.Quantity, SalesLine."Line Amount", ItemChargeAssgntSales.AssignEquallyMenuText());
            ChargeGroupLine.Assignment::"By Amount":
                ItemChargeAssgntSales.AssignItemCharges(SalesLine, SalesLine.Quantity, SalesLine."Line Amount", ItemChargeAssgntSales.AssignByAmountMenuText());
            ChargeGroupLine.Assignment::"By Weight":
                ItemChargeAssgntSales.AssignItemCharges(SalesLine, SalesLine.Quantity, SalesLine."Line Amount", ItemChargeAssgntSales.AssignByWeightMenuText());
            ChargeGroupLine.Assignment::"By Volume":
                ItemChargeAssgntSales.AssignItemCharges(SalesLine, SalesLine.Quantity, SalesLine."Line Amount", ItemChargeAssgntSales.AssignByVolumeMenuText());
            else
                OnSuggestItemChargeAssignmentSales(SalesLine, ChargeGroupLine, ItemChargeAssgntSales);
        end;
    end;

    local procedure GetRecordIdFromVariantRec(VariantRec: Variant): RecordId
    var
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        if not DataTypeManagement.GetRecordRef(VariantRec, RecRef) then
            exit;

        exit(RecRef.RecordId);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertChargeItemOnline(var VariantRec: Variant; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertChargeItemOnline(VariantRec: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure GetLineNoFromOtherTables(VariantRec: Variant; var LineNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure GetTotalAmountFromOtherRec(VariantRec: Variant; var TotalItemLineAmt: Decimal; var TotalItemQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure InsertChargeGroupLineOnOtherTable(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure FindChargeGroupFromOthTable(VariantRec: Variant; ChargeGroupCode: Code[20])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckDocLineOnOtheTable(VariantRec: Variant; var LineExist: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure RemoveChargeGroupLineOnOtherTable(VariantRec: Variant)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckChargeGroupValuesOnOtherItemUpdate(VariantRec: Variant; ChargeGroupLine: Record "Charge Group Line"; var EntryUpdated: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CheckChargeGroupLinesExistOnOtherTable(VariantRec: Variant; var IsExist: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure CalLineAmountForMoreComputationMethod(ChargeGroupLine: Record "Charge Group Line"; TotalItemLineAmt: Decimal; TotalItemQty: Decimal; var LineAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPurchaseTotal(VariantRec: Variant; var TotalItemLineAmt: Decimal; var TotalItemQty: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetPurchaseTotal(VariantRec: Variant; var TotalItemLineAmt: Decimal; var TotalItemQty: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSuggestItemChargeAssignmentPurchase(PurchaseLine: Record "Purchase Line"; ChargeGroupLine: Record "Charge Group Line"; ItemChargeAssgntPurch: Codeunit "Item Charge Assgnt. (Purch.)")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSuggestItemChargeAssignmentSales(SalesLine: Record "Sales Line"; ChargeGroupLine: Record "Charge Group Line"; ItemChargeAssgntSales: Codeunit "Item Charge Assgnt. (Sales)")
    begin
    end;
}
