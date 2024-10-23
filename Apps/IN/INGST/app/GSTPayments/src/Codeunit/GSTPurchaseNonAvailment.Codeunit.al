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

codeunit 18251 "GST Purchase Non Availment"
{
    var
        GSTBaseValidation: Codeunit "GST Base Validation";
        GSTNonAvailmentSessionMgt: Codeunit "GST Non Availment Session Mgt";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure QuantityToBeInvoiced(var QtyToBeInvoiced: Decimal)
    begin
        GSTNonAvailmentSessionMgt.SetQtyToBeInvoiced(QtyToBeInvoiced);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", 'OnAfterPrepareInvoicePostingBuffer', '', false, false)]
    local procedure FillInvoicePostingBufferNonAvailmentFA(var InvoicePostingBuffer: Record "Invoice Posting Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        QtyFactor: Decimal;
        CustomDutyLoaded: Decimal;
    begin
        if (PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset") and (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Non-Availment") then begin
            QtyFactor := PurchaseLine."Qty. to Invoice" / PurchaseLine.Quantity;
            InvoicePostingBuffer."FA Non-Availment Amount" := Round(GSTCalculatedAmount(PurchaseLine) * QtyFactor);
            CustomDutyLoaded := GSTNonAvailmentSessionMgt.GetCustomDutyAmount();
            InvoicePostingBuffer."FA Non-Availment" := true;

            if CustomDutyLoaded <> 0 then
                InvoicePostingBuffer."FA Non-Availment Amount" += Round(CustomDutyLoaded * QtyFactor);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnUpdateOnAfterModify', '', false, false)]
    local procedure UpdateInvoicePostingBufferNonAvailmentFA(FromInvoicePostingBuffer: Record "Invoice Posting Buffer"; var InvoicePostingBuffer: Record "Invoice Posting Buffer")
    begin
        InvoicePostingBuffer."FA Non-Availment Amount" += FromInvoicePostingBuffer."FA Non-Availment Amount";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure FillGenJournalLineNonAvailmentFA(InvoicePostingBuffer: Record "Invoice Posting Buffer"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."FA Non-Availment" := InvoicePostingBuffer."FA Non-Availment";
        GenJnlLine."FA Non-Availment Amount" := InvoicePostingBuffer."FA Non-Availment Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Post Line", 'OnBeforePostFixedAssetFromGenJnlLine', '', false, false)]
    local procedure UpdateFANonAvailmentAmount(var FALedgerEntry: Record "FA Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."FA Non-Availment" then
            FALedgerEntry.Amount += GenJournalLine."FA Non-Availment Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostFixedAssetOnBeforeInitGLEntryFromTempFAGLPostBuf', '', false, false)]
    local procedure UpdateTempFAGLPostBufNonAvailment(var GenJournalLine: Record "Gen. Journal Line"; var TempFAGLPostBuf: Record "FA G/L Posting Buffer")
    begin
        if TempFAGLPostBuf."FA Entry Type" = TempFAGLPostBuf."FA Entry Type"::Maintenance then
            exit;

        if GenJournalLine."FA Non-Availment" then
            TempFAGLPostBuf.Amount -= GenJournalLine."FA Non-Availment Amount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnBeforeItemJnlPostLineRunWithCheck', '', false, false)]
    local procedure LoadGSTUnitCost(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; var ItemJnlLine: Record "Item Journal Line"; QtyToBeInvoiced: Decimal)
    var
        PurchLineGSTAmount: Decimal;
        QuantityFactor: Decimal;
        CustomDutyAmount: Decimal;
    begin
        if (PurchaseLine.Type = PurchaseLine.Type::"Charge (Item)") and
            (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Non-Availment") then
            exit;

        PurchLineGSTAmount := GSTCalculatedAmount(PurchaseLine);
        if PurchLineGSTAmount = 0 then
            exit;

        if PurchaseHeader."Currency Code" <> '' then
            CustomDutyAmount := ConvertCustomDutyAmountToLCY(
                            PurchaseHeader."Currency Code",
                            PurchaseLine."Custom Duty Amount",
                            PurchaseHeader."Currency Factor",
                            PurchaseHeader."Posting Date")
        else
            CustomDutyAmount := PurchaseLine."Custom Duty Amount";

        if PurchaseLine."Qty. to Invoice" <> 0 then
            QuantityFactor := QtytoBeInvoiced / PurchaseLine."Qty. to Invoice";

        if PurchaseLine."Document Type" in [PurchaseLine."Document Type"::"Credit Memo", PurchaseLine."Document Type"::"Return Order"] then
            ItemJnlLine.Amount := ItemJnlLine.Amount - Round(PurchLineGSTAmount * QuantityFactor)
        else
            ItemJnlLine.Amount := ItemJnlLine.Amount + Round(PurchLineGSTAmount * QuantityFactor);

        if (PurchaseHeader."GST Vendor Type" in
            [PurchaseHeader."GST Vendor Type"::SEZ, PurchaseHeader."GST Vendor Type"::Import]) and
            (CustomDutyAmount <> 0) and (PurchaseLine."Qty. to Invoice" <> 0)
            then
            ItemJnlLine.Amount := ItemJnlLine.Amount + CustomDutyAmount / PurchaseLine."Qty. to Invoice" * ItemJnlLine."Invoiced Quantity";

        if QtyToBeInvoiced <> 0 then
            ItemJnlLine."Unit Cost" := ItemJnlLine."Unit Cost" + ((PurchLineGSTAmount + CustomDutyAmount) * QuantityFactor / QtyToBeInvoiced)
        else
            if (PurchaseLine."Qty. to Receive" > PurchaseLine."Qty. to Invoice") and (PurchaseLine."Qty. to Invoice" <> 0) and PurchaseHeader.Invoice then
                ItemJnlLine."Unit Cost" := ItemJnlLine."Unit Cost" + ((PurchLineGSTAmount + CustomDutyAmount) * QuantityFactor / PurchaseLine."Qty. to Invoice");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostPurchLineOnAfterSetEverythingInvoiced', '', false, false)]
    local procedure GetAmounts(PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        LoadGSTAmount: Decimal;
    begin
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
        LoadGSTAmount := GSTCalculatedAmount(PurchaseLine);

        if LoadGSTAmount = 0 then begin
            GSTNonAvailmentSessionMgt.SetGSTAmountToBeLoaded(LoadGSTAmount);
            exit;
        end;

        if (PurchaseLine.Type <> PurchaseLine.Type::"Charge (Item)") and (not PurchaseHeader."GST Input Service Distribution") then
            GSTNonAvailmentSessionMgt.SetGSTAmountToBeLoaded(LoadGSTAmount);
    end;

    local procedure GSTCalculatedAmount(PurchaseLine: Record "Purchase Line"): Decimal;
    var
        GSTSetup: Record "GST Setup";
        PurchaseHeader: Record "Purchase Header";
        GSTGroup: Record "GST Group";
        TransactionGSTAmount: Decimal;
        TransactionCessAmount: Decimal;
        GSTAmountToBeLoaded: Decimal;
        CustomDuty: Decimal;
        Sign: Integer;
    begin
        if not GSTSetup.Get() then
            exit;

        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;

        if not GSTGroup.Get(PurchaseLine."GST Group Code") then
            exit;

        if PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Non-Availment" then
            TransactionGSTAmount := GetTaxAmount(GSTSetup."GST Tax Type", PurchaseLine.RecordId);

        if (PurchaseHeader."GST Vendor Type" in [PurchaseHeader."GST Vendor Type"::Import, PurchaseHeader."GST Vendor Type"::SEZ]) and
            (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Non-Availment") and
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

        if (GSTSetup."Cess Tax Type" <> '') and (GSTGroup."Cess Credit" = GSTGroup."Cess Credit"::"Non-Availment") then
            TransactionCessAmount := GetTaxAmount(GSTSetup."Cess Tax Type", PurchaseLine.RecordId);

        if (TransactionGSTAmount + TransactionCessAmount) <> 0 then
            GSTAmountToBeLoaded := GSTBaseValidation.RoundGSTPrecision((TransactionGSTAmount + TransactionCessAmount) * (PurchaseLine."Qty. to Invoice" / PurchaseLine.Quantity));

        if PurchaseLine."Document Type" in [PurchaseLine."Document Type"::Order,
            PurchaseLine."Document Type"::Invoice,
            PurchaseLine."Document Type"::Quote,
            PurchaseLine."Document Type"::"Blanket Order"] then
            Sign := 1
        else
            Sign := -1;

        exit(GSTAmountToBeLoaded * Sign);
    end;

    local procedure GetTaxAmount(TaxType: Code[20]; PurchaseLineTaxID: RecordId): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        TaxAmount: Decimal;
    begin
        TaxTransactionValue.Reset();
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Tax Record ID", PurchaseLineTaxID);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if TaxTransactionValue.FindSet() then
            repeat
                TaxAmount += RoundTaxAmount(TaxType, TaxTransactionValue."Value ID", TaxTransactionValue."Amount (LCY)");
            until TaxTransactionValue.Next() = 0;

        exit(TaxAmount);
    end;

    procedure RoundTaxAmount(TaxType: Code[20]; ID: Integer; TaxAmt: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        RoundedValue: Decimal;
        GSTRoundingDirection: Text[1];
    begin
        TaxComponent.Reset();
        TaxComponent.SetRange("Tax Type", TaxType);
        TaxComponent.SetRange(ID, ID);
        TaxComponent.SetFilter("Rounding Precision", '<>%1', 0);
        if TaxComponent.FindFirst() then begin
            case TaxComponent.Direction of
                TaxComponent.Direction::Nearest:
                    GSTRoundingDirection := '=';
                TaxComponent.Direction::Up:
                    GSTRoundingDirection := '>';
                TaxComponent.Direction::Down:
                    GSTRoundingDirection := '<';
            end;

            RoundedValue := Round(TaxAmt, TaxComponent."Rounding Precision", GSTRoundingDirection);
            exit(RoundedValue);
        end;

        exit(TaxAmt);
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
