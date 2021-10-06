codeunit 31019 "PurchAdvLetterManagement CZZ"
{
    Permissions = tabledata "Vendor Ledger Entry" = m;

    var
        PurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ";
        TempPurchAdvLetterEntryCZZGlob: Record "Purch. Adv. Letter Entry CZZ" temporary;
        CurrencyGlob: Record Currency;
        DocumentNoOrDatesEmptyErr: Label 'Document No. and Dates cannot be empty.';
        ExternalDocumentNoEmptyErr: Label 'External Document No. cannot be empty.';
        NothingToPostErr: Label 'Nothing to Post.';
        VATDocumentExistsErr: Label 'VAT Document already exists.';

    procedure AdvEntryInit(Preview: Boolean)
    begin
        if (PurchAdvLetterEntryCZZGlob."Entry No." = 0) and (not Preview) then begin
            PurchAdvLetterEntryCZZGlob.LockTable();
            if PurchAdvLetterEntryCZZGlob.FindLast() then;
        end;
        PurchAdvLetterEntryCZZGlob.Init();
        PurchAdvLetterEntryCZZGlob."Entry No." += 1;
    end;

    procedure AdvEntryInsert(EntryType: Enum "Advance Letter Entry Type CZZ"; AdvLetterNo: Code[20]; PostingDate: Date; Amt: Decimal; AmtLCY: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; GlDim1Code: Code[20]; GlDim2Code: Code[20]; DimSetID: Integer; Preview: Boolean)
    begin
        PurchAdvLetterEntryCZZGlob."Entry Type" := EntryType;
        PurchAdvLetterEntryCZZGlob."Purch. Adv. Letter No." := AdvLetterNo;
        PurchAdvLetterEntryCZZGlob."Posting Date" := PostingDate;
        PurchAdvLetterEntryCZZGlob.Amount := Amt;
        PurchAdvLetterEntryCZZGlob."Amount (LCY)" := AmtLCY;
        PurchAdvLetterEntryCZZGlob."Currency Code" := CurrencyCode;
        PurchAdvLetterEntryCZZGlob."Currency Factor" := CurrencyFactor;
        PurchAdvLetterEntryCZZGlob."Document No." := DocumentNo;
        PurchAdvLetterEntryCZZGlob."External Document No." := ExternalDocumentNo;
        PurchAdvLetterEntryCZZGlob."User ID" := CopyStr(UserId(), 1, MaxStrLen(PurchAdvLetterEntryCZZGlob."User ID"));
        PurchAdvLetterEntryCZZGlob."Global Dimension 1 Code" := GlDim1Code;
        PurchAdvLetterEntryCZZGlob."Global Dimension 2 Code" := GlDim2Code;
        PurchAdvLetterEntryCZZGlob."Dimension Set ID" := DimSetID;
        OnBeforeInsertAdvEntry(PurchAdvLetterEntryCZZGlob, Preview);
        if Preview then begin
            TempPurchAdvLetterEntryCZZGlob := PurchAdvLetterEntryCZZGlob;
            TempPurchAdvLetterEntryCZZGlob.Insert();
        end else
            PurchAdvLetterEntryCZZGlob.Insert();
        OnAfterInsertAdvEntry(PurchAdvLetterEntryCZZGlob, Preview);
    end;

    procedure AdvEntryInitVAT(VATBusPostGr: Code[20]; VATProdPostGr: Code[20]; VATDate: Date; VATEntryNo: Integer; VATPer: Decimal; VATIdentifier: Code[20]; VATCalcType: Enum "Tax Calculation Type"; VATAmount: Decimal; VATAmountLCY: Decimal; VATBase: Decimal; VATBaseLCY: Decimal)
    begin
        PurchAdvLetterEntryCZZGlob."VAT Bus. Posting Group" := VATBusPostGr;
        PurchAdvLetterEntryCZZGlob."VAT Prod. Posting Group" := VATProdPostGr;
        PurchAdvLetterEntryCZZGlob."VAT Date" := VATDate;
        PurchAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        PurchAdvLetterEntryCZZGlob."VAT %" := VATPer;
        PurchAdvLetterEntryCZZGlob."VAT Identifier" := VATIdentifier;
        PurchAdvLetterEntryCZZGlob."VAT Calculation Type" := VATCalcType;
        PurchAdvLetterEntryCZZGlob."VAT Amount" := VATAmount;
        PurchAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmountLCY;
        PurchAdvLetterEntryCZZGlob."VAT Base Amount" := VATBase;
        PurchAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := VATBaseLCY;
    end;

    procedure AdvEntryInitVendLedgEntryNo(VendLedgEntryNo: Integer)
    begin
        PurchAdvLetterEntryCZZGlob."Vendor Ledger Entry No." := VendLedgEntryNo;
    end;

    procedure AdvEntryInitDetVendLedgEntryNo(DetVendLedgEntryNo: Integer)
    begin
        PurchAdvLetterEntryCZZGlob."Det. Vendor Ledger Entry No." := DetVendLedgEntryNo;
    end;

    procedure AdvEntryInitRelatedEntry(RelatedEntry: Integer)
    begin
        PurchAdvLetterEntryCZZGlob."Related Entry" := RelatedEntry;
    end;

    procedure AdvEntryInitCancel()
    begin
        PurchAdvLetterEntryCZZGlob.Cancelled := true;
    end;

    procedure GetTempAdvLetterEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    begin
        if TempPurchAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                PurchAdvLetterEntryCZZ := TempPurchAdvLetterEntryCZZGlob;
                PurchAdvLetterEntryCZZ.Insert();
            until TempPurchAdvLetterEntryCZZGlob.Next() = 0;
            TempPurchAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UpdateStatus(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
    begin
        OnBeforeUpdateStatus(PurchAdvLetterHeaderCZZ, DocStatus);
        case DocStatus of
            DocStatus::New:
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount = 0 then begin
                        PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::New;
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Pay":
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount <> 0 then begin
                        PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::"To Pay";
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Use":
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry", PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount = 0 then begin
                        PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::"To Use";
                        PurchAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::Closed:
                begin
                    PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
                    PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry", PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Close);
                    PurchAdvLetterEntryCZZ.CalcSums(Amount);
                    if PurchAdvLetterEntryCZZ.Amount = 0 then begin
                        PurchAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3|%4|%5|%6', PurchAdvLetterEntryCZZ."Entry Type"::Payment, PurchAdvLetterEntryCZZ."Entry Type"::Usage, PurchAdvLetterEntryCZZ."Entry Type"::Close,
                            PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Close");
                        PurchAdvLetterEntryCZZ.CalcSums(Amount, "VAT Base Amount", "VAT Amount");
                        if (PurchAdvLetterEntryCZZ.Amount = 0) and (PurchAdvLetterEntryCZZ."VAT Base Amount" = 0) and (PurchAdvLetterEntryCZZ."VAT Amount" = 0) then begin
                            PurchAdvLetterHeaderCZZ.Status := PurchAdvLetterHeaderCZZ.Status::Closed;
                            PurchAdvLetterHeaderCZZ.Modify();
                        end;
                    end;
                end;
            else
                OnUpdateStatus(PurchAdvLetterHeaderCZZ, DocStatus);
        end;
    end;

    procedure CancelInitEntry(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; EntryDate: Date; Cancel: Boolean)
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        ToPayLCY: Decimal;
    begin
        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
        if PurchAdvLetterHeaderCZZ."To Pay" = 0 then
            exit;

        if Cancel then begin
            PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
            PurchAdvLetterHeaderCZZ.TestField("To Pay", PurchAdvLetterHeaderCZZ."Amount Including VAT");
        end;

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
        PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if PurchAdvLetterEntryCZZ.FindFirst() then begin
            if EntryDate = 0D then
                EntryDate := PurchAdvLetterEntryCZZ."Posting Date";

            if PurchAdvLetterEntryCZZ."Currency Factor" = 0 then
                ToPayLCY := PurchAdvLetterHeaderCZZ."To Pay"
            else
                ToPayLCY := Round(PurchAdvLetterHeaderCZZ."To Pay" / PurchAdvLetterEntryCZZ."Currency Factor");

            AdvEntryInit(false);
            if Cancel then
                AdvEntryInitCancel();
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", PurchAdvLetterHeaderCZZ."No.", EntryDate,
                PurchAdvLetterHeaderCZZ."To Pay", ToPayLCY,
                PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor", PurchAdvLetterHeaderCZZ."No.", '',
                PurchAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", PurchAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", PurchAdvLetterHeaderCZZ."Dimension Set ID", false);

            if Cancel then begin
                PurchAdvLetterEntryCZZ.Cancelled := true;
                PurchAdvLetterEntryCZZ.Modify();
            end;
        end;
    end;

    procedure LinkAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        TempAdvanceLetterLinkBuffer: Record "Advance Letter Link Buffer CZZ" temporary;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvanceLetterLink: Page "Advance Letter Link CZZ";
    begin
        AdvanceLetterLink.SetCVEntry(VendorLedgerEntry.RecordId);
        AdvanceLetterLink.LookupMode(true);
        if AdvanceLetterLink.RunModal() = Action::LookupOK then begin
            AdvanceLetterLink.GetLetterLink(TempAdvanceLetterLinkBuffer);
            TempAdvanceLetterLinkBuffer.SetFilter(Amount, '>0');
            if TempAdvanceLetterLinkBuffer.FindSet() then
                repeat
                    PostAdvancePayment(VendorLedgerEntry, TempAdvanceLetterLinkBuffer."Advance Letter No.", TempAdvanceLetterLinkBuffer.Amount, GenJnlPostLine);
                until TempAdvanceLetterLinkBuffer.Next() = 0;
        end;
    end;

    procedure PostAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry"; AdvanceLetterNo: Code[20]; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        ApplId: Code[50];
        Amount: Decimal;
        AmountLCY: Decimal;
        RemainingAmountExceededErr: Label 'The amount cannot be higher than remaining amount on ledger entry.';
        ToPayAmountExceededErr: Label 'The amount cannot be higher than to pay on advance letter.';
    begin
        VendorLedgerEntry.TestField("Advance Letter No. CZZ", '');
        PurchAdvLetterHeaderCZZ.Get(AdvanceLetterNo);
        PurchAdvLetterHeaderCZZ.CheckPurchaseAdvanceLetterPostRestrictions();
        PurchAdvLetterHeaderCZZ.TestField("Currency Code", VendorLedgerEntry."Currency Code");
        PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", VendorLedgerEntry."Vendor No.");
        if LinkAmount = 0 then begin
            VendorLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            Amount := VendorLedgerEntry."Remaining Amount";
            AmountLCY := VendorLedgerEntry."Remaining Amt. (LCY)";
        end else begin
            VendorLedgerEntry.CalcFields("Remaining Amount");
            if LinkAmount > VendorLedgerEntry."Remaining Amount" then
                Error(RemainingAmountExceededErr);

            Amount := LinkAmount;
            AmountLCY := Round(Amount / VendorLedgerEntry."Original Currency Factor");
        end;
        PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
        if Amount > PurchAdvLetterHeaderCZZ."To Pay" then
            Error(ToPayAmountExceededErr);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(VendorLedgerEntry."Currency Code", VendorLedgerEntry."Original Currency Factor");
        GenJournalLine.Amount := -Amount;
        GenJournalLine."Amount (LCY)" := -AmountLCY;

        ApplId := CopyStr(VendorLedgerEntry."Document No." + Format(VendorLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        VendorLedgerEntry.CalcFields("Remaining Amount");
        VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
        VendorLedgerEntry."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);

        GenJournalLine."Applies-to ID" := ApplId;
        OnBeforePostPaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnAfterPostPaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(VendorLedgerEntry."Currency Code", VendorLedgerEntry."Original Currency Factor");
        GenJournalLine.Amount := Amount;
        GenJournalLine."Amount (LCY)" := AmountLCY;
        OnBeforePostPayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnAfterPostPayment(GenJournalLine, PurchAdvLetterHeaderCZZ);

        VendorLedgerEntry2.FindLast();
        AdvEntryInit(false);
        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry2."Entry No.");
        AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, PurchAdvLetterHeaderCZZ."No.", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Use")
    end;

    procedure GetAdvanceGLAccount(var GenJournalLine: Record "Gen. Journal Line"): Code[20]
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        PurchAdvLetterHeaderCZZ.Get(GenJournalLine."Adv. Letter No. (Entry) CZZ");
        PurchAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        exit(AdvanceLetterTemplateCZZ."Advance Letter G/L Account");
    end;

    procedure PostAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
#pragma warning disable AL0432
        TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        IsHandled: Boolean;
        DocumentDate: Date;
        VATDate: Date;
        ExternalDocumentNo: Code[35];
        VATDocumentExistsQst: Label 'VAT Document already exists.\Continue?';
        ExceededAmountErr: Label 'Amount has been exceeded.';
    begin
        OnBeforePostPaymentVAT(PurchAdvLetterEntryCZZ, PostingDate, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        if PurchAdvLetterHeaderCZZ."Amount Including VAT" = 0 then
            exit;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            if not ConfirmManagement.GetResponseOrDefault(VATDocumentExistsQst, false) then
                exit;

        if PostingDate = 0D then
            PostingDate := PurchAdvLetterEntryCZZ."Posting Date";

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Invoice Nos.");

        InitVATAmountLine(TempInvoicePostBuffer, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ.Amount, PurchAdvLetterEntryCZZ."Currency Factor");
        VATDocumentCZZ.InitDocument(AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos.", '', PostingDate, 0D, PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor", '', TempInvoicePostBuffer);
        if VATDocumentCZZ.RunModal() <> Action::OK then
            exit;

        VATDocumentCZZ.SaveNoSeries();
        VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, ExternalDocumentNo, TempInvoicePostBuffer);
        if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) then
            Error(DocumentNoOrDatesEmptyErr);

        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
            Error(ExternalDocumentNoEmptyErr);

#pragma warning disable AA0210
        TempInvoicePostBuffer.SetFilter(Amount, '<>0');
#pragma warning restore AA0210
        if TempInvoicePostBuffer.IsEmpty() then
            Error(NothingToPostErr);

        PurchAdvLetterEntryCZZ2.CalcSums(Amount);
        TempInvoicePostBuffer.CalcSums(Amount);
        if (PurchAdvLetterEntryCZZ.Amount - PurchAdvLetterEntryCZZ2.Amount) < TempInvoicePostBuffer.Amount then
            Error(ExceededAmountErr);

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

        TempInvoicePostBuffer.FindSet();
        repeat
            VATPostingSetup.Get(TempInvoicePostBuffer."VAT Bus. Posting Group", TempInvoicePostBuffer."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
            VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VendorLedgerEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."VAT Date CZL" := VATDate;
            GenJournalLine."Document Date" := DocumentDate;
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            GenJournalLine."VAT Calculation Type" := TempInvoicePostBuffer."VAT Calculation Type";
            GenJournalLine."VAT Bus. Posting Group" := TempInvoicePostBuffer."VAT Bus. Posting Group";
            GenJournalLine.Validate("VAT Prod. Posting Group", TempInvoicePostBuffer."VAT Prod. Posting Group");
            GenJournalLine.Validate(Amount, TempInvoicePostBuffer.Amount);
            GenJournalLine."VAT Amount" := TempInvoicePostBuffer."VAT Amount";
            GenJournalLine."VAT Base Amount" := TempInvoicePostBuffer."VAT Base Amount";
            GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := TempInvoicePostBuffer."Amount (ACY)";
                GenJournalLine."VAT Amount (LCY)" := TempInvoicePostBuffer."VAT Amount (ACY)";
                GenJournalLine."VAT Base Amount (LCY)" := TempInvoicePostBuffer."VAT Base Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end else begin
                GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
            end;
            GenJournalLine."Bill-to/Pay-to No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
            GenJournalLine."Country/Region Code" := PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code";
            GenJournalLine."VAT Registration No." := PurchAdvLetterHeaderCZZ."VAT Registration No.";

            BindSubscription(VATPostingSetupHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(VATPostingSetupHandlerCZZ);

            AdvEntryInit(false);
            AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
            AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Date CZL",
                GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", PurchAdvLetterHeaderCZZ."No.", GenJournalLine."Posting Date",
                GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VendorLedgerEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine.Validate(Amount, -TempInvoicePostBuffer.Amount);
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := -TempInvoicePostBuffer."Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end;
            GenJnlPostLine.RunWithCheck(GenJournalLine);
        until TempInvoicePostBuffer.Next() = 0;
    end;

#pragma warning disable AL0432
    local procedure InitVATAmountLine(var InvoicePostBuffer: Record "Invoice Post. Buffer"; PurchAdvanceNo: Code[20]; Amount: Decimal; CurrencyFactor: Decimal)
#pragma warning restore AL0432
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
#pragma warning disable AL0432
        TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        RestToDivide: Decimal;
        RestLines: Decimal;
    begin
        InvoicePostBuffer.Reset();
        InvoicePostBuffer.DeleteAll();

        if Amount = 0 then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvanceNo);
        GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

        RestToDivide := Amount;
        PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        RestLines := PurchAdvLetterHeaderCZZ."Amount Including VAT";

        BufferAdvanceLines(PurchAdvanceNo, TempInvoicePostBuffer);
        TempInvoicePostBuffer.SetFilter(Amount, '<>0');
        if TempInvoicePostBuffer.FindSet() then
            repeat
                InvoicePostBuffer.Init();
                InvoicePostBuffer."VAT Bus. Posting Group" := TempInvoicePostBuffer."VAT Bus. Posting Group";
                InvoicePostBuffer."VAT Prod. Posting Group" := TempInvoicePostBuffer."VAT Prod. Posting Group";
                InvoicePostBuffer."VAT Calculation Type" := TempInvoicePostBuffer."VAT Calculation Type";
                InvoicePostBuffer."VAT %" := TempInvoicePostBuffer."VAT %";

                InvoicePostBuffer.Amount := Round(RestToDivide * TempInvoicePostBuffer.Amount / RestLines, CurrencyGlob."Amount Rounding Precision");
                case TempInvoicePostBuffer."VAT Calculation Type" of
                    TempInvoicePostBuffer."VAT Calculation Type"::"Normal VAT":
                        InvoicePostBuffer."VAT Amount" := Round(InvoicePostBuffer.Amount * TempInvoicePostBuffer."VAT %" / (100 + TempInvoicePostBuffer."VAT %"));
                    TempInvoicePostBuffer."VAT Calculation Type"::"Reverse Charge VAT":
                        InvoicePostBuffer."VAT Amount" := 0;
                end;
                InvoicePostBuffer."VAT Base Amount" := InvoicePostBuffer.Amount - InvoicePostBuffer."VAT Amount";
                CalculateAmountLCY(InvoicePostBuffer, PurchAdvLetterHeaderCZZ."Currency Code", CurrencyFactor);
                InvoicePostBuffer.Insert();

                RestToDivide := RestToDivide - InvoicePostBuffer.Amount;
                RestLines := RestLines - TempInvoicePostBuffer.Amount;
            until TempInvoicePostBuffer.Next() = 0;
    end;

#pragma warning disable AL0432
    local procedure CalculateAmountLCY(var InvoicePostBuffer: Record "Invoice Post. Buffer"; CurrencyCode: Code[10]; CurrencyFactor: Decimal)
#pragma warning restore AL0432
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if (CurrencyCode = '') or (CurrencyFactor = 0) then begin
            InvoicePostBuffer."Amount (ACY)" := InvoicePostBuffer.Amount;
            InvoicePostBuffer."VAT Base Amount (ACY)" := InvoicePostBuffer."VAT Base Amount";
            InvoicePostBuffer."VAT Amount (ACY)" := InvoicePostBuffer."VAT Amount";
            exit;
        end;

        InvoicePostBuffer."Amount (ACY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(0D, CurrencyCode, InvoicePostBuffer.Amount, CurrencyFactor));
        InvoicePostBuffer."VAT Base Amount (ACY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(0D, CurrencyCode, InvoicePostBuffer."VAT Base Amount", CurrencyFactor));
        InvoicePostBuffer."VAT Amount (ACY)" := InvoicePostBuffer."Amount (ACY)" - InvoicePostBuffer."VAT Base Amount (ACY)";
    end;

#pragma warning disable AL0432
    local procedure BufferAdvanceLines(AdvanceNo: Code[20]; var InvoicePostBuffer: Record "Invoice Post. Buffer")
#pragma warning restore AL0432
    var
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        InvoicePostBuffer.Reset();
        InvoicePostBuffer.DeleteAll();

        PurchAdvLetterLineCZZ.SetRange("Document No.", AdvanceNo);
        PurchAdvLetterLineCZZ.SetFilter(Amount, '<>0');
        if PurchAdvLetterLineCZZ.FindSet() then
            repeat
                InvoicePostBuffer.Init();
                InvoicePostBuffer."VAT Bus. Posting Group" := PurchAdvLetterLineCZZ."VAT Bus. Posting Group";
                InvoicePostBuffer."VAT Prod. Posting Group" := PurchAdvLetterLineCZZ."VAT Prod. Posting Group";
                if InvoicePostBuffer.Find() then begin
                    InvoicePostBuffer.Amount += PurchAdvLetterLineCZZ."Amount Including VAT";
                    InvoicePostBuffer."VAT Base Amount" += PurchAdvLetterLineCZZ.Amount;
                    InvoicePostBuffer."VAT Amount" += PurchAdvLetterLineCZZ."VAT Amount";
                    InvoicePostBuffer.Modify();
                end else begin
                    InvoicePostBuffer."VAT Calculation Type" := PurchAdvLetterLineCZZ."VAT Calculation Type";
                    InvoicePostBuffer."VAT %" := PurchAdvLetterLineCZZ."VAT %";
                    InvoicePostBuffer.Amount := PurchAdvLetterLineCZZ."Amount Including VAT";
                    InvoicePostBuffer."VAT Base Amount" := PurchAdvLetterLineCZZ.Amount;
                    InvoicePostBuffer."VAT Amount" := PurchAdvLetterLineCZZ."VAT Amount";
                    InvoicePostBuffer.Insert();
                end;
            until PurchAdvLetterLineCZZ.Next() = 0;
    end;

    local procedure GetCurrency(CurrencyCode: Code[10])
    begin
        if CurrencyCode = '' then
            CurrencyGlob.InitRoundingPrecision()
        else begin
            CurrencyGlob.Get(CurrencyCode);
            CurrencyGlob.TestField("Amount Rounding Precision");
        end;
    end;

    procedure LinkAdvanceLetter(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; PayToVendorNo: Code[20]; PostingDate: Date; CurrencyCode: Code[10])
    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvanceLetterApplEditPageCZZ: Page "Advance Letter Appl. Edit CZZ";
    begin
        AdvanceLetterApplEditPageCZZ.InitializePurchase(AdvLetterUsageDocTypeCZZ, DocumentNo, PayToVendorNo, PostingDate, CurrencyCode);
        Commit();
        AdvanceLetterApplEditPageCZZ.LookupMode(true);
        if AdvanceLetterApplEditPageCZZ.RunModal() = Action::LookupOK then begin
            AdvanceLetterApplEditPageCZZ.GetAssignedAdvance(TempAdvanceLetterApplicationCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
            AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
            if AdvanceLetterApplicationCZZ.FindSet(true) then
                repeat
                    if TempAdvanceLetterApplicationCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter No.",
                        AdvanceLetterApplicationCZZ."Document Type", AdvanceLetterApplicationCZZ."Document No.") then begin
                        if TempAdvanceLetterApplicationCZZ.Amount <> AdvanceLetterApplicationCZZ.Amount then begin
                            AdvanceLetterApplicationCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;
                            AdvanceLetterApplicationCZZ.Modify();
                        end;
                        TempAdvanceLetterApplicationCZZ.Delete(false);
                    end else
                        AdvanceLetterApplicationCZZ.Delete(true);
                until AdvanceLetterApplicationCZZ.Next() = 0;

            if TempAdvanceLetterApplicationCZZ.FindSet() then
                repeat
                    AdvanceLetterApplicationCZZ.Init();
                    AdvanceLetterApplicationCZZ."Advance Letter Type" := TempAdvanceLetterApplicationCZZ."Advance Letter Type";
                    AdvanceLetterApplicationCZZ."Advance Letter No." := TempAdvanceLetterApplicationCZZ."Advance Letter No.";
                    AdvanceLetterApplicationCZZ."Posting Date" := TempAdvanceLetterApplicationCZZ."Posting Date";
                    AdvanceLetterApplicationCZZ."Document Type" := AdvLetterUsageDocTypeCZZ;
                    AdvanceLetterApplicationCZZ."Document No." := DocumentNo;
                    AdvanceLetterApplicationCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;
                    AdvanceLetterApplicationCZZ.Insert();
                until TempAdvanceLetterApplicationCZZ.Next() = 0;
        end;
    end;

    procedure UnlinkAdvancePayment(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        PurchAdvLetterEntryCZZ1: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        VendorLedgerEntry.TestField("Advance Letter No. CZZ");

        PurchAdvLetterEntryCZZ1.SetRange("Purch. Adv. Letter No.", VendorLedgerEntry."Advance Letter No. CZZ");
        PurchAdvLetterEntryCZZ1.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ1.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        if PurchAdvLetterEntryCZZ1.FindSet() then
            repeat
                PurchAdvLetterEntryCZZ2 := PurchAdvLetterEntryCZZ1;
                UnlinkAdvancePayment(PurchAdvLetterEntryCZZ2);
            until PurchAdvLetterEntryCZZ1.Next() = 0;
    end;

    procedure UnlinkAdvancePayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntryPay: Record "Vendor Ledger Entry";
        VendorLedgerEntryAdv: Record "Vendor Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        ApplId: Code[50];
        UsedOnDocument: Text;
        UnlinkIsNotPossibleErr: Label 'Unlink is not possible, because %1 entry exists.', Comment = '%1 = Entry type';
        UsedOnDocumentQst: Label 'Advance is used on document(s) %1.\Continue?', Comment = '%1 = Advance No. list';
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.FindFirst() then
            Error(UnlinkIsNotPossibleErr, PurchAdvLetterEntryCZZ2."Entry Type");

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                if UsedOnDocument <> '' then
                    UsedOnDocument := UsedOnDocument + ', ';
                UsedOnDocument := AdvanceLetterApplicationCZZ."Document No.";
            until AdvanceLetterApplicationCZZ.Next() = 0;
        if UsedOnDocument <> '' then
            if not Confirm(UsedOnDocumentQst, false, UsedOnDocument) then
                Error('');

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.FindSet() then begin
            repeat
                VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
                VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

                InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."External Document No.", '', '', GenJournalLine);
                GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
                GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                GenJournalLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ2."VAT Calculation Type";
                GenJournalLine."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                GenJournalLine.validate("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                GenJournalLine.Validate(Amount, -PurchAdvLetterEntryCZZ2.Amount);
                GenJournalLine."VAT Amount" := -PurchAdvLetterEntryCZZ2."VAT Amount";
                GenJournalLine."VAT Base Amount" := -PurchAdvLetterEntryCZZ2."VAT Base Amount";
                GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                    CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ2."Amount (LCY)";
                GenJournalLine."VAT Amount (LCY)" := -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                GenJournalLine."VAT Base Amount (LCY)" := -PurchAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                BindSubscription(VATPostingSetupHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);

                AdvEntryInit(false);
                AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
                AdvEntryInitCancel();
                AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Date CZL",
                    GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                    GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                AdvEntryInsert(PurchAdvLetterEntryCZZ2."Entry Type", PurchAdvLetterEntryCZZ2."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                    GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                    GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                    GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ."External Document No.", '', '', GenJournalLine);
                GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
                GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                GenJournalLine.Amount := PurchAdvLetterEntryCZZ2.Amount;
                GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ2."Amount (LCY)";
                GenJnlPostLine.RunWithCheck(GenJournalLine);
            until PurchAdvLetterEntryCZZ2.Next() = 0;
            PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
        end;

        VendorLedgerEntryAdv.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        VendorLedgerEntryPay := VendorLedgerEntryAdv;
#pragma warning disable AA0181
        VendorLedgerEntryPay.Next(-1);
#pragma warning restore AA0181
        UnapplyVendLedgEntry(VendorLedgerEntryPay, GenJnlPostLine);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntryAdv, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine.Correction := true;
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
        ApplId := CopyStr(VendorLedgerEntryAdv."Document No." + Format(VendorLedgerEntryAdv."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        VendorLedgerEntryAdv.Prepayment := false;
        VendorLedgerEntryAdv."Advance Letter No. CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        VendorLedgerEntryAdv.CalcFields("Remaining Amount");
        VendorLedgerEntryAdv."Amount to Apply" := VendorLedgerEntryAdv."Remaining Amount";
        VendorLedgerEntryAdv."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntryAdv);
        GenJournalLine."Applies-to ID" := ApplId;
        GenJnlPostLine.RunWithCheck(GenJournalLine);

        VendorLedgerEntry.FindLast();

        AdvEntryInit(false);
        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry."Entry No.");
        AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
        AdvEntryInsert(PurchAdvLetterEntryCZZ."Entry Type", GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntryAdv, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := PurchAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";
        ApplId := CopyStr(VendorLedgerEntryPay."Document No." + Format(VendorLedgerEntryPay."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        VendorLedgerEntryPay.CalcFields("Remaining Amount");
        VendorLedgerEntryPay."Amount to Apply" := VendorLedgerEntryPay."Remaining Amount";
        VendorLedgerEntryPay."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntryPay);
        GenJournalLine."Applies-to ID" := ApplId;
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        UnbindSubscription(GenJnlCheckLnHandlerCZZ);

        PurchAdvLetterEntryCZZ.Cancelled := true;
        PurchAdvLetterEntryCZZ.Modify();

        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    procedure PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var PurchInvHeader: Record "Purch. Inv. Header"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempPurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ" temporary;
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        AdvanceLetterTypeCZZ: Enum "Advance Letter Type CZZ";
        AmountToUse, UseAmount, UseAmountLCY : Decimal;
        PostingDateErr: Label 'Posting Date of Advance Payment %1 must be before Posting Date of Purchase Invoice %2.', Comment = '%1 = Advance Letter No., %2 = Purchase Invoice No.';
    begin
        if VendorLedgerEntry."Remaining Amount" = 0 then
            VendorLedgerEntry.CalcFields("Remaining Amount");

        if VendorLedgerEntry."Remaining Amount" = 0 then
            exit;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.IsEmpty() then
            exit;

        AdvanceLetterApplicationCZZ.FindSet();
        repeat
            PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
            PurchAdvLetterHeaderCZZ.TestField("Currency Code", PurchInvHeader."Currency Code");
            PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", PurchInvHeader."Pay-to Vendor No.");

            PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
            PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
            PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
            if PurchAdvLetterEntryCZZ.FindSet() then
                repeat
                    if not Preview then
                        if PurchAdvLetterEntryCZZ."Posting Date" > PurchInvHeader."Posting Date" then
                            Error(PostingDateErr, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PurchInvHeader."No.");
                    TempPurchAdvLetterEntryCZZ := PurchAdvLetterEntryCZZ;
                    TempPurchAdvLetterEntryCZZ.Amount := GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);
                    if TempPurchAdvLetterEntryCZZ.Amount <> 0 then
                        TempPurchAdvLetterEntryCZZ.Insert();
                until PurchAdvLetterEntryCZZ.Next() = 0;
            TempAdvanceLetterApplicationCZZ.Init();
            TempAdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterApplicationCZZ."Advance Letter No.";
            TempAdvanceLetterApplicationCZZ.Amount := AdvanceLetterApplicationCZZ.Amount;
            TempAdvanceLetterApplicationCZZ.Insert();
        until AdvanceLetterApplicationCZZ.Next() = 0;

        AmountToUse := -VendorLedgerEntry."Remaining Amount";
        TempPurchAdvLetterEntryCZZ.Reset();
        TempPurchAdvLetterEntryCZZ.SetCurrentKey("Posting Date");
        if TempPurchAdvLetterEntryCZZ.FindSet() then
            repeat
                TempAdvanceLetterApplicationCZZ.Get(0, TempPurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                if TempAdvanceLetterApplicationCZZ.Amount < TempPurchAdvLetterEntryCZZ.Amount then
                    TempPurchAdvLetterEntryCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;

                if AmountToUse > TempPurchAdvLetterEntryCZZ.Amount then
                    UseAmount := TempPurchAdvLetterEntryCZZ.Amount
                else
                    UseAmount := AmountToUse;

                if UseAmount <> 0 then begin
                    PurchAdvLetterEntryCZZ.Get(TempPurchAdvLetterEntryCZZ."Entry No.");
                    UseAmountLCY := Round(GetRemAmtLCYPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D) * UseAmount / GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D));
                    ReverseAdvancePayment(PurchAdvLetterEntryCZZ, PurchInvHeader."VAT Currency Factor CZL", UseAmount, UseAmountLCY, VendorLedgerEntry, GenJnlPostLine, Preview);
                    AmountToUse -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Amount -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Modify();

                    if not Preview then
                        if AdvanceLetterApplicationCZZ.Get(AdvanceLetterTypeCZZ::Purchase, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", AdvLetterUsageDocTypeCZZ, DocumentNo) then
                            if AdvanceLetterApplicationCZZ.Amount <= UseAmount then
                                AdvanceLetterApplicationCZZ.Delete(true)
                            else begin
                                AdvanceLetterApplicationCZZ.Amount -= UseAmount;
                                AdvanceLetterApplicationCZZ.Modify();
                            end;
                end;
            until (TempPurchAdvLetterEntryCZZ.Next() = 0) or (AmountToUse = 0);
    end;

    local procedure ReverseAdvancePayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; CurrFactor: Decimal; ReverseAmount: Decimal; ReverseAmountLCY: Decimal; var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        RemainingAmount: Decimal;
        RemainingAmountLCY: Decimal;
        ApplId: Code[50];
        ReverseErr: Label 'Reverse amount %1 is not posible on entry %2.', Comment = '%1 = Reverse Amount, %2 = Purchase Advance Entry No.';
    begin
        RemainingAmount := GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);
        RemainingAmountLCY := GetRemAmtLCYPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);

        if ReverseAmount <> 0 then begin
            if ReverseAmount > RemainingAmount then
                Error(ReverseErr, ReverseAmount, PurchAdvLetterEntryCZZ."Entry No.");
        end else begin
            ReverseAmount := RemainingAmount;
            ReverseAmountLCY := RemainingAmountLCY;
        end;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := ReverseAmount;
        GenJournalLine."Amount (LCY)" := ReverseAmountLCY;

        if not Preview then begin
            ApplId := CopyStr(VendorLedgerEntry."Document No." + Format(VendorLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
            VendorLedgerEntry.CalcFields("Remaining Amount");
            VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
            VendorLedgerEntry."Applies-to ID" := ApplId;
            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);
            GenJournalLine."Applies-to ID" := ApplId;

            OnBeforePostReversePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
            BindSubscription(GenJnlCheckLnHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            OnAfterPostReversePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
        end;

        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -ReverseAmount;
        GenJournalLine."Amount (LCY)" := -ReverseAmountLCY;

        VendorLedgerEntry2.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
        if not Preview then begin
            ApplId := CopyStr(VendorLedgerEntry2."Document No." + Format(VendorLedgerEntry2."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
            VendorLedgerEntry2.Prepayment := false;
            VendorLedgerEntry2."Advance Letter No. CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
            VendorLedgerEntry2.Modify();
            VendorLedgerEntry2.CalcFields("Remaining Amount");
            VendorLedgerEntry2."Amount to Apply" := VendorLedgerEntry2."Remaining Amount";
            VendorLedgerEntry2."Applies-to ID" := ApplId;
            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry2);
            GenJournalLine."Applies-to ID" := ApplId;

            OnBeforePostReversePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(GenJnlCheckLnHandlerCZZ);
            OnAfterPostReversePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);

            VendorLedgerEntry2.FindLast();
        end;

        AdvEntryInit(Preview);
        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry2."Entry No.");
        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
        AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", Preview);

        if PurchAdvLetterHeaderCZZ."Automatic Post VAT Usage" then
            ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ, VendorLedgerEntry."Source Code", VendorLedgerEntry.Description, CurrFactor, VendorLedgerEntry."Document No.", VendorLedgerEntry."External Document No.", VendorLedgerEntry."Posting Date", VendorLedgerEntry."VAT Date CZL", ReverseAmount, PurchAdvLetterEntryCZZGlob."Entry No.", VendorLedgerEntry."Document No.", "Advance Letter Entry Type CZZ"::"VAT Usage", true, GenJnlPostLine, Preview)
        else
            if not Preview then
                UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

    local procedure ReverseAdvancePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; SourceCode: Code[10]; PostDescription: Text[100]; CurrencyFactor: Decimal; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; PostingDate: Date; VATDate: Date; ReverseAmount: Decimal; UsageEntryNo: Integer; InvoiceNo: Code[20]; EntryType: enum "Advance Letter Entry Type CZZ"; AutoPostVATUsage: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
#pragma warning disable AL0432
        TempInvoicePostBuffer1: Record "Invoice Post. Buffer" temporary;
        TempInvoicePostBuffer2: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        VATDocumentCZZ: Page "VAT Document CZZ";
        CalcVATAmountLCY: Decimal;
        CalcAmountLCY: Decimal;
        ExchRateAmount: Decimal;
        ExchRateVATAmount: Decimal;
        AmountToUse: Decimal;
        DocumentDate: Date;
        IsHandled: Boolean;
        UsedMoreAmountErr: Label 'Post VAT Document higher than usage is not possible.';
    begin
        OnBeforePostReversePaymentVAT(PurchAdvLetterEntryCZZ, PostingDate, Preview, IsHandled);
        if IsHandled then
            exit;

        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if PurchAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");
        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer1, 0D, true);
        SuggestUsageVAT(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer1, InvoiceNo, ReverseAmount, CurrencyFactor, Preview);

        if not AutoPostVATUsage then begin
            VATDocumentCZZ.InitDocument('', DocumentNo, PostingDate, VATDate, PurchAdvLetterHeaderCZZ."Currency Code", CurrencyFactor, ExternalDocumentNo, TempInvoicePostBuffer1);
            if VATDocumentCZZ.RunModal() <> Action::OK then
                exit;

            VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, ExternalDocumentNo, TempInvoicePostBuffer1);
            if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) then
                Error(DocumentNoOrDatesEmptyErr);

            PurchasesPayablesSetup.Get();
            if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
                Error(ExternalDocumentNoEmptyErr);

            TempInvoicePostBuffer1.SetFilter(Amount, '<>0');
            if TempInvoicePostBuffer1.IsEmpty() then
                Error(NothingToPostErr);

            if ReverseAmount <> 0 then begin
                TempInvoicePostBuffer1.CalcSums(Amount);
                if TempInvoicePostBuffer1.Amount > ReverseAmount then
                    Error(UsedMoreAmountErr);
            end;
        end;

        TempInvoicePostBuffer1.FilterGroup(-1);
#pragma warning disable AA0210
        TempInvoicePostBuffer1.SetFilter("VAT Base Amount", '<>0');
        TempInvoicePostBuffer1.SetFilter("VAT Amount", '<>0');
#pragma warning restore AA0210
        TempInvoicePostBuffer1.FilterGroup(0);
        if TempInvoicePostBuffer1.IsEmpty() then
            exit;

        if PurchAdvLetterEntryCZZ."Currency Code" <> '' then begin
            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer2, 0D, true);
            TempInvoicePostBuffer2.CalcSums(Amount);
            AmountToUse := TempInvoicePostBuffer2.Amount;
        end;

        TempInvoicePostBuffer1.FindSet();
        repeat
            VATPostingSetup.Get(TempInvoicePostBuffer1."VAT Bus. Posting Group", TempInvoicePostBuffer1."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
            VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."VAT Date CZL" := VATDate;
            GenJournalLine."Document Date" := DocumentDate;
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            GenJournalLine."VAT Calculation Type" := TempInvoicePostBuffer1."VAT Calculation Type";
            GenJournalLine."VAT Bus. Posting Group" := TempInvoicePostBuffer1."VAT Bus. Posting Group";
            GenJournalLine.validate("VAT Prod. Posting Group", TempInvoicePostBuffer1."VAT Prod. Posting Group");
            GenJournalLine.Validate(Amount, -TempInvoicePostBuffer1.Amount);
            GenJournalLine."VAT Amount" := -TempInvoicePostBuffer1."VAT Amount";
            GenJournalLine."VAT Base Amount" := -TempInvoicePostBuffer1."VAT Base Amount";
            GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := -TempInvoicePostBuffer1."Amount (ACY)";
                GenJournalLine."VAT Amount (LCY)" := -TempInvoicePostBuffer1."VAT Amount (ACY)";
                GenJournalLine."VAT Base Amount (LCY)" := -TempInvoicePostBuffer1."VAT Base Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end else begin
                GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
            end;
            if not Preview then begin
                BindSubscription(VATPostingSetupHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);
            end;

            AdvEntryInit(Preview);
            AdvEntryInitRelatedEntry(UsageEntryNo);
            AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Date CZL",
                GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
            AdvEntryInsert(EntryType, PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", Preview);

            if GenJournalLine."Currency Code" <> '' then begin
                TempInvoicePostBuffer2.Reset();
                TempInvoicePostBuffer2.SetRange("VAT Bus. Posting Group", TempInvoicePostBuffer1."VAT Bus. Posting Group");
                TempInvoicePostBuffer2.SetRange("VAT Prod. Posting Group", TempInvoicePostBuffer1."VAT Prod. Posting Group");
                if TempInvoicePostBuffer2.FindFirst() then begin
                    CalcAmountLCY := Round(TempInvoicePostBuffer2."Amount (ACY)" * TempInvoicePostBuffer1.Amount / TempInvoicePostBuffer2.Amount);
                    CalcVATAmountLCY := Round(TempInvoicePostBuffer2."VAT Amount (ACY)" * TempInvoicePostBuffer1.Amount / TempInvoicePostBuffer2.Amount);

                    ExchRateAmount := CalcAmountLCY + GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := CalcVATAmountLCY + GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(-ExchRateAmount, -ExchRateVATAmount, PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            DocumentNo, PostingDate, SourceCode, PostDescription, UsageEntryNo, false, GenJnlPostLine, Preview);

                    ReverseUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempInvoicePostBuffer1.Amount / AmountToUse,
                        UsageEntryNo, DocumentNo, PostingDate, PostDescription, GenJnlPostLine, Preview);
                end;
            end;

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
            GenJournalLine.Validate(Amount, TempInvoicePostBuffer1.Amount);
            if GenJournalLine."Currency Code" <> '' then
                GenJournalLine."Amount (LCY)" := TempInvoicePostBuffer1."Amount (ACY)";
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        until TempInvoicePostBuffer1.Next() = 0;

        if not Preview then
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
    end;

#pragma warning disable AL0432
    local procedure SuggestUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; InvoiceNo: Code[20]; UsedAmount: Decimal; CurrencyFactor: Decimal; Preview: Boolean)
