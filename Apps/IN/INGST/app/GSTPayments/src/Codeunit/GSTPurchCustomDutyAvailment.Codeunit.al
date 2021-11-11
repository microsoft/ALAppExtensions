codeunit 18253 "GST Purch CustomDuty Availment"
{
    var
        GSTNonAvailmentSessionMgt: Codeunit "GST Non Availment Session Mgt";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostItemJnlLine', '', false, false)]
    local procedure QuantityToBeInvoiced(var QtyToBeInvoiced: Decimal)
    begin
        GSTNonAvailmentSessionMgt.SetQtyToBeInvoiced(QtyToBeInvoiced);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnPostItemJnlLineOnAfterPrepareItemJnlLine', '', false, false)]
    local procedure LoadGSTUnitCost(PurchaseHeader: Record "Purchase Header"; PurchaseLine: Record "Purchase Line"; var ItemJournalLine: Record "Item Journal Line")
    var
        QtytoBeInvoiced: Decimal;
        QtyFactor: Decimal;
        CustomDutyLoaded: Decimal;
    begin
        if PurchaseLine."GST Credit" <> PurchaseLine."GST Credit"::Availment then
            exit;

        CustomDutyLoaded := GSTNonAvailmentSessionMgt.GetCustomDutyAmount();
        QtytoBeInvoiced := GSTNonAvailmentSessionMgt.GetQtyToBeInvoiced();
        if CustomDutyLoaded = 0 then
            exit;

        if PurchaseLine."Qty. to Invoice" <> 0 then
            QtyFactor := QtytoBeInvoiced / PurchaseLine."Qty. to Invoice";

        if (PurchaseHeader."GST Vendor Type" in
            [PurchaseHeader."GST Vendor Type"::SEZ, PurchaseHeader."GST Vendor Type"::Import]) and
            (CustomDutyLoaded <> 0) and (PurchaseLine."Qty. to Invoice" <> 0) then
            ItemJournalLine.Amount := ItemJournalLine.Amount + CustomDutyLoaded / PurchaseLine."Qty. to Invoice" * ItemJournalLine."Invoiced Quantity";

        if QtyToBeInvoiced <> 0 then
            ItemJournalLine."Unit Cost" := ItemJournalLine."Unit Cost" + ((CustomDutyLoaded) * QtyFactor / QtyToBeInvoiced)
        else
            if (PurchaseLine."Qty. to Receive" > PurchaseLine."Qty. to Invoice") and (PurchaseLine."Qty. to Invoice" <> 0) and PurchaseHeader.Invoice then
                ItemJournalLine."Unit Cost" := ItemJournalLine."Unit Cost" + ((CustomDutyLoaded) * QtyFactor / PurchaseLine."Qty. to Invoice");
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

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferPreparePurchase', '', false, false)]
    local procedure FillInvoicePostingBufferNonAvailmentFA(var InvoicePostBuffer: Record "Invoice Post. Buffer"; var PurchaseLine: Record "Purchase Line")
    var
        QtyFactor: Decimal;
        CustomDutyLoaded: Decimal;

    begin
        if (PurchaseLine.Type = PurchaseLine.Type::"Fixed Asset") and (PurchaseLine."GST Credit" = PurchaseLine."GST Credit"::"Availment") then begin
            QtyFactor := PurchaseLine."Qty. to Invoice" / PurchaseLine.Quantity;
            GSTCalculatedAmount(PurchaseLine);
            CustomDutyLoaded := GSTNonAvailmentSessionMgt.GetCustomDutyAmount();
            InvoicePostBuffer."FA Availment" := true;
            InvoicePostBuffer."FA Custom Duty Amount" := Round(CustomDutyLoaded * QtyFactor);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterInvPostBufferModify', '', false, false)]
    local procedure UpdateInvoicePostingBufferNonAvailmentFA(FromInvoicePostBuffer: Record "Invoice Post. Buffer"; var InvoicePostBuffer: Record "Invoice Post. Buffer")
    begin
        InvoicePostBuffer."FA Custom Duty Amount" += FromInvoicePostBuffer."FA Custom Duty Amount";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure FillGenJournalLineNonAvailmentFA(InvoicePostBuffer: Record "Invoice Post. Buffer"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine."FA Availment" := InvoicePostBuffer."FA Availment";
        GenJnlLine."FA Custom Duty Amount" := InvoicePostBuffer."FA Custom Duty Amount";
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