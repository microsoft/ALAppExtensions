#pragma warning disable AL0432
codeunit 11746 "Gen. Journal Line Handler CZL"
{
    Permissions = TableData "VAT Entry" = d,
                  TableData "G/L Entry - VAT Entry Link" = d;

    var
        GLSetup: Record "General Ledger Setup";
        GenJnlPostAccGroupCZL: Codeunit "Gen.Jnl. - Post Acc. Group CZL";

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforeGenJnlLinePostingDateValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account No.', false, false)]
    local procedure UpdateOriginalDocPartnerTypeOnBeforeGenJnlLineAccountNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Original Doc. Partner Type CZL", Rec."Original Doc. Partner Type CZL"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Bal. Account No.', false, false)]
    local procedure UpdateOriginalDocPartnerTypeOnBeforeGenJnlLineBalAccountNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Original Doc. Partner Type CZL", Rec."Original Doc. Partner Type CZL"::" ");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetUpNewLine', '', false, false)]
    local procedure UpdateVatDateOnAfterGenJnlLineSetUpNewLine(var GenJournalLine: Record "Gen. Journal Line"; LastGenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Validate("VAT Date CZL", LastGenJournalLine."VAT Date CZL");
        if GenJournalLine."VAT Date CZL" = 0D then
            GenJournalLine.Validate("VAT Date CZL", WorkDate());
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterUpdateCountryCodeAndVATRegNo', '', false, false)]
    local procedure UpdateRegNoOnAfterUpdateCountryCodeAndVATRegNo(var GenJournalLine: Record "Gen. Journal Line")
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        BillPaySellBuyNo: Code[20];
    begin
        GLSetup.Get();
        if GLSetup."Bill-to/Sell-to VAT Calc." = GLSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." then
            BillPaySellBuyNo := GenJournalLine."Bill-to/Pay-to No.";
        if GLSetup."Bill-to/Sell-to VAT Calc." = GLSetup."Bill-to/Sell-to VAT Calc."::"Sell-to/Buy-from No." then
            BillPaySellBuyNo := GenJournalLine."Sell-to/Buy-from No.";

        if BillPaySellBuyNo = '' then begin
            GenJournalLine."Registration No. CZL" := '';
            exit;
        end;
        case true of
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Customer) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Customer):
                begin
                    Customer.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Customer."Registration No. CZL";
                    GenJournalLine."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
                end;
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor):
                begin
                    Vendor.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Vendor."Registration No. CZL";
                    GenJournalLine."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromSalesHeader(var GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    begin
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
        GenJournalLine."Registration No. CZL" := SalesHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := SalesHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromPurchHeader(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := PurchaseHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3-Party Trade CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromServHeader', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromServHeader(var GenJournalLine: Record "Gen. Journal Line"; ServiceHeader: Record "Service Header")
    begin
        GenJournalLine."VAT Date CZL" := ServiceHeader."VAT Date CZL";
        GenJournalLine."Registration No. CZL" := ServiceHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := ServiceHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := ServiceHeader."EU 3-Party Intermed. Role CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure UpdateTestReportIdOnAfterValidateType(var Rec: Record "Gen. Journal Template")
    begin
        Rec."Test Report ID" := Report::"General Journal - Test CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateEvent', 'Test Report ID', false, false)]
    local procedure UpdateTestReportIdOnAfterValidatePostingReportID(var Rec: Record "Gen. Journal Template"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = 0 then
            if Rec."Test Report ID" = Report::"General Journal - Test" then
                Rec."Test Report ID" := Report::"General Journal - Test CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateEvent', 'Posting Report ID', false, false)]
    local procedure UpdatePostingReportIdOnAfterValidatePostingReportID(var Rec: Record "Gen. Journal Template"; CurrFieldNo: Integer)
    begin
        if CurrFieldNo = 0 then
            if Rec."Posting Report ID" = Report::"General Ledger Document" then
                Rec."Posting Report ID" := Report::"General Ledger Document CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure CheckVatDateOnBeforeRunCheck(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."VAT Date CZL" = 0D then
            GenJournalLine.Validate("VAT Date CZL", GenJournalLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckVatDateOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        VATDateHandler: Codeunit "VAT Date Handler CZL";
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
        GLSetup.Get();
        if GLSetup."Use VAT Date CZL" then begin
            VATDateHandler.CheckVATDateCZL(GenJournalLine);
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and (GenJournalLine."Document Type" <> GenJournalLine."Document Type"::" ") then
                GenJournalLine.TestField("Original Doc. VAT Date CZL");
            if GenJournalLine."Original Doc. VAT Date CZL" > GenJournalLine."VAT Date CZL" then
                GenJournalLine.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, GenJournalLine.FieldCaption(GenJournalLine."VAT Date CZL")));
        end;
        if GenJournalLine."Original Doc. Partner Type CZL" <> GenJournalLine."Original Doc. Partner Type CZL"::" " then begin
            GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::"G/L Account".AsInteger());
            GenJournalLine.TestField("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account".AsInteger());
            GenJournalLine.TestField("Original Doc. Partner No. CZL");
            case GenJournalLine."Gen. Posting Type" of
                GenJournalLine."Gen. Posting Type"::Sale:
                    GenJournalLine.TestField("Original Doc. Partner Type CZL", GenJournalLine."Original Doc. Partner Type CZL"::Customer);
                GenJournalLine."Gen. Posting Type"::Purchase:
                    GenJournalLine.TestField("Original Doc. Partner Type CZL", GenJournalLine."Original Doc. Partner Type CZL"::Vendor);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCode', '', false, false)]
    local procedure UpdateVatDateOnBeforeCode(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."VAT Date CZL" = 0D then
            GenJnlLine.Validate("VAT Date CZL", GenJnlLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertTempVATEntry', '', false, false)]
    local procedure UpdateVatDateOnBeforeInsertTempVATEntry(var TempVATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(TempVATEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertTempVATEntryOnBeforeInsert', '', false, false)]
    local procedure UpdateVatDateOnInsertTempVATEntryOnBeforeInsert(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(VATEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertPostUnrealVATEntry', '', false, false)]
    local procedure UpdateVatDateOnBeforeInsertPostUnrealVATEntry(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(VATEntry, GenJournalLine);
    end;

    local procedure UpdateVATEntryCZL(var VATEntry: Record "VAT Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
        VATEntry."Original Doc. VAT Date CZL" := GenJournalLine."Original Doc. VAT Date CZL";
        VATEntry."Registration No. CZL" := GenJournalLine."Registration No. CZL";
        VATEntry."Tax Registration No. CZL" := GenJournalLine."Tax Registration No. CZL";
        VATEntry."VAT Settlement No. CZL" := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertVATEntry', '', false, false)]
    local procedure DeleteSettlementReverseVATEntryOnAfterInsertVATEntry(VATEntry: Record "VAT Entry"; GLEntryNo: Integer; var NextEntryNo: Integer)
    var
        GLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link";
    begin
        if (VATEntry.Type = VATEntry.Type::Settlement) and
           (VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT") and
           (VATEntry."Document Type" = VATEntry."Document Type"::" ") and
           (VATEntry.Base = 0) and (VATEntry.Amount <> 0)
        then begin
            VATEntry.Delete(false);
            GLEntryVATEntryLink.Get(GLEntryNo, VATEntry."Entry No.");
            GLEntryVATEntryLink.Delete(false);
            NextEntryNo -= 1;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure UpdateCheckAmountsOnBeforeInsertGLEntryBuffer(var TempGLEntryBuf: Record "G/L Entry")
    begin
        GenJnlPostAccGroupCZL.UpdateCheckAmounts(TempGLEntryBuf);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterSettingIsTransactionConsistent', '', false, false)]
    local procedure CheckAccountGroupAmountsOnAfterSettingIsTransactionConsistent(var IsTransactionConsistent: Boolean)
    begin
        IsTransactionConsistent := IsTransactionConsistent and GenJnlPostAccGroupCZL.IsAcountGroupTransactionConsistent();
    end;
}