#pragma warning restore AL0432
    var
        PurchInvLine: Record "Purch. Inv. Line";
        PurchaseLine: Record "Purchase Line";
#pragma warning disable AL0432
        TempInvoicePostBuffer1: Record "Invoice Post. Buffer" temporary;
        TempInvoicePostBuffer2: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        TotalAmount: Decimal;
        UseAmount: Decimal;
        UseBaseAmount: Decimal;
        i: Integer;
        Continue: Boolean;
    begin
        InvoicePostBuffer.CalcSums(Amount);
        TotalAmount := InvoicePostBuffer.Amount;
        if (UsedAmount <> 0) and (TotalAmount > UsedAmount) then begin
            Continue := InvoiceNo <> '';
            if Continue then
                if Preview then begin
                    PurchaseLine.SetFilter("Document Type", '%1|%2', PurchaseLine."Document Type"::Order, PurchaseLine."Document Type"::Invoice);
                    PurchaseLine.SetRange("Document No.", InvoiceNo);
                    Continue := PurchaseLine.FindSet();
                end else begin
                    PurchInvLine.SetRange("Document No.", InvoiceNo);
                    Continue := PurchInvLine.FindSet();
                end;

            if Continue then begin
                BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer2, 0D, true);

                if Preview then
                    repeat
                        TempInvoicePostBuffer1.Init();
                        TempInvoicePostBuffer1."VAT Bus. Posting Group" := PurchaseLine."VAT Bus. Posting Group";
                        TempInvoicePostBuffer1."VAT Prod. Posting Group" := PurchaseLine."VAT Prod. Posting Group";
                        if TempInvoicePostBuffer1.Find() then begin
                            TempInvoicePostBuffer1.Amount += PurchaseLine."Amount Including VAT";
                            TempInvoicePostBuffer1."VAT Base Amount" += PurchaseLine.Amount;
                            TempInvoicePostBuffer1.Modify();
                        end else begin
                            TempInvoicePostBuffer1."VAT Calculation Type" := PurchaseLine."VAT Calculation Type";
                            TempInvoicePostBuffer1."VAT %" := PurchaseLine."VAT %";
                            TempInvoicePostBuffer1.Amount := PurchaseLine."Amount Including VAT";
                            TempInvoicePostBuffer1."VAT Base Amount" := PurchaseLine.Amount;
                            TempInvoicePostBuffer1.Insert();
                        end;
                    until PurchaseLine.Next() = 0
                else
                    repeat
                        TempInvoicePostBuffer1.Init();
                        TempInvoicePostBuffer1."VAT Bus. Posting Group" := PurchInvLine."VAT Bus. Posting Group";
                        TempInvoicePostBuffer1."VAT Prod. Posting Group" := PurchInvLine."VAT Prod. Posting Group";
                        if TempInvoicePostBuffer1.Find() then begin
                            TempInvoicePostBuffer1.Amount += PurchInvLine."Amount Including VAT";
                            TempInvoicePostBuffer1."VAT Base Amount" += PurchInvLine.Amount;
                            TempInvoicePostBuffer1.Modify();
                        end else begin
                            TempInvoicePostBuffer1."VAT Calculation Type" := PurchInvLine."VAT Calculation Type";
                            TempInvoicePostBuffer1."VAT %" := PurchInvLine."VAT %";
                            TempInvoicePostBuffer1.Amount := PurchInvLine."Amount Including VAT";
                            TempInvoicePostBuffer1."VAT Base Amount" := PurchInvLine.Amount;
                            TempInvoicePostBuffer1.Insert();
                        end;
                    until PurchInvLine.Next() = 0;

                GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

                for i := 1 to 3 do begin
                    TempInvoicePostBuffer1.FindSet();
                    repeat
                        case i of
                            1:
                                begin
                                    TempInvoicePostBuffer2.SetRange("VAT Bus. Posting Group", TempInvoicePostBuffer1."VAT Bus. Posting Group");
                                    TempInvoicePostBuffer2.SetRange("VAT Prod. Posting Group", TempInvoicePostBuffer1."VAT Prod. Posting Group");
                                end;
                            2:
                                begin
                                    TempInvoicePostBuffer2.SetRange("VAT Calculation Type", TempInvoicePostBuffer1."VAT Calculation Type");
                                    TempInvoicePostBuffer2.SetRange("VAT %", TempInvoicePostBuffer1."VAT %");
                                end;
                        end;
                        if TempInvoicePostBuffer2.FindSet() then
                            repeat
                                UseAmount := TempInvoicePostBuffer1.Amount;
                                UseBaseAmount := TempInvoicePostBuffer1."VAT Base Amount";
                                if TempInvoicePostBuffer2.Amount < UseAmount then begin
                                    UseAmount := TempInvoicePostBuffer2.Amount;
                                    UseBaseAmount := TempInvoicePostBuffer2."VAT Base Amount";
                                end;
                                if UsedAmount < UseAmount then begin
                                    UseAmount := UsedAmount;
                                    UseBaseAmount := Round(TempInvoicePostBuffer2."VAT Base Amount" * UseAmount / TempInvoicePostBuffer2.Amount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                                end;

                                TempInvoicePostBuffer2.Amount -= UseAmount;
                                TempInvoicePostBuffer2."VAT Base Amount" -= UseBaseAmount;
                                TempInvoicePostBuffer2.Modify();
                                TempInvoicePostBuffer1.Amount -= UseAmount;
                                TempInvoicePostBuffer1."VAT Base Amount" -= UseBaseAmount;
                                TempInvoicePostBuffer1.Modify();
                                UsedAmount -= UseAmount;
                            until (TempInvoicePostBuffer2.Next() = 0) or (UsedAmount = 0);
                        TempInvoicePostBuffer2.Reset();
                    until TempInvoicePostBuffer1.Next() = 0;
                end;

                if InvoicePostBuffer.FindSet() then
                    repeat
                        TempInvoicePostBuffer2 := InvoicePostBuffer;
#pragma warning disable AA0181
                        TempInvoicePostBuffer2.Find();
#pragma warning restore AA0181
                        case true of
                            TempInvoicePostBuffer2.Amount = 0:
                                ;
                            TempInvoicePostBuffer2.Amount <> InvoicePostBuffer.Amount:
                                begin
                                    InvoicePostBuffer.Amount := InvoicePostBuffer.Amount - TempInvoicePostBuffer2.Amount;
                                    InvoicePostBuffer."VAT Base Amount" := InvoicePostBuffer."VAT Base Amount" - TempInvoicePostBuffer2."VAT Base Amount";
                                    InvoicePostBuffer."VAT Amount" := InvoicePostBuffer.Amount - InvoicePostBuffer."VAT Base Amount";
                                    InvoicePostBuffer.Modify();
                                end;
                            TempInvoicePostBuffer2.Amount = InvoicePostBuffer.Amount:
                                begin
                                    InvoicePostBuffer.Amount := 0;
                                    InvoicePostBuffer."VAT Base Amount" := 0;
                                    InvoicePostBuffer."VAT Amount" := 0;
                                    InvoicePostBuffer.Modify();
                                end;
                        end;
                    until InvoicePostBuffer.Next() = 0;
            end else begin
                InvoicePostBuffer.FindSet();
                repeat
                    InvoicePostBuffer.Amount := Round(InvoicePostBuffer.Amount * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision");
                    InvoicePostBuffer."VAT Amount" := Round(InvoicePostBuffer."VAT Amount" * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                    InvoicePostBuffer."VAT Base Amount" := InvoicePostBuffer.Amount - InvoicePostBuffer."VAT Amount";
                    InvoicePostBuffer.Modify();
                until InvoicePostBuffer.Next() = 0;
            end;
        end;

        if InvoicePostBuffer.FindSet() then
            repeat
                if (PurchAdvLetterEntryCZZ."Currency Code" <> '') and (CurrencyFactor <> 0) then begin
                    InvoicePostBuffer."Amount (ACY)" := Round(InvoicePostBuffer.Amount / CurrencyFactor);
                    InvoicePostBuffer."VAT Amount (ACY)" := Round(InvoicePostBuffer."VAT Amount" / CurrencyFactor);
                end else begin
                    InvoicePostBuffer."Amount (ACY)" := InvoicePostBuffer.Amount;
                    InvoicePostBuffer."VAT Amount (ACY)" := InvoicePostBuffer."VAT Amount";
                end;
                InvoicePostBuffer."VAT Base Amount (ACY)" := InvoicePostBuffer."Amount (ACY)" - InvoicePostBuffer."VAT Amount (ACY)";
                InvoicePostBuffer.Modify();
            until InvoicePostBuffer.Next() = 0;
    end;

    procedure PostAdvancePaymentUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
#pragma warning disable AL0432
        TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        PurchInvHeader: Record "Purch. Inv. Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CurrencyFactor: Decimal;
    begin
        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Usage then
            exit;

        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            Error(VATDocumentExistsErr);

        PurchAdvLetterEntryCZZ2.Get(PurchAdvLetterEntryCZZ."Related Entry");
        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ2, TempInvoicePostBuffer, 0D, true);
        TempInvoicePostBuffer.SetFilter(Amount, '<>0');
        if TempInvoicePostBuffer.IsEmpty() then
            Error(NothingToPostErr);

        PurchAdvLetterEntryCZZ2.Get(PurchAdvLetterEntryCZZ."Related Entry");
        PurchAdvLetterEntryCZZ2.TestField(PurchAdvLetterEntryCZZ2."Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Payment);

        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");

        if PurchInvHeader.Get(VendorLedgerEntry."Document No.") then
            CurrencyFactor := PurchInvHeader."VAT Currency Factor CZL"
        else
            CurrencyFactor := VendorLedgerEntry."Original Currency Factor";

        ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ2, VendorLedgerEntry."Source Code", VendorLedgerEntry.Description, CurrencyFactor, PurchAdvLetterEntryCZZ."Document No.", VendorLedgerEntry."External Document No.", VendorLedgerEntry."Posting Date", VendorLedgerEntry."VAT Date CZL", -PurchAdvLetterEntryCZZ.Amount, PurchAdvLetterEntryCZZ."Entry No.", VendorLedgerEntry."Document No.", "Advance Letter Entry Type CZZ"::"VAT Usage", false, GenJnlPostLine, false);
    end;

    local procedure PostExchangeRate(ExchRateAmount: Decimal; ExchRateVATAmount: Decimal; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20]; PostingDate: Date; SourceCode: Code[10]; PostDescription: Text[100]; UsageEntryNo: Integer; Correction: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if (ExchRateAmount = 0) and (ExchRateVATAmount = 0) then
            exit;

        if ExchRateVATAmount <> 0 then begin
            GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, ExchRateAmount - ExchRateVATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
            if ExchRateVATAmount < 0 then begin
                CurrencyGlob.TestField("Realized Losses Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Realized Losses Acc.";
            end else begin
                CurrencyGlob.TestField("Realized Gains Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Realized Gains Acc.";
            end;
            GenJournalLine.Validate(Amount, ExchRateVATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, -ExchRateAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        end;

        AdvEntryInit(Preview);
        if Correction then
            AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(UsageEntryNo);
        AdvEntryInitVAT(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", PostingDate,
            0, VATPostingSetup."VAT %", VATPostingSetup."VAT Identifier", VATPostingSetup."VAT Calculation Type",
            0, ExchRateVATAmount, 0, ExchRateAmount - ExchRateVATAmount);
        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PostingDate,
            0, ExchRateAmount, '', 0, DocumentNo, GenJournalLine."External Document No.",
            PurchAdvLetterEntryCZZ."Global Dimension 1 Code", PurchAdvLetterEntryCZZ."Global Dimension 2 Code", PurchAdvLetterEntryCZZ."Dimension Set ID", Preview);
    end;

#pragma warning disable AL0432
    local procedure BufferAdvanceVATLines(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var InvoicePostBuffer: Record "Invoice Post. Buffer"; BalanceAtDate: Date; ResetBuffer: Boolean)
#pragma warning restore AL0432
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if ResetBuffer then begin
            InvoicePostBuffer.Reset();
            InvoicePostBuffer.DeleteAll();
        end;

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntryCZZ2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        if PurchAdvLetterEntryCZZ2.FindSet() then
            repeat
                if PurchAdvLetterEntryCZZ2."Entry Type" in [PurchAdvLetterEntryCZZ2."Entry Type"::Payment,
                    PurchAdvLetterEntryCZZ2."Entry Type"::Usage, PurchAdvLetterEntryCZZ2."Entry Type"::Close] then
                    BufferAdvanceVATLines(PurchAdvLetterEntryCZZ2, InvoicePostBuffer, BalanceAtDate, false)
                else begin
                    InvoicePostBuffer.Init();
                    InvoicePostBuffer."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                    InvoicePostBuffer."VAT Prod. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group";
                    if InvoicePostBuffer.Find() then begin
                        InvoicePostBuffer.Amount += PurchAdvLetterEntryCZZ2.Amount;
                        InvoicePostBuffer."VAT Base Amount" += PurchAdvLetterEntryCZZ2."VAT Base Amount";
                        InvoicePostBuffer."VAT Amount" += PurchAdvLetterEntryCZZ2."VAT Amount";
                        InvoicePostBuffer."Amount (ACY)" += PurchAdvLetterEntryCZZ2."Amount (LCY)";
                        InvoicePostBuffer."VAT Base Amount (ACY)" += PurchAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                        InvoicePostBuffer."VAT Amount (ACY)" += PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                        InvoicePostBuffer.Modify();
                    end else begin
                        InvoicePostBuffer."VAT Calculation Type" := PurchAdvLetterEntryCZZ2."VAT Calculation Type";
                        InvoicePostBuffer."VAT %" := PurchAdvLetterEntryCZZ2."VAT %";
                        InvoicePostBuffer.Amount := PurchAdvLetterEntryCZZ2.Amount;
                        InvoicePostBuffer."VAT Base Amount" := PurchAdvLetterEntryCZZ2."VAT Base Amount";
                        InvoicePostBuffer."VAT Amount" := PurchAdvLetterEntryCZZ2."VAT Amount";
                        InvoicePostBuffer."Amount (ACY)" := PurchAdvLetterEntryCZZ2."Amount (LCY)";
                        InvoicePostBuffer."VAT Base Amount (ACY)" := PurchAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                        InvoicePostBuffer."VAT Amount (ACY)" := PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                        InvoicePostBuffer.Insert();
                    end;
                end;
            until PurchAdvLetterEntryCZZ2.Next() = 0;
    end;

    local procedure InitGenJnlLineFromVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        GenJournalLine.InitNewLine(
            VendorLedgerEntry."Posting Date", VendorLedgerEntry."Document Date", VendorLedgerEntry.Description,
            VendorLedgerEntry."Global Dimension 1 Code", VendorLedgerEntry."Global Dimension 2 Code",
            VendorLedgerEntry."Dimension Set ID", VendorLedgerEntry."Reason Code");
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.CopyDocumentFields(GenJournalDocumentType, VendorLedgerEntry."Document No.", VendorLedgerEntry."External Document No.", VendorLedgerEntry."Source Code", '');
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
        GenJournalLine."Account No." := VendorLedgerEntry."Vendor No.";
        GenJournalLine."Source Currency Code" := VendorLedgerEntry."Currency Code";
        GenJournalLine."Currency Factor" := VendorLedgerEntry."Original Currency Factor";
        GenJournalLine."Sell-to/Buy-from No." := VendorLedgerEntry."Buy-from Vendor No.";
        GenJournalLine."Bill-to/Pay-to No." := VendorLedgerEntry."Vendor No.";
        GenJournalLine."IC Partner Code" := VendorLedgerEntry."IC Partner Code";
        GenJournalLine."Salespers./Purch. Code" := VendorLedgerEntry."Purchaser Code";
        GenJournalLine."On Hold" := VendorLedgerEntry."On Hold";
        GenJournalLine."Posting Group" := VendorLedgerEntry."Vendor Posting Group";
        GenJournalLine."VAT Date CZL" := VendorLedgerEntry."VAT Date CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := VendorLedgerEntry."VAT Date CZL";
#if not CLEAN19
#pragma warning disable AL0432
        GenJournalLine."VAT Date" := VendorLedgerEntry."VAT Date CZL";
        GenJournalLine."Original Document VAT Date" := VendorLedgerEntry."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."System-Created Entry" := true;
    end;

    local procedure InitGenJnlLineFromAdvance(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; DocumentNo: Code[20]; ExternalDocumentNo: Code[35]; SourceCode: Code[10]; PostDescription: Text[100]; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine."External Document No." := ExternalDocumentNo;
        GenJournalLine.Description := PostDescription;
        GenJournalLine."Bill-to/Pay-to No." := PurchAdvLetterHeaderCZZ."Pay-to Vendor No.";
        GenJournalLine."Country/Region Code" := PurchAdvLetterHeaderCZZ."Pay-to Country/Region Code";
        GenJournalLine."Source Code" := SourceCode;
        GenJournalLine."VAT Registration No." := PurchAdvLetterHeaderCZZ."VAT Registration No.";
        GenJournalLine."Shortcut Dimension 1 Code" := PurchAdvLetterEntryCZZ."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := PurchAdvLetterEntryCZZ."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := PurchAdvLetterEntryCZZ."Dimension Set ID";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
    end;

    procedure GetRemAmtPurchAdvPayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        PurchAdvLetterEntry2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if (PurchAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        PurchAdvLetterEntry2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntry2.SetRange(Cancelled, false);
        PurchAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntry2."Entry Type"::Payment,
            PurchAdvLetterEntry2."Entry Type"::Usage, PurchAdvLetterEntry2."Entry Type"::Close);
        PurchAdvLetterEntry2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        PurchAdvLetterEntry2.CalcSums(Amount);
        exit(PurchAdvLetterEntryCZZ.Amount + PurchAdvLetterEntry2.Amount);
    end;

    procedure GetRemAmtLCYPurchAdvPayment(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        PurchAdvLetterEntry2: Record "Purch. Adv. Letter Entry CZZ";
    begin
        if (PurchAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        PurchAdvLetterEntry2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntry2.SetRange(Cancelled, false);
        PurchAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntry2."Entry Type"::Payment,
            PurchAdvLetterEntry2."Entry Type"::Usage, PurchAdvLetterEntry2."Entry Type"::Close);
        PurchAdvLetterEntry2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        PurchAdvLetterEntry2.CalcSums("Amount (LCY)");
        exit(PurchAdvLetterEntryCZZ."Amount (LCY)" + PurchAdvLetterEntry2."Amount (LCY)");
    end;

    procedure GetRemAmtLCYVATAdjust(var AmountLCY: Decimal; var VATAmountLCY: Decimal; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; BalanceAtDate: Date; VATBusPostGr: Code[20]; VATProdPostGr: Code[20])
    var
        PurchAdvLetterEntry2: Record "Purch. Adv. Letter Entry CZZ";
        AmountLCY2, VATAmountLCY2 : Decimal;
    begin
        PurchAdvLetterEntry2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntry2.SetRange(Cancelled, false);
        PurchAdvLetterEntry2.SetRange("Entry Type", PurchAdvLetterEntry2."Entry Type"::"VAT Adjustment");
        PurchAdvLetterEntry2.SetRange("VAT Bus. Posting Group", VATBusPostGr);
        PurchAdvLetterEntry2.SetRange("VAT Prod. Posting Group", VATProdPostGr);
        PurchAdvLetterEntry2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            PurchAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        PurchAdvLetterEntry2.CalcSums("Amount (LCY)", "VAT Amount (LCY)");
        AmountLCY := PurchAdvLetterEntry2."Amount (LCY)";
        VATAmountLCY := PurchAdvLetterEntry2."VAT Amount (LCY)";

        PurchAdvLetterEntry2.SetRange("VAT Bus. Posting Group");
        PurchAdvLetterEntry2.SetRange("VAT Prod. Posting Group");
        PurchAdvLetterEntry2.SetRange("Entry Type", PurchAdvLetterEntry2."Entry Type"::Usage);
        if PurchAdvLetterEntry2.FindSet() then
            repeat
                GetRemAmtLCYVATAdjust(AmountLCY2, VATAmountLCY2, PurchAdvLetterEntry2, BalanceAtDate, VATBusPostGr, VATProdPostGr);
                AmountLCY += AmountLCY2;
                VATAmountLCY += VATAmountLCY2;
            until PurchAdvLetterEntry2.Next() = 0
    end;

    procedure CloseAdvanceLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        VendorLedgerEntry1: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
#pragma warning disable AL0432
        TempInvoicePostBuffer: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        AdvPaymentCloseDialogCZZ: Page "Adv. Payment Close Dialog CZZ";
        ApplId: Code[50];
        ExternalDocumentNo: Code[35];
        VATDocumentNo: Code[20];
        PostingDate: Date;
        VATDate: Date;
        CurrencyFactor: Decimal;
        RemAmount: Decimal;
        RemAmountLCY: Decimal;
        UsageEntryNo: Integer;
        DateEmptyErr: Label 'Posting Date and VAT Date cannot be empty.';
    begin
        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if PurchAdvLetterHeaderCZZ.Status = PurchAdvLetterHeaderCZZ.Status::New then begin
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        AdvPaymentCloseDialogCZZ.SetValues(WorkDate(), WorkDate(), PurchAdvLetterHeaderCZZ."Currency Code", 0, '', true);
        if AdvPaymentCloseDialogCZZ.RunModal() = Action::OK then begin
            AdvPaymentCloseDialogCZZ.GetValues(PostingDate, VATDate, CurrencyFactor);
            if (PostingDate = 0D) or (VATDate = 0D) then
                Error(DateEmptyErr);
            if PurchAdvLetterHeaderCZZ."Currency Code" = '' then
                CurrencyFactor := 1;
            ExternalDocumentNo := AdvPaymentCloseDialogCZZ.GetExternalDocumentNo();
            PurchasesPayablesSetup.Get();
            if PurchasesPayablesSetup."Ext. Doc. No. Mandatory" and (ExternalDocumentNo = '') then
                Error(ExternalDocumentNoEmptyErr);

            VATDocumentNo := '';

            PurchAdvLetterEntryCZZ.SetRange("Purch. Adv. Letter No.", PurchAdvLetterHeaderCZZ."No.");
            PurchAdvLetterEntryCZZ.SetRange("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Payment);
            PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
            if PurchAdvLetterEntryCZZ.FindSet() then
                repeat
                    RemAmount := GetRemAmtPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);
                    RemAmountLCY := GetRemAmtLCYPurchAdvPayment(PurchAdvLetterEntryCZZ, 0D);

                    BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer, 0D, true);
                    TempInvoicePostBuffer.SetFilter("VAT Amount", '<>0');

                    if (RemAmount <> 0) or (not TempInvoicePostBuffer.IsEmpty()) then begin
                        if VATDocumentNo = '' then
                            if not TempInvoicePostBuffer.IsEmpty() then begin
                                AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
                                AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
                                VATDocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", PostingDate, true);
                            end;

                        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                        VendorLedgerEntry1.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
                        if RemAmount <> 0 then begin
                            InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry1, GenJournalLine, GenJournalLine."Document Type"::" ");
                            GenJournalLine.Correction := true;
                            GenJournalLine."External Document No." := ExternalDocumentNo;
                            GenJournalLine."Document No." := VATDocumentNo;
                            GenJournalLine."Posting Date" := PostingDate;
                            GenJournalLine."Document Date" := PostingDate;
                            GenJournalLine."VAT Date CZL" := VATDate;
                            GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                            GenJournalLine."Use Advance G/L Account CZZ" := true;
                            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                            GenJournalLine.Validate(Amount, -RemAmount);

                            ApplId := CopyStr(VendorLedgerEntry1."Document No." + Format(VendorLedgerEntry1."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                            VendorLedgerEntry1.Prepayment := false;
                            VendorLedgerEntry1."Advance Letter No. CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                            VendorLedgerEntry1.Modify();
                            VendorLedgerEntry1.CalcFields("Remaining Amount");
                            VendorLedgerEntry1."Amount to Apply" := VendorLedgerEntry1."Remaining Amount";
                            VendorLedgerEntry1."Applies-to ID" := ApplId;
                            Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry1);
                            GenJournalLine."Applies-to ID" := ApplId;

                            OnBeforePostClosePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);
                            GenJnlPostLine.RunWithCheck(GenJournalLine);
                            OnAfterPostClosePayment(GenJournalLine, PurchAdvLetterHeaderCZZ);

                            VendorLedgerEntry2.FindLast();
                            AdvEntryInit(false);
                            AdvEntryInitVendLedgEntryNo(VendorLedgerEntry2."Entry No.");
                            AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
                            AdvEntryInsert("Advance Letter Entry Type CZZ"::Close, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
                                GenJournalLine.Amount, -RemAmountLCY,
                                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                            UsageEntryNo := PurchAdvLetterEntryCZZGlob."Entry No.";
                        end else begin
                            VendorLedgerEntry2.Init();
                            UsageEntryNo := 0;
                        end;

                        ReverseAdvancePaymentVAT(PurchAdvLetterEntryCZZ, VendorLedgerEntry1."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", CurrencyFactor, VATDocumentNo, ExternalDocumentNo, PostingDate, VATDate, 0, UsageEntryNo, '', "Advance Letter Entry Type CZZ"::"VAT Close", true, GenJnlPostLine, false);

                        if RemAmount <> 0 then begin
                            InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry1, GenJournalLine, GenJournalLine."Document Type"::Payment);
                            GenJournalLine.Correction := true;
                            GenJournalLine."External Document No." := ExternalDocumentNo;
                            GenJournalLine."Document No." := VATDocumentNo;
                            GenJournalLine."Posting Date" := PostingDate;
                            GenJournalLine."Document Date" := PostingDate;
                            GenJournalLine."VAT Date CZL" := VATDate;
                            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                            GenJournalLine.Validate(Amount, RemAmount);
                            OnBeforePostClosePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
                            GenJnlPostLine.RunWithCheck(GenJournalLine);
                            OnAfterPostClosePaymentRepos(GenJournalLine, PurchAdvLetterHeaderCZZ);
                        end;
                    end;
                until PurchAdvLetterEntryCZZ.Next() = 0;

            CancelInitEntry(PurchAdvLetterHeaderCZZ, PostingDate, false);
            PurchAdvLetterHeaderCZZ.Find();
            UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::Closed);

            AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Purchase);
            AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", PurchAdvLetterHeaderCZZ."No.");
            AdvanceLetterApplicationCZZ.DeleteAll(true);
        end;
    end;

    procedure PostAdvanceCreditMemoVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ3: Record "Purch. Adv. Letter Entry CZZ";
#pragma warning disable AL0432
        TempInvoicePostBuffer1: Record "Invoice Post. Buffer" temporary;
        TempInvoicePostBuffer2: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATEntry: Record "VAT Entry";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATDocumentCZZ: Page "VAT Document CZZ";
        DocumentNo: Code[20];
        ExternalDocumentNo: Code[35];
        VATDate: Date;
        DocumentDate: Date;
        PostingDate: Date;
        ExchRateAmount: Decimal;
        ExchRateVATAmount: Decimal;
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        VATEntry.Get(PurchAdvLetterEntryCZZ."VAT Entry No.");

        PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        PurchAdvLetterEntryCZZ2.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        PurchAdvLetterEntryCZZ2.FindSet();
        repeat
            TempInvoicePostBuffer1."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group";
            TempInvoicePostBuffer1."VAT Prod. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group";
            if TempInvoicePostBuffer1.Find() then begin
                TempInvoicePostBuffer1.Amount += PurchAdvLetterEntryCZZ2.Amount;
                TempInvoicePostBuffer1."VAT Base Amount" += PurchAdvLetterEntryCZZ2."VAT Base Amount";
                TempInvoicePostBuffer1."VAT Amount" += PurchAdvLetterEntryCZZ2."VAT Amount";
                TempInvoicePostBuffer1."Amount (ACY)" += PurchAdvLetterEntryCZZ2."Amount (LCY)";
                TempInvoicePostBuffer1."VAT Base Amount (ACY)" += PurchAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                TempInvoicePostBuffer1."VAT Amount (ACY)" += PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                TempInvoicePostBuffer1.Modify();
            end else begin
                TempInvoicePostBuffer1."VAT Calculation Type" := PurchAdvLetterEntryCZZ2."VAT Calculation Type";
                TempInvoicePostBuffer1."VAT %" := PurchAdvLetterEntryCZZ2."VAT %";
                TempInvoicePostBuffer1.Amount := PurchAdvLetterEntryCZZ2.Amount;
                TempInvoicePostBuffer1."VAT Base Amount" := PurchAdvLetterEntryCZZ2."VAT Base Amount";
                TempInvoicePostBuffer1."VAT Amount" := PurchAdvLetterEntryCZZ2."VAT Amount";
                TempInvoicePostBuffer1."Amount (ACY)" := PurchAdvLetterEntryCZZ2."Amount (LCY)";
                TempInvoicePostBuffer1."VAT Base Amount (ACY)" := PurchAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                TempInvoicePostBuffer1."VAT Amount (ACY)" := PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                TempInvoicePostBuffer1.Insert();
            end;
        until PurchAdvLetterEntryCZZ2.Next() = 0;

        VATDocumentCZZ.InitDocument(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", '', PurchAdvLetterEntryCZZ."Posting Date", PurchAdvLetterEntryCZZ."VAT Date", PurchAdvLetterHeaderCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor", PurchAdvLetterEntryCZZ."External Document No.", TempInvoicePostBuffer1);
        if VATDocumentCZZ.RunModal() <> Action::OK then
            exit;

        VATDocumentCZZ.SaveNoSeries();
        VATDocumentCZZ.GetDocument(DocumentNo, PostingDate, DocumentDate, VATDate, ExternalDocumentNo, TempInvoicePostBuffer1);
        if (DocumentNo = '') or (PostingDate = 0D) or (VATDate = 0D) then
            Error(DocumentNoOrDatesEmptyErr);

        TempInvoicePostBuffer1.SetFilter(Amount, '<>0');
        if not TempInvoicePostBuffer1.FindSet() then
            Error(NothingToPostErr);

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

        if PurchAdvLetterEntryCZZ."Currency Code" <> '' then begin
            PurchAdvLetterEntryCZZ3.Get(PurchAdvLetterEntryCZZ."Related Entry");
            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ3, TempInvoicePostBuffer2, 0D, true);
        end;

        PurchAdvLetterEntryCZZ2.FindSet(true, true);
        repeat
            TempInvoicePostBuffer1.Reset();
            TempInvoicePostBuffer1.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group");
            TempInvoicePostBuffer1.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
            TempInvoicePostBuffer1.FindFirst();
            PurchAdvLetterEntryCZZ2.TestField(Amount, TempInvoicePostBuffer1.Amount);

            VATPostingSetup.Get(TempInvoicePostBuffer1."VAT Bus. Posting Group", TempInvoicePostBuffer1."VAT Prod. Posting Group");
            VATPostingSetup.TestField("Purch. Adv. Letter Account CZZ");
            VATPostingSetup.TestField("Purch. Adv.Letter VAT Acc. CZZ");

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VATEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
            GenJournalLine."VAT Calculation Type" := TempInvoicePostBuffer1."VAT Calculation Type";
            GenJournalLine."VAT Bus. Posting Group" := TempInvoicePostBuffer1."VAT Bus. Posting Group";
            GenJournalLine.validate("VAT Prod. Posting Group", TempInvoicePostBuffer1."VAT Prod. Posting Group");
            GenJournalLine.Validate(Amount, -TempInvoicePostBuffer1.Amount);
            GenJournalLine."VAT Amount" := -TempInvoicePostBuffer1."VAT Amount";
            GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
            GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
            if GenJournalLine."Currency Code" <> '' then begin
                GenJournalLine."Amount (LCY)" := -TempInvoicePostBuffer1."Amount (ACY)";
                GenJournalLine."VAT Amount (LCY)" := -TempInvoicePostBuffer1."VAT Amount (ACY)";
                GenJournalLine."VAT Base Amount (LCY)" := -TempInvoicePostBuffer1."VAT Base Amount (ACY)";
                GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            end else begin
                GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
            end;
            BindSubscription(VATPostingSetupHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(VATPostingSetupHandlerCZZ);

            AdvEntryInit(false);
            AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
            AdvEntryInitCancel();
            AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Date CZL",
                GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

            if GenJournalLine."Currency Code" <> '' then begin
                ExchRateAmount := PurchAdvLetterEntryCZZ2."Amount (LCY)" + GenJournalLine."Amount (LCY)";
                ExchRateVATAmount := PurchAdvLetterEntryCZZ2."VAT Amount (LCY)" + GenJournalLine."VAT Amount (LCY)";
                if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                    PostExchangeRate(ExchRateAmount, ExchRateVATAmount, PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                        DocumentNo, PostingDate, '', PurchAdvLetterHeaderCZZ."Posting Description", PurchAdvLetterEntryCZZ2."Related Entry", true, GenJnlPostLine, false);

                TempInvoicePostBuffer2.Reset();
                TempInvoicePostBuffer2.SetRange("VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group");
                TempInvoicePostBuffer2.SetRange("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                TempInvoicePostBuffer2.FindFirst();

                ReverseUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempInvoicePostBuffer1.Amount / TempInvoicePostBuffer2.Amount,
                    PurchAdvLetterEntryCZZ."Related Entry", DocumentNo, PostingDate, PurchAdvLetterHeaderCZZ."Posting Description", GenJnlPostLine, false);
            end;

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, ExternalDocumentNo, VATEntry."Source Code", PurchAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
            GenJournalLine.Validate(Amount, TempInvoicePostBuffer1.Amount);
            GenJournalLine."Amount (LCY)" := TempInvoicePostBuffer1."Amount (ACY)";
            GenJournalLine."Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
            GenJnlPostLine.RunWithCheck(GenJournalLine);
        until PurchAdvLetterEntryCZZ2.Next() = 0;

        PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
    end;

    procedure PostCancelUsageVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        DocumentNo: Code[20];
    begin
        PurchAdvLetterEntryCZZ.TestField("Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ.TestField(Cancelled, false);

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
        AdvanceLetterTemplateCZZ.Get(PurchAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
        DocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", 0D, true);

        GetCurrency(PurchAdvLetterEntryCZZ."Currency Code");

        PurchAdvLetterEntryCZZ2.Reset();
        PurchAdvLetterEntryCZZ2.SetRange("Document No.", PurchAdvLetterEntryCZZ."Document No.");
        PurchAdvLetterEntryCZZ2.SetFilter("Entry Type", '%1|%2|%3', PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment",
            PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Rate", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage");
        PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ2.Find('+');
        PurchAdvLetterEntryCZZ2.SetFilter("Entry No.", '..%1', PurchAdvLetterEntryCZZ2."Entry No.");
        repeat
            case PurchAdvLetterEntryCZZ2."Entry Type" of
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ2, PurchAdvLetterHeaderCZZ, VATPostingSetup, -PurchAdvLetterEntryCZZ2."Amount (LCY)", -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ2."Related Entry", 0, DocumentNo, PurchAdvLetterEntryCZZ2."Posting Date", '', GenJnlPostLine, true, false);
                    end;
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Rate":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        PostExchangeRate(-PurchAdvLetterEntryCZZ2."Amount (LCY)", -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)", PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, VATPostingSetup,
                            PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."Posting Date", '',
                            '', PurchAdvLetterEntryCZZ2."Related Entry", true, GenJnlPostLine, false);
                    end;
                PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Usage":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."External Document No.",
                            '', '', GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                        GenJournalLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ2."VAT Calculation Type";
                        GenJournalLine."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                        GenJournalLine.validate("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, -PurchAdvLetterEntryCZZ2.Amount);
                        GenJournalLine."VAT Amount" := -PurchAdvLetterEntryCZZ2."VAT Amount";
                        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                        GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                             CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                        if GenJournalLine."Currency Code" = '' then begin
                            GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                            GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
                        end else begin
                            GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ2."Amount (LCY)";
                            GenJournalLine."VAT Amount (LCY)" := -PurchAdvLetterEntryCZZ2."VAT Amount (LCY)";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
                        end;
                        BindSubscription(VATPostingSetupHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(VATPostingSetupHandlerCZZ);

                        AdvEntryInit(false);
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ2."Related Entry");
                        AdvEntryInitCancel();
                        AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Date CZL",
                            GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                            GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", PurchAdvLetterEntryCZZ2."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ2, PurchAdvLetterEntryCZZ2."Document No.", PurchAdvLetterEntryCZZ2."External Document No.", '', '', GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ2."Posting Date");
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ2."Currency Code", PurchAdvLetterEntryCZZ2."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, PurchAdvLetterEntryCZZ2.Amount);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                    end;
            end;
        until PurchAdvLetterEntryCZZ2.Next(-1) = 0;

        PurchAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Use");
    end;

    procedure PostAdvancePaymentUsagePreview(var PurchaseHeader: Record "Purchase Header"; Amount: Decimal; AmountLCY: Decimal; var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ")
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ";
    begin
        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.DeleteAll();

        if not TempPurchAdvLetterEntryCZZGlob.IsEmpty() then
            TempPurchAdvLetterEntryCZZGlob.DeleteAll();

        case PurchaseHeader."Document Type" of
            PurchaseHeader."Document Type"::Order:
                AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Purchase Order";
            PurchaseHeader."Document Type"::Invoice:
                AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Purchase Invoice";
            else
                exit;
        end;

        PurchInvHeader.TransferFields(PurchaseHeader);
        VendorLedgerEntry.Init();
        VendorLedgerEntry."Vendor No." := PurchaseHeader."Pay-to Vendor No.";
        VendorLedgerEntry."Posting Date" := PurchaseHeader."Posting Date";
        VendorLedgerEntry."Document Date" := PurchaseHeader."Document Date";
        VendorLedgerEntry."Document Type" := PurchaseHeader."Document Type";
        VendorLedgerEntry."Document No." := PurchaseHeader."No.";
        VendorLedgerEntry."External Document No." := PurchaseHeader."Vendor Order No.";
        VendorLedgerEntry.Description := PurchaseHeader."Posting Description";
        VendorLedgerEntry."Currency Code" := PurchaseHeader."Currency Code";
        VendorLedgerEntry."Buy-from Vendor No." := PurchaseHeader."Buy-from Vendor No.";
        VendorLedgerEntry."Vendor Posting Group" := PurchaseHeader."Vendor Posting Group";
        VendorLedgerEntry."Global Dimension 1 Code" := PurchaseHeader."Shortcut Dimension 1 Code";
        VendorLedgerEntry."Global Dimension 2 Code" := PurchaseHeader."Shortcut Dimension 2 Code";
        VendorLedgerEntry."Dimension Set ID" := PurchaseHeader."Dimension Set ID";
        VendorLedgerEntry."Purchaser Code" := PurchaseHeader."Purchaser Code";
        VendorLedgerEntry."Due Date" := PurchaseHeader."Due Date";
        VendorLedgerEntry."Payment Method Code" := PurchaseHeader."Payment Method Code";
        VendorLedgerEntry."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
        VendorLedgerEntry."Original Currency Factor" := PurchaseHeader."Currency Factor";
        VendorLedgerEntry.Amount := -Amount;
        VendorLedgerEntry."Amount (LCY)" := -AmountLCY;
        VendorLedgerEntry."Remaining Amount" := -Amount;
        VendorLedgerEntry."Remaining Amt. (LCY)" := -AmountLCY;

        PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, PurchaseHeader."No.", PurchInvHeader, VendorLedgerEntry, GenJnlPostLine, true);

        if TempPurchAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                PurchAdvLetterEntryCZZ := TempPurchAdvLetterEntryCZZGlob;
                PurchAdvLetterEntryCZZ.Insert();
            until TempPurchAdvLetterEntryCZZGlob.Next() = 0;

            TempPurchAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UnapplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        TempPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryInv: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        ApplId: Code[50];
        AdvLetters: Text;
        UnapplyIsNotPossibleErr: Label 'Unapply is not possible.';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
    begin
        PurchAdvLetterEntryCZZ.SetRange(PurchAdvLetterEntryCZZ."Entry Type", PurchAdvLetterEntryCZZ."Entry Type"::Usage);
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not PurchAdvLetterEntryCZZ.FindSet() then
            exit;

        repeat
            if not TempPurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.") then begin
                TempPurchAdvLetterHeaderCZZ."No." := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                TempPurchAdvLetterHeaderCZZ.Insert();
            end;
        until PurchAdvLetterEntryCZZ.Next() = 0;

        if TempPurchAdvLetterHeaderCZZ.FindSet() then
            repeat
                if AdvLetters <> '' then
                    AdvLetters := AdvLetters + ', ';
                AdvLetters := AdvLetters + TempPurchAdvLetterHeaderCZZ."No.";
            until TempPurchAdvLetterHeaderCZZ.Next() = 0;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UnapplyAdvLetterQst, AdvLetters), false) then
            exit;

        PurchAdvLetterEntryCZZ.Reset();
        PurchAdvLetterEntryCZZ.SetRange("Document No.", PurchInvHeader."No.");
        PurchAdvLetterEntryCZZ.SetRange(Cancelled, false);
        PurchAdvLetterEntryCZZ.Find('+');
        PurchAdvLetterEntryCZZ.SetFilter("Entry No.", '..%1', PurchAdvLetterEntryCZZ."Entry No.");
        repeat
            PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            case PurchAdvLetterEntryCZZ."Entry Type" of
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, -PurchAdvLetterEntryCZZ."Amount (LCY)", -PurchAdvLetterEntryCZZ."VAT Amount (LCY)",
                            PurchAdvLetterEntryCZZ."Related Entry", 0, PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."Posting Date", PurchInvHeader."Posting Description", GenJnlPostLine, true, false);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Rate":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostExchangeRate(-PurchAdvLetterEntryCZZ."Amount (LCY)", -PurchAdvLetterEntryCZZ."VAT Amount (LCY)", PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, VATPostingSetup,
                            PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."Posting Date", PurchInvHeader."Source Code",
                            PurchInvHeader."Posting Description", PurchAdvLetterEntryCZZ."Related Entry", true, GenJnlPostLine, false);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::"VAT Usage":
                    begin
                        VATPostingSetup.Get(PurchAdvLetterEntryCZZ."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."External Document No.",
                            PurchInvHeader."Source Code", PurchInvHeader."Posting Description", GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ."Posting Date");
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Purchase;
                        GenJournalLine."VAT Calculation Type" := PurchAdvLetterEntryCZZ."VAT Calculation Type";
                        GenJournalLine."VAT Bus. Posting Group" := PurchAdvLetterEntryCZZ."VAT Bus. Posting Group";
                        GenJournalLine.validate("VAT Prod. Posting Group", PurchAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, -PurchAdvLetterEntryCZZ.Amount);
                        GenJournalLine."VAT Amount" := -PurchAdvLetterEntryCZZ."VAT Amount";
                        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                        GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                             CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                        if GenJournalLine."Currency Code" = '' then begin
                            GenJournalLine."Amount (LCY)" := GenJournalLine.Amount;
                            GenJournalLine."VAT Amount (LCY)" := GenJournalLine."VAT Amount";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."VAT Base Amount";
                        end else begin
                            GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";
                            GenJournalLine."VAT Amount (LCY)" := -PurchAdvLetterEntryCZZ."VAT Amount (LCY)";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
                        end;
                        BindSubscription(VATPostingSetupHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(VATPostingSetupHandlerCZZ);

                        AdvEntryInit(false);
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Related Entry");
                        AdvEntryInitCancel();
                        AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Date CZL",
                            GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                            GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, PurchAdvLetterEntryCZZ."Document No.", PurchAdvLetterEntryCZZ."External Document No.", PurchInvHeader."Source Code", PurchInvHeader."Posting Description", GenJournalLine);
                        GenJournalLine.Validate("Posting Date", PurchAdvLetterEntryCZZ."Posting Date");
                        GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(PurchInvHeader."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, PurchAdvLetterEntryCZZ.Amount);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                    end;
                PurchAdvLetterEntryCZZ."Entry Type"::Usage:
                    begin
                        VendorLedgerEntry.Get(PurchAdvLetterEntryCZZ."Vendor Ledger Entry No.");
                        VendorLedgerEntryInv := VendorLedgerEntry;
#pragma warning disable AA0181
                        VendorLedgerEntryInv.Next(-1);
#pragma warning restore AA0181
                        UnapplyVendLedgEntry(VendorLedgerEntry, GenJnlPostLine);

                        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, VendorLedgerEntry."Document Type"::" ");
                        GenJournalLine.Correction := true;
                        GenJournalLine."Adv. Letter No. (Entry) CZZ" := PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.";
                        GenJournalLine."Use Advance G/L Account CZZ" := true;
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Amount := -PurchAdvLetterEntryCZZ.Amount;
                        GenJournalLine."Amount (LCY)" := -PurchAdvLetterEntryCZZ."Amount (LCY)";

                        ApplId := CopyStr(VendorLedgerEntry."Document No." + Format(VendorLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        VendorLedgerEntry.CalcFields("Remaining Amount");
                        VendorLedgerEntry."Amount to Apply" := VendorLedgerEntry."Remaining Amount";
                        VendorLedgerEntry."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntry);
                        GenJournalLine."Applies-to ID" := ApplId;

                        BindSubscription(GenJnlCheckLnHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);

                        VendorLedgerEntry.FindLast();
                        AdvEntryInit(false);
                        AdvEntryInitCancel();
                        AdvEntryInitVendLedgEntryNo(VendorLedgerEntry."Entry No.");
                        AdvEntryInitRelatedEntry(PurchAdvLetterEntryCZZ."Entry No.");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.", GenJournalLine."External Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromVendLedgEntry(VendorLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
                        GenJournalLine.Correction := true;
                        GenJournalLine.SetCurrencyFactor(PurchAdvLetterEntryCZZ."Currency Code", PurchAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Amount := PurchAdvLetterEntryCZZ.Amount;
                        GenJournalLine."Amount (LCY)" := PurchAdvLetterEntryCZZ."Amount (LCY)";

                        ApplId := CopyStr(VendorLedgerEntryInv."Document No." + Format(VendorLedgerEntryInv."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        VendorLedgerEntryInv.Prepayment := false;
                        VendorLedgerEntryInv."Advance Letter No. CZZ" := '';
                        VendorLedgerEntryInv.CalcFields("Remaining Amount");
                        VendorLedgerEntryInv."Amount to Apply" := VendorLedgerEntryInv."Remaining Amount";
                        VendorLedgerEntryInv."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Vend. Entry-Edit", VendorLedgerEntryInv);
                        GenJournalLine."Applies-to ID" := ApplId;

                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(GenJnlCheckLnHandlerCZZ);

                        UpdateStatus(PurchAdvLetterHeaderCZZ, PurchAdvLetterHeaderCZZ.Status::"To Use");
                    end;
                else
                    Error(UnapplyIsNotPossibleErr);
            end;
        until PurchAdvLetterEntryCZZ.Next(-1) = 0;

        PurchAdvLetterEntryCZZ.ModifyAll(Cancelled, true);
    end;

    local procedure UnapplyVendLedgEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        DetailedVendorLedgEntry1: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry2: Record "Detailed Vendor Ledg. Entry";
        DetailedVendorLedgEntry3: Record "Detailed Vendor Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        Succes: Boolean;
        UnapplyLastInvoicesErr: Label 'First you must unapply invoces that were applied to advance last time.';
    begin
        DetailedVendorLedgEntry1.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
        DetailedVendorLedgEntry1.SetRange("Vendor Ledger Entry No.", VendorLedgerEntry."Entry No.");
        DetailedVendorLedgEntry1.SetRange("Entry Type", DetailedVendorLedgEntry1."Entry Type"::Application);
        DetailedVendorLedgEntry1.SetRange(Unapplied, false);
        Succes := false;
        repeat
            if DetailedVendorLedgEntry1.FindLast() then begin
                DetailedVendorLedgEntry2.Reset();
                DetailedVendorLedgEntry2.SetCurrentKey("Transaction No.", "Vendor No.", "Entry Type");
                DetailedVendorLedgEntry2.SetRange("Transaction No.", DetailedVendorLedgEntry1."Transaction No.");
                DetailedVendorLedgEntry2.SetRange("Vendor No.", DetailedVendorLedgEntry1."Vendor No.");
                if DetailedVendorLedgEntry2.FindSet() then
                    repeat
                        if (DetailedVendorLedgEntry2."Entry Type" <> DetailedVendorLedgEntry2."Entry Type"::"Initial Entry") and
                           not DetailedVendorLedgEntry2.Unapplied
                        then
                            DetailedVendorLedgEntry3.Reset();
                        DetailedVendorLedgEntry3.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type");
                        DetailedVendorLedgEntry3.SetRange("Vendor Ledger Entry No.", DetailedVendorLedgEntry2."Vendor Ledger Entry No.");
                        DetailedVendorLedgEntry3.SetRange(Unapplied, false);
                        if DetailedVendorLedgEntry3.FindLast() and
                           (DetailedVendorLedgEntry3."Transaction No." > DetailedVendorLedgEntry2."Transaction No.")
                        then
                            Error(UnapplyLastInvoicesErr);
                    until DetailedVendorLedgEntry2.Next() = 0;

                GenJournalLine.Init();
                GenJournalLine."Document No." := DetailedVendorLedgEntry1."Document No.";
                GenJournalLine."Posting Date" := DetailedVendorLedgEntry1."Posting Date";
                GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
                GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Date CZL";
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
                GenJournalLine."Account No." := DetailedVendorLedgEntry1."Vendor No.";
                GenJournalLine.Correction := true;
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
                GenJournalLine.Description := VendorLedgerEntry.Description;
                GenJournalLine."Shortcut Dimension 1 Code" := VendorLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := VendorLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := VendorLedgerEntry."Dimension Set ID";
                GenJournalLine."Posting Group" := VendorLedgerEntry."Vendor Posting Group";
                GenJournalLine."Source Currency Code" := DetailedVendorLedgEntry1."Currency Code";
                GenJournalLine."System-Created Entry" := true;
                GenJnlPostLine.UnapplyVendLedgEntry(GenJournalLine, DetailedVendorLedgEntry1);
            end else
                Succes := true;
        until Succes;
    end;

    procedure ApplyAdvanceLetter(var PurchInvHeader: Record "Purch. Inv. Header")
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        ConfirmManagement: Codeunit "Confirm Management";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ApplyAdvanceLetterQst: Label 'Apply Advance Letter?';
        CannotApplyErr: Label 'You cannot apply more than %1.', Comment = '%1 = Remaining amount to apply';
    begin
        LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Posted Purchase Invoice", PurchInvHeader."No.", PurchInvHeader."Pay-to Vendor No.", PurchInvHeader."Posting Date", PurchInvHeader."Currency Code");

        AdvanceLetterApplication.SetRange("Document Type", AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice");
        AdvanceLetterApplication.SetRange("Document No.", PurchInvHeader."No.");
        if AdvanceLetterApplication.IsEmpty() then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(ApplyAdvanceLetterQst, false) then
            exit;

        CheckAdvancePayement(AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice", PurchInvHeader."No.");
        AdvanceLetterApplication.CalcSums(Amount);
        VendorLedgerEntry.SetCurrentKey("Document No.");
        VendorLedgerEntry.SetRange("Document No.", PurchInvHeader."No.");
        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.FindLast();
        VendorLedgerEntry.CalcFields("Remaining Amount");
        if AdvanceLetterApplication.Amount > -VendorLedgerEntry."Remaining Amount" then
            Error(CannotApplyErr, -VendorLedgerEntry."Remaining Amount");

        PostAdvancePaymentUsage(AdvanceLetterApplication."Document Type"::"Posted Purchase Invoice", PurchInvHeader."No.", PurchInvHeader,
            VendorLedgerEntry, GenJnlPostLine, false);
    end;

    procedure CheckAdvancePayement(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20])
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        UsageQst: Label 'Usage all applicated advances is not possible.\Continue?';
    begin
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                PurchAdvLetterHeaderCZZ.SetAutoCalcFields("To Use");
                PurchAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
                if PurchAdvLetterHeaderCZZ."To Use" < AdvanceLetterApplicationCZZ.Amount then
                    if not ConfirmManagement.GetResponseOrDefault(UsageQst, false) then
                        Error('');
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;

    procedure AdjustVATExchangeRate(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; Amount: Decimal; DetEntryNo: Integer; ToDate: Date; DocumentNo: Code[20]; PostDescription: Text[100])
    var
#pragma warning disable AL0432
        TempInvoicePostBuffer1: Record "Invoice Post. Buffer" temporary;
        TempInvoicePostBuffer2: Record "Invoice Post. Buffer" temporary;
#pragma warning restore AL0432
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        PurchAdvLetterEntryCZZ2: Record "Purch. Adv. Letter Entry CZZ";
        PurchAdvLetterEntryCZZ3: Record "Purch. Adv. Letter Entry CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        RestToDivide: Decimal;
        RestLines: Decimal;
        AmountToPost: Decimal;
        VATAmountToPost: Decimal;
        VATDocAmtToDate: Decimal;
    begin
        if Amount = 0 then
            exit;
        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        PurchAdvLetterEntryCZZ2.SetRange("Det. Vendor Ledger Entry No.", DetEntryNo);
        if not PurchAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        PurchAdvLetterHeaderCZZ.Get(PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");

        BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer1, ToDate, true);
        TempInvoicePostBuffer1.CalcSums(Amount);
        VATDocAmtToDate := TempInvoicePostBuffer1.Amount;
        if VATDocAmtToDate <> 0 then begin
            RestLines := VATDocAmtToDate;
            RestToDivide := Amount;
            TempInvoicePostBuffer1.FindSet();
            repeat
                TempInvoicePostBuffer2.Init();
                TempInvoicePostBuffer2."VAT Bus. Posting Group" := TempInvoicePostBuffer1."VAT Bus. Posting Group";
                TempInvoicePostBuffer2."VAT Prod. Posting Group" := TempInvoicePostBuffer1."VAT Prod. Posting Group";
                TempInvoicePostBuffer2."VAT Calculation Type" := TempInvoicePostBuffer1."VAT Calculation Type";
                TempInvoicePostBuffer2."VAT %" := TempInvoicePostBuffer1."VAT %";

                TempInvoicePostBuffer2."Amount (ACY)" := Round(RestToDivide * TempInvoicePostBuffer1.Amount / RestLines);
                case TempInvoicePostBuffer2."VAT Calculation Type" of
                    TempInvoicePostBuffer2."VAT Calculation Type"::"Normal VAT":
                        TempInvoicePostBuffer2."VAT Amount (ACY)" := Round(TempInvoicePostBuffer2."Amount (ACY)" * TempInvoicePostBuffer2."VAT %" / (100 + TempInvoicePostBuffer2."VAT %"));
                    TempInvoicePostBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                        TempInvoicePostBuffer2."VAT Amount (ACY)" := 0;
                end;
                TempInvoicePostBuffer2."VAT Base Amount (ACY)" := TempInvoicePostBuffer2."Amount (ACY)" - TempInvoicePostBuffer2."VAT Amount (ACY)";
                TempInvoicePostBuffer2.Insert();

                RestToDivide := RestToDivide - TempInvoicePostBuffer2."Amount (ACY)";
                RestLines := RestLines - TempInvoicePostBuffer1.Amount;
            until TempInvoicePostBuffer1.Next() = 0;

            if TempInvoicePostBuffer2.FindSet() then
                repeat
                    VATPostingSetup.Get(TempInvoicePostBuffer2."VAT Bus. Posting Group", TempInvoicePostBuffer2."VAT Prod. Posting Group");
                    PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, TempInvoicePostBuffer2."Amount (ACY)", TempInvoicePostBuffer2."VAT Amount (ACY)",
                        PurchAdvLetterEntryCZZ."Entry No.", DetEntryNo, DocumentNo, ToDate, PostDescription, GenJnlPostLine, false, false);
                until TempInvoicePostBuffer2.Next() = 0;

            BufferAdvanceVATLines(PurchAdvLetterEntryCZZ, TempInvoicePostBuffer1, 0D, true);
            TempInvoicePostBuffer1.CalcSums(Amount);
            TempInvoicePostBuffer2.CalcSums("Amount (ACY)");
            if TempInvoicePostBuffer1.Amount = 0 then
                RestToDivide := TempInvoicePostBuffer2."Amount (ACY)"
            else begin
                PurchAdvLetterEntryCZZ2.Reset();
                PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
                PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
                PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
                PurchAdvLetterEntryCZZ2.CalcSums(Amount);
                RestToDivide := Round(TempInvoicePostBuffer2."Amount (ACY)" * (VATDocAmtToDate - TempInvoicePostBuffer1.Amount) / PurchAdvLetterEntryCZZ2.Amount);
            end;

            RestLines := 0;
            PurchAdvLetterEntryCZZ2.Reset();
            PurchAdvLetterEntryCZZ2.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
            PurchAdvLetterEntryCZZ2.SetRange(Cancelled, false);
            PurchAdvLetterEntryCZZ2.SetRange("Related Entry", PurchAdvLetterEntryCZZ."Entry No.");
            PurchAdvLetterEntryCZZ2.SetRange("Entry Type", PurchAdvLetterEntryCZZ2."Entry Type"::Usage);
            PurchAdvLetterEntryCZZ2.SetFilter("Posting Date", '>%1', ToDate);
            if PurchAdvLetterEntryCZZ2.FindSet() then begin
                repeat
                    PurchAdvLetterEntryCZZ3.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    PurchAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ3.SetRange("Related Entry", PurchAdvLetterEntryCZZ2."Entry No.");
                    PurchAdvLetterEntryCZZ3.SetRange("Entry Type", PurchAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    PurchAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    PurchAdvLetterEntryCZZ3.CalcSums(Amount);
                    RestLines += PurchAdvLetterEntryCZZ3.Amount;
                until PurchAdvLetterEntryCZZ2.Next() = 0;

                PurchAdvLetterEntryCZZ2.FindSet();
                repeat
                    PurchAdvLetterEntryCZZ3.SetRange("Purch. Adv. Letter No.", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.");
                    PurchAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    PurchAdvLetterEntryCZZ3.SetRange("Related Entry", PurchAdvLetterEntryCZZ2."Entry No.");
                    PurchAdvLetterEntryCZZ3.SetRange("Entry Type", PurchAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    PurchAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    if PurchAdvLetterEntryCZZ3.FindSet() then
                        repeat
                            AmountToPost := Round(RestToDivide * PurchAdvLetterEntryCZZ3.Amount / RestLines);
                            case PurchAdvLetterEntryCZZ3."VAT Calculation Type" of
                                PurchAdvLetterEntryCZZ3."VAT Calculation Type"::"Normal VAT":
                                    VATAmountToPost := Round(AmountToPost * PurchAdvLetterEntryCZZ3."VAT %" / (100 + PurchAdvLetterEntryCZZ3."VAT %"));
                                TempInvoicePostBuffer2."VAT Calculation Type"::"Reverse Charge VAT":
                                    VATAmountToPost := 0;
                            end;

                            VATPostingSetup.Get(PurchAdvLetterEntryCZZ3."VAT Bus. Posting Group", PurchAdvLetterEntryCZZ3."VAT Prod. Posting Group");
                            PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, -AmountToPost, -VATAmountToPost,
                                PurchAdvLetterEntryCZZ2."Entry No.", 0, DocumentNo, PurchAdvLetterEntryCZZ3."Posting Date", PostDescription, GenJnlPostLine, false, false);

                            RestToDivide := RestToDivide - AmountToPost;
                            RestLines := RestLines - PurchAdvLetterEntryCZZ3.Amount;
                        until PurchAdvLetterEntryCZZ3.Next() = 0;
                until PurchAdvLetterEntryCZZ2.Next() = 0;
            end;
        end;
    end;

    local procedure PostUnrealizedExchangeRate(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        Amount: Decimal; VATAmount: Decimal; RelatedEntryNo: Integer; RelatedDetEntryNo: Integer; DocumentNo: Code[20]; PostingDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Correction: Boolean; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        GetCurrency(PurchAdvLetterHeaderCZZ."Currency Code");

        if VATAmount <> 0 then begin
            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCodeSetup."Exchange Rate Adjmt.", PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            if VATAmount > 0 then begin
                CurrencyGlob.TestField("Unrealized Losses Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Unrealized Losses Acc.";
            end else begin
                CurrencyGlob.TestField("Unrealized Gains Acc.");
                GenJournalLine."Account No." := CurrencyGlob."Unrealized Gains Acc.";
            end;
            GenJournalLine.Validate(Amount, VATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(PurchAdvLetterHeaderCZZ, PurchAdvLetterEntryCZZ, DocumentNo, '', SourceCodeSetup."Exchange Rate Adjmt.", PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Purch. Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, -VATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        end;

        AdvEntryInit(Preview);
        if Correction then
            AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(RelatedEntryNo);
        AdvEntryInitDetVendLedgEntryNo(RelatedDetEntryNo);
        AdvEntryInitVAT(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", PostingDate,
            0, VATPostingSetup."VAT %", VATPostingSetup."VAT Identifier", VATPostingSetup."VAT Calculation Type",
            0, VATAmount, 0, Amount - VATAmount);
        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Adjustment", PurchAdvLetterEntryCZZ."Purch. Adv. Letter No.", PostingDate,
            0, Amount, '', 0, DocumentNo, GenJournalLine."External Document No.",
            PurchAdvLetterEntryCZZ."Global Dimension 1 Code", PurchAdvLetterEntryCZZ."Global Dimension 2 Code", PurchAdvLetterEntryCZZ."Dimension Set ID", Preview);
    end;

    local procedure ReverseUnrealizedExchangeRate(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        var VATPostingSetup: Record "VAT Posting Setup"; Coef: Decimal; RelatedEntryNo: Integer;
        DocumentNo: Code[20]; PostingDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AmountLCY: Decimal;
        VATAmountLCY: Decimal;
    begin
        if PurchAdvLetterEntryCZZ."Entry Type" <> PurchAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        GetRemAmtLCYVATAdjust(AmountLCY, VATAmountLCY, PurchAdvLetterEntryCZZ, PostingDate, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        if (AmountLCY = 0) and (VATAmountLCY = 0) then
            exit;

        AmountLCY := Round(AmountLCY * Coef);
        VATAmountLCY := Round(VATAmountLCY * Coef);

        PostUnrealizedExchangeRate(PurchAdvLetterEntryCZZ, PurchAdvLetterHeaderCZZ, VATPostingSetup, -AmountLCY, -VATAmountLCY,
            RelatedEntryNo, 0, DocumentNo, PostingDate, PostDescription, GenJnlPostLine, false, Preview);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAdvEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAdvEntry(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateStatus(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStatus(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentVAT(var PurchAdvLetterEntryCZZ: Record "Purch. Adv. Letter Entry CZZ"; PostingDate: Date; var Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
    end;
}
