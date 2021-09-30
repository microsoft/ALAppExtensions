codeunit 31239 "FA Deprec. Book Handler CZF"
{
    var
        FASetup: Record "FA Setup";
        DepreciationBook: Record "Depreciation Book";
        FADepreciationBook: Record "FA Depreciation Book";
        AccountingPeriodMgt: Codeunit "Accounting Period Mgt.";
        FANo: Code[20];
        DeprBookCode: Code[10];
        FAPostingDate: Date;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'Depreciation Starting Date', false, false)]
    local procedure CheckDepreciationStartingDateOnBeforeValidateEvent(var Rec: Record "FA Depreciation Book")
    begin
        if Rec.IsTemporary() then
            exit;
        if Rec."Depreciation Starting Date" = 0D then
            exit;
        DepreciationBook.Get(Rec."Depreciation Book Code");
        if DepreciationBook."Deprec. from 1st Month Day CZF" then
            Rec.TestField("Depreciation Starting Date",
              DMY2Date(1, Date2DMY(Rec."Depreciation Starting Date", 2), Date2DMY(Rec."Depreciation Starting Date", 3)));
        if DepreciationBook."Deprec. from 1st Year Day CZF" then
            Rec.TestField("Depreciation Starting Date",
              AccountingPeriodMgt.FindFiscalYear(Rec."Depreciation Starting Date"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckConsistencyOnAfterCheckGenJnlLine(var GenJnlLine: Record "Gen. Journal Line")
    begin
        DepreciationBook.Get(GenJnlLine."Depreciation Book Code");
        if GenJnlLine."Account No." <> '' then
            if GenJnlLine."Account Type" = GenJnlLine."Account Type"::"Fixed Asset" then
                FANo := GenJnlLine."Account No.";
        if GenJnlLine."Bal. Account No." <> '' then
            if GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::"Fixed Asset" then
                FANo := GenJnlLine."Bal. Account No.";
        DeprBookCode := GenJnlLine."Depreciation Book Code";
        FADepreciationBook.Get(FANo, DeprBookCode);
        if GenJnlLine."FA Posting Date" = 0D then
            FAPostingDate := GenJnlLine."Posting Date"
        else
            FAPostingDate := GenJnlLine."FA Posting Date";

        ControlingCheck(GenJnlLine."FA Posting Type".AsInteger() - 1);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"FA Jnl.-Check Line", 'OnAfterCheckFAJnlLine', '', false, false)]
    local procedure CheckConsistencyOnAfterCheckFAJnlLine(var FAJnlLine: Record "FA Journal Line")
    begin
        DepreciationBook.Get(FAJnlLine."Depreciation Book Code");
        FANo := FAJnlLine."FA No.";
        DeprBookCode := FAJnlLine."Depreciation Book Code";
        FADepreciationBook.Get(FANo, DeprBookCode);
        FAPostingDate := FAJnlLine."FA Posting Date";

        ControlingCheck(FAJnlLine."FA Posting Type".AsInteger());
    end;

    local procedure ControlingCheck(PostingType: Option "Acquisition Cost",Depreciation,"Write-Down",Appreciation,"Custom 1","Custom 2",Disposal,Maintenance,"Salvage Value")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        IsCheck: Boolean;
        PostAfterErr: Label 'Acquisition Cost or Appreciation must be posted after Depreciation.';
        PostInSameYearFirstErr: Label 'Acquisition Cost must be post in same year as first Acquisition Cost.';
    begin
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code", "FA Posting Date");
        FALedgerEntry.SetRange("FA No.", FANo);
        FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode);

        if (PostingType = PostingType::Disposal) and
          DepreciationBook."Check Deprec. on Disposal CZF"
        then begin
            IsCheck := true;
            FASetup.Get();
            if FASetup."Tax Depreciation Book CZF" = FADepreciationBook."Depreciation Book Code" then begin
                FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
                if FALedgerEntry.FindFirst() then
                    IsCheck := AccountingPeriodMgt.FindFiscalYear(FALedgerEntry."FA Posting Date") <> AccountingPeriodMgt.FindFiscalYear(FAPostingDate);
            end;

            if IsCheck then begin
                FADepreciationBook.CalcFields("Book Value");
                if FADepreciationBook."Book Value" <> 0 then begin
                    FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
                    FALedgerEntry.SetRange("FA Posting Date", FAPostingDate);
                    FALedgerEntry.FindFirst();
                    FALedgerEntry.SetRange("FA Posting Date");
                end;
            end;
        end;

        if ((PostingType = PostingType::"Acquisition Cost") or (PostingType = PostingType::Appreciation)) and
          DepreciationBook."Check Acq. Appr. bef. Dep. CZF"
        then begin
            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::Depreciation);
            FALedgerEntry.SetFilter("FA Posting Date", '%1..', FAPostingDate + 1);
            if not FALedgerEntry.IsEmpty() then
                Error(PostAfterErr);
            FALedgerEntry.SetRange("FA Posting Date");
        end;

        if (PostingType = PostingType::"Acquisition Cost") and
          DepreciationBook."All Acquisit. in same Year CZF"
        then begin
            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
            if FALedgerEntry.FindFirst() then
                if AccountingPeriodMgt.FindFiscalYear(FALedgerEntry."FA Posting Date") <> AccountingPeriodMgt.FindFiscalYear(FAPostingDate) then
                    Error(PostInSameYearFirstErr);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnAfterValidateEvent', 'Clasification Code', false, false)]
    local procedure CheckTaxDepreciationCodeOnAfterValidateEvent(var Rec: Record "Fixed Asset")
    var
        TaxDepreciationGroupCZF: Record "Tax Depreciation Group CZF";
        ClassificationCodeCZF: Record "Classification Code CZF";
        DeprecGroupMismatchMsg: Label 'The depreciation group (%1) associated with classification code %2 doesn''t correspond to depreciation group (%3) associated with tax depreciation group code %4.', Comment = '%1 = Classification Code Depreciation Group, %2 = Fixed Asset Clasification Code, %3 = Tax Depreciation Group Code, %4 = Tax Deprec. Group Code';
    begin
        if Rec."Classification Code CZF" = '' then
            exit;

        FADepreciationBook.SetRange("FA No.", Rec."No.");
        FADepreciationBook.SetFilter("Tax Deprec. Group Code CZF", '<>%1', '');
        if not FADepreciationBook.FindFirst() then
            exit;

        if FADepreciationBook."Tax Deprec. Group Code CZF" <> '' then begin
            TaxDepreciationGroupCZF.SetRange(Code, FADepreciationBook."Tax Deprec. Group Code CZF");
            TaxDepreciationGroupCZF.SetRange("Starting Date", 0D, WorkDate());
            if TaxDepreciationGroupCZF.FindLast() then begin
                ClassificationCodeCZF.Get(Rec."Classification Code CZF");
                if ClassificationCodeCZF."Depreciation Group" <> TaxDepreciationGroupCZF."Depreciation Group" then
                    Message(DeprecGroupMismatchMsg,
                      ClassificationCodeCZF."Depreciation Group", Rec."Classification Code CZF", TaxDepreciationGroupCZF."Depreciation Group", FADepreciationBook."Tax Deprec. Group Code CZF");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Fixed Asset Card", 'OnAfterLoadDepreciationBooks', '', false, false)]
    local procedure ShowDeprBooksOnAfterLoadDepreciationBooks(var Simple: Boolean)
    begin
        if not IsInstalledByAppId('c81764a5-be79-4d50-ba3e-4ade02073780') then // only if test application "Tests-Fixed Asset" is not installed
            Simple := false;
    end;

    local procedure IsInstalledByAppId(AppID: Guid): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get(AppID));
    end;

    [EventSubscriber(ObjectType::Table, Database::"FA Depreciation Book", 'OnBeforeValidateEvent', 'FA Posting Group', false, false)]
    local procedure CheckFALedgerEntriesExistOnBeforeFAPostingGroup(var Rec: Record "FA Depreciation Book"; var xRec: Record "FA Depreciation Book")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        FAPostingGroupCanNotBeChangedErr: Label 'FA Posting Group can not be changed if there is at least one FA Entry for Fixed Asset and Deprecation Book.';
    begin
        if Rec."FA Posting Group" = xRec."FA Posting Group" then
            exit;
        if Rec."FA No." = '' then
            exit;
        FALedgerEntry.SetCurrentKey("FA No.", "Depreciation Book Code");
        FALedgerEntry.SetRange("FA No.", Rec."FA No.");
        FALedgerEntry.SetRange("Depreciation Book Code", Rec."Depreciation Book Code");
        if not FALedgerEntry.IsEmpty() then
            Error(FAPostingGroupCanNotBeChangedErr);
    end;
}
