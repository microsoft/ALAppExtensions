codeunit 11746 "Gen. Journal Line Handler CZL"
{
    Permissions = tabledata "VAT Entry" = d,
                  tabledata "G/L Entry - VAT Entry Link" = d;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlPostAccGroupCZL: Codeunit "Gen.Jnl. - Post Acc. Group CZL";


    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure UpdateBankInfoOnAfterGenJnlLineDocumentTypeValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Bank Account Code CZL", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Bill-to/Pay-to No.', false, false)]
    local procedure UpdateBankInfoOnAfterGenJnlLineBiilToPayToNoValidate(var Rec: Record "Gen. Journal Line")
    begin
        Rec.Validate("Bank Account Code CZL", '');
    end;

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
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Bill-to/Sell-to VAT Calc." = GeneralLedgerSetup."Bill-to/Sell-to VAT Calc."::"Bill-to/Pay-to No." then
            BillPaySellBuyNo := GenJournalLine."Bill-to/Pay-to No.";
        if GeneralLedgerSetup."Bill-to/Sell-to VAT Calc." = GeneralLedgerSetup."Bill-to/Sell-to VAT Calc."::"Sell-to/Buy-from No." then
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
        GenJournalLine."Posting Group" := ServiceHeader."Customer Posting Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeOpenJnl', '', false, false)]
    local procedure JournalTemplateUserRestrictionsOnBeforeOpenJnl(var CurrentJnlBatchName: Code[10]; var GenJnlLine: Record "Gen. Journal Line")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
        UserSetupLineTypeCZL: Enum "User Setup Line Type CZL";
        JournalTemplateName: Code[10];
    begin
        JournalTemplateName := GenJnlLine.GetRangeMax("Journal Template Name");
        UserSetupLineTypeCZL := UserSetupLineTypeCZL::"General Journal";
        UserSetupAdvManagementCZL.CheckJournalTemplate(UserSetupLineTypeCZL, JournalTemplateName);

        if GenJnlLine.GetFilter("Journal Batch Name") <> '' then begin
            CurrentJnlBatchName := GenJnlLine.GetRangeMax("Journal Batch Name");
            GenJnlLine.SetRange("Journal Batch Name");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateEvent', 'Type', false, false)]
    local procedure UpdateTestReportIdOnAfterValidateType(var Rec: Record "Gen. Journal Template")
    begin
        Rec."Test Report ID" := Report::"General Journal - Test CZL";
    end;

#if not CLEAN17
#pragma warning disable AL0432
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
#pragma warning restore AL0432

#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure CheckVatDateOnBeforeRunCheck(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if GenJournalLine."VAT Date CZL" = 0D then
            GenJournalLine.Validate("VAT Date CZL", GenJournalLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckVatDateOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
        VATDateNeeded: Boolean;
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Use VAT Date CZL" then begin
            VATDateNeeded := false;
            if GenJournalLine."Gen. Posting Type" <> Enum::"General Posting Type"::" " then
                if VATPostingSetup.Get(GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group") then
                    VATDateNeeded := true;
            if GenJournalLine."Bal. Gen. Posting Type" <> Enum::"General Posting Type"::" " then
                if VATPostingSetup.Get(GenJournalLine."Bal. VAT Bus. Posting Group", GenJournalLine."Bal. VAT Prod. Posting Group") then
                    VATDateNeeded := true;
            if VATDateNeeded then
                VATDateHandlerCZL.CheckVATDateCZL(GenJournalLine);
            if (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) and
               (GenJournalLine."Document Type" in [GenJournalLine."Document Type"::"Credit Memo", GenJournalLine."Document Type"::Invoice])
            then
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

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Posting Group', false, false)]
    local procedure CheckPostingGroupChangeOnBeforeCustomerPostingGroupValidate(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; CurrFieldNo: Integer)
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        if CurrFieldNo = Rec.FieldNo("Posting Group") then
            PostingGroupManagementCZL.CheckPostingGroupChange(Rec."Posting Group", xRec."Posting Group", Rec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitNewDtldCVLedgEntryBuf', '', false, false)]
    local procedure SetApplAcrossPostGroupsCZLOnAfterInitNewDtldCVLedgEntryBuf(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        DtldCVLedgEntryBuf.SetApplAcrossPostGroupsCZL(NewCVLedgEntryBuf."CV Posting Group" <> OldCVLedgEntryBuf."CV Posting Group");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeGetDtldCustLedgEntryAccNo', '', false, false)]
    local procedure GetApplAcrossPostGrpAccNoOnBeforeGetDtldCustLedgEntryAccNo(var DetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; var AccountNo: code[20]; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if not DetailedCVLedgEntryBuffer."Appl. Across Post. Groups CZL" then
            exit;

        AccountNo := GetReceivablesAccNo(DetailedCVLedgEntryBuffer."CV Ledger Entry No.");
        IsHandled := true;
    end;

    local procedure GetReceivablesAccNo(CustLedgerEntryNo: Integer): Code[20]
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.Get(CustLedgerEntryNo);
        exit(GetReceivablesAccNo(CustLedgerEntry));
    end;

    procedure GetReceivablesAccNo(CustLedgerEntry: Record "Cust. Ledger Entry"): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        GLAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReceivablesAccountNo(CustLedgerEntry, GLAccountNo, IsHandled);
        if IsHandled then
            exit(GLAccountNo);

        CustLedgerEntry.TestField("Customer Posting Group");
        CustomerPostingGroup.Get(CustLedgerEntry."Customer Posting Group");
#if not CLEAN19
#pragma warning disable AL0432
        if CustLedgerEntry.Prepayment and (CustLedgerEntry."Prepayment Type" = CustLedgerEntry."Prepayment Type"::Advance) then begin
            CustomerPostingGroup.TestField("Advance Account");
            exit(CustomerPostingGroup."Advance Account");
        end;
#pragma warning restore AL0432
#endif
        CustomerPostingGroup.TestField("Receivables Account");
        exit(CustomerPostingGroup.GetReceivablesAccount());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeGetDtldVendLedgEntryAccNo', '', false, false)]
    local procedure GetApplAcrossPostGrpAccNoOnBeforeGetDtldVendLedgEntryAccNo(var DetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; var AccountNo: code[20]; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if not DetailedCVLedgEntryBuffer."Appl. Across Post. Groups CZL" then
            exit;

        AccountNo := GetPayablesAccNo(DetailedCVLedgEntryBuffer."CV Ledger Entry No.");
        IsHandled := true;
    end;

    local procedure GetPayablesAccNo(VendorLedgerEntryNo: Integer): Code[20]
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.Get(VendorLedgerEntryNo);
        exit(GetPayablesAccNo(VendorLedgerEntry));
    end;

    procedure GetPayablesAccNo(VendorLedgerEntry: Record "Vendor Ledger Entry"): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
        GLAccountNo: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetPayablesAccountNo(VendorLedgerEntry, GLAccountNo, IsHandled);
        if IsHandled then
            exit(GLAccountNo);

        VendorLedgerEntry.TestField("Vendor Posting Group");
        VendorPostingGroup.Get(VendorLedgerEntry."Vendor Posting Group");
#if not CLEAN19
#pragma warning disable AL0432
        if VendorLedgerEntry.Prepayment and (VendorLedgerEntry."Prepayment Type" = VendorLedgerEntry."Prepayment Type"::Advance) then begin
            VendorPostingGroup.TestField("Advance Account");
            exit(VendorPostingGroup."Advance Account");
        end;
#pragma warning restore AL0432
#endif
        VendorPostingGroup.TestField("Payables Account");
        exit(VendorPostingGroup.GetPayablesAccount());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostDtldCVLedgEntry', '', false, false)]
    local procedure PostApplAcrossPostGroupsOnBeforePostDtldCVLedgEntry(Sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; var DetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; var AccNo: Code[20]; var Unapply: Boolean; var AdjAmount: array[4] of Decimal)
    var
        CorrectionFlag: Boolean;
    begin
        if not DetailedCVLedgEntryBuffer."Appl. Across Post. Groups CZL" then
            exit;
        GeneralLedgerSetup.Get();
        CorrectionFlag := GenJournalLine.Correction;
        GenJournalLine.Correction := not Unapply;
        Sender.CreateGLEntry(GenJournalLine, AccNo, DetailedCVLedgEntryBuffer."Amount (LCY)", 0, DetailedCVLedgEntryBuffer."Currency Code" = GeneralLedgerSetup."Additional Reporting Currency");
        GenJournalLine.Correction := CorrectionFlag;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostApplyCustLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostApplyCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"CustEntry-Apply Posted Entries", 'OnBeforePostUnapplyCustLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostUnapplyCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; CustLedgerEntry: Record "Cust. Ledger Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostApplyVendLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostApplyVendLedgEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostUnapplyVendLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostUnapplyVendLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Date CZL";
    end;

#if not CLEAN18
#pragma warning disable AL0432
    [Obsolete('This procedure will be removed after removing feature from Base Application.', '18.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckMultiplePostingGr', '', false, false)]
    local procedure ResetMultiplePostingGroupsOnBeforeCheckMultiplePostingGr(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; Customer: Boolean; var MultiplePostingGroups: Boolean; var IsHandled: Boolean);
    begin
        if IsHandled then
            exit;
        MultiplePostingGroups := false; // Disable BaseApp MultiplePostingGrApplied flag to prevent duplicate detail entry posting to G/L.
        IsHandled := true;
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '18.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckDetCustLedgEntryMultiplePostingGrOnBeforeUnapply', '', false, false)]
    local procedure ResetMultiplePostingGroupsOnBeforeCheckDetCustLedgEntryMultiplePostingGrOnBeforeUnapply(var DetailedCustLedgEntry2: Record "Detailed Cust. Ledg. Entry"; DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; var MultiplePostingGroups: Boolean; var IsHandled: Boolean);
    begin
        if IsHandled then
            exit;
        MultiplePostingGroups := false; // Disable BaseApp MultiplePostingGrApplied flag to prevent duplicate detail entry posting to G/L.
        IsHandled := true;
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '18.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckDetVendLedgEntryMultiplePostingGrOnBeforeUnapply', '', false, false)]
    local procedure ResetMultiplePostingGroupsOnBeforeCheckDetVendLedgEntryMultiplePostingGrOnBeforeUnapply(var DetailedVendorLedgEntry2: Record "Detailed Vendor Ledg. Entry"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var MultiplePostingGroups: Boolean; var IsHandled: Boolean);
    begin
        if IsHandled then
            exit;
        MultiplePostingGroups := false; // Disable BaseApp MultiplePostingGrApplied flag to prevent duplicate detail entry posting to G/L.
        IsHandled := true;
    end;
#pragma warning restore AL0432

#endif
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInitVATOnBeforeVATPostingSetupCheck', '', false, false)]
    local procedure SkipVATCalculationTypeCheckForVATLCYCorrection(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
        if IsVATLCYCorrectionSourceCodeCZL(GenJournalLine."Source Code") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertVATOnBeforeCreateGLEntryForReverseChargeVATToRevChargeAcc', '', false, false)]
    local procedure SuppressReverseChargePostingForVATLCYCorrection(var GenJournalLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; UnrealizedVAT: Boolean; var VATAmount: Decimal; var VATAmountAddCurr: Decimal; UseAmountAddCurr: Boolean)
    begin
        if IsVATLCYCorrectionSourceCodeCZL(GenJournalLine."Source Code") then
            VATAmount := 0;
    end;

    local procedure IsVATLCYCorrectionSourceCodeCZL(SrcCode: Code[10]): Boolean
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SrcCode = '' then
            exit;
        SourceCodeSetup.Get();
        exit(SourceCodeSetup."VAT LCY Correction CZL" = SrcCode)
    end;
#if not CLEAN18

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCalculatedVATAmountLCY', '', false, false)]
    local procedure OnBeforeCalculatedVATAmountLCY(GenJournalLine: Record "Gen. Journal Line"; var CalculatedVATAmtLCY: Decimal; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        CalculatedVATAmtLCY := GenJournalLine."VAT Amount (LCY)";
        IsHandled := true;
    end;
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVAT', '', false, false)]
    local procedure UpdateVATAmountOnAfterInitVAT(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    begin
        if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::" ") or
           (GenJournalLine."VAT Posting" <> GenJournalLine."VAT Posting"::"Automatic VAT Entry") or
           (GenJournalLine."VAT Calculation Type" <> GenJournalLine."VAT Calculation Type"::"Normal VAT") or
           (GenJournalLine."VAT Difference" <> 0)
        then
            exit;

        GLEntry.Amount := GenJournalLine."VAT Base Amount (LCY)";
        GLEntry."VAT Amount" := GenJournalLine."VAT Amount (LCY)";
    end;

#if CLEAN19
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer");
    begin
        GenJnlLine.Correction := InvoicePostBuffer."Correction CZL";
        GenJnlLine."VAT Date CZL" := InvoicePostBuffer."VAT Date CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;
#else
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromInvPostBuffer', '', false, false)]
    local procedure CopyOnAfterCopyGenJnlLineFromInvPostBuffer(InvoicePostBuffer: Record "Invoice Post. Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine.Correction := InvoicePostBuffer."Correction CZL";
        GenJournalLine."VAT Date CZL" := InvoicePostBuffer."VAT Date CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmt(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmt(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReceivablesAccountNo(CustLedgerEntry: Record "Cust. Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetPayablesAccountNo(VendorLedgerEntry: Record "Vendor Ledger Entry"; var GLAccountNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
