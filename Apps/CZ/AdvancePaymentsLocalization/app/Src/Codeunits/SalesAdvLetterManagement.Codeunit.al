codeunit 31002 "SalesAdvLetterManagement CZZ"
{
    Permissions = tabledata "Cust. Ledger Entry" = m,
                  tabledata "Sales Invoice Line" = i;

    var
        SalesAdvLetterEntryCZZGlob: Record "Sales Adv. Letter Entry CZZ";
        TempSalesAdvLetterEntryCZZGlob: Record "Sales Adv. Letter Entry CZZ" temporary;
        CurrencyGlob: Record Currency;
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
#endif
        VATDocumentExistsErr: Label 'VAT Document already exists.';
        DateEmptyErr: Label 'Posting Date and VAT Date cannot be empty.';

    procedure AdvEntryInit(Preview: Boolean)
    begin
        if (SalesAdvLetterEntryCZZGlob."Entry No." = 0) and (not Preview) then begin
            SalesAdvLetterEntryCZZGlob.LockTable();
            if SalesAdvLetterEntryCZZGlob.FindLast() then;
        end;
        SalesAdvLetterEntryCZZGlob.Init();
        SalesAdvLetterEntryCZZGlob."Entry No." += 1;
    end;

    procedure AdvEntryInsert(EntryType: Enum "Advance Letter Entry Type CZZ"; AdvLetterNo: Code[20]; PostingDate: Date; Amt: Decimal; AmtLCY: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; DocumentNo: Code[20]; GlDim1Code: Code[20]; GlDim2Code: Code[20]; DimSetID: Integer; Preview: Boolean) InsertedEntryNo: Integer
    begin
        SalesAdvLetterEntryCZZGlob."Entry Type" := EntryType;
        SalesAdvLetterEntryCZZGlob."Sales Adv. Letter No." := AdvLetterNo;
        SalesAdvLetterEntryCZZGlob."Posting Date" := PostingDate;
        SalesAdvLetterEntryCZZGlob.Amount := Amt;
        SalesAdvLetterEntryCZZGlob."Amount (LCY)" := AmtLCY;
        SalesAdvLetterEntryCZZGlob."Currency Code" := CurrencyCode;
        SalesAdvLetterEntryCZZGlob."Currency Factor" := CurrencyFactor;
        SalesAdvLetterEntryCZZGlob."Document No." := DocumentNo;
        SalesAdvLetterEntryCZZGlob."User ID" := CopyStr(UserId(), 1, MaxStrLen(SalesAdvLetterEntryCZZGlob."User ID"));
        SalesAdvLetterEntryCZZGlob."Global Dimension 1 Code" := GlDim1Code;
        SalesAdvLetterEntryCZZGlob."Global Dimension 2 Code" := GlDim2Code;
        SalesAdvLetterEntryCZZGlob."Dimension Set ID" := DimSetID;
        SalesAdvLetterEntryCZZGlob."Customer No." := SalesAdvLetterEntryCZZGlob.GetCustomerNo();
        OnBeforeInsertAdvEntry(SalesAdvLetterEntryCZZGlob, Preview);
        if Preview then begin
            TempSalesAdvLetterEntryCZZGlob := SalesAdvLetterEntryCZZGlob;
            TempSalesAdvLetterEntryCZZGlob.Insert();
        end else begin
            SalesAdvLetterEntryCZZGlob.Insert();
            InsertedEntryNo := SalesAdvLetterEntryCZZGlob."Entry No.";
        end;
        OnAfterInsertAdvEntry(SalesAdvLetterEntryCZZGlob, Preview);
    end;

    procedure AdvEntryInitVAT(VATBusPostGr: Code[20]; VATProdPostGr: Code[20]; VATDate: Date; VATEntryNo: Integer; VATPer: Decimal; VATIdentifier: Code[20]; VATCalcType: Enum "Tax Calculation Type"; VATAmount: Decimal; VATAmountLCY: Decimal; VATBase: Decimal; VATBaseLCY: Decimal)
    begin
        SalesAdvLetterEntryCZZGlob."VAT Bus. Posting Group" := VATBusPostGr;
        SalesAdvLetterEntryCZZGlob."VAT Prod. Posting Group" := VATProdPostGr;
        SalesAdvLetterEntryCZZGlob."VAT Date" := VATDate;
        SalesAdvLetterEntryCZZGlob."VAT Entry No." := VATEntryNo;
        SalesAdvLetterEntryCZZGlob."VAT %" := VATPer;
        SalesAdvLetterEntryCZZGlob."VAT Identifier" := VATIdentifier;
        SalesAdvLetterEntryCZZGlob."VAT Calculation Type" := VATCalcType;
        SalesAdvLetterEntryCZZGlob."VAT Amount" := VATAmount;
        SalesAdvLetterEntryCZZGlob."VAT Amount (LCY)" := VATAmountLCY;
        SalesAdvLetterEntryCZZGlob."VAT Base Amount" := VATBase;
        SalesAdvLetterEntryCZZGlob."VAT Base Amount (LCY)" := VATBaseLCY;
    end;

    procedure AdvEntryInitCustLedgEntryNo(CustLedgEntryNo: Integer)
    begin
        SalesAdvLetterEntryCZZGlob."Cust. Ledger Entry No." := CustLedgEntryNo;
    end;

    procedure AdvEntryInitDetCustLedgEntryNo(DetCustLedgEntryNo: Integer)
    begin
        SalesAdvLetterEntryCZZGlob."Det. Cust. Ledger Entry No." := DetCustLedgEntryNo;
    end;

    procedure AdvEntryInitRelatedEntry(RelatedEntry: Integer)
    begin
        SalesAdvLetterEntryCZZGlob."Related Entry" := RelatedEntry;
    end;

    procedure AdvEntryInitCancel()
    begin
        SalesAdvLetterEntryCZZGlob.Cancelled := true;
    end;

    procedure GetTempAdvLetterEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
        if TempSalesAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                SalesAdvLetterEntryCZZ := TempSalesAdvLetterEntryCZZGlob;
                SalesAdvLetterEntryCZZ.Insert();
            until TempSalesAdvLetterEntryCZZGlob.Next() = 0;
            TempSalesAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UpdateStatus(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; DocStatus: Enum "Advance Letter Doc. Status CZZ")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
    begin
        OnBeforeUpdateStatus(SalesAdvLetterHeaderCZZ, DocStatus);
        case DocStatus of
            DocStatus::New:
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                        SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::New;
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Pay":
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount <> 0 then begin
                        SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::"To Pay";
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::"To Use":
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry", SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                        SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::"To Use";
                        SalesAdvLetterHeaderCZZ.Modify();
                    end;
                end;
            DocStatus::Closed:
                begin
                    SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
                    SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry", SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Close);
                    SalesAdvLetterEntryCZZ.CalcSums(Amount);
                    if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                        SalesAdvLetterEntryCZZ.SetFilter("Entry Type", '%1|%2|%3|%4|%5|%6', SalesAdvLetterEntryCZZ."Entry Type"::Payment, SalesAdvLetterEntryCZZ."Entry Type"::Usage, SalesAdvLetterEntryCZZ."Entry Type"::Close,
                            SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Close");
                        SalesAdvLetterEntryCZZ.CalcSums(Amount);
                        if SalesAdvLetterEntryCZZ.Amount = 0 then begin
                            SalesAdvLetterHeaderCZZ.Status := SalesAdvLetterHeaderCZZ.Status::Closed;
                            SalesAdvLetterHeaderCZZ.Modify();
                        end;
                    end;
                end;
            else
                OnUpdateStatus(SalesAdvLetterHeaderCZZ, DocStatus);
        end;
    end;

    procedure CancelInitEntry(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; EntryDate: Date; Cancel: Boolean)
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        ToPayLCY: Decimal;
    begin
        SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
        if SalesAdvLetterHeaderCZZ."To Pay" = 0 then
            exit;

        if Cancel then begin
            SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
            SalesAdvLetterHeaderCZZ.TestField("To Pay", SalesAdvLetterHeaderCZZ."Amount Including VAT");
        end;

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
        SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"Initial Entry");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.FindFirst() then begin
            if EntryDate = 0D then
                EntryDate := SalesAdvLetterEntryCZZ."Posting Date";

            if SalesAdvLetterEntryCZZ."Currency Factor" = 0 then
                ToPayLCY := SalesAdvLetterHeaderCZZ."To Pay"
            else
                ToPayLCY := Round(SalesAdvLetterHeaderCZZ."To Pay" / SalesAdvLetterEntryCZZ."Currency Factor");

            AdvEntryInit(false);
            if Cancel then
                AdvEntryInitCancel();
            AdvEntryInsert("Advance Letter Entry Type CZZ"::"Initial Entry", SalesAdvLetterHeaderCZZ."No.", EntryDate,
                -SalesAdvLetterHeaderCZZ."To Pay", -ToPayLCY,
                SalesAdvLetterHeaderCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor", SalesAdvLetterHeaderCZZ."No.",
                SalesAdvLetterHeaderCZZ."Shortcut Dimension 1 Code", SalesAdvLetterHeaderCZZ."Shortcut Dimension 2 Code", SalesAdvLetterHeaderCZZ."Dimension Set ID", false);

            if Cancel then begin
                SalesAdvLetterEntryCZZ.Cancelled := true;
                SalesAdvLetterEntryCZZ.Modify();
            end;
        end;
    end;

    procedure LinkAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        TempAdvanceLetterLinkBufferCZZ: Record "Advance Letter Link Buffer CZZ" temporary;
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvanceLetterLinkCZZ: Page "Advance Letter Link CZZ";
        InsertedEntryNo: Integer;
    begin
        AdvanceLetterLinkCZZ.SetCVEntry(CustLedgerEntry.RecordId);
        AdvanceLetterLinkCZZ.LookupMode(true);
        if AdvanceLetterLinkCZZ.RunModal() = Action::LookupOK then begin
            AdvanceLetterLinkCZZ.GetLetterLink(TempAdvanceLetterLinkBufferCZZ);
            TempAdvanceLetterLinkBufferCZZ.SetFilter(Amount, '>0');
            if TempAdvanceLetterLinkBufferCZZ.FindSet() then begin
                repeat
                    InsertedEntryNo := PostAdvancePayment(CustLedgerEntry, TempAdvanceLetterLinkBufferCZZ."Advance Letter No.", TempAdvanceLetterLinkBufferCZZ.Amount, GenJnlPostLine);
                    SalesAdvLetterEntryCZZ.Get(InsertedEntryNo);
                    TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
                    TempSalesAdvLetterEntryCZZ.Insert();
                until TempAdvanceLetterLinkBufferCZZ.Next() = 0;

                if TempSalesAdvLetterEntryCZZ.FindSet() then
                    repeat
                        SalesAdvLetterHeaderCZZ.Get(TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                        if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then
                            PostAdvancePaymentVAT(TempSalesAdvLetterEntryCZZ, 0D);
                    until TempSalesAdvLetterEntryCZZ.Next() = 0;
            end;
        end;
    end;

    procedure PostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; AdvanceLetterNo: Code[20]; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line") InsertedEntryNo: Integer
    var
        PostedGenJournalLine: Record "Gen. Journal Line";
    begin
        PostedGenJournalLine."Advance Letter No. CZZ" := AdvanceLetterNo;
        InsertedEntryNo := PostAdvancePayment(CustLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine);
    end;

    procedure PostAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry"; PostedGenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line") InsertedEntryNo: Integer
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        ApplId: Code[50];
        Amount: Decimal;
        AmountLCY: Decimal;
        IsHandled: Boolean;
        RemainingAmountExceededErr: Label 'The amount cannot be higher than remaining amount on ledger entry.';
        ToPayAmountExceededErr: Label 'The amount cannot be higher than to pay on advance letter.';
    begin
        OnBeforePostAdvancePayment(CustLedgerEntry, PostedGenJournalLine, LinkAmount, GenJnlPostLine, IsHandled);
        if IsHandled then
            exit;

        CustLedgerEntry.TestField("Advance Letter No. CZZ", '');
        SalesAdvLetterHeaderCZZ.Get(PostedGenJournalLine."Advance Letter No. CZZ");
        SalesAdvLetterHeaderCZZ.CheckSalesAdvanceLetterPostRestrictions();
        SalesAdvLetterHeaderCZZ.TestField("Currency Code", CustLedgerEntry."Currency Code");
        SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", CustLedgerEntry."Customer No.");
        if LinkAmount = 0 then begin
            CustLedgerEntry.CalcFields("Remaining Amount", "Remaining Amt. (LCY)");
            Amount := CustLedgerEntry."Remaining Amount";
            AmountLCY := CustLedgerEntry."Remaining Amt. (LCY)";
        end else begin
            CustLedgerEntry.CalcFields("Remaining Amount");
            if LinkAmount > -CustLedgerEntry."Remaining Amount" then
                Error(RemainingAmountExceededErr);

            Amount := -LinkAmount;
            AmountLCY := Round(Amount / CustLedgerEntry."Original Currency Factor");
        end;
        SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
        if -Amount > SalesAdvLetterHeaderCZZ."To Pay" then
            Error(ToPayAmountExceededErr);

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(CustLedgerEntry."Currency Code", CustLedgerEntry."Original Currency Factor");
        GenJournalLine.Amount := -Amount;
        GenJournalLine."Amount (LCY)" := -AmountLCY;

        ApplId := CopyStr(CustLedgerEntry."Document No." + Format(CustLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        CustLedgerEntry.CalcFields("Remaining Amount");
        CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
        CustLedgerEntry."Applies-to ID" := ApplId;
        CustLedgerEntry."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry);

        GenJournalLine."Applies-to ID" := ApplId;
        OnBeforePostPaymentRepos(GenJournalLine, SalesAdvLetterHeaderCZZ, PostedGenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnAfterPostPaymentRepos(GenJournalLine, SalesAdvLetterHeaderCZZ, PostedGenJournalLine);

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterHeaderCZZ."No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(CustLedgerEntry."Currency Code", CustLedgerEntry."Original Currency Factor");
        GenJournalLine.Amount := Amount;
        GenJournalLine."Amount (LCY)" := AmountLCY;
        OnBeforePostPayment(GenJournalLine, SalesAdvLetterHeaderCZZ, PostedGenJournalLine);
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        OnAfterPostPayment(GenJournalLine, SalesAdvLetterHeaderCZZ, PostedGenJournalLine);

        CustLedgerEntry2.FindLast();
        AdvEntryInit(false);
        AdvEntryInitCustLedgEntryNo(CustLedgerEntry2."Entry No.");
        InsertedEntryNo := AdvEntryInsert("Advance Letter Entry Type CZZ"::Payment, SalesAdvLetterHeaderCZZ."No.", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

        UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::"To Use")
    end;

    procedure GetAdvanceGLAccount(var GenJournalLine: Record "Gen. Journal Line"): Code[20]
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
    begin
        SalesAdvLetterHeaderCZZ.Get(GenJournalLine."Adv. Letter No. (Entry) CZZ");
        SalesAdvLetterHeaderCZZ.TestField("Advance Letter Code");
        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter G/L Account");
        exit(AdvanceLetterTemplateCZZ."Advance Letter G/L Account");
    end;

    procedure PostAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        DocumentNo: Code[20];
        AmountToPost: Decimal;
        Coeff: Decimal;
        IsHandled: Boolean;
        SettingErr: Label '%1 cannot be empty in table %2, for %3, %4. You have to fill field and post VAT document again.', Comment = '%1 = Field Caption, %2 = Table Caption, %3 = VAT Bus. Posting Group, %4 = "VAT Prod. Posting Group"';
    begin
        OnBeforePostPaymentVAT(SalesAdvLetterEntryCZZ, PostingDate, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
        if SalesAdvLetterHeaderCZZ."Amount Including VAT" = 0 then
            exit;

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if not SalesAdvLetterEntryCZZ2.IsEmpty() then
            Error(VATDocumentExistsErr);

        if PostingDate = 0D then
            PostingDate := SalesAdvLetterEntryCZZ."Posting Date";

        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
        AdvanceLetterTemplateCZZ.TestField("Advance Letter Invoice Nos.");
        DocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Invoice Nos.", PostingDate, true);

        GetCurrency(SalesAdvLetterEntryCZZ."Currency Code");

        Coeff := SalesAdvLetterEntryCZZ.Amount / SalesAdvLetterHeaderCZZ."Amount Including VAT";

        BufferAdvanceLines(SalesAdvLetterHeaderCZZ."No.", TempAdvancePostingBufferCZZ);
        TempAdvancePostingBufferCZZ.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ.FindSet() then
            repeat
                VATPostingSetup.Get(TempAdvancePostingBufferCZZ."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group");
                if VATPostingSetup."Sales Adv. Letter Account CZZ" = '' then
                    Error(SettingErr, VATPostingSetup.FieldCaption("Sales Adv. Letter Account CZZ"), VATPostingSetup.TableCaption, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
                if VATPostingSetup."Sales Adv. Letter VAT Acc. CZZ" = '' then
                    Error(SettingErr, VATPostingSetup.FieldCaption("Sales Adv. Letter VAT Acc. CZZ"), VATPostingSetup.TableCaption, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");

                AmountToPost := Round(TempAdvancePostingBufferCZZ.Amount * Coeff, CurrencyGlob."Amount Rounding Precision");

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, CustLedgerEntry."Source Code", SalesAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
                GenJournalLine."VAT Calculation Type" := TempAdvancePostingBufferCZZ."VAT Calculation Type";
                GenJournalLine."VAT Bus. Posting Group" := TempAdvancePostingBufferCZZ."VAT Bus. Posting Group";
                GenJournalLine.validate("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ."VAT Prod. Posting Group");
                GenJournalLine.Validate(Amount, AmountToPost);
                if GenJournalLine."Currency Code" <> '' then
                    CalculateAmountLCY(GenJournalLine);
                GenJournalLine."Bill-to/Pay-to No." := SalesAdvLetterHeaderCZZ."Bill-to Customer No.";
                GenJournalLine."Country/Region Code" := SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code";
                GenJournalLine."VAT Registration No." := SalesAdvLetterHeaderCZZ."VAT Registration No.";
                GenJournalLine."Registration No. CZL" := SalesAdvLetterHeaderCZZ."Registration No.";
                GenJournalLine."Tax Registration No. CZL" := SalesAdvLetterHeaderCZZ."Tax Registration No.";
                OnPostAdvancePaymentVATOnBeforeGenJnlPostLine(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, GenJournalLine);

                BindSubscription(VATPostingSetupHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                AdvEntryInit(false);
                AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Entry No.");
                AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Reporting Date",
                    GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                    GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", SalesAdvLetterHeaderCZZ."No.", GenJournalLine."Posting Date",
                    GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                    GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
                    GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, CustLedgerEntry."Source Code", SalesAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
                GenJournalLine.Validate(Amount, -AmountToPost);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
            until TempAdvancePostingBufferCZZ.Next() = 0;
    end;

    procedure PostAndSendAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
    begin
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        PostAdvancePaymentVAT(SalesAdvLetterEntryCZZ, 0D);

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ2.EmailRecords(true);
    end;

    local procedure CalculateAmountLCY(var GenJournalLine: Record "Gen. Journal Line")
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        if (GenJournalLine."Currency Code" = '') or (GenJournalLine."Amount (LCY)" = 0) then
            exit;

        GenJournalLine."Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(GenJournalLine."Posting Date", GenJournalLine."Currency Code", GenJournalLine.Amount, GenJournalLine."Currency Factor"));
        GenJournalLine."VAT Base Amount (LCY)" := Round(CurrencyExchangeRate.ExchangeAmtFCYToLCY(GenJournalLine."Posting Date", GenJournalLine."Currency Code", GenJournalLine."VAT Base Amount", GenJournalLine."Currency Factor"));
        GenJournalLine."VAT Amount (LCY)" := GenJournalLine."Amount (LCY)" - GenJournalLine."VAT Base Amount (LCY)";
    end;

    local procedure BufferAdvanceLines(AdvanceNo: Code[20]; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ")
    var
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        AdvancePostingBufferCZZ.Reset();
        AdvancePostingBufferCZZ.DeleteAll();

        SalesAdvLetterLineCZZ.SetRange("Document No.", AdvanceNo);
        SalesAdvLetterLineCZZ.SetFilter(Amount, '<>0');
        if SalesAdvLetterLineCZZ.FindSet() then
            repeat
                AdvancePostingBufferCZZ.Init();
                AdvancePostingBufferCZZ."VAT Bus. Posting Group" := SalesAdvLetterLineCZZ."VAT Bus. Posting Group";
                AdvancePostingBufferCZZ."VAT Prod. Posting Group" := SalesAdvLetterLineCZZ."VAT Prod. Posting Group";
                if AdvancePostingBufferCZZ.Find() then begin
                    AdvancePostingBufferCZZ.Amount += SalesAdvLetterLineCZZ."Amount Including VAT";
                    AdvancePostingBufferCZZ."VAT Base Amount" += SalesAdvLetterLineCZZ.Amount;
                    AdvancePostingBufferCZZ."VAT Amount" += SalesAdvLetterLineCZZ."VAT Amount";
                    AdvancePostingBufferCZZ.Modify();
                end else begin
                    AdvancePostingBufferCZZ."VAT Calculation Type" := SalesAdvLetterLineCZZ."VAT Calculation Type";
                    AdvancePostingBufferCZZ."VAT %" := SalesAdvLetterLineCZZ."VAT %";
                    AdvancePostingBufferCZZ.Amount := SalesAdvLetterLineCZZ."Amount Including VAT";
                    AdvancePostingBufferCZZ."VAT Base Amount" := SalesAdvLetterLineCZZ.Amount;
                    AdvancePostingBufferCZZ."VAT Amount" := SalesAdvLetterLineCZZ."VAT Amount";
                    AdvancePostingBufferCZZ.Insert();
                end;
            until SalesAdvLetterLineCZZ.Next() = 0;
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

    procedure LinkAdvanceLetter(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; BillToCustomerNo: Code[20]; PostingDate: Date; CurrencyCode: Code[10])
    var
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        AdvanceLetterApplEditPageCZZ: Page "Advance Letter Appl. Edit CZZ";
        ModifyRecord: Boolean;
    begin
        AdvanceLetterApplEditPageCZZ.InitializeSales(AdvLetterUsageDocTypeCZZ, DocumentNo, BillToCustomerNo, PostingDate, CurrencyCode);
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
                            ModifyRecord := true;
                        end;
                        OnLinkAdvanceLetterOnBeforeModifyAdvanceLetterApplication(AdvanceLetterApplicationCZZ, TempAdvanceLetterApplicationCZZ, ModifyRecord);
                        if ModifyRecord then
                            AdvanceLetterApplicationCZZ.Modify();
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
                    OnLinkAdvanceLetterOnBeforeInsertAdvanceLetterApplication(AdvanceLetterApplicationCZZ, TempAdvanceLetterApplicationCZZ);
                    AdvanceLetterApplicationCZZ.Insert();
                until TempAdvanceLetterApplicationCZZ.Next() = 0;
        end;
    end;

    procedure UnlinkAdvancePayment(var CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        SalesAdvLetterEntryCZZ1: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
    begin
        CustLedgerEntry.TestField("Advance Letter No. CZZ");

        SalesAdvLetterEntryCZZ1.SetRange("Sales Adv. Letter No.", CustLedgerEntry."Advance Letter No. CZZ");
        SalesAdvLetterEntryCZZ1.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ1.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        if SalesAdvLetterEntryCZZ1.FindSet() then
            repeat
                SalesAdvLetterEntryCZZ2 := SalesAdvLetterEntryCZZ1;
                UnlinkAdvancePayment(SalesAdvLetterEntryCZZ2);
            until SalesAdvLetterEntryCZZ1.Next() = 0;
    end;

    procedure UnlinkAdvancePayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntryPay: Record "Cust. Ledger Entry";
        CustLedgerEntryAdv: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        ApplId: Code[50];
        UsedOnDocument: Text;
        UnlinkIsNotPossibleErr: Label 'Unlink is not possible, because %1 entry exists.', Comment = '%1 = Entry type';
        UsedOnDocumentQst: Label 'Advance is used on document(s) %1.\Continue?', Comment = '%1 = Advance No. list';
    begin
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if SalesAdvLetterEntryCZZ2.FindFirst() then
            Error(UnlinkIsNotPossibleErr, SalesAdvLetterEntryCZZ2."Entry Type");

        AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
        AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                if UsedOnDocument <> '' then
                    UsedOnDocument := UsedOnDocument + ', ';
                UsedOnDocument := AdvanceLetterApplicationCZZ."Document No.";
            until AdvanceLetterApplicationCZZ.Next() = 0;
        if UsedOnDocument <> '' then
            if not Confirm(UsedOnDocumentQst, false, UsedOnDocument) then
                Error('');

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        GetCurrency(SalesAdvLetterHeaderCZZ."Currency Code");

        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if SalesAdvLetterEntryCZZ2.FindSet() then begin
            repeat
                VATPostingSetup.Get(SalesAdvLetterEntryCZZ2."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                VATPostingSetup.TestField("Sales Adv. Letter Account CZZ");
                VATPostingSetup.TestField("Sales Adv. Letter VAT Acc. CZZ");

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ2, SalesAdvLetterEntryCZZ2."Document No.", '', '', GenJournalLine);
                GenJournalLine.Validate("Posting Date", SalesAdvLetterEntryCZZ2."Posting Date");
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ2."Currency Code", SalesAdvLetterEntryCZZ2."Currency Factor");
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
                GenJournalLine."VAT Calculation Type" := SalesAdvLetterEntryCZZ2."VAT Calculation Type";
                GenJournalLine."VAT Bus. Posting Group" := SalesAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                GenJournalLine.Validate("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                GenJournalLine.Validate(Amount, -SalesAdvLetterEntryCZZ2.Amount);
                GenJournalLine."VAT Amount" := -SalesAdvLetterEntryCZZ2."VAT Amount";
                GenJournalLine."VAT Base Amount" := -SalesAdvLetterEntryCZZ2."VAT Base Amount";
                GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                    CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                GenJournalLine."Amount (LCY)" := -SalesAdvLetterEntryCZZ2."Amount (LCY)";
                GenJournalLine."VAT Amount (LCY)" := -SalesAdvLetterEntryCZZ2."VAT Amount (LCY)";
                GenJournalLine."VAT Base Amount (LCY)" := -SalesAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                BindSubscription(VATPostingSetupHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                AdvEntryInit(false);
                AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Entry No.");
                AdvEntryInitCancel();
                AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Reporting Date",
                    GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                    GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                AdvEntryInsert(SalesAdvLetterEntryCZZ2."Entry Type", SalesAdvLetterEntryCZZ2."Sales Adv. Letter No.", GenJournalLine."Posting Date",
                    GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                    GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
                    GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ2, SalesAdvLetterEntryCZZ2."Document No.", '', '', GenJournalLine);
                GenJournalLine.Validate("Posting Date", SalesAdvLetterEntryCZZ2."Posting Date");
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ2."Currency Code", SalesAdvLetterEntryCZZ2."Currency Factor");
                GenJournalLine.Amount := SalesAdvLetterEntryCZZ2.Amount;
                GenJournalLine."Amount (LCY)" := SalesAdvLetterEntryCZZ2."Amount (LCY)";
                GenJnlPostLine.RunWithCheck(GenJournalLine);
            until SalesAdvLetterEntryCZZ2.Next() = 0;
            SalesAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
        end;

        CustLedgerEntryAdv.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        CustLedgerEntryPay := CustLedgerEntryAdv;
#pragma warning disable AA0181
        CustLedgerEntryPay.Next(-1);
#pragma warning restore AA0181
        UnapplyCustLedgEntry(CustLedgerEntryPay, GenJnlPostLine);

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntryAdv, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -SalesAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";
        ApplId := CopyStr(CustLedgerEntryAdv."Document No." + Format(CustLedgerEntryAdv."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        CustLedgerEntryAdv.Prepayment := false;
        CustLedgerEntryAdv."Advance Letter No. CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
        CustLedgerEntryAdv.CalcFields("Remaining Amount");
        CustLedgerEntryAdv."Amount to Apply" := CustLedgerEntryAdv."Remaining Amount";
        CustLedgerEntryAdv."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntryAdv);
        GenJournalLine."Applies-to ID" := ApplId;
        GenJnlPostLine.RunWithCheck(GenJournalLine);

        CustLedgerEntry.FindLast();

        AdvEntryInit(false);
        AdvEntryInitCustLedgEntryNo(CustLedgerEntry."Entry No.");
        AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Entry No.");
        AdvEntryInsert(SalesAdvLetterEntryCZZ."Entry Type", GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntryAdv, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := SalesAdvLetterEntryCZZ.Amount;
        GenJournalLine."Amount (LCY)" := SalesAdvLetterEntryCZZ."Amount (LCY)";
        ApplId := CopyStr(CustLedgerEntryPay."Document No." + Format(CustLedgerEntryPay."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
        CustLedgerEntryPay.CalcFields("Remaining Amount");
        CustLedgerEntryPay."Amount to Apply" := CustLedgerEntryPay."Remaining Amount";
        CustLedgerEntryPay."Applies-to ID" := ApplId;
        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntryPay);
        GenJournalLine."Applies-to ID" := ApplId;
        GenJnlPostLine.RunWithCheck(GenJournalLine);
        UnbindSubscription(GenJnlCheckLnHandlerCZZ);

        SalesAdvLetterEntryCZZ.Cancelled := true;
        SalesAdvLetterEntryCZZ.Modify();

        UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::"To Pay");
    end;

    procedure PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary;
        TempSalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ" temporary;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        AdvanceLetterTypeCZZ: Enum "Advance Letter Type CZZ";
        AmountToUse, UseAmount, UseAmountLCY : Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, DocumentNo, SalesInvoiceHeader, CustLedgerEntry, GenJnlPostLine, Preview, IsHandled);
        if IsHandled then
            exit;

        if CustLedgerEntry."Remaining Amount" = 0 then
            CustLedgerEntry.CalcFields("Remaining Amount");

        if CustLedgerEntry."Remaining Amount" = 0 then
            exit;

        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.IsEmpty() then
            exit;

        AdvanceLetterApplicationCZZ.FindSet();
        repeat
            SalesAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
            SalesAdvLetterHeaderCZZ.TestField("Currency Code", SalesInvoiceHeader."Currency Code");
            SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", SalesInvoiceHeader."Bill-to Customer No.");

            SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", AdvanceLetterApplicationCZZ."Advance Letter No.");
            SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
            SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
            SalesAdvLetterEntryCZZ.SetFilter("Posting Date", '..%1', SalesInvoiceHeader."Posting Date");
            OnPostAdvancePaymentUsageOnBeforeLoopSalesAdvLetterEntry(AdvanceLetterApplicationCZZ, SalesAdvLetterEntryCZZ);
            if SalesAdvLetterEntryCZZ.FindSet() then
                repeat
                    TempSalesAdvLetterEntryCZZ := SalesAdvLetterEntryCZZ;
                    TempSalesAdvLetterEntryCZZ.Amount := GetRemAmtSalAdvPayment(SalesAdvLetterEntryCZZ, 0D);
                    if TempSalesAdvLetterEntryCZZ.Amount <> 0 then
                        TempSalesAdvLetterEntryCZZ.Insert();
                until SalesAdvLetterEntryCZZ.Next() = 0;
            TempAdvanceLetterApplicationCZZ.Init();
            TempAdvanceLetterApplicationCZZ."Advance Letter No." := AdvanceLetterApplicationCZZ."Advance Letter No.";
            TempAdvanceLetterApplicationCZZ.Amount := AdvanceLetterApplicationCZZ.Amount;
            TempAdvanceLetterApplicationCZZ.Insert();
        until AdvanceLetterApplicationCZZ.Next() = 0;

        AmountToUse := CustLedgerEntry."Remaining Amount";
        TempSalesAdvLetterEntryCZZ.Reset();
        TempSalesAdvLetterEntryCZZ.SetCurrentKey("Posting Date");
        if TempSalesAdvLetterEntryCZZ.FindSet() then
            repeat
                TempAdvanceLetterApplicationCZZ.Get(0, TempSalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                if TempAdvanceLetterApplicationCZZ.Amount < TempSalesAdvLetterEntryCZZ.Amount then
                    TempSalesAdvLetterEntryCZZ.Amount := TempAdvanceLetterApplicationCZZ.Amount;

                if AmountToUse > TempSalesAdvLetterEntryCZZ.Amount then
                    UseAmount := TempSalesAdvLetterEntryCZZ.Amount
                else
                    UseAmount := AmountToUse;

                if UseAmount <> 0 then begin
                    SalesAdvLetterEntryCZZ.Get(TempSalesAdvLetterEntryCZZ."Entry No.");
                    UseAmountLCY := Round(GetRemAmtLCYSalAdvPayment(SalesAdvLetterEntryCZZ, 0D) * UseAmount / GetRemAmtSalAdvPayment(SalesAdvLetterEntryCZZ, 0D));
                    ReverseAdvancePayment(SalesAdvLetterEntryCZZ, UseAmount, UseAmountLCY, SalesInvoiceHeader."No.", CustLedgerEntry, GenJnlPostLine, Preview);
                    AmountToUse -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Amount -= UseAmount;
                    TempAdvanceLetterApplicationCZZ.Modify();

                    if not Preview then
                        if AdvanceLetterApplicationCZZ.Get(AdvanceLetterTypeCZZ::Sales, SalesAdvLetterEntryCZZ."Sales Adv. Letter No.", AdvLetterUsageDocTypeCZZ, DocumentNo) then
                            if AdvanceLetterApplicationCZZ.Amount <= UseAmount then
                                AdvanceLetterApplicationCZZ.Delete(true)
                            else begin
                                AdvanceLetterApplicationCZZ.Amount -= UseAmount;
                                AdvanceLetterApplicationCZZ.Modify();
                            end;
                end;
            until (TempSalesAdvLetterEntryCZZ.Next() = 0) or (AmountToUse = 0);

        OnAfterPostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, DocumentNo, SalesInvoiceHeader, CustLedgerEntry, GenJnlPostLine, Preview);
    end;

    procedure CorrectDocumentAfterPaymentUsage(DocumentNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        FirstVATPostingSetup: Record "VAT Posting Setup";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerPostingGroup: Record "Customer Posting Group";
        GenJournalLine: Record "Gen. Journal Line";
        VATBaseCorr, VATAmountCorr : Decimal;
        CorrectLineDescriptionTxt: Label 'Advance VAT Correction';
        IsHandled: Boolean;
    begin
        OnBeforeCorrectDocumentAfterPaymentUsage(DocumentNo, CustLedgerEntry, GenJnlPostLine, IsHandled);
        if IsHandled then
            exit;

        if DocumentNo = '' then
            exit;

        SalesInvoiceHeader.SetAutoCalcFields("Amount Including VAT");
        SalesInvoiceHeader.Get(DocumentNo);
        if SalesInvoiceHeader."Currency Code" <> '' then
            exit;

        SalesAdvLetterEntryCZZ.SetRange("Document No.", DocumentNo);
        SalesAdvLetterEntryCZZ.SetRange(SalesAdvLetterEntryCZZ."Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if SalesAdvLetterEntryCZZ.IsEmpty() then
            exit;

        SalesAdvLetterEntryCZZ.CalcSums(Amount);

        if SalesAdvLetterEntryCZZ.Amount <> SalesInvoiceHeader."Amount Including VAT" then
            exit;

        VATEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        VATEntry.SetRange("Posting Date", SalesInvoiceHeader."Posting Date");
        // check whether multiple VAT rates is used
        VATEntry.FindFirst();
        FirstVATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
        VATEntry.SetFilter("VAT Prod. Posting Group", '<>%1', VATEntry."VAT Prod. Posting Group");
        if VATEntry.FindSet() then
            repeat
                VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
                // correction should applied only when one VAT rate is used
                if FirstVATPostingSetup."VAT %" <> VATPostingSetup."VAT %" then
                    exit;
            until VATEntry.Next() = 0;
        VATEntry.SetRange("VAT Prod. Posting Group");
        VATEntry.CalcSums(Base, Amount);
        VATBaseCorr := VATEntry.Base;
        VATAmountCorr := VATEntry.Amount;
        if (VATBaseCorr <> -VATAmountCorr) or (VATBaseCorr = 0) then
            exit;

#pragma warning disable AA0210
        VATEntry.SetFilter(Amount, '<>0');
#pragma warning restore AA0210
        VATEntry.FindFirst();
        VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");

        CustomerPostingGroup.Get(SalesInvoiceHeader."Customer Posting Group");
        CustomerPostingGroup.TestField("Invoice Rounding Account");

        SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesInvoiceLine.FindLast();

        SalesInvoiceLine.Init();
        SalesInvoiceLine."Line No." += 10000;
        SalesInvoiceLine."Posting Date" := SalesInvoiceHeader."Posting Date";
        SalesInvoiceLine."Sell-to Customer No." := SalesInvoiceHeader."Sell-to Customer No.";
        SalesInvoiceLine."Bill-to Customer No." := SalesInvoiceHeader."Bill-to Customer No.";
        SalesInvoiceLine."Gen. Bus. Posting Group" := SalesInvoiceHeader."Gen. Bus. Posting Group";
        SalesInvoiceLine."Responsibility Center" := SalesInvoiceHeader."Responsibility Center";
        SalesInvoiceLine.Type := SalesInvoiceLine.Type::"G/L Account";
        SalesInvoiceLine."No." := CustomerPostingGroup."Invoice Rounding Account";
        SalesInvoiceLine.Description := CorrectLineDescriptionTxt;
        SalesInvoiceLine."VAT Bus. Posting Group" := VATEntry."VAT Bus. Posting Group";
        SalesInvoiceLine."VAT Prod. Posting Group" := VATEntry."VAT Prod. Posting Group";
        SalesInvoiceLine."VAT %" := VATPostingSetup."VAT %";
        SalesInvoiceLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
        SalesInvoiceLine."VAT Identifier" := VATPostingSetup."VAT Identifier";
        SalesInvoiceLine."VAT Clause Code" := VATPostingSetup."VAT Clause Code";
        SalesInvoiceLine."Tax Area Code" := VATEntry."Tax Area Code";
        SalesInvoiceLine."Tax Liable" := VATEntry."Tax Liable";
        SalesInvoiceLine.Amount := VATBaseCorr;
        SalesInvoiceLine."Amount Including VAT" := 0;
        SalesInvoiceLine."VAT Base Amount" := VATBaseCorr;
        if SalesInvoiceHeader."Prices Including VAT" then
            SalesInvoiceLine."Line Amount" := 0
        else
            SalesInvoiceLine."Line Amount" := VATBaseCorr;
        SalesInvoiceLine."VAT Difference" := VATAmountCorr - Round(SalesInvoiceLine.Amount * SalesInvoiceLine."VAT %" / (100 + SalesInvoiceLine."VAT %"));
        SalesInvoiceLine.Insert();

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::Invoice);
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
        GenJournalLine."Account No." := SalesInvoiceLine."No.";
        GenJournalLine.Description := CorrectLineDescriptionTxt;
        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
        GenJournalLine."VAT Calculation Type" := SalesInvoiceLine."VAT Calculation Type";
        GenJournalLine."VAT Bus. Posting Group" := SalesInvoiceLine."VAT Bus. Posting Group";
        GenJournalLine.validate("VAT Prod. Posting Group", SalesInvoiceLine."VAT Prod. Posting Group");
        GenJournalLine."Bill-to/Pay-to No." := SalesInvoiceHeader."Bill-to Customer No.";
        GenJournalLine."Country/Region Code" := SalesInvoiceHeader."Bill-to Country/Region Code";
        GenJournalLine."VAT Registration No." := SalesInvoiceHeader."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := SalesInvoiceHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := SalesInvoiceHeader."Tax Registration No. CZL";
        GenJournalLine.Amount := 0;
        GenJournalLine."VAT Amount" := -VATAmountCorr;
        GenJournalLine."VAT Base Amount" := -VATBaseCorr;
        GenJournalLine."VAT Difference" := SalesInvoiceLine."VAT Difference";

        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure ReverseAdvancePayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; ReverseAmount: Decimal; ReverseAmountLCY: Decimal; DocumentNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        RemainingAmount: Decimal;
        RemainingAmountLCY: Decimal;
        ApplId: Code[50];
        ReverseErr: Label 'Reverse amount %1 is not posible on entry %2.', Comment = '%1 = Reverse Amount, %2 = Sales Advance Entry No.';
    begin
        RemainingAmount := GetRemAmtSalAdvPayment(SalesAdvLetterEntryCZZ, 0D);
        RemainingAmountLCY := GetRemAmtLCYSalAdvPayment(SalesAdvLetterEntryCZZ, 0D);

        if ReverseAmount <> 0 then begin
            if ReverseAmount > RemainingAmount then
                Error(ReverseErr, ReverseAmount, SalesAdvLetterEntryCZZ."Entry No.");
        end else begin
            ReverseAmount := RemainingAmount;
            ReverseAmountLCY := RemainingAmountLCY;
        end;

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine.Correction := true;
        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := -ReverseAmount;
        GenJournalLine."Amount (LCY)" := -ReverseAmountLCY;

        if not Preview then begin
            ApplId := CopyStr(CustLedgerEntry."Document No." + Format(CustLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
            CustLedgerEntry.CalcFields("Remaining Amount");
            CustLedgerEntry."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
            CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
            CustLedgerEntry."Applies-to ID" := ApplId;
            Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry);
            GenJournalLine."Applies-to ID" := ApplId;

            OnBeforePostReversePaymentRepos(GenJournalLine, SalesAdvLetterHeaderCZZ);
            BindSubscription(GenJnlCheckLnHandlerCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            OnAfterPostReversePaymentRepos(GenJournalLine, SalesAdvLetterHeaderCZZ);
        end;

        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
        GenJournalLine."Use Advance G/L Account CZZ" := true;
        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
        GenJournalLine.Amount := ReverseAmount;
        GenJournalLine."Amount (LCY)" := ReverseAmountLCY;

        CustLedgerEntry2.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
        if not Preview then begin
            ApplId := CopyStr(CustLedgerEntry2."Document No." + Format(CustLedgerEntry2."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
            CustLedgerEntry2.Prepayment := false;
            CustLedgerEntry2."Advance Letter No. CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
            CustLedgerEntry2.Modify();
            CustLedgerEntry2.CalcFields("Remaining Amount");
            CustLedgerEntry2."Amount to Apply" := CustLedgerEntry2."Remaining Amount";
            CustLedgerEntry2."Applies-to ID" := ApplId;
            Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry2);
            GenJournalLine."Applies-to ID" := ApplId;

            OnBeforePostReversePayment(GenJournalLine, SalesAdvLetterHeaderCZZ);
            GenJnlPostLine.RunWithCheck(GenJournalLine);
            UnbindSubscription(GenJnlCheckLnHandlerCZZ);
            OnAfterPostReversePayment(GenJournalLine, SalesAdvLetterHeaderCZZ);

            CustLedgerEntry2.FindLast();
        end;

        AdvEntryInit(Preview);
        AdvEntryInitCustLedgEntryNo(CustLedgerEntry2."Entry No.");
        AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Entry No.");
        AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", DocumentNo,
            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", Preview);

        if SalesAdvLetterHeaderCZZ."Automatic Post VAT Document" then
            ReverseAdvancePaymentVAT(SalesAdvLetterEntryCZZ, CustLedgerEntry."Source Code", CustLedgerEntry.Description, ReverseAmount, CustLedgerEntry."Original Currency Factor", DocumentNo, CustLedgerEntry."Posting Date", SalesAdvLetterEntryCZZGlob."Entry No.", CustLedgerEntry."Document No.", "Advance Letter Entry Type CZZ"::"VAT Usage", GenJnlPostLine, Preview);

        if not Preview then begin
            SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::Closed);
        end;
    end;

    local procedure ReverseAdvancePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; SourceCode: Code[10]; PostDescription: Text[100]; ReverseAmount: Decimal; CurrencyFactor: Decimal; DocumentNo: Code[20]; PostingDate: Date; UsageEntryNo: Integer; InvoiceNo: Code[20]; EntryType: enum "Advance Letter Entry Type CZZ"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        CalcVATAmountLCY: Decimal;
        CalcAmountLCY: Decimal;
        ExchRateAmount: Decimal;
        ExchRateVATAmount: Decimal;
        AmountToUse: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforePostReversePaymentVAT(SalesAdvLetterEntryCZZ, PostingDate, Preview, IsHandled);
        if IsHandled then
            exit;

        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
        if SalesAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        GetCurrency(SalesAdvLetterEntryCZZ."Currency Code");
        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, 0D, true);

        SuggestUsageVAT(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, InvoiceNo, ReverseAmount, Preview);

        if SalesAdvLetterEntryCZZ."Currency Code" <> '' then begin
            BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ2, 0D, true);
            TempAdvancePostingBufferCZZ2.CalcSums(Amount);
            AmountToUse := TempAdvancePostingBufferCZZ2.Amount;
        end;

        TempAdvancePostingBufferCZZ1.SetFilter(Amount, '<>0');
        if TempAdvancePostingBufferCZZ1.FindSet() then
            repeat
                VATPostingSetup.Get(TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                VATPostingSetup.TestField("Sales Adv. Letter Account CZZ");
                VATPostingSetup.TestField("Sales Adv. Letter VAT Acc. CZZ");

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCode, PostDescription, GenJournalLine);
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
                GenJournalLine."VAT Calculation Type" := TempAdvancePostingBufferCZZ1."VAT Calculation Type";
                GenJournalLine."VAT Bus. Posting Group" := TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group";
                GenJournalLine.validate("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                GenJournalLine.Validate(Amount, -TempAdvancePostingBufferCZZ1.Amount);
                GenJournalLine."VAT Amount" := -Round(TempAdvancePostingBufferCZZ1."VAT Amount", CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                    CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                if GenJournalLine."Currency Code" <> '' then
                    CalculateAmountLCY(GenJournalLine);
                if not Preview then begin
                    BindSubscription(VATPostingSetupHandlerCZZ);
                    GenJnlPostLine.RunWithCheck(GenJournalLine);
                    UnbindSubscription(VATPostingSetupHandlerCZZ);
                end;

#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                AdvEntryInit(Preview);
                AdvEntryInitRelatedEntry(UsageEntryNo);
                AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Reporting Date",
                    GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                    GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                AdvEntryInsert(EntryType, SalesAdvLetterEntryCZZ."Sales Adv. Letter No.", GenJournalLine."Posting Date",
                    GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                    GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
                    GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", Preview);

                if GenJournalLine."Currency Code" <> '' then begin
                    TempAdvancePostingBufferCZZ2.Reset();
                    TempAdvancePostingBufferCZZ2.SetRange("VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group");
                    TempAdvancePostingBufferCZZ2.SetRange("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                    if TempAdvancePostingBufferCZZ2.FindFirst() then begin
                        CalcAmountLCY := Round(TempAdvancePostingBufferCZZ2."Amount (ACY)" * TempAdvancePostingBufferCZZ1.Amount / TempAdvancePostingBufferCZZ2.Amount);
                        CalcVATAmountLCY := Round(TempAdvancePostingBufferCZZ2."VAT Amount (ACY)" * TempAdvancePostingBufferCZZ1.Amount / TempAdvancePostingBufferCZZ2.Amount);

                        ExchRateAmount := -CalcAmountLCY - GenJournalLine."Amount (LCY)";
                        ExchRateVATAmount := -CalcVATAmountLCY - GenJournalLine."VAT Amount (LCY)";
                        if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                            PostExchangeRate(ExchRateAmount, ExchRateVATAmount, SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                                DocumentNo, PostingDate, SourceCode, PostDescription, UsageEntryNo, false, GenJnlPostLine, Preview);

                        ReverseUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup, TempAdvancePostingBufferCZZ1.Amount / AmountToUse,
                            UsageEntryNo, DocumentNo, PostingDate, PostDescription, GenJnlPostLine, Preview);
                    end;
                end;

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCode, PostDescription, GenJournalLine);
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                GenJournalLine.Validate(Amount, TempAdvancePostingBufferCZZ1.Amount);
                if not Preview then
                    GenJnlPostLine.RunWithCheck(GenJournalLine);
            until TempAdvancePostingBufferCZZ1.Next() = 0;

        if not Preview then
            UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::Closed);
    end;

    local procedure SuggestUsageVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; InvoiceNo: Code[20]; UsedAmount: Decimal; Preview: Boolean)
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesLine: Record "Sales Line";
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        TotalAmount: Decimal;
        UseAmount: Decimal;
        UseBaseAmount: Decimal;
        i: Integer;
        Continue: Boolean;
    begin
        AdvancePostingBufferCZZ.CalcSums(Amount);
        TotalAmount := -AdvancePostingBufferCZZ.Amount;
        if (UsedAmount <> 0) and (TotalAmount > UsedAmount) then begin
            Continue := InvoiceNo <> '';
            if Continue then
                if Preview then begin
                    SalesLine.SetFilter("Document Type", '%1|%2', SalesLine."Document Type"::Order, SalesLine."Document Type"::Invoice);
                    SalesLine.SetRange("Document No.", InvoiceNo);
                    Continue := SalesInvoiceLine.FindSet();
                end else begin
                    SalesInvoiceLine.SetRange("Document No.", InvoiceNo);
                    Continue := SalesInvoiceLine.FindSet();
                end;

            if Continue then begin
                BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ2, 0D, true);

                if Preview then
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := SalesLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := SalesLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount -= SalesLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" -= SalesLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := SalesLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := SalesLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := -SalesLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := -SalesLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until SalesLine.Next() = 0
                else
                    repeat
                        TempAdvancePostingBufferCZZ1.Init();
                        TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group" := SalesInvoiceLine."VAT Bus. Posting Group";
                        TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group" := SalesInvoiceLine."VAT Prod. Posting Group";
                        if TempAdvancePostingBufferCZZ1.Find() then begin
                            TempAdvancePostingBufferCZZ1.Amount -= SalesInvoiceLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" -= SalesInvoiceLine.Amount;
                            TempAdvancePostingBufferCZZ1.Modify();
                        end else begin
                            TempAdvancePostingBufferCZZ1."VAT Calculation Type" := SalesInvoiceLine."VAT Calculation Type";
                            TempAdvancePostingBufferCZZ1."VAT %" := SalesInvoiceLine."VAT %";
                            TempAdvancePostingBufferCZZ1.Amount := -SalesInvoiceLine."Amount Including VAT";
                            TempAdvancePostingBufferCZZ1."VAT Base Amount" := -SalesInvoiceLine.Amount;
                            TempAdvancePostingBufferCZZ1.Insert();
                        end;
                    until SalesInvoiceLine.Next() = 0;

                GetCurrency(SalesAdvLetterEntryCZZ."Currency Code");

                for i := 1 to 3 do begin
                    TempAdvancePostingBufferCZZ1.FindSet();
                    repeat
                        case i of
                            1:
                                begin
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Bus. Posting Group", TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group");
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Prod. Posting Group", TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group");
                                end;
                            2:
                                begin
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT Calculation Type", TempAdvancePostingBufferCZZ1."VAT Calculation Type");
                                    TempAdvancePostingBufferCZZ2.SetRange("VAT %", TempAdvancePostingBufferCZZ1."VAT %");
                                end;
                        end;
                        if TempAdvancePostingBufferCZZ2.FindSet() then
                            repeat
                                UseAmount := TempAdvancePostingBufferCZZ1.Amount;
                                UseBaseAmount := TempAdvancePostingBufferCZZ1."VAT Base Amount";
                                if TempAdvancePostingBufferCZZ2.Amount > UseAmount then begin
                                    UseAmount := TempAdvancePostingBufferCZZ2.Amount;
                                    UseBaseAmount := TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                end;
                                if (-UsedAmount > UseAmount) or
                                   (TempAdvancePostingBufferCZZ1."VAT %" <> TempAdvancePostingBufferCZZ2."VAT %")
                                then begin
                                    UseAmount := -UsedAmount;
                                    UseBaseAmount := Round(TempAdvancePostingBufferCZZ2."VAT Base Amount" * UseAmount / TempAdvancePostingBufferCZZ2.Amount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                                end;

                                TempAdvancePostingBufferCZZ2.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ2."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ2.Modify();
                                TempAdvancePostingBufferCZZ1.Amount -= UseAmount;
                                TempAdvancePostingBufferCZZ1."VAT Base Amount" -= UseBaseAmount;
                                TempAdvancePostingBufferCZZ1.Modify();
                                UsedAmount += UseAmount;
                            until (TempAdvancePostingBufferCZZ2.Next() = 0) or (UsedAmount = 0);
                        TempAdvancePostingBufferCZZ2.Reset();
                    until TempAdvancePostingBufferCZZ1.Next() = 0;
                end;

                if AdvancePostingBufferCZZ.FindSet() then
                    repeat
                        TempAdvancePostingBufferCZZ2.Get(AdvancePostingBufferCZZ."VAT Bus. Posting Group", AdvancePostingBufferCZZ."VAT Prod. Posting Group");
                        case true of
                            TempAdvancePostingBufferCZZ2.Amount = 0:
                                ;
                            TempAdvancePostingBufferCZZ2.Amount <> AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount := AdvancePostingBufferCZZ.Amount - TempAdvancePostingBufferCZZ2.Amount;
                                    AdvancePostingBufferCZZ."VAT Base Amount" := AdvancePostingBufferCZZ."VAT Base Amount" - TempAdvancePostingBufferCZZ2."VAT Base Amount";
                                    AdvancePostingBufferCZZ."VAT Amount" := AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Base Amount";
                                    AdvancePostingBufferCZZ.Modify();
                                end;
                            TempAdvancePostingBufferCZZ2.Amount = AdvancePostingBufferCZZ.Amount:
                                begin
                                    AdvancePostingBufferCZZ.Amount := 0;
                                    AdvancePostingBufferCZZ."VAT Base Amount" := 0;
                                    AdvancePostingBufferCZZ."VAT Amount" := 0;
                                    AdvancePostingBufferCZZ.Modify();
                                end;
                        end;
                    until AdvancePostingBufferCZZ.Next() = 0;
            end else begin
                AdvancePostingBufferCZZ.FindSet();
                repeat
                    AdvancePostingBufferCZZ.Amount := Round(AdvancePostingBufferCZZ.Amount * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision");
                    AdvancePostingBufferCZZ."VAT Amount" := Round(AdvancePostingBufferCZZ."VAT Amount" * UsedAmount / TotalAmount, CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                    AdvancePostingBufferCZZ."VAT Base Amount" := AdvancePostingBufferCZZ.Amount - AdvancePostingBufferCZZ."VAT Amount";
                    AdvancePostingBufferCZZ.Modify();
                until AdvancePostingBufferCZZ.Next() = 0;
            end;
        end;
    end;

    procedure PostAdvancePaymentUsageVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CurrencyFactor: Decimal;
    begin
        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Usage then
            exit;

        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntry2.SetRange("Entry Type", SalesAdvLetterEntry2."Entry Type"::"VAT Usage");
        if not SalesAdvLetterEntry2.IsEmpty() then
            Error(VATDocumentExistsErr);

        SalesAdvLetterEntry2.Get(SalesAdvLetterEntryCZZ."Related Entry");
        SalesAdvLetterEntry2.TestField(SalesAdvLetterEntry2."Entry Type", SalesAdvLetterEntry2."Entry Type"::Payment);

        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");

        if SalesInvoiceHeader.Get(CustLedgerEntry."Document No.") then
            CurrencyFactor := SalesInvoiceHeader."Currency Factor"
        else
            CurrencyFactor := CustLedgerEntry."Original Currency Factor";

        ReverseAdvancePaymentVAT(SalesAdvLetterEntry2, CustLedgerEntry."Source Code", CustLedgerEntry.Description, SalesAdvLetterEntryCZZ.Amount, CurrencyFactor, SalesAdvLetterEntryCZZ."Document No.", CustLedgerEntry."Posting Date", SalesAdvLetterEntryCZZ."Entry No.", CustLedgerEntry."Document No.", "Advance Letter Entry Type CZZ"::"VAT Usage", GenJnlPostLine, false);
    end;

    local procedure PostExchangeRate(ExchRateAmount: Decimal; ExchRateVATAmount: Decimal; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        DocumentNo: Code[20]; PostingDate: Date; SourceCode: Code[10]; PostDescription: Text[100]; UsageEntryNo: Integer; Correction: Boolean;
        var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if (ExchRateAmount = 0) and (ExchRateVATAmount = 0) then
            exit;

        if ExchRateVATAmount <> 0 then begin
            GetCurrency(SalesAdvLetterHeaderCZZ."Currency Code");

            InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, ExchRateAmount - ExchRateVATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);

            InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCode, PostDescription, GenJournalLine);
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

            InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCode, PostDescription, GenJournalLine);
            GenJournalLine.Correction := Correction;
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
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
        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Rate", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.", PostingDate,
            0, ExchRateAmount, '', 0, DocumentNo,
            SalesAdvLetterEntryCZZ."Global Dimension 1 Code", SalesAdvLetterEntryCZZ."Global Dimension 2 Code", SalesAdvLetterEntryCZZ."Dimension Set ID", Preview);
    end;

    local procedure BufferAdvanceVATLines(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var AdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ"; BalanceAtDate: Date; ResetBuffer: Boolean)
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
    begin
        if ResetBuffer then begin
            AdvancePostingBufferCZZ.Reset();
            AdvancePostingBufferCZZ.DeleteAll();
        end;

        SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        SalesAdvLetterEntryCZZ2.SetFilter("Entry Type", '<>%1', SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Adjustment");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntryCZZ2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        if SalesAdvLetterEntryCZZ2.FindSet() then
            repeat
                if SalesAdvLetterEntryCZZ2."Entry Type" in [SalesAdvLetterEntryCZZ2."Entry Type"::Payment,
                    SalesAdvLetterEntryCZZ2."Entry Type"::Usage, SalesAdvLetterEntryCZZ2."Entry Type"::Close] then
                    BufferAdvanceVATLines(SalesAdvLetterEntryCZZ2, AdvancePostingBufferCZZ, BalanceAtDate, false)
                else begin
                    AdvancePostingBufferCZZ.Init();
                    AdvancePostingBufferCZZ."VAT Bus. Posting Group" := SalesAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                    AdvancePostingBufferCZZ."VAT Prod. Posting Group" := SalesAdvLetterEntryCZZ2."VAT Prod. Posting Group";
                    if AdvancePostingBufferCZZ.Find() then begin
                        AdvancePostingBufferCZZ.Amount += SalesAdvLetterEntryCZZ2.Amount;
                        AdvancePostingBufferCZZ."VAT Base Amount" += SalesAdvLetterEntryCZZ2."VAT Base Amount";
                        AdvancePostingBufferCZZ."VAT Amount" += SalesAdvLetterEntryCZZ2."VAT Amount";
                        AdvancePostingBufferCZZ."Amount (ACY)" += SalesAdvLetterEntryCZZ2."Amount (LCY)";
                        AdvancePostingBufferCZZ."VAT Base Amount (ACY)" += SalesAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                        AdvancePostingBufferCZZ."VAT Amount (ACY)" += SalesAdvLetterEntryCZZ2."VAT Amount (LCY)";
                        AdvancePostingBufferCZZ.Modify();
                    end else begin
                        AdvancePostingBufferCZZ."VAT Calculation Type" := SalesAdvLetterEntryCZZ2."VAT Calculation Type";
                        AdvancePostingBufferCZZ."VAT %" := SalesAdvLetterEntryCZZ2."VAT %";
                        AdvancePostingBufferCZZ.Amount := SalesAdvLetterEntryCZZ2.Amount;
                        AdvancePostingBufferCZZ."VAT Base Amount" := SalesAdvLetterEntryCZZ2."VAT Base Amount";
                        AdvancePostingBufferCZZ."VAT Amount" := SalesAdvLetterEntryCZZ2."VAT Amount";
                        AdvancePostingBufferCZZ."Amount (ACY)" := SalesAdvLetterEntryCZZ2."Amount (LCY)";
                        AdvancePostingBufferCZZ."VAT Base Amount (ACY)" := SalesAdvLetterEntryCZZ2."VAT Base Amount (LCY)";
                        AdvancePostingBufferCZZ."VAT Amount (ACY)" := SalesAdvLetterEntryCZZ2."VAT Amount (LCY)";
                        AdvancePostingBufferCZZ.Insert();
                    end;
                end;
            until SalesAdvLetterEntryCZZ2.Next() = 0;
    end;

    local procedure InitGenJnlLineFromCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; GenJournalDocumentType: Enum "Gen. Journal Document Type")
    begin
        GenJournalLine.InitNewLine(
            CustLedgerEntry."Posting Date", CustLedgerEntry."Document Date", CustLedgerEntry."VAT Date CZL", CustLedgerEntry.Description,
            CustLedgerEntry."Global Dimension 1 Code", CustLedgerEntry."Global Dimension 2 Code",
            CustLedgerEntry."Dimension Set ID", CustLedgerEntry."Reason Code");
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.CopyDocumentFields(GenJournalDocumentType, CustLedgerEntry."Document No.", '', CustLedgerEntry."Source Code", '');
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := CustLedgerEntry."Customer No.";
        GenJournalLine."Source Currency Code" := CustLedgerEntry."Currency Code";
        GenJournalLine."Currency Factor" := CustLedgerEntry."Original Currency Factor";
        GenJournalLine."Sell-to/Buy-from No." := CustLedgerEntry."Sell-to Customer No.";
        GenJournalLine."Bill-to/Pay-to No." := CustLedgerEntry."Customer No.";
        GenJournalLine."IC Partner Code" := CustLedgerEntry."IC Partner Code";
        GenJournalLine."Salespers./Purch. Code" := CustLedgerEntry."Salesperson Code";
        GenJournalLine."On Hold" := CustLedgerEntry."On Hold";
        GenJournalLine."Posting Group" := CustLedgerEntry."Customer Posting Group";
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            GenJournalLine.Validate("VAT Date CZL", CustLedgerEntry."VAT Date CZL")
        else
#pragma warning restore AL0432
#endif
        GenJournalLine.Validate("VAT Reporting Date", CustLedgerEntry."VAT Date CZL");
        GenJournalLine."System-Created Entry" := true;
        OnAfterInitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine);
    end;

    local procedure InitGenJnlLineFromAdvance(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; DocumentNo: Code[20]; SourceCode: Code[10]; PostDescription: Text[100]; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Init();
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Document No." := DocumentNo;
        GenJournalLine.Description := PostDescription;
        GenJournalLine."Bill-to/Pay-to No." := SalesAdvLetterHeaderCZZ."Bill-to Customer No.";
        GenJournalLine."Country/Region Code" := SalesAdvLetterHeaderCZZ."Bill-to Country/Region Code";
        GenJournalLine."Source Code" := SourceCode;
        GenJournalLine."VAT Registration No." := SalesAdvLetterHeaderCZZ."VAT Registration No.";
        GenJournalLine."Registration No. CZL" := SalesAdvLetterHeaderCZZ."Registration No.";
        GenJournalLine."Tax Registration No. CZL" := SalesAdvLetterHeaderCZZ."Tax Registration No.";
        GenJournalLine."Shortcut Dimension 1 Code" := SalesAdvLetterEntryCZZ."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := SalesAdvLetterEntryCZZ."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := SalesAdvLetterEntryCZZ."Dimension Set ID";
        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
        OnAfterInitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, GenJournalLine);
    end;

    procedure GetRemAmtSalAdvPayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
    begin
        if (SalesAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntry2."Entry Type"::Payment,
            SalesAdvLetterEntry2."Entry Type"::Usage, SalesAdvLetterEntry2."Entry Type"::Close);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        SalesAdvLetterEntry2.CalcSums(Amount);
        exit(-SalesAdvLetterEntryCZZ.Amount - SalesAdvLetterEntry2.Amount);
    end;

    procedure GetRemAmtLCYSalAdvPayment(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date): Decimal
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
    begin
        if (SalesAdvLetterEntryCZZ."Posting Date" > BalanceAtDate) and (BalanceAtDate <> 0D) then
            exit(0);

        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetFilter("Entry Type", '%1|%2|%3', SalesAdvLetterEntry2."Entry Type"::Payment,
            SalesAdvLetterEntry2."Entry Type"::Usage, SalesAdvLetterEntry2."Entry Type"::Close);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        SalesAdvLetterEntry2.CalcSums("Amount (LCY)");
        exit(-SalesAdvLetterEntryCZZ."Amount (LCY)" - SalesAdvLetterEntry2."Amount (LCY)");
    end;

    procedure GetRemAmtLCYVATAdjust(var AmountLCY: Decimal; var VATAmountLCY: Decimal; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; BalanceAtDate: Date; VATBusPostGr: Code[20]; VATProdPostGr: Code[20])
    var
        SalesAdvLetterEntry2: Record "Sales Adv. Letter Entry CZZ";
        AmountLCY2, VATAmountLCY2 : Decimal;
    begin
        SalesAdvLetterEntry2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
        SalesAdvLetterEntry2.SetRange(Cancelled, false);
        SalesAdvLetterEntry2.SetRange("Entry Type", SalesAdvLetterEntry2."Entry Type"::"VAT Adjustment");
        SalesAdvLetterEntry2.SetRange("VAT Bus. Posting Group", VATBusPostGr);
        SalesAdvLetterEntry2.SetRange("VAT Prod. Posting Group", VATProdPostGr);
        SalesAdvLetterEntry2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
        if BalanceAtDate <> 0D then
            SalesAdvLetterEntry2.SetFilter("Posting Date", '..%1', BalanceAtDate);
        SalesAdvLetterEntry2.CalcSums("Amount (LCY)", "VAT Amount (LCY)");
        AmountLCY := SalesAdvLetterEntry2."Amount (LCY)";
        VATAmountLCY := SalesAdvLetterEntry2."VAT Amount (LCY)";

        SalesAdvLetterEntry2.SetRange("VAT Bus. Posting Group");
        SalesAdvLetterEntry2.SetRange("VAT Prod. Posting Group");
        SalesAdvLetterEntry2.SetRange("Entry Type", SalesAdvLetterEntry2."Entry Type"::Usage);
        if SalesAdvLetterEntry2.FindSet() then
            repeat
                GetRemAmtLCYVATAdjust(AmountLCY2, VATAmountLCY2, SalesAdvLetterEntry2, BalanceAtDate, VATBusPostGr, VATProdPostGr);
                AmountLCY += AmountLCY2;
                VATAmountLCY += VATAmountLCY2;
            until SalesAdvLetterEntry2.Next() = 0
    end;

    procedure CloseAdvanceLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry1: Record "Cust. Ledger Entry";
        CustLedgerEntry2: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        AdvPaymentCloseDialogCZZ: Page "Adv. Payment Close Dialog CZZ";
        ApplId: Code[50];
        VATDocumentNo: Code[20];
        PostingDate: Date;
        VATDate: Date;
        CurrencyFactor: Decimal;
        RemAmount: Decimal;
        RemAmountLCY: Decimal;
    begin
        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::Closed then
            exit;

        if SalesAdvLetterHeaderCZZ.Status = SalesAdvLetterHeaderCZZ.Status::New then begin
            UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::Closed);
            exit;
        end;

        AdvPaymentCloseDialogCZZ.SetValues(WorkDate(), WorkDate(), SalesAdvLetterHeaderCZZ."Currency Code", 0, '', false);
        if AdvPaymentCloseDialogCZZ.RunModal() = Action::OK then begin
            AdvPaymentCloseDialogCZZ.GetValues(PostingDate, VATDate, CurrencyFactor);
            if (PostingDate = 0D) or (VATDate = 0D) then
                Error(DateEmptyErr);
            if SalesAdvLetterHeaderCZZ."Currency Code" = '' then
                CurrencyFactor := 1;
            VATDocumentNo := '';

            SalesAdvLetterEntryCZZ.SetRange("Sales Adv. Letter No.", SalesAdvLetterHeaderCZZ."No.");
            SalesAdvLetterEntryCZZ.SetRange("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Payment);
            SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
            if SalesAdvLetterEntryCZZ.FindSet() then
                repeat
                    RemAmount := GetRemAmtSalAdvPayment(SalesAdvLetterEntryCZZ, 0D);
                    RemAmountLCY := GetRemAmtLCYSalAdvPayment(SalesAdvLetterEntryCZZ, 0D);
                    if RemAmount <> 0 then begin
                        if VATDocumentNo = '' then begin
                            AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
                            AdvanceLetterTemplateCZZ.TestField("Advance Letter Cr. Memo Nos.");
                            VATDocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", PostingDate, true);
                        end;

                        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                        Customer.Get(SalesAdvLetterHeaderCZZ."Bill-to Customer No.");
                        CustLedgerEntry1.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");

                        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry1, GenJournalLine, GenJournalLine."Document Type"::" ");
                        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
                        GenJournalLine.Correction := true;
                        GenJournalLine."Document No." := VATDocumentNo;
                        GenJournalLine."Posting Date" := PostingDate;
                        GenJournalLine."Document Date" := PostingDate;
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", VATDate)
                        else
#pragma warning restore AL0432
#endif
                        GenJournalLine.Validate("VAT Reporting Date", VATDate);
                        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
                        GenJournalLine."Use Advance G/L Account CZZ" := true;
                        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                        GenJournalLine.Validate(Amount, RemAmount);

                        ApplId := CopyStr(CustLedgerEntry1."Document No." + Format(CustLedgerEntry1."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        CustLedgerEntry1.Prepayment := false;
                        CustLedgerEntry1."Advance Letter No. CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
                        CustLedgerEntry1.Modify();
                        CustLedgerEntry1.CalcFields("Remaining Amount");
                        CustLedgerEntry1."Amount to Apply" := CustLedgerEntry1."Remaining Amount";
                        CustLedgerEntry1."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry1);
                        GenJournalLine."Applies-to ID" := ApplId;

                        OnBeforePostClosePayment(GenJournalLine, SalesAdvLetterHeaderCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        OnAfterPostClosePayment(GenJournalLine, SalesAdvLetterHeaderCZZ);

                        CustLedgerEntry2.FindLast();
                        AdvEntryInit(false);
                        AdvEntryInitCustLedgEntryNo(CustLedgerEntry2."Entry No.");
                        AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Entry No.");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::Close, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, RemAmountLCY,
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        ReverseAdvancePaymentVAT(SalesAdvLetterEntryCZZ, CustLedgerEntry1."Source Code", SalesAdvLetterHeaderCZZ."Posting Description", RemAmount, CurrencyFactor, VATDocumentNo, PostingDate, SalesAdvLetterEntryCZZGlob."Entry No.", '', "Advance Letter Entry Type CZZ"::"VAT Close", GenJnlPostLine, false);

                        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry1, GenJournalLine, GenJournalLine."Document Type"::Payment);
                        GenJournalLine.Correction := true;
                        GenJournalLine."Document No." := VATDocumentNo;
                        GenJournalLine."Posting Date" := PostingDate;
                        GenJournalLine."Document Date" := PostingDate;
#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine.Validate("VAT Date CZL", VATDate)
                        else
#pragma warning restore AL0432
#endif
                        GenJournalLine.Validate("VAT Reporting Date", VATDate);
                        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", CurrencyFactor);
                        GenJournalLine.Validate(Amount, -RemAmount);
                        GenJournalLine."Variable Symbol CZL" := SalesAdvLetterHeaderCZZ."Variable Symbol";
                        if CustomerBankAccount.Get(Customer."No.", Customer."Preferred Bank Account Code") then begin
                            GenJournalLine."Bank Account Code CZL" := CustomerBankAccount.Code;
                            GenJournalLine."Bank Account No. CZL" := CustomerBankAccount."Bank Account No.";
                            GenJournalLine."Transit No. CZL" := CustomerBankAccount."Transit No.";
                            GenJournalLine."IBAN CZL" := CustomerBankAccount.IBAN;
                            GenJournalLine."SWIFT Code CZL" := CustomerBankAccount."SWIFT Code";
                        end;
                        OnBeforePostClosePaymentRepos(GenJournalLine, SalesAdvLetterHeaderCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        OnAfterPostClosePaymentRepos(GenJournalLine, SalesAdvLetterHeaderCZZ);
                    end;
                until SalesAdvLetterEntryCZZ.Next() = 0;

            CancelInitEntry(SalesAdvLetterHeaderCZZ, PostingDate, false);
            SalesAdvLetterHeaderCZZ.Find();
            UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::Closed);

            AdvanceLetterApplicationCZZ.SetRange("Advance Letter Type", AdvanceLetterApplicationCZZ."Advance Letter Type"::Sales);
            AdvanceLetterApplicationCZZ.SetRange("Advance Letter No.", SalesAdvLetterHeaderCZZ."No.");
            AdvanceLetterApplicationCZZ.DeleteAll(true);
        end;
    end;

    procedure PostAdvanceCreditMemoVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ3: Record "Sales Adv. Letter Entry CZZ";
        TempAdvancePostingBufferCZZ: Record "Advance Posting Buffer CZZ" temporary;
        VATPostingSetup: Record "VAT Posting Setup";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        GenJournalLine: Record "Gen. Journal Line";
        AdvanceLetterTemplateCZZ: Record "Advance Letter Template CZZ";
        VATEntry: Record "VAT Entry";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvPaymentCloseDialog: Page "Adv. Payment Close Dialog CZZ";
        DocumentNo: Code[20];
        VATDate: Date;
        PostingDate: Date;
        CurrencyFactor: Decimal;
        ExchRateAmount: Decimal;
        ExchRateVATAmount: Decimal;
        Coef: Decimal;
        CreateCrMemoErr: Label 'Credit memo cannot be created because some VAT usage exists.';
    begin
        SalesAdvLetterEntryCZZ.TestField("Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::"VAT Payment");
        SalesAdvLetterEntryCZZ.TestField(Cancelled, false);

        AdvPaymentCloseDialog.SetValues(SalesAdvLetterEntryCZZ."Posting Date", SalesAdvLetterEntryCZZ."VAT Date", SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor", '', false);
        if AdvPaymentCloseDialog.RunModal() = Action::OK then begin
            AdvPaymentCloseDialog.GetValues(PostingDate, VATDate, CurrencyFactor);
            if (PostingDate = 0D) or (VATDate = 0D) then
                Error(DateEmptyErr);
            OnPostAdvanceCreditMemoVATOnAfterGetValues(SalesAdvLetterEntryCZZ, PostingDate, VATDate);
            if SalesAdvLetterEntryCZZ."Currency Code" = '' then
                CurrencyFactor := 1;

            SalesAdvLetterEntryCZZ3.Get(SalesAdvLetterEntryCZZ."Related Entry");
            BufferAdvanceVATLines(SalesAdvLetterEntryCZZ3, TempAdvancePostingBufferCZZ, 0D, true);

            GetCurrency(SalesAdvLetterEntryCZZ."Currency Code");
            SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            AdvanceLetterTemplateCZZ.Get(SalesAdvLetterHeaderCZZ."Advance Letter Code");
            VATEntry.Get(SalesAdvLetterEntryCZZ."VAT Entry No.");
            DocumentNo := NoSeriesManagement.GetNextNo(AdvanceLetterTemplateCZZ."Advance Letter Cr. Memo Nos.", WorkDate(), true);

            SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
            SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
            SalesAdvLetterEntryCZZ2.SetRange("Document No.", SalesAdvLetterEntryCZZ."Document No.");
            SalesAdvLetterEntryCZZ2.CalcSums(Amount);
            Coef := SalesAdvLetterEntryCZZ2.Amount / SalesAdvLetterEntryCZZ3.Amount;

            SalesAdvLetterEntryCZZ2.FindSet(true, true);
            repeat
                TempAdvancePostingBufferCZZ.SetRange("VAT Bus. Posting Group", SalesAdvLetterEntryCZZ2."VAT Bus. Posting Group");
                TempAdvancePostingBufferCZZ.SetRange("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                TempAdvancePostingBufferCZZ.SetRange("VAT Calculation Type", SalesAdvLetterEntryCZZ2."VAT Calculation Type");
                TempAdvancePostingBufferCZZ.FindFirst();
                if TempAdvancePostingBufferCZZ.Amount > SalesAdvLetterEntryCZZ2.Amount then
                    Error(CreateCrMemoErr);

                VATPostingSetup.Get(SalesAdvLetterEntryCZZ2."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                VATPostingSetup.TestField("Sales Adv. Letter Account CZZ");
                VATPostingSetup.TestField("Sales Adv. Letter VAT Acc. CZZ");

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, VATEntry."Source Code", SalesAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ2."Currency Code", CurrencyFactor);
                GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
                GenJournalLine."VAT Calculation Type" := SalesAdvLetterEntryCZZ2."VAT Calculation Type";
                GenJournalLine."VAT Bus. Posting Group" := SalesAdvLetterEntryCZZ2."VAT Bus. Posting Group";
                GenJournalLine.Validate("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ2."VAT Prod. Posting Group");
                GenJournalLine.Validate(Amount, -SalesAdvLetterEntryCZZ2.Amount);
                GenJournalLine."VAT Amount" := -SalesAdvLetterEntryCZZ2."VAT Amount";
                GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                    CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                if GenJournalLine."Currency Code" <> '' then
                    CalculateAmountLCY(GenJournalLine);
                BindSubscription(VATPostingSetupHandlerCZZ);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
                UnbindSubscription(VATPostingSetupHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                AdvEntryInit(false);
                AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Related Entry");
                AdvEntryInitCancel();
                AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Reporting Date",
                    GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                    GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Payment", SalesAdvLetterEntryCZZ2."Sales Adv. Letter No.", GenJournalLine."Posting Date",
                    GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                    GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
                    GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                if GenJournalLine."Currency Code" <> '' then begin
                    ExchRateAmount := -SalesAdvLetterEntryCZZ2."Amount (LCY)" - GenJournalLine."Amount (LCY)";
                    ExchRateVATAmount := -SalesAdvLetterEntryCZZ2."VAT Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
                    if (ExchRateAmount <> 0) or (ExchRateVATAmount <> 0) then
                        PostExchangeRate(ExchRateAmount, ExchRateVATAmount, SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                            DocumentNo, PostingDate, '', '', SalesAdvLetterEntryCZZ2."Related Entry", true, GenJnlPostLine, false);

                    ReverseUnrealizedExchangeRate(SalesAdvLetterEntryCZZ3, SalesAdvLetterHeaderCZZ, VATPostingSetup, Coef,
                        SalesAdvLetterEntryCZZ3."Entry No.", DocumentNo, PostingDate, '', GenJnlPostLine, false);
                end;

                InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, VATEntry."Source Code", SalesAdvLetterHeaderCZZ."Posting Description", GenJournalLine);
                GenJournalLine.Validate("Posting Date", PostingDate);
                GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ2."Currency Code", CurrencyFactor);
                GenJournalLine.Validate(Amount, SalesAdvLetterEntryCZZ2.Amount);
                GenJnlPostLine.RunWithCheck(GenJournalLine);
            until SalesAdvLetterEntryCZZ2.Next() = 0;
            SalesAdvLetterEntryCZZ2.ModifyAll(Cancelled, true);
        end;
    end;

    procedure PostAdvancePaymentUsagePreview(var SalesHeader: Record "Sales Header"; Amount: Decimal; AmountLCY: Decimal; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ";
    begin
        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.DeleteAll();

        if not TempSalesAdvLetterEntryCZZGlob.IsEmpty() then
            TempSalesAdvLetterEntryCZZGlob.DeleteAll();

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Sales Order";
            SalesHeader."Document Type"::Invoice:
                AdvLetterUsageDocTypeCZZ := AdvLetterUsageDocTypeCZZ::"Sales Invoice";
            else
                exit;
        end;

        SalesInvoiceHeader.TransferFields(SalesHeader);
        CustLedgerEntry.Init();
        CustLedgerEntry."Customer No." := SalesHeader."Bill-to Customer No.";
        CustLedgerEntry."Posting Date" := SalesHeader."Posting Date";
        CustLedgerEntry."Document Date" := SalesHeader."Document Date";
        CustLedgerEntry."Document Type" := SalesHeader."Document Type";
        CustLedgerEntry."Document No." := SalesHeader."No.";
        CustLedgerEntry."External Document No." := SalesHeader."External Document No.";
        CustLedgerEntry.Description := SalesHeader."Posting Description";
        CustLedgerEntry."Currency Code" := SalesHeader."Currency Code";
        CustLedgerEntry."Sell-to Customer No." := SalesHeader."Sell-to Customer No.";
        CustLedgerEntry."Customer Posting Group" := SalesHeader."Customer Posting Group";
        CustLedgerEntry."Global Dimension 1 Code" := SalesHeader."Shortcut Dimension 1 Code";
        CustLedgerEntry."Global Dimension 2 Code" := SalesHeader."Shortcut Dimension 2 Code";
        CustLedgerEntry."Dimension Set ID" := SalesHeader."Dimension Set ID";
        CustLedgerEntry."Salesperson Code" := SalesHeader."Salesperson Code";
        CustLedgerEntry."Due Date" := SalesHeader."Due Date";
        CustLedgerEntry."Payment Method Code" := SalesHeader."Payment Method Code";
#if not CLEAN22
#pragma warning disable AL0432
        if not ReplaceVATDateMgtCZL.IsEnabled() then
            CustLedgerEntry."VAT Date CZL" := SalesHeader."VAT Date CZL"
        else
#pragma warning restore AL0432
#endif
        CustLedgerEntry."VAT Date CZL" := SalesHeader."VAT Reporting Date";
        CustLedgerEntry."Original Currency Factor" := SalesHeader."Currency Factor";
        CustLedgerEntry.Amount := Amount;
        CustLedgerEntry."Amount (LCY)" := AmountLCY;
        CustLedgerEntry."Remaining Amount" := Amount;
        CustLedgerEntry."Remaining Amt. (LCY)" := AmountLCY;

        PostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ, SalesHeader."No.", SalesInvoiceHeader, CustLedgerEntry, GenJnlPostLine, true);

        if TempSalesAdvLetterEntryCZZGlob.FindSet() then begin
            repeat
                SalesAdvLetterEntryCZZ := TempSalesAdvLetterEntryCZZGlob;
                SalesAdvLetterEntryCZZ.Insert();
            until TempSalesAdvLetterEntryCZZGlob.Next() = 0;

            TempSalesAdvLetterEntryCZZGlob.DeleteAll();
        end;
    end;

    procedure UnapplyAdvanceLetter(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        TempSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ" temporary;
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryInv: Record "Cust. Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATPostingSetupHandlerCZZ: Codeunit "VAT Posting Setup Handler CZZ";
        GenJnlCheckLnHandlerCZZ: Codeunit "Gen.Jnl.-Check Ln. Handler CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        ApplId: Code[50];
        AdvLetters: Text;
        UnapplyIsNotPossibleErr: Label 'Unapply is not possible.';
        UnapplyAdvLetterQst: Label 'Unapply advance letter: %1\Continue?', Comment = '%1 = Advance Letters';
    begin
        SalesAdvLetterEntryCZZ.SetRange(SalesAdvLetterEntryCZZ."Entry Type", SalesAdvLetterEntryCZZ."Entry Type"::Usage);
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        if not SalesAdvLetterEntryCZZ.FindSet() then
            exit;

        repeat
            if not TempSalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.") then begin
                TempSalesAdvLetterHeaderCZZ."No." := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
                TempSalesAdvLetterHeaderCZZ.Insert();
            end;
        until SalesAdvLetterEntryCZZ.Next() = 0;

        if TempSalesAdvLetterHeaderCZZ.FindSet() then
            repeat
                if AdvLetters <> '' then
                    AdvLetters := AdvLetters + ', ';
                AdvLetters := AdvLetters + TempSalesAdvLetterHeaderCZZ."No.";
            until TempSalesAdvLetterHeaderCZZ.Next() = 0;

        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(UnapplyAdvLetterQst, AdvLetters), false) then
            exit;

        SalesAdvLetterEntryCZZ.Reset();
        SalesAdvLetterEntryCZZ.SetRange("Document No.", SalesInvoiceHeader."No.");
        SalesAdvLetterEntryCZZ.SetRange(Cancelled, false);
        SalesAdvLetterEntryCZZ.Find('+');
        SalesAdvLetterEntryCZZ.SetFilter("Entry No.", '..%1', SalesAdvLetterEntryCZZ."Entry No.");
        repeat
            SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            case SalesAdvLetterEntryCZZ."Entry Type" of
                SalesAdvLetterEntryCZZ."Entry Type"::"VAT Adjustment":
                    begin
                        VATPostingSetup.Get(SalesAdvLetterEntryCZZ."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup, -SalesAdvLetterEntryCZZ."Amount (LCY)", -SalesAdvLetterEntryCZZ."VAT Amount (LCY)",
                            SalesAdvLetterEntryCZZ."Related Entry", 0, SalesAdvLetterEntryCZZ."Document No.", SalesAdvLetterEntryCZZ."Posting Date", SalesInvoiceHeader."Posting Description", GenJnlPostLine, true, false);
                    end;
                SalesAdvLetterEntryCZZ."Entry Type"::"VAT Rate":
                    begin
                        VATPostingSetup.Get(SalesAdvLetterEntryCZZ."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        PostExchangeRate(-SalesAdvLetterEntryCZZ."Amount (LCY)", -SalesAdvLetterEntryCZZ."VAT Amount (LCY)", SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, VATPostingSetup,
                            SalesAdvLetterEntryCZZ."Document No.", SalesAdvLetterEntryCZZ."Posting Date", SalesInvoiceHeader."Source Code",
                            SalesInvoiceHeader."Posting Description", SalesAdvLetterEntryCZZ."Related Entry", true, GenJnlPostLine, false);
                    end;
                SalesAdvLetterEntryCZZ."Entry Type"::"VAT Usage":
                    begin
                        VATPostingSetup.Get(SalesAdvLetterEntryCZZ."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, SalesAdvLetterEntryCZZ."Document No.",
                            SalesInvoiceHeader."Source Code", SalesInvoiceHeader."Posting Description", GenJournalLine);
                        GenJournalLine.Validate("Posting Date", SalesAdvLetterEntryCZZ."Posting Date");
                        GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine."Gen. Posting Type" := GenJournalLine."Gen. Posting Type"::Sale;
                        GenJournalLine."VAT Calculation Type" := SalesAdvLetterEntryCZZ."VAT Calculation Type";
                        GenJournalLine."VAT Bus. Posting Group" := SalesAdvLetterEntryCZZ."VAT Bus. Posting Group";
                        GenJournalLine.validate("VAT Prod. Posting Group", SalesAdvLetterEntryCZZ."VAT Prod. Posting Group");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, -SalesAdvLetterEntryCZZ.Amount);
                        GenJournalLine."VAT Amount" := -SalesAdvLetterEntryCZZ."VAT Amount";
                        GenJournalLine."VAT Base Amount" := GenJournalLine.Amount - GenJournalLine."VAT Amount";
                        GenJournalLine."VAT Difference" := GenJournalLine."VAT Amount" - Round(GenJournalLine.Amount * GenJournalLine."VAT %" / (100 + GenJournalLine."VAT %"),
                            CurrencyGlob."Amount Rounding Precision", CurrencyGlob.VATRoundingDirection());
                        if GenJournalLine."Currency Code" <> '' then begin
                            GenJournalLine."VAT Amount (LCY)" := -SalesAdvLetterEntryCZZ."VAT Amount (LCY)";
                            GenJournalLine."VAT Base Amount (LCY)" := GenJournalLine."Amount (LCY)" - GenJournalLine."VAT Amount (LCY)";
                        end;
                        BindSubscription(VATPostingSetupHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(VATPostingSetupHandlerCZZ);

#if not CLEAN22
#pragma warning disable AL0432
                        if not ReplaceVATDateMgtCZL.IsEnabled() then
                            GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
                        AdvEntryInit(false);
                        AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Related Entry");
                        AdvEntryInitCancel();
                        AdvEntryInitVAT(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group", GenJournalLine."VAT Reporting Date",
                            GenJnlPostLine.GetNextVATEntryNo() - 1, GenJournalLine."VAT %", VATPostingSetup."VAT Identifier", GenJournalLine."VAT Calculation Type",
                            GenJournalLine."VAT Amount", GenJournalLine."VAT Amount (LCY)", GenJournalLine."VAT Base Amount", GenJournalLine."VAT Base Amount (LCY)");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Usage", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", GenJournalLine."Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, SalesAdvLetterEntryCZZ."Document No.", SalesInvoiceHeader."Source Code", SalesInvoiceHeader."Posting Description", GenJournalLine);
                        GenJournalLine.Validate("Posting Date", SalesAdvLetterEntryCZZ."Posting Date");
                        GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
                        GenJournalLine.SetCurrencyFactor(SalesInvoiceHeader."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Validate(Amount, SalesAdvLetterEntryCZZ.Amount);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                    end;
                SalesAdvLetterEntryCZZ."Entry Type"::Usage:
                    begin
                        CustLedgerEntry.Get(SalesAdvLetterEntryCZZ."Cust. Ledger Entry No.");
                        CustLedgerEntryInv := CustLedgerEntry;
#pragma warning disable AA0181
                        CustLedgerEntryInv.Next(-1);
#pragma warning restore AA0181
                        UnapplyCustLedgEntry(CustLedgerEntry, GenJnlPostLine);

                        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, CustLedgerEntry."Document Type"::" ");
                        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
                        GenJournalLine.Correction := true;
                        GenJournalLine."Adv. Letter No. (Entry) CZZ" := SalesAdvLetterEntryCZZ."Sales Adv. Letter No.";
                        GenJournalLine."Use Advance G/L Account CZZ" := true;
                        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Amount := -SalesAdvLetterEntryCZZ.Amount;
                        GenJournalLine."Amount (LCY)" := -SalesAdvLetterEntryCZZ."Amount (LCY)";

                        ApplId := CopyStr(CustLedgerEntry."Document No." + Format(CustLedgerEntry."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        CustLedgerEntry.CalcFields("Remaining Amount");
                        CustLedgerEntry."Amount to Apply" := CustLedgerEntry."Remaining Amount";
                        CustLedgerEntry."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntry);
                        GenJournalLine."Applies-to ID" := ApplId;

                        BindSubscription(GenJnlCheckLnHandlerCZZ);
                        GenJnlPostLine.RunWithCheck(GenJournalLine);

                        CustLedgerEntry.FindLast();
                        AdvEntryInit(false);
                        AdvEntryInitCancel();
                        AdvEntryInitCustLedgEntryNo(CustLedgerEntry."Entry No.");
                        AdvEntryInitRelatedEntry(SalesAdvLetterEntryCZZ."Entry No.");
                        AdvEntryInsert("Advance Letter Entry Type CZZ"::Usage, GenJournalLine."Adv. Letter No. (Entry) CZZ", GenJournalLine."Posting Date",
                            GenJournalLine.Amount, GenJournalLine."Amount (LCY)",
                            GenJournalLine."Currency Code", GenJournalLine."Currency Factor", SalesAdvLetterEntryCZZ."Document No.",
                            GenJournalLine."Shortcut Dimension 1 Code", GenJournalLine."Shortcut Dimension 2 Code", GenJournalLine."Dimension Set ID", false);

                        InitGenJnlLineFromCustLedgEntry(CustLedgerEntry, GenJournalLine, GenJournalLine."Document Type"::" ");
                        GenJournalLine."Adv. Letter Template Code CZZ" := SalesAdvLetterHeaderCZZ."Advance Letter Code";
                        GenJournalLine.Correction := true;
                        GenJournalLine.SetCurrencyFactor(SalesAdvLetterEntryCZZ."Currency Code", SalesAdvLetterEntryCZZ."Currency Factor");
                        GenJournalLine.Correction := true;
                        GenJournalLine.Amount := SalesAdvLetterEntryCZZ.Amount;
                        GenJournalLine."Amount (LCY)" := SalesAdvLetterEntryCZZ."Amount (LCY)";

                        ApplId := CopyStr(CustLedgerEntryInv."Document No." + Format(CustLedgerEntryInv."Entry No.", 0, '<Integer>'), 1, MaxStrLen(ApplId));
                        CustLedgerEntryInv.Prepayment := false;
                        CustLedgerEntryInv."Advance Letter No. CZZ" := '';
                        CustLedgerEntryInv.CalcFields("Remaining Amount");
                        CustLedgerEntryInv."Amount to Apply" := CustLedgerEntryInv."Remaining Amount";
                        CustLedgerEntryInv."Applies-to ID" := ApplId;
                        Codeunit.Run(Codeunit::"Cust. Entry-Edit", CustLedgerEntryInv);
                        GenJournalLine."Applies-to ID" := ApplId;

                        GenJnlPostLine.RunWithCheck(GenJournalLine);
                        UnbindSubscription(GenJnlCheckLnHandlerCZZ);

                        UpdateStatus(SalesAdvLetterHeaderCZZ, SalesAdvLetterHeaderCZZ.Status::"To Use");
                    end;
                else
                    Error(UnapplyIsNotPossibleErr);
            end;
        until SalesAdvLetterEntryCZZ.Next(-1) = 0;

        SalesAdvLetterEntryCZZ.ModifyAll(Cancelled, true);
    end;

    local procedure UnapplyCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        DetailedCustLedgEntry1: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry";
        DetailedCustLedgEntry3: Record "Detailed Cust. Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        Succes: Boolean;
        UnapplyLastInvoicesErr: Label 'First you must unapply invoces that were applied to advance last time.';
    begin
        DetailedCustLedgEntry1.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
        DetailedCustLedgEntry1.SetRange("Cust. Ledger Entry No.", CustLedgerEntry."Entry No.");
        DetailedCustLedgEntry1.SetRange("Entry Type", DetailedCustLedgEntry1."Entry Type"::Application);
        DetailedCustLedgEntry1.SetRange(Unapplied, false);
        Succes := false;
        repeat
            if DetailedCustLedgEntry1.FindLast() then begin
                DetailedCustLedgEntry2.Reset();
                DetailedCustLedgEntry2.SetCurrentKey("Transaction No.", "Customer No.", "Entry Type");
                DetailedCustLedgEntry2.SetRange("Transaction No.", DetailedCustLedgEntry1."Transaction No.");
                DetailedCustLedgEntry2.SetRange("Customer No.", DetailedCustLedgEntry1."Customer No.");
                if DetailedCustLedgEntry2.FindSet() then
                    repeat
                        if (DetailedCustLedgEntry2."Entry Type" <> DetailedCustLedgEntry2."Entry Type"::"Initial Entry") and
                           not DetailedCustLedgEntry2.Unapplied
                        then begin
                            DetailedCustLedgEntry3.Reset();
                            DetailedCustLedgEntry3.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type");
                            DetailedCustLedgEntry3.SetRange("Cust. Ledger Entry No.", DetailedCustLedgEntry2."Cust. Ledger Entry No.");
                            DetailedCustLedgEntry3.SetRange(Unapplied, false);
                            if DetailedCustLedgEntry3.FindLast() and
                               (DetailedCustLedgEntry3."Transaction No." > DetailedCustLedgEntry2."Transaction No.")
                            then
                                Error(UnapplyLastInvoicesErr);
                        end;
                    until DetailedCustLedgEntry2.Next() = 0;

                GenJournalLine.Init();
                GenJournalLine."Document No." := DetailedCustLedgEntry1."Document No.";
                GenJournalLine."Posting Date" := DetailedCustLedgEntry1."Posting Date";
#if not CLEAN22
#pragma warning disable AL0432
                if not ReplaceVATDateMgtCZL.IsEnabled() then
                    GenJournalLine.Validate("VAT Date CZL", GenJournalLine."Posting Date")
                else
#pragma warning restore AL0432
#endif
                GenJournalLine.Validate("VAT Reporting Date", GenJournalLine."Posting Date");
                GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
                GenJournalLine."Account No." := DetailedCustLedgEntry1."Customer No.";
                GenJournalLine.Correction := true;
                GenJournalLine."Document Type" := GenJournalLine."Document Type"::" ";
                GenJournalLine.Description := CustLedgerEntry.Description;
                GenJournalLine."Shortcut Dimension 1 Code" := CustLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := CustLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := CustLedgerEntry."Dimension Set ID";
                GenJournalLine."Posting Group" := CustLedgerEntry."Customer Posting Group";
                GenJournalLine."Source Currency Code" := DetailedCustLedgEntry1."Currency Code";
                GenJournalLine."System-Created Entry" := true;
                OnUnapplyCustLedgEntryOnBeforePostUnapplyCustLedgEntry(CustLedgerEntry, DetailedCustLedgEntry1, GenJournalLine);
                GenJnlPostLine.UnapplyCustLedgEntry(GenJournalLine, DetailedCustLedgEntry1);
            end else
                Succes := true;
        until Succes;
    end;

    procedure ApplyAdvanceLetter(var SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        AdvanceLetterApplication: Record "Advance Letter Application CZZ";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesAdvLetterManagement: Codeunit "SalesAdvLetterManagement CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        ApplyAdvanceLetterQst: Label 'Apply Advance Letter?';
        CannotApplyErr: Label 'You cannot apply more than %1.', Comment = '%1 = Remaining amount to apply';
    begin
        SalesAdvLetterManagement.LinkAdvanceLetter("Adv. Letter Usage Doc.Type CZZ"::"Posted Sales Invoice", SalesInvoiceHeader."No.", SalesInvoiceHeader."Bill-to Customer No.", SalesInvoiceHeader."Posting Date", SalesInvoiceHeader."Currency Code");

        AdvanceLetterApplication.SetRange("Document Type", AdvanceLetterApplication."Document Type"::"Posted Sales Invoice");
        AdvanceLetterApplication.SetRange("Document No.", SalesInvoiceHeader."No.");
        if AdvanceLetterApplication.IsEmpty() then
            exit;

        if not ConfirmManagement.GetResponseOrDefault(ApplyAdvanceLetterQst, false) then
            exit;

        CheckAdvancePayement(AdvanceLetterApplication."Document Type"::"Posted Sales Invoice", SalesInvoiceHeader."No.");
        AdvanceLetterApplication.CalcSums(Amount);
        CustLedgerEntry.SetCurrentKey("Document No.");
        CustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.FindLast();
        CustLedgerEntry.CalcFields("Remaining Amount");
        OnApplyAdvanceLetterOnBeforeTestAmount(AdvanceLetterApplication, CustLedgerEntry);
        if AdvanceLetterApplication.Amount > CustLedgerEntry."Remaining Amount" then
            Error(CannotApplyErr, CustLedgerEntry."Remaining Amount");

        PostAdvancePaymentUsage(AdvanceLetterApplication."Document Type"::"Posted Sales Invoice", SalesInvoiceHeader."No.", SalesInvoiceHeader,
            CustLedgerEntry, GenJnlPostLine, false);
    end;

    procedure CheckAdvancePayement(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20])
    var
        AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        ConfirmManagement: Codeunit "Confirm Management";
        UsageQst: Label 'Usage all applicated advances is not possible.\Continue?';
    begin
        AdvanceLetterApplicationCZZ.SetRange("Document Type", AdvLetterUsageDocTypeCZZ);
        AdvanceLetterApplicationCZZ.SetRange("Document No.", DocumentNo);
        if AdvanceLetterApplicationCZZ.FindSet() then
            repeat
                SalesAdvLetterHeaderCZZ.SetAutoCalcFields("To Use");
                SalesAdvLetterHeaderCZZ.Get(AdvanceLetterApplicationCZZ."Advance Letter No.");
                if SalesAdvLetterHeaderCZZ."To Use" < AdvanceLetterApplicationCZZ.Amount then
                    if not ConfirmManagement.GetResponseOrDefault(UsageQst, false) then
                        Error('');
            until AdvanceLetterApplicationCZZ.Next() = 0;
    end;

    procedure AdjustVATExchangeRate(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; Amount: Decimal; DetEntryNo: Integer; ToDate: Date; DocumentNo: Code[20]; PostDescription: Text[100])
    var
        TempAdvancePostingBufferCZZ1: Record "Advance Posting Buffer CZZ" temporary;
        TempAdvancePostingBufferCZZ2: Record "Advance Posting Buffer CZZ" temporary;
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        VATPostingSetup: Record "VAT Posting Setup";
        SalesAdvLetterEntryCZZ2: Record "Sales Adv. Letter Entry CZZ";
        SalesAdvLetterEntryCZZ3: Record "Sales Adv. Letter Entry CZZ";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        AmountToDivide: Decimal;
        AmountToPost: Decimal;
        AmountTotal: Decimal;
        Coeff: Decimal;
        VATAmountToPost: Decimal;
        VATDocAmtToDate: Decimal;
    begin
        if Amount = 0 then
            exit;
        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        SalesAdvLetterEntryCZZ2.SetRange("Det. Cust. Ledger Entry No.", DetEntryNo);
        if not SalesAdvLetterEntryCZZ2.IsEmpty() then
            exit;

        SalesAdvLetterHeaderCZZ.Get(SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");

        BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, ToDate, true);
        TempAdvancePostingBufferCZZ1.CalcSums(Amount);
        VATDocAmtToDate := TempAdvancePostingBufferCZZ1.Amount;
        if VATDocAmtToDate <> 0 then begin
            Coeff := Amount / VATDocAmtToDate;
            TempAdvancePostingBufferCZZ1.FindSet();
            repeat
                TempAdvancePostingBufferCZZ2.Init();
                TempAdvancePostingBufferCZZ2."VAT Bus. Posting Group" := TempAdvancePostingBufferCZZ1."VAT Bus. Posting Group";
                TempAdvancePostingBufferCZZ2."VAT Prod. Posting Group" := TempAdvancePostingBufferCZZ1."VAT Prod. Posting Group";
                TempAdvancePostingBufferCZZ2."VAT Calculation Type" := TempAdvancePostingBufferCZZ1."VAT Calculation Type";
                TempAdvancePostingBufferCZZ2."VAT %" := TempAdvancePostingBufferCZZ1."VAT %";

                TempAdvancePostingBufferCZZ2."Amount (ACY)" := Round(TempAdvancePostingBufferCZZ1.Amount * Coeff);
                case TempAdvancePostingBufferCZZ2."VAT Calculation Type" of
                    TempAdvancePostingBufferCZZ2."VAT Calculation Type"::"Normal VAT":
                        TempAdvancePostingBufferCZZ2."VAT Amount (ACY)" := Round(TempAdvancePostingBufferCZZ2."Amount (ACY)" * TempAdvancePostingBufferCZZ2."VAT %" / (100 + TempAdvancePostingBufferCZZ2."VAT %"));
                    TempAdvancePostingBufferCZZ2."VAT Calculation Type"::"Reverse Charge VAT":
                        TempAdvancePostingBufferCZZ2."VAT Amount (ACY)" := 0;
                end;
                TempAdvancePostingBufferCZZ2."VAT Base Amount (ACY)" := TempAdvancePostingBufferCZZ2."Amount (ACY)" - TempAdvancePostingBufferCZZ2."VAT Amount (ACY)";
                TempAdvancePostingBufferCZZ2.Insert();
            until TempAdvancePostingBufferCZZ1.Next() = 0;

            if TempAdvancePostingBufferCZZ2.FindSet() then
                repeat
                    VATPostingSetup.Get(TempAdvancePostingBufferCZZ2."VAT Bus. Posting Group", TempAdvancePostingBufferCZZ2."VAT Prod. Posting Group");
                    PostUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup, TempAdvancePostingBufferCZZ2."Amount (ACY)", TempAdvancePostingBufferCZZ2."VAT Amount (ACY)",
                        SalesAdvLetterEntryCZZ."Entry No.", DetEntryNo, DocumentNo, ToDate, PostDescription, GenJnlPostLine, false, false);
                until TempAdvancePostingBufferCZZ2.Next() = 0;

            BufferAdvanceVATLines(SalesAdvLetterEntryCZZ, TempAdvancePostingBufferCZZ1, 0D, true);
            TempAdvancePostingBufferCZZ1.CalcSums(Amount);
            TempAdvancePostingBufferCZZ2.CalcSums("Amount (ACY)");
            if TempAdvancePostingBufferCZZ1.Amount = 0 then
                AmountToDivide := TempAdvancePostingBufferCZZ2."Amount (ACY)"
            else begin
                SalesAdvLetterEntryCZZ2.Reset();
                SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
                SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
                SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::"VAT Payment");
                SalesAdvLetterEntryCZZ2.CalcSums(Amount);
                AmountToDivide := Round(TempAdvancePostingBufferCZZ2."Amount (ACY)" * (VATDocAmtToDate - TempAdvancePostingBufferCZZ1.Amount) / SalesAdvLetterEntryCZZ2.Amount);
            end;

            AmountTotal := 0;
            SalesAdvLetterEntryCZZ2.Reset();
            SalesAdvLetterEntryCZZ2.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
            SalesAdvLetterEntryCZZ2.SetRange(Cancelled, false);
            SalesAdvLetterEntryCZZ2.SetRange("Related Entry", SalesAdvLetterEntryCZZ."Entry No.");
            SalesAdvLetterEntryCZZ2.SetRange("Entry Type", SalesAdvLetterEntryCZZ2."Entry Type"::Usage);
            SalesAdvLetterEntryCZZ2.SetFilter("Posting Date", '>%1', ToDate);
            if SalesAdvLetterEntryCZZ2.FindSet() then begin
                repeat
                    SalesAdvLetterEntryCZZ3.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    SalesAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ3.SetRange("Related Entry", SalesAdvLetterEntryCZZ2."Entry No.");
                    SalesAdvLetterEntryCZZ3.SetRange("Entry Type", SalesAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    SalesAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    SalesAdvLetterEntryCZZ3.CalcSums(Amount);
                    AmountTotal += SalesAdvLetterEntryCZZ3.Amount;
                until SalesAdvLetterEntryCZZ2.Next() = 0;

                Coeff := AmountToDivide / AmountTotal;
                SalesAdvLetterEntryCZZ2.FindSet();
                repeat
                    SalesAdvLetterEntryCZZ3.SetRange("Sales Adv. Letter No.", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.");
                    SalesAdvLetterEntryCZZ3.SetRange(Cancelled, false);
                    SalesAdvLetterEntryCZZ3.SetRange("Related Entry", SalesAdvLetterEntryCZZ2."Entry No.");
                    SalesAdvLetterEntryCZZ3.SetRange("Entry Type", SalesAdvLetterEntryCZZ3."Entry Type"::"VAT Usage");
                    SalesAdvLetterEntryCZZ3.SetFilter("Posting Date", '>%1', ToDate);
                    if SalesAdvLetterEntryCZZ3.FindSet() then
                        repeat
                            AmountToPost := Round(SalesAdvLetterEntryCZZ3.Amount * Coeff);
                            case SalesAdvLetterEntryCZZ3."VAT Calculation Type" of
                                SalesAdvLetterEntryCZZ3."VAT Calculation Type"::"Normal VAT":
                                    VATAmountToPost := Round(AmountToPost * SalesAdvLetterEntryCZZ3."VAT %" / (100 + SalesAdvLetterEntryCZZ3."VAT %"));
                                TempAdvancePostingBufferCZZ2."VAT Calculation Type"::"Reverse Charge VAT":
                                    VATAmountToPost := 0;
                            end;

                            VATPostingSetup.Get(SalesAdvLetterEntryCZZ3."VAT Bus. Posting Group", SalesAdvLetterEntryCZZ3."VAT Prod. Posting Group");
                            PostUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup, -AmountToPost, -VATAmountToPost,
                                SalesAdvLetterEntryCZZ2."Entry No.", 0, DocumentNo, SalesAdvLetterEntryCZZ3."Posting Date", PostDescription, GenJnlPostLine, false, false);
                        until SalesAdvLetterEntryCZZ3.Next() = 0;
                until SalesAdvLetterEntryCZZ2.Next() = 0;
            end;
        end;
    end;

    local procedure PostUnrealizedExchangeRate(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var VATPostingSetup: Record "VAT Posting Setup";
        Amount: Decimal; VATAmount: Decimal; RelatedEntryNo: Integer; RelatedDetEntryNo: Integer; DocumentNo: Code[20]; PostingDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        Correction: Boolean; Preview: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
    begin
        SourceCodeSetup.Get();
        GetCurrency(SalesAdvLetterHeaderCZZ."Currency Code");

        if VATAmount <> 0 then begin
            InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCodeSetup."Exchange Rate Adjmt.", PostDescription, GenJournalLine);
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

            InitGenJnlLineFromAdvance(SalesAdvLetterHeaderCZZ, SalesAdvLetterEntryCZZ, DocumentNo, SourceCodeSetup."Exchange Rate Adjmt.", PostDescription, GenJournalLine);
            GenJournalLine.Validate("Posting Date", PostingDate);
            GenJournalLine."Account No." := VATPostingSetup."Sales Adv. Letter Account CZZ";
            GenJournalLine.Validate(Amount, -VATAmount);
            if not Preview then
                GenJnlPostLine.RunWithCheck(GenJournalLine);
        end;

        AdvEntryInit(Preview);
        if Correction then
            AdvEntryInitCancel();
        AdvEntryInitRelatedEntry(RelatedEntryNo);
        AdvEntryInitDetCustLedgEntryNo(RelatedDetEntryNo);
        AdvEntryInitVAT(VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group", PostingDate,
            0, VATPostingSetup."VAT %", VATPostingSetup."VAT Identifier", VATPostingSetup."VAT Calculation Type",
            0, VATAmount, 0, Amount - VATAmount);
        AdvEntryInsert("Advance Letter Entry Type CZZ"::"VAT Adjustment", SalesAdvLetterEntryCZZ."Sales Adv. Letter No.", PostingDate,
            0, Amount, '', 0, DocumentNo,
            SalesAdvLetterEntryCZZ."Global Dimension 1 Code", SalesAdvLetterEntryCZZ."Global Dimension 2 Code", SalesAdvLetterEntryCZZ."Dimension Set ID", Preview);
    end;

    local procedure ReverseUnrealizedExchangeRate(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        var VATPostingSetup: Record "VAT Posting Setup"; Coef: Decimal; RelatedEntryNo: Integer;
        DocumentNo: Code[20]; PostingDate: Date; PostDescription: Text[100]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    var
        AmountLCY: Decimal;
        VATAmountLCY: Decimal;
    begin
        if SalesAdvLetterEntryCZZ."Entry Type" <> SalesAdvLetterEntryCZZ."Entry Type"::Payment then
            exit;

        GetRemAmtLCYVATAdjust(AmountLCY, VATAmountLCY, SalesAdvLetterEntryCZZ, PostingDate, VATPostingSetup."VAT Bus. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        if (AmountLCY = 0) and (VATAmountLCY = 0) then
            exit;

        AmountLCY := Round(AmountLCY * Coef);
        VATAmountLCY := Round(VATAmountLCY * Coef);

        PostUnrealizedExchangeRate(SalesAdvLetterEntryCZZ, SalesAdvLetterHeaderCZZ, VATPostingSetup, -AmountLCY, -VATAmountLCY,
            RelatedEntryNo, 0, DocumentNo, PostingDate, PostDescription, GenJnlPostLine, false, Preview);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertAdvEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInsertAdvEntry(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var Preview: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateStatus(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; AdvanceLetterDocStatusCZZ: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUpdateStatus(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; AdvanceLetterDocStatusCZZ: Enum "Advance Letter Doc. Status CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPayment(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostPayment(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; PostedGenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostReversePayment(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostReversePaymentVAT(var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; var Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePaymentRepos(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostAdvanceCreditMemoVATOnAfterGetValues(SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; PostingDate: Date; VATDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostClosePayment(var GenJournalLine: Record "Gen. Journal Line"; var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnApplyAdvanceLetterOnBeforeTestAmount(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitGenJnlLineFromCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnUnapplyCustLedgEntryOnBeforePostUnapplyCustLedgEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterInitGenJnlLineFromAdvance(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostAdvancePayment(CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line"; LinkAmount: Decimal; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLinkAdvanceLetterOnBeforeModifyAdvanceLetterApplication(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary; var ModifyRecord: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLinkAdvanceLetterOnBeforeInsertAdvanceLetterApplication(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var TempAdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnPostAdvancePaymentUsageOnBeforeLoopSalesAdvLetterEntry(var AdvanceLetterApplicationCZZ: Record "Advance Letter Application CZZ"; var SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterPostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePostAdvancePaymentUsage(AdvLetterUsageDocTypeCZZ: Enum "Adv. Letter Usage Doc.Type CZZ"; DocumentNo: Code[20]; var SalesInvoiceHeader: Record "Sales Invoice Header"; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; Preview: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCorrectDocumentAfterPaymentUsage(DocumentNo: Code[20]; var CustLedgerEntry: Record "Cust. Ledger Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnPostAdvancePaymentVATOnBeforeGenJnlPostLine(SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; SalesAdvLetterEntryCZZ: Record "Sales Adv. Letter Entry CZZ"; var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}
