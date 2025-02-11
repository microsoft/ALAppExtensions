namespace Microsoft.Purchases.Document;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Tracking;
using Microsoft.Purchases.Posting;

codeunit 31179 "Item Charge Assgnt. Purch. CZL"
{
    procedure CreateItemEntryChargeAssgnt(var FromItemLedgerEntry: Record "Item Ledger Entry"; var FromItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)")
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
        Item: Record Item;
        PurchaseAppliestoDocumentType: Enum "Purchase Applies-to Document Type";
        NextLineNo: Integer;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateItemEntryChargeAssgnt(FromItemLedgerEntry, FromItemChargeAssignmentPurch, IsHandled);
        if IsHandled then
            exit;

        if not FromItemChargeAssignmentPurch.RecordLevelLocking then
            FromItemChargeAssignmentPurch.LockTable(true, true);

        NextLineNo := FromItemChargeAssignmentPurch."Line No.";

        ItemChargeAssignmentPurch.SetRange("Document Type", FromItemChargeAssignmentPurch."Document Type");
        ItemChargeAssignmentPurch.SetRange("Document No.", FromItemChargeAssignmentPurch."Document No.");
        ItemChargeAssignmentPurch.SetRange("Document Line No.", FromItemChargeAssignmentPurch."Document Line No.");
        ItemChargeAssignmentPurch.SetRange("Applies-to Doc. Type", ItemChargeAssignmentPurch."Applies-to Doc. Type"::Receipt);

        FromItemLedgerEntry.SetLoadFields("Document No.", "Entry No.", "Item No.", "Description");
        if FromItemLedgerEntry.FindSet(true) then
            repeat
                ItemChargeAssignmentPurch.SetRange("Applies-to Doc. No.", FromItemLedgerEntry."Document No.");
                ItemChargeAssignmentPurch.SetRange("Applies-to Doc. Line No.", FromItemLedgerEntry."Entry No.");
                if FromItemLedgerEntry.Description = '' then begin
                    Item.Get(FromItemLedgerEntry."Item No.");
                    FromItemLedgerEntry.Description := Item.Description;
                end;
                if not ItemChargeAssignmentPurch.FindFirst() then
                    InsertItemChargeAssignmentWithValues(
                        FromItemChargeAssignmentPurch, PurchaseAppliestoDocumentType::"Item Ledger Entry Positive Adjmt. CZL",
                        FromItemLedgerEntry."Document No.", FromItemLedgerEntry."Entry No.",
                        FromItemLedgerEntry."Item No.", FromItemLedgerEntry.Description, NextLineNo);
            until FromItemLedgerEntry.Next() = 0;
    end;

    procedure PostItemChargePerPosAdjItem(PurchPost: Codeunit "Purch.-Post"; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ItemLedgerEntry: Record "Item Ledger Entry";
        DummyTrackingSpecification: Record "Tracking Specification";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        IsHandled: Boolean;
        TextDeletedErr: Label 'Item Ledger Entry has been deleted.';
    begin
        IsHandled := false;
        OnBeforePostItemChargePerPosAdjItem(PurchPost, TempItemChargeAssignmentPurch, PurchaseHeader, PurchaseLine, IsHandled);
        if IsHandled then
            exit;

        GeneralLedgerSetup.Get();
        if not ItemLedgerEntry.Get(TempItemChargeAssignmentPurch."Applies-to Doc. Line No.") then
            Error(TextDeletedErr);

        PurchaseLine."No." := TempItemChargeAssignmentPurch."Item No.";
        PurchaseLine."Appl.-to Item Entry" := ItemLedgerEntry."Entry No.";
        PurchaseLine.Amount := TempItemChargeAssignmentPurch."Amount to Assign";
        PurchaseLine."Unit Cost" := Round(PurchaseLine.Amount / ItemLedgerEntry.Quantity, GeneralLedgerSetup."Unit-Amount Rounding Precision");
        if TempItemChargeAssignmentPurch."Document Type" in [TempItemChargeAssignmentPurch."Document Type"::"Return Order", TempItemChargeAssignmentPurch."Document Type"::"Credit Memo"] then
            PurchaseLine.Amount := -PurchaseLine.Amount;

        if PurchaseHeader."Currency Code" <> '' then
            PurchaseLine.Amount :=
              CurrencyExchangeRate.ExchangeAmtFCYToLCY(
                PurchaseHeader.GetUseDate(), PurchaseHeader."Currency Code", PurchaseLine.Amount, PurchaseHeader."Currency Factor");
        PurchaseLine."Inv. Discount Amount" := Round(
            PurchaseLine."Inv. Discount Amount" / PurchaseLine.Quantity * TempItemChargeAssignmentPurch."Qty. to Assign",
            GeneralLedgerSetup."Amount Rounding Precision");

        PurchaseLine.Amount := Round(PurchaseLine.Amount, GeneralLedgerSetup."Amount Rounding Precision");
        PurchaseLine."Unit Cost (LCY)" := Round(PurchaseLine.Amount / ItemLedgerEntry.Quantity, GeneralLedgerSetup."Unit-Amount Rounding Precision");
        PurchaseLine."Line No." := TempItemChargeAssignmentPurch."Document Line No.";

        PurchPost.PostItemJnlLine(
          PurchaseHeader, PurchaseLine, 0, 0,
          ItemLedgerEntry.Quantity, ItemLedgerEntry.Quantity,
          PurchaseLine."Appl.-to Item Entry", TempItemChargeAssignmentPurch."Item Charge No.", DummyTrackingSpecification);
    end;

    procedure AssignByAmountItemLedgerEntryPositiveAdjmt(ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; PurchaseHeader: Record "Purchase Header")
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        ItemLedgerEntry.Get(ItemChargeAssignmentPurch."Applies-to Doc. Line No.");
        ItemLedgerEntry.CalcFields("Cost Amount (Actual)");

        if PurchaseHeader."Currency Code" = '' then
            TempItemChargeAssignmentPurch."Applies-to Doc. Line Amount" := Abs(ItemLedgerEntry."Cost Amount (Actual)")
        else
            TempItemChargeAssignmentPurch."Applies-to Doc. Line Amount" :=
              CurrencyExchangeRate.ExchangeAmtFCYToFCY(
                PurchaseHeader."Posting Date", '', PurchaseHeader."Currency Code",
                Abs(ItemLedgerEntry."Cost Amount (Actual)"));
    end;

    local procedure InsertItemChargeAssignmentWithValues(FromItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; PurchaseAppliestoDocumentType: Enum "Purchase Applies-to Document Type";
                                                         FromApplToDocNo: Code[20]; FromApplToDocLineNo: Integer; FromItemNo: Code[20]; FromDescription: Text[100]; var NextLineNo: Integer)
    var
        ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)";
    begin
        NextLineNo := NextLineNo + 10000;

        ItemChargeAssignmentPurch."Document No." := FromItemChargeAssignmentPurch."Document No.";
        ItemChargeAssignmentPurch."Document Type" := FromItemChargeAssignmentPurch."Document Type";
        ItemChargeAssignmentPurch."Document Line No." := FromItemChargeAssignmentPurch."Document Line No.";
        ItemChargeAssignmentPurch."Item Charge No." := FromItemChargeAssignmentPurch."Item Charge No.";
        ItemChargeAssignmentPurch."Line No." := NextLineNo;
        ItemChargeAssignmentPurch."Applies-to Doc. No." := FromApplToDocNo;
        ItemChargeAssignmentPurch."Applies-to Doc. Type" := PurchaseAppliestoDocumentType;
        ItemChargeAssignmentPurch."Applies-to Doc. Line No." := FromApplToDocLineNo;
        ItemChargeAssignmentPurch."Item No." := FromItemNo;
        ItemChargeAssignmentPurch.Description := FromDescription;
        ItemChargeAssignmentPurch."Unit Cost" := FromItemChargeAssignmentPurch."Unit Cost";

        OnBeforeInsertItemChargeAssgntWithAssignValues(ItemChargeAssignmentPurch, FromItemChargeAssignmentPurch);
        ItemChargeAssignmentPurch.Insert();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateItemEntryChargeAssgnt(var ItemLedgerEntry: Record "Item Ledger Entry"; var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostItemChargePerPosAdjItem(PurchPost: Codeunit "Purch.-Post"; var TempItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)" temporary; PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItemChargeAssgntWithAssignValues(var ItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)"; FromItemChargeAssignmentPurch: Record "Item Charge Assignment (Purch)")
    begin
    end;
}
