// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Payments;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Posting;
using Microsoft.Inventory.Journal;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Vendor;

codeunit 18253 "GST Purch CustomDuty Availment"
{
    var
        GSTNonAvailmentSessionMgt: Codeunit "GST Non Availment Session Mgt";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure QuantityToBeInvoiced(var QtyToBeInvoiced: Decimal)
    begin
        GSTNonAvailmentSessionMgt.SetQtyToBeInvoiced(QtyToBeInvoiced);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnBeforeItemJnlPostLineRunWithCheck', '', false, false)]
    local procedure LoadGSTUnitCost(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; var ItemJnlLine: Record "Item Journal Line"; QtyToBeInvoiced: Decimal)
    var
        QtyFactor: Decimal;
        CustomDutyAmount: Decimal;
    begin
        if PurchaseLine."GST Credit" <> PurchaseLine."GST Credit"::Availment then
            exit;

        if PurchaseLine."Custom Duty Amount" = 0 then
            exit;

        if PurchaseLine."Qty. to Invoice" <> 0 then
            QtyFactor := QtyToBeInvoiced / PurchaseLine."Qty. to Invoice";

        if PurchaseHeader."Currency Code" <> '' then
            CustomDutyAmount := ConvertCustomDutyAmountToLCY(
                            PurchaseHeader."Currency Code",
                            PurchaseLine."Custom Duty Amount",
                            PurchaseHeader."Currency Factor",
                            PurchaseHeader."Posting Date")
        else
            CustomDutyAmount := PurchaseLine."Custom Duty Amount";

        if (PurchaseHeader."GST Vendor Type" in
            [PurchaseHeader."GST Vendor Type"::SEZ, PurchaseHeader."GST Vendor Type"::Import]) and
            (CustomDutyAmount <> 0) and (PurchaseLine."Qty. to Invoice" <> 0) then
            ItemJnlLine.Amount := ItemJnlLine.Amount + CustomDutyAmount / PurchaseLine."Qty. to Invoice" * ItemJnlLine."Invoiced Quantity";

        if QtyToBeInvoiced <> 0 then
            ItemJnlLine."Unit Cost" := ItemJnlLine."Unit Cost" + ((CustomDutyAmount) * QtyFactor / QtyToBeInvoiced)
        else
            if (PurchaseLine."Qty. to Receive" > PurchaseLine."Qty. to Invoice") and (PurchaseLine."Qty. to Invoice" <> 0) and PurchaseHeader.Invoice then
                ItemJnlLine."Unit Cost" := ItemJnlLine."Unit Cost" + ((CustomDutyAmount) * QtyFactor / PurchaseLine."Qty. to Invoice");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostPurchLineOnAfterSetEverythingInvoiced', '', false, false)]
    local procedure GetAmounts(PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        if PurchaseLine."GST Credit" <> PurchaseLine."GST Credit"::Availment then
            exit;

        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        GSTCalculatedAmount(PurchaseLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure FillInvoicePostingBufferNonAvailmentFA(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        QtyFactor: Decimal;
        CustomDutyLoaded: Decimal;
    begin
        if (PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset") and (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Availment") then begin
            QtyFactor := PurchaseLine."Qty. to Invoice" / PurchaseLine.Quantity;
            GSTCalculatedAmount(PurchaseLine);
            CustomDutyLoaded := GSTNonAvailmentSessionMgt.GetCustomDutyAmount();
            InvoicePostingBuffer."FA Availment" := true;
            InvoicePostingBuffer."FA Custom Duty Amount" := Round(CustomDutyLoaded * QtyFactor);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnUpdateOnAfterModify', '', false, false)]
    local procedure UpdateInvoicePostingBufferNonAvailmentFA(FromInvoicePostingBuffer: Record "Invoice Posting Buffer"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."FA Custom Duty Amount" += FromInvoicePostingBuffer."FA Custom Duty Amount";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure FillGenJournalLineNonAvailmentFA(InvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."FA Availment" := InvoicePostingBuffer."FA Availment";
        GenJnlLine."FA Custom Duty Amount" := InvoicePostingBuffer."FA Custom Duty Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Post Line", 'OnBeforePostFixedAssetFromGenJnlLine', '', false, false)]
    local procedure UpdateFANonAvailmentAmount(var FALedgerEntry: Record "FA Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."FA Availment" then
            FALedgerEntry.Amount += GenJournalLine."FA Custom Duty Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostFixedAssetOnBeforeInitGLEntryFromTempFAGLPostBuf', '', false, false)]
    local procedure UpdateTempFAGLPostBufNonAvailment(var GenJournalLine: Record "Gen. Journal Line"; var TempFAGLPostBuf: Record "FA G/L Posting Buffer")
    begin
        if GenJournalLine."FA Availment" then
            TempFAGLPostBuf.Amount -= GenJournalLine."FA Custom Duty Amount";
    end;

    local procedure GSTCalculatedAmount(PurchaseLine: Record "Purchase Line")
    var
        GSTSetup: Record "GST Setup";
        PurchaseHeader: Record "Purchase Header";
        GSTGroup: Record "GST Group";
        CustomDuty: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;

        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;

        if not GSTGroup.Get(PurchaseLine."GST Group Code") then
            exit;

        if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) and
            (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Availment") and
            (PurchaseLine."Custom Duty Amount" <> 0) and
            not (PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::"Credit Memo", PurchaseHeader."Document Type"::"Return Order"]) then begin
            CustomDuty := PurchaseLine."Custom Duty Amount";
            if PurchaseHeader."Currency Code" <> '' then
                CustomDuty := ConvertCustomDutyAmountToLCY(
                                PurchaseHeader."Currency Code",
                                PurchaseLine."Custom Duty Amount",
                                PurchaseHeader."Currency Factor",
                                PurchaseHeader."Posting Date");

            GSTNonAvailmentSessionMgt.SetCustomDutyAmount(CustomDuty);
        end else
            GSTNonAvailmentSessionMgt.SetCustomDutyAmount(0);
    end;

    local procedure ConvertCustomDutyAmountToLCY(CurrencyCode: Code[10]; Amount: Decimal; CurrencyFactor: Decimal; PostingDate: Date): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        if CurrencyCode <> '' then begin
            GeneralLedgerSetup.Get();
            GSTSetup.TestField("GST Tax Type");
            GeneralLedgerSetup.TestField("Custom Duty Component Code");
            TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxComponent.SetRange(name, Format(GeneralLedgerSetup."Custom Duty Component Code"));
            TaxComponent.FindFirst();
            exit(Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PostingDate, CurrencyCode, Amount, CurrencyFactor), TaxComponent."Rounding Precision"));
        end;
    end;
}
