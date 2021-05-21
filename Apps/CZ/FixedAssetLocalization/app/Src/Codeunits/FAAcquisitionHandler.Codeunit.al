codeunit 31236 "FA Acquisition Handler CZF"
{
    var
        FASetup: Record "FA Setup";
        FieldErrorText: Text;
        SpecifiedTogetherErr: Label 'must not be specified together with %1 = %2', Comment = '%1 = Field Caption, %2 = Field Value';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Check Consistency", 'OnCheckNormalPostingOnAfterSetFALedgerEntryFilters', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnCheckNormalPostingOnAfterSetFALedgerEntryFilters(var FALedgerEntry: Record "FA Ledger Entry")
    var
        AcquisitionCostErr: Label 'The first entry must be an Acquisition Cost for Fixed Asset %1.', Comment = '%1 = Fixed Asset No.';
    begin
        if not FALedgerEntry.FindFirst() then
            exit;
        FASetup.Get();
        if (FALedgerEntry."FA Posting Type" <> FALedgerEntry."FA Posting Type"::"Acquisition Cost") and
           (not FASetup."FA Acquisition As Custom 2 CZF" or (FALedgerEntry."FA Posting Type" <> FALedgerEntry."FA Posting Type"::"Custom 2"))
        then
            Error(AcquisitionCostErr, FALedgerEntry."FA No.");
    end;

    [EventSubscriber(ObjectType::Report, Report::"General Journal - Test CZL", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure TestFixedAssetOnAfterCheckGenJnlLine(GenJournalLine: Record "Gen. Journal Line"; var ErrorCounter: Integer; var ErrorText: array[50] of Text[250])
    var
        FieldMustBeSpecifiedErr: Label '%1 must be specified.', Comment = '%1 = FieldCaption';
    begin
        FASetup.Get();
        if GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Fixed Asset" then
            if (GenJournalLine."FA Posting Type" in [GenJournalLine."FA Posting Type"::"Acquisition Cost", GenJournalLine."FA Posting Type"::Disposal, GenJournalLine."FA Posting Type"::Maintenance]) or
               (FASetup."FA Acquisition As Custom 2 CZF" and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"))
            then
                if (GenJournalLine."Gen. Bus. Posting Group" <> '') or (GenJournalLine."Gen. Prod. Posting Group" <> '') then
                    if GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::" " then
                        AddError(ErrorCounter, ErrorText, StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption("Gen. Posting Type")));

        if GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Fixed Asset" then
            if (GenJournalLine."FA Posting Type" in [GenJournalLine."FA Posting Type"::"Acquisition Cost", GenJournalLine."FA Posting Type"::Disposal, GenJournalLine."FA Posting Type"::Maintenance]) or
               (FASetup."FA Acquisition As Custom 2 CZF" and (GenJournalLine."FA Posting Type" = GenJournalLine."FA Posting Type"::"Custom 2"))
            then
                if (GenJournalLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJournalLine."Bal. Gen. Prod. Posting Group" <> '') then
                    if GenJournalLine."Bal. Gen. Posting Type" = GenJournalLine."Bal. Gen. Posting Type"::" " then
                        AddError(ErrorCounter, ErrorText, StrSubstNo(FieldMustBeSpecifiedErr, GenJournalLine.FieldCaption("Bal. Gen. Posting Type")));
    end;

    local procedure AddError(var ErrorCounter: Integer; var ErrorText: array[50] of Text[250]; Text: Text[250])
    begin
        ErrorCounter += 1;
        ErrorText[ErrorCounter] := Text;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnAfterCheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    var
        VATAmountErr: Label '%1 + %2 must be %3.', Comment = '%1 = VAT Amount, %2 = VAT Base Amount, %3 = Amount';
        BalanceVATAmountErr: Label '%1 + %2 must be -%3.', Comment = '%1 = VAT Amount, %2 = VAT Base Amount, %3 = Amount';
    begin
        FASetup.Get();
        if ((GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF") then begin
            if GenJnlLine."Account No." <> '' then
                if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
                    if (GenJnlLine."Gen. Bus. Posting Group" <> '') or (GenJnlLine."Gen. Prod. Posting Group" <> '') or
                       (GenJnlLine."VAT Bus. Posting Group" <> '') or (GenJnlLine."VAT Prod. Posting Group" <> '')
                    then
                        GenJnlLine.TestField("Gen. Posting Type");
            if (GenJnlLine."Gen. Posting Type" <> GenJnlLine."Gen. Posting Type"::" ") and
               (GenJnlLine."VAT Posting" = GenJnlLine."VAT Posting"::"Automatic VAT Entry")
            then begin
                if GenJnlLine."VAT Amount" + GenJnlLine."VAT Base Amount" <> GenJnlLine.Amount then
                    Error(
                      VATAmountErr, GenJnlLine.FieldCaption("VAT Amount"), GenJnlLine.FieldCaption("VAT Base Amount"),
                      GenJnlLine.FieldCaption(Amount));
                if GenJnlLine."Currency Code" <> '' then
                    if GenJnlLine."VAT Amount (LCY)" + GenJnlLine."VAT Base Amount (LCY)" <> GenJnlLine."Amount (LCY)" then
                        Error(
                          VATAmountErr, GenJnlLine.FieldCaption("VAT Amount (LCY)"),
                          GenJnlLine.FieldCaption("VAT Base Amount (LCY)"), GenJnlLine.FieldCaption("Amount (LCY)"));
            end;

            if GenJnlLine."Bal. Account No." <> '' then
                if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
                    if (GenJnlLine."Bal. Gen. Bus. Posting Group" <> '') or (GenJnlLine."Bal. Gen. Prod. Posting Group" <> '') or
                       (GenJnlLine."Bal. VAT Bus. Posting Group" <> '') or (GenJnlLine."Bal. VAT Prod. Posting Group" <> '')
                    then
                        GenJnlLine.TestField("Bal. Gen. Posting Type");
            if (GenJnlLine."Bal. Gen. Posting Type" <> GenJnlLine."Bal. Gen. Posting Type"::" ") and
               (GenJnlLine."VAT Posting" = GenJnlLine."VAT Posting"::"Automatic VAT Entry")
            then begin
                if GenJnlLine."Bal. VAT Amount" + GenJnlLine."Bal. VAT Base Amount" <> -GenJnlLine.Amount then
                    Error(
                      BalanceVATAmountErr, GenJnlLine.FieldCaption("Bal. VAT Amount"), GenJnlLine.FieldCaption("Bal. VAT Base Amount"),
                      GenJnlLine.FieldCaption(Amount));
                if GenJnlLine."Currency Code" <> '' then
                    if GenJnlLine."Bal. VAT Amount (LCY)" + GenJnlLine."Bal. VAT Base Amount (LCY)" <> -GenJnlLine."Amount (LCY)" then
                        Error(
                          BalanceVATAmountErr, GenJnlLine.FieldCaption("Bal. VAT Amount (LCY)"),
                          GenJnlLine.FieldCaption("Bal. VAT Base Amount (LCY)"), GenJnlLine.FieldCaption("Amount (LCY)"));
            end;
        end;

        if ((GenJnlLine."FA Posting Type" = GenJnlLine."FA Posting Type"::"Acquisition Cost") and FASetup."FA Acquisition As Custom 2 CZF") then
            if (GenJnlLine."Insurance No." <> '') and (GenJnlLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book") then
                GenJnlLine.TestField("Insurance No.", '');

        FieldErrorText := StrSubstNo(SpecifiedTogetherErr, GenJnlLine.FieldCaption("FA Posting Type"), GenJnlLine."FA Posting Type");
        if (GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Acquisition Cost") and
           ((GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF")
        then
            case true of
                GenJnlLine."Depr. Acquisition Cost":
                    GenJnlLine.FieldError("Depr. Acquisition Cost", FieldErrorText);
                GenJnlLine."Salvage Value" <> 0:
                    GenJnlLine.FieldError("Salvage Value", FieldErrorText);
                GenJnlLine."Insurance No." <> '':
                    GenJnlLine.FieldError("Insurance No.", FieldErrorText);
                GenJnlLine.Quantity <> 0:
                    if GenJnlLine."FA Posting Type" <> GenJnlLine."FA Posting Type"::Maintenance then
                        GenJnlLine.FieldError(Quantity, FieldErrorText);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckFAJnlLine', '', false, false)]
    local procedure CheckAcquisitionAsCustom2OnAfterCheckFAJnlLine(var FAJnlLine: Record "FA Journal Line")
    begin
        FASetup.Get();
        if ((FAJnlLine."FA Posting Type" = FAJnlLine."FA Posting Type"::"Acquisition Cost") and FASetup."FA Acquisition As Custom 2 CZF") then
            if (FAJnlLine."Insurance No." <> '') and (FAJnlLine."Depreciation Book Code" <> FASetup."Insurance Depr. Book") then
                FAJnlLine.TestField("Insurance No.", '');

        FieldErrorText := StrSubstNo(SpecifiedTogetherErr, FAJnlLine.FieldCaption("FA Posting Type"), FAJnlLine."FA Posting Type");
        if (FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::"Acquisition Cost") and
           ((FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF")
        then
            case true of
                FAJnlLine."Depr. Acquisition Cost":
                    FAJnlLine.FieldError("Depr. Acquisition Cost", FieldErrorText);
                FAJnlLine."Salvage Value" <> 0:
                    FAJnlLine.FieldError("Salvage Value", FieldErrorText);
                FAJnlLine.Quantity <> 0:
                    if FAJnlLine."FA Posting Type" <> FAJnlLine."FA Posting Type"::Maintenance then
                        FAJnlLine.FieldError(Quantity, FieldErrorText);
                FAJnlLine."Insurance No." <> '':
                    FAJnlLine.FieldError("Insurance No.", FieldErrorText);
            end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterValidateEvent', 'FA Posting Type', false, false)]
    local procedure AcquisitionAsCustom2OnAfterValidateFAPostingType(var Rec: Record "Purchase Line")
    begin
        if Rec.Type <> Rec.Type::"Fixed Asset" then
            exit;
        if Rec."FA Posting Type" <> Rec."FA Posting Type"::"Acquisition Cost" then
            exit;

        FASetup.Get();
        if FASetup."FA Acquisition As Custom 2 CZF" then
            Rec."FA Posting Type" := Rec."FA Posting Type"::"Custom 2";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnBeforeGetFAPostingGroup', '', false, false)]
    local procedure AcquisitionAsCustom2OnBeforeGetFAPostingGroup(var PurchaseLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        FADepreciationBook: Record "FA Depreciation Book";
        FAPostingGroup: Record "FA Posting Group";
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
        GLAccount: Record "G/L Account";
        ApplicationAreaMgmt: Codeunit "Application Area Mgmt.";
    begin
        if PurchaseLine.Type <> PurchaseLine.Type::"Fixed Asset" then
            exit;
        if PurchaseLine."No." = '' then
            exit;

        FASetup.Get();
        if PurchaseLine."Depreciation Book Code" = '' then begin
            FADepreciationBook.SetRange("FA No.", PurchaseLine."No.");
            FADepreciationBook.SetRange("Default FA Depreciation Book", true);
            if not FADepreciationBook.FindFirst() then begin
                PurchaseLine."Depreciation Book Code" := FASetup."Default Depr. Book";
                if not FADepreciationBook.Get(PurchaseLine."No.", PurchaseLine."Depreciation Book Code") then
                    PurchaseLine."Depreciation Book Code" := '';
            end else
                PurchaseLine."Depreciation Book Code" := FADepreciationBook."Depreciation Book Code";
            if PurchaseLine."Depreciation Book Code" = '' then
                exit;
        end;

        if PurchaseLine."FA Posting Type" = PurchaseLine."FA Posting Type"::"Acquisition Cost" then
            if FASetup."FA Acquisition As Custom 2 CZF" then
                PurchaseLine."FA Posting Type" := PurchaseLine."FA Posting Type"::"Custom 2";

        FADepreciationBook.Get(PurchaseLine."No.", PurchaseLine."Depreciation Book Code");
        FADepreciationBook.TestField("FA Posting Group");
        FAPostingGroup.GetPostingGroup(FADepreciationBook."FA Posting Group", FADepreciationBook."Depreciation Book Code");
        case PurchaseLine."FA Posting Type" of
            PurchaseLine."FA Posting Type"::"Custom 2":
                begin
                    FAPostingGroup.TestField("Custom 2 Account");
                    GLAccount.Get(FAPostingGroup."Custom 2 Account");
                end;
            PurchaseLine."FA Posting Type"::Maintenance:
                if (not FAPostingGroup.UseStandardMaintenanceCZF()) and (PurchaseLine."Maintenance Code" <> '') then begin
                    FAExtendedPostingGroupCZF.Get(FADepreciationBook."FA Posting Group", FAExtendedPostingGroupCZF."FA Posting Type"::Maintenance, PurchaseLine."Maintenance Code");
                    GLAccount.Get(FAExtendedPostingGroupCZF.GetMaintenanceExpenseAccount());
                end else
                    GLAccount.Get(FAPostingGroup.GetMaintenanceExpenseAccount());
            else
                exit;
        end;

        GLAccount.CheckGLAcc();
        if not ApplicationAreaMgmt.IsSalesTaxEnabled() then
            GLAccount.TestField("Gen. Prod. Posting Group");
        PurchaseLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
        PurchaseLine."Tax Group Code" := GLAccount."Tax Group Code";
        PurchaseLine.Validate("VAT Prod. Posting Group", GLAccount."VAT Prod. Posting Group");
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Setup", 'OnIsFAAcquisitionAsCustom2CZL', '', false, false)]
    local procedure OnIsFAAcquisitionAsCustom2CZL(var FAAcquisitionAsCustom2: Boolean; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        if not FASetup.Get() then
            exit;
        FAAcquisitionAsCustom2 := FASetup."FA Acquisition As Custom 2 CZF";
        IsHandled := true;
    end;
}
