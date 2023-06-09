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
#if not CLEAN22

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforeGenJnlLinePostingDateValidate(var Rec: Record "Gen. Journal Line")
    begin
        if Rec.IsReplaceVATDateEnabled() then
            exit;
#pragma warning disable AL0432
        Rec.Validate("VAT Date CZL", Rec."Posting Date");
#pragma warning restore AL0432
    end;
#endif

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
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then begin
            GenJournalLine.Validate("VAT Date CZL", LastGenJournalLine."VAT Date CZL");
            if GenJournalLine."VAT Date CZL" = 0D then
                GenJournalLine.Validate("VAT Date CZL", WorkDate());
            GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Date CZL";
            exit;
        end;
#pragma warning restore AL0432
#endif
        if GenJournalLine."VAT Reporting Date" = 0D then
            GenJournalLine."VAT Reporting Date" := WorkDate();
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
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
                    GenJournalLine."Registration No. CZL" := Customer.GetRegistrationNoTrimmedCZL();
                    GenJournalLine."Tax Registration No. CZL" := Customer."Tax Registration No. CZL";
                end;
            (GenJournalLine."Account Type" = GenJournalLine."Account Type"::Vendor) or (GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::Vendor):
                begin
                    Vendor.Get(BillPaySellBuyNo);
                    GenJournalLine."Registration No. CZL" := Vendor.GetRegistrationNoTrimmedCZL();
                    GenJournalLine."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromSalesHeader(var GenJournalLine: Record "Gen. Journal Line"; SalesHeader: Record "Sales Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := SalesHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := SalesHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := SalesHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := SalesHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeader', '', false, false)]
    local procedure UpdateFieldsOnAfterCopyGenJnlLineFromPurchHeader(var GenJournalLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := PurchaseHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := PurchaseHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Trade" := PurchaseHeader."EU 3-Party Trade CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := PurchaseHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Original Doc. VAT Date CZL" := PurchaseHeader."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromServHeader', '', false, false)]
    local procedure UpdateVatDateOnAfterCopyGenJnlLineFromServHeader(var GenJournalLine: Record "Gen. Journal Line"; ServiceHeader: Record "Service Header")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := ServiceHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := ServiceHeader."VAT Reporting Date";
        GenJournalLine."Registration No. CZL" := ServiceHeader."Registration No. CZL";
        GenJournalLine."Tax Registration No. CZL" := ServiceHeader."Tax Registration No. CZL";
        GenJournalLine."EU 3-Party Intermed. Role CZL" := ServiceHeader."EU 3-Party Intermed. Role CZL";
        GenJournalLine."Posting Group" := ServiceHeader."Customer Posting Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnTemplateSelectionSetFilter', '', false, false)]
    local procedure SetFilterTemplateNameOnTemplateSelectionSetFilter(var GenJnlTemplate: Record "Gen. Journal Template"; var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine.GetFilter("Journal Template Name") <> '' then
            GenJnlLine.CopyFilter("Journal Template Name", GenJnlTemplate.Name);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeRunTemplateJournalPage', '', false, false)]
    local procedure ClearFilterTemplateNameOnBeforeRunTemplateJournalPage(var GenJnlLine: Record "Gen. Journal Line")
    begin
        GenJnlLine.SetRange("Journal Template Name");
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnBeforeRunCheck', '', false, false)]
    local procedure CheckVatDateOnBeforeRunCheck(var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then begin
            if GenJournalLine."VAT Date CZL" = 0D then
                GenJournalLine.Validate("VAT Date CZL", GenJournalLine."Posting Date");
            exit;
        end;
#pragma warning restore AL0432
#endif
        if GenJournalLine."VAT Reporting Date" = 0D then
            GenJournalLine.Validate("VAT Reporting Date", GenJournalLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckVatDateOnAfterCheckGenJnlLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        VATPostingSetup: Record "VAT Posting Setup";
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
        VATDateNeeded: Boolean;
        MustBeLessOrEqualErr: Label 'must be less or equal to %1', Comment = '%1 = fieldcaption of VAT Date CZL';
    begin
        if VATReportingDateMgt.IsVATDateEnabled() then begin
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
#if not CLEAN22
#pragma warning disable AL0432
            if not GenJournalLine.IsReplaceVATDateEnabled() then
                if GenJournalLine."Original Doc. VAT Date CZL" > GenJournalLine."VAT Date CZL" then
                    GenJournalLine.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, GenJournalLine.FieldCaption(GenJournalLine."VAT Date CZL")));
            if GenJournalLine.IsReplaceVATDateEnabled() then
#pragma warning restore AL0432
#endif
                if GenJournalLine."Original Doc. VAT Date CZL" > GenJournalLine."VAT Reporting Date" then
                    GenJournalLine.FieldError("Original Doc. VAT Date CZL", StrSubstNo(MustBeLessOrEqualErr, GenJournalLine.FieldCaption(GenJournalLine."VAT Reporting Date")));
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
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJnlLine.IsReplaceVATDateEnabled() then begin
            if GenJnlLine."VAT Date CZL" = 0D then
                GenJnlLine.Validate("VAT Date CZL", GenJnlLine."Posting Date");
            exit;
        end;
#pragma warning restore AL0432
#endif
        if GenJnlLine."VAT Reporting Date" = 0D then
            GenJnlLine.Validate("VAT Reporting Date", GenJnlLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertTempVATEntry', '', false, false)]
    local procedure UpdateVatDateOnBeforeInsertTempVATEntry(var TempVATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(TempVATEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertTempVATEntryOnBeforeInsert', '', false, false)]
    local procedure UpdateVatDateOnInsertTempVATEntryOnBeforeInsert(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."VAT Reporting Date" := GenJournalLine."VAT Reporting Date";
        UpdateVATEntryCZL(VATEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertPostUnrealVATEntry', '', false, false)]
    local procedure UpdateVatDateOnBeforeInsertPostUnrealVATEntry(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(VATEntry, GenJournalLine);
    end;

    local procedure UpdateVATEntryCZL(var VATEntry: Record "VAT Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        VATEntry."VAT Date CZL" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
        VATEntry."Original Doc. VAT Date CZL" := GenJournalLine."Original Doc. VAT Date CZL";
        VATEntry."Registration No. CZL" := GenJournalLine."Registration No. CZL";
        VATEntry."Tax Registration No. CZL" := GenJournalLine."Tax Registration No. CZL";
        VATEntry."VAT Settlement No. CZL" := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertVATEntry', '', false, false)]
    local procedure DeleteSettlementReverseVATEntryOnAfterInsertVATEntry(VATEntry: Record "VAT Entry"; GLEntryNo: Integer; var NextEntryNo: Integer; var TempGLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link" temporary)
    begin
        if (VATEntry.Type = VATEntry.Type::Settlement) and
           (VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT") and
           (VATEntry."Document Type" = VATEntry."Document Type"::" ") and
           (VATEntry.Base = 0) and (VATEntry.Amount <> 0)
        then begin
            VATEntry.Delete(false);
            TempGLEntryVATEntryLink.Get(GLEntryNo, VATEntry."Entry No.");
            TempGLEntryVATEntryLink.Delete(false);
            NextEntryNo -= 1;
        end;
    end;
#if not CLEAN20
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Posting Group', false, false)]
    local procedure CheckPostingGroupChangeOnBeforeCustomerPostingGroupValidate(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line"; CurrFieldNo: Integer)
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        if PostingGroupManagementCZL.IsAllowMultipleCustVendPostingGroupsEnabled() then
            exit;
        if CurrFieldNo = Rec.FieldNo("Posting Group") then
            PostingGroupManagementCZL.CheckPostingGroupChange(Rec."Posting Group", xRec."Posting Group", Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeCheckPostingGroupChange', '', false, false)]
    local procedure SuppressPostingGroupChangeOnBeforeCheckCustomerPostingGroupChange(var IsHandled: Boolean)
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        if IsHandled then
            exit;
        IsHandled := not PostingGroupManagementCZL.IsAllowMultipleCustVendPostingGroupsEnabled();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitNewDtldCVLedgEntryBuf', '', false, false)]
    local procedure SetApplAcrossPostGroupsCZLOnAfterInitNewDtldCVLedgEntryBuf(var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var PrevNewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var PrevOldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var GenJnlLine: Record "Gen. Journal Line")
    var
        PostingGroupManagement: Codeunit "Posting Group Management CZL";
    begin
        if PostingGroupManagement.IsAllowMultipleCustVendPostingGroupsEnabled() then
            exit;
        DtldCVLedgEntryBuf.SetApplAcrossPostGroupsCZL(NewCVLedgEntryBuf."CV Posting Group" <> OldCVLedgEntryBuf."CV Posting Group");
    end;
#pragma warning restore AL0432
#endif

#if not CLEAN22
#pragma warning disable AL0432
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
#pragma warning restore AL0432
#endif

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
        CustomerPostingGroup.TestField("Receivables Account");
        exit(CustomerPostingGroup.GetReceivablesAccount());
    end;
#if not CLEAN22
#pragma warning disable AL0432
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
#pragma warning restore AL0432
#endif

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
        VendorPostingGroup.TestField("Payables Account");
        exit(VendorPostingGroup.GetPayablesAccount());
    end;
#if not CLEAN22
#pragma warning disable AL0432
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
#pragma warning restore AL0432
#endif

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostApplyVendLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostApplyVendLedgEntry(var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
#pragma warning restore AL0432
#endif
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"VendEntry-Apply Posted Entries", 'OnBeforePostUnapplyVendLedgEntry', '', false, false)]
    local procedure UpdateVATDateOnBeforePostUnapplyVendLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; VendorLedgerEntry: Record "Vendor Ledger Entry"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := GenJournalLine."Posting Date";
#pragma warning restore AL0432
#endif
        GenJournalLine."Original Doc. VAT Date CZL" := GenJournalLine."VAT Reporting Date";
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

#if not CLEAN20
#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Invoice Post. Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyToGenJnlLineOld(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostBuffer: Record "Invoice Post. Buffer");
    begin
        GenJnlLine.Correction := InvoicePostBuffer."Correction CZL";
        GenJnlLine."VAT Date CZL" := InvoicePostBuffer."VAT Date CZL";
        GenJnlLine."VAT Reporting Date" := InvoicePostBuffer."VAT Date CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostBuffer."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromInvPostBufferFA', '', false, false)]
    local procedure Custom2OnAfterCopyGenJnlLineFromInvPostBufferFA(InvoicePostBuffer: Record "Invoice Post. Buffer"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        if InvoicePostBuffer.Type <> InvoicePostBuffer.Type::"Fixed Asset" then
            exit;
        case InvoicePostBuffer."FA Posting Type" of
            InvoicePostBuffer."FA Posting Type"::"Custom 2":
                GenJournalLine."FA Posting Type" := GenJournalLine."FA Posting Type"::"Custom 2";
        end;
    end;
#pragma warning restore AL0432
#endif
    [EventSubscriber(ObjectType::Table, Database::"Invoice Posting Buffer", 'OnAfterCopyToGenJnlLine', '', false, false)]
    local procedure CopyFieldsOnAfterCopyToGenJnlLine(var GenJnlLine: Record "Gen. Journal Line"; InvoicePostingBuffer: Record "Invoice Posting Buffer");
    begin
        GenJnlLine.Correction := InvoicePostingBuffer."Correction CZL";
#if not CLEAN22
#pragma warning disable AL0432
        GenJnlLine."VAT Date CZL" := InvoicePostingBuffer."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJnlLine."VAT Reporting Date" := InvoicePostingBuffer."VAT Date CZL";
        GenJnlLine."Original Doc. VAT Date CZL" := InvoicePostingBuffer."Original Doc. VAT Date CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmt(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromSalesHeaderPrepmtPost(SalesHeader: Record "Sales Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := SalesHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := SalesHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmt', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmt(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line")
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost', '', false, false)]
    local procedure CopyVATDateOnAfterCopyGenJnlLineFromPurchHeaderPrepmtPost(PurchaseHeader: Record "Purchase Header"; var GenJournalLine: Record "Gen. Journal Line"; UsePmtDisc: Boolean)
    begin
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine."VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#endif
        GenJournalLine."VAT Reporting Date" := PurchaseHeader."VAT Reporting Date";
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