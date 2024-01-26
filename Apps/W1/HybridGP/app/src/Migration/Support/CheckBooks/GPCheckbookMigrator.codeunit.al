namespace Microsoft.DataMigration.GP;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 40025 "GP Checkbook Migrator"
{
    var
        BatchNameTxt: Label 'GPBANK', Locked = true;
        BankWarningTxt: Label 'Unable to get %1 posting account.', Comment = '%1 = Posting Group', Locked = true;
        DescriptionTxt: Label 'Last GP Reconciled Balance Amount';

    procedure MoveCheckbookStagingData()
    var
        GPCheckbookMSTR: Record "GP Checkbook MSTR";
        BankAccount: Record "Bank Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        MigrateInactiveCheckbooks: Boolean;
    begin
        MigrateInactiveCheckbooks := GPCompanyAdditionalSettings.GetMigrateInactiveCheckbooks();

        if not GPCheckbookMSTR.FindSet() then
            exit;

        repeat
            if not BankAccount.Get(GPCheckbookMSTR.CHEKBKID) then
                if MigrateInactiveCheckbooks or not GPCheckbookMSTR.INACTIVE then begin
                    Clear(BankAccount);
                    BankAccount."No." := DelChr(GPCheckbookMSTR.CHEKBKID, '>', ' ');
                    BankAccount.Name := DelChr(GPCheckbookMSTR.DSCRIPTN, '>', ' ');
                    BankAccount."Bank Account No." := DelChr(GPCheckbookMSTR.BNKACTNM, '>', ' ');
                    BankAccount."Last Check No." := GetLastCheckNumber(GPCheckbookMSTR.NXTCHNUM);
                    BankAccount."Bank Acc. Posting Group" := GetOrCreateBankAccPostingGroup(GPCheckbookMSTR.ACTINDX);
                    UpdateBankInfo(DelChr(GPCheckbookMSTR.BANKID, '>', ' '), BankAccount);
                    BankAccount.Insert(true);

                    if not GPCompanyAdditionalSettings.GetMigrateOnlyBankMaster() then
                        CreateTransactions(BankAccount."No.", BankAccount."Bank Acc. Posting Group", GPCheckbookMSTR.CHEKBKID,
                                            GPCheckbookMSTR.Last_Reconciled_Date, GPCheckbookMSTR.Last_Reconciled_Balance);
                end;
        until GPCheckbookMSTR.Next() = 0;
    end;

    local procedure CreateTransactions(BankAccountNo: Code[20]; BankAccPostingGroupCode: Code[20]; CheckbookID: Text[15]; TrxDate: Date; Amount: Decimal)
    var
        PostingAccountNumber: Code[20];
    begin
        if not GetBankAccPostingAccountNumber(PostingAccountNumber, BankAccPostingGroupCode) then
            exit;

        if Amount <> 0.00 then
            CreateGeneralJournalLine('BBF', DescriptionTxt, '', TrxDate, PostingAccountNumber, Amount, BankAccountNo);

        MoveTransactionsData(BankAccountNo, BankAccPostingGroupCode, CheckbookID);
    end;

    procedure MoveTransactionsData(BankAccountNo: Code[20]; BankAccPostingGroupCode: Code[20]; CheckbookID: Text[15])
    var
        GPCheckbookTransactions: Record "GP Checkbook Transactions";
        PostingAccountNumber: Code[20];
        DocumentNo: Code[20];
        Description: Text[100];
        ExternalDocumentNo: Code[35];
        Amount: Decimal;
    begin
        GPCheckbookTransactions.SetRange(CHEKBKID, CheckbookID);
        GPCheckbookTransactions.SetRange(Recond, false);
        GPCheckbookTransactions.SetFilter(TRXAMNT, '<>%1', 0);
        if not GPCheckbookTransactions.FindSet() then
            exit;

        if not GetBankAccPostingAccountNumber(PostingAccountNumber, BankAccPostingGroupCode) then
            exit;

        repeat
            Amount := GPCheckbookTransactions.TRXAMNT;

            if GPCheckbookTransactions.CMTrxType in [3, 4, 6] then
                Amount := -GPCheckbookTransactions.TRXAMNT;

            if GPCheckbookTransactions.CMTrxType = 7 then
                if IsNegativeAmount(GPCheckbookTransactions.CMRECNUM, GPCheckbookTransactions.CMTrxNum) then
                    Amount := -GPCheckbookTransactions.TRXAMNT;

            DocumentNo := CopyStr(GPCheckbookTransactions.CMTrxNum.Trim(), 1, MaxStrLen(DocumentNo));
            Description := CopyStr(GPCheckbookTransactions.paidtorcvdfrom.Trim(), 1, MaxStrLen(Description));
            ExternalDocumentNo := CopyStr(GPCheckbookTransactions.CMLinkID.Trim(), 1, MaxStrLen(ExternalDocumentNo));
            CreateGeneralJournalLine(DocumentNo, Description, ExternalDocumentNo, GPCheckbookTransactions.TRXDATE, PostingAccountNumber, Amount, BankAccountNo);
        until GPCheckbookTransactions.Next() = 0;
    end;

    local procedure UpdateBankInfo(BankId: Text[15]; var BankAccount: Record "Bank Account")
    var
        GPBankMSTR: Record "GP Bank MSTR";
    begin
        if not GPBankMSTR.Get(BankId) then
            exit;

        BankAccount.Address := DelChr(GPBankMSTR.ADDRESS1, '>', ' ');
        BankAccount."Address 2" := CopyStr(DelChr(GPBankMSTR.ADDRESS2, '>', ' '), 1, 50);
        BankAccount.City := CopyStr(DelChr(GPBankMSTR.CITY, '>', ' '), 1, 30);
        BankAccount."Phone No." := DelChr(GPBankMSTR.PHNUMBR1, '>', ' ');
        BankAccount."Transit No." := DelChr(GPBankMSTR.TRNSTNBR, '>', ' ');
        BankAccount."Fax No." := DelChr(GPBankMSTR.FAXNUMBR, '>', ' ');
        BankAccount.County := DelChr(GPBankMSTR.STATE, '>', ' ');
        BankAccount."Post Code" := DelChr(GPBankMSTR.ZIPCODE, '>', ' ');
        BankAccount."Bank Branch No." := CopyStr(DelChr(GPBankMSTR.BNKBRNCH, '>', ' '), 1, 20);
    end;

    local procedure GetOrCreateBankAccPostingGroup(AcctIndex: Integer): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        GPAccount: Record "GP Account";
    begin
        if not GPAccount.Get(AcctIndex) then
            exit;

        // If a posting group already exists for this GL account use it.
        BankAccountPostingGroup.SetRange("G/L Account No.", CopyStr(GPAccount.AcctNum, 1, 20));
        if BankAccountPostingGroup.FindFirst() then
            exit(BankAccountPostingGroup.Code);

        Clear(BankAccountPostingGroup);
        BankAccountPostingGroup.Code := 'GP' + Format(GetNextPostingGroupNumber());
        BankAccountPostingGroup."G/L Account No." := CopyStr(GPAccount.AcctNum, 1, 20);
        BankAccountPostingGroup.Insert(true);
        exit(BankAccountPostingGroup.Code);
    end;

    local procedure GetNextPostingGroupNumber(): Integer
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccountPostingGroup.SetFilter(Code, 'GP' + '*');
        if BankAccountPostingGroup.IsEmpty then
            exit(1);

        exit(BankAccountPostingGroup.Count + 1);
    end;

    local procedure GetLastCheckNumber(NextCheckNumber: Text[21]): Code[20]
    var
        NextCheck: Integer;
        LastCheckNumber: Integer;
    begin
        if not Evaluate(NextCheck, NextCheckNumber.TrimEnd()) then
            exit('');

        if NextCheck <= 0 then
            exit(Format(0));

        LastCheckNumber := NextCheck - 1;
        exit(Format(LastCheckNumber));
    end;

    local procedure CreateGeneralJournalLine(DocumentNo: Code[20]; Description: Text[100]; ExternalDocumentNo: Code[35]; PostingDate: Date; OffsetAccount: Code[20]; TrxAmount: Decimal; BankAccount: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        JournalTemplateName: Code[10];
        LineNum: Integer;
    begin
        JournalTemplateName := 'GENERAL';
        CreateGeneralJournalBatchIfNeeded(JournalTemplateName, 'GJNL-GEN');

        GenJournalLineCurrent.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLineCurrent.SetRange("Journal Batch Name", BatchNameTxt);
        if GenJournalLineCurrent.FindLast() then
            LineNum := GenJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        GenJournalTemplate.Get(JournalTemplateName);

        Clear(GenJournalLine);
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", BatchNameTxt);
        GenJournalLine.Validate("Line No.", LineNum);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::" ");
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("External Document No.", ExternalDocumentNo);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
        GenJournalLine.Validate("Account No.", BankAccount);
        GenJournalLine.Validate(Description, Description);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate(Amount, TrxAmount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", OffsetAccount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
        GenJournalLine.Insert(true);
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(JournalTemplateName: Code[10]; NoSeries: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange(Name, BatchNameTxt);
        GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalBatch.SetRange("No. Series", NoSeries);

        if GenJournalBatch.FindFirst() then
            exit;

        Clear(GenJournalBatch);
        GenJournalBatch.Validate(Name, BatchNameTxt);
        GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        GenJournalBatch.Validate("No. Series", NoSeries);

        GenJournalBatch.SetupNewBatch();
        GenJournalBatch.Insert(true);
    end;

    local procedure GetBankAccPostingAccountNumber(var GLAccountNumber: Code[20]; BankAccPostingGroup: Code[20]): Boolean
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if not BankAccountPostingGroup.Get(BankAccPostingGroup) then begin
            Session.LogMessage('0000HRD', StrSubstNo(BankWarningTxt, BankAccPostingGroup), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', HelperFunctions.GetTelemetryCategory());
            exit(false);
        end;

        GLAccountNumber := BankAccountPostingGroup."G/L Account No.";
        exit(true);
    end;

    local procedure IsNegativeAmount(CMRECNUM: Decimal; CMTrxNum: Text[21]): Boolean
    var
        GPCM20600: Record "GP CM20600";
        ShouldBeNegative: Boolean;
    begin
        ShouldBeNegative := false;
        GPCM20600.SetRange(CMXFRNUM, CMTrxNum);
        if GPCM20600.FindFirst() then
            if GPCM20600.CMFRMRECNUM = CMRECNUM then
                ShouldBeNegative := true;

        exit(ShouldBeNegative);
    end;
}