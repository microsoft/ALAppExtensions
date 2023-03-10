codeunit 1698 "Feature Bank Deposits" implements "Feature Data Update"
{
    Access = Internal;
    Permissions = tabledata "Posted Bank Deposit Header" = r,
                  tabledata "Bank Account Ledger Entry" = m;

    procedure IsDataUpdateRequired(): Boolean;
    begin
        exit(false);
    end;

    procedure ReviewData();
    begin
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

#if not CLEAN21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureEnableConfirmed', '', false, false)]
    local procedure HandleOnAfterFeatureEnableConfirmed(var FeatureKey: Record "Feature Key")
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if FeatureKey.ID <> BankDepositFeatureMgt.GetFeatureKeyId() then
            exit;
        UpgradeToBankDeposits();
    end;

    local procedure UpgradeToBankDeposits()
    var
        Company: Record Company;
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
        DepositsTableId: Integer;
        BankRecHeaderTableId: Integer;
        BankRecLineTableId: Integer;
    begin
        BankDepositFeatureMgt.OnBeforeUpgradeToBankDeposits(DepositsTableId, BankRecHeaderTableId, BankRecLineTableId);
        if DepositsTableId = 0 then
            exit;

        if Company.FindSet() then
        repeat
            TransferDeposits(DepositsTableId, Company);
            TransferBankRecWorksheets(BankRecHeaderTableId, BankRecLineTableId, Company);
        until Company.Next() = 0;
    end;

    local procedure RemoveNAsDeposits(DepositsTableId: Integer; var Company: Record Company)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.Open(DepositsTableId, false, Company.Name);
        RecordRef.DeleteAll();
    end;

    local procedure RemoveNAsReconciliations(BankRecHeaderTableId: Integer; BankRecLineTableId: Integer; var Company: Record Company)
    var
        RecordRef: RecordRef;
    begin
        RecordRef.Open(BankRecLineTableId, false, Company.Name);
        RecordRef.DeleteAll();
        RecordRef.Close();
        RecordRef.Open(BankRecHeaderTableId, false, Company.Name);
        RecordRef.DeleteAll();
    end;

    local procedure TransferDeposits(DepositsTableId: Integer; var Company: Record Company)
    var
        BankDepositHeader: Record "Bank Deposit Header";
        DepositHeaderRecRef: RecordRef;
        BankDepositHeaderRecRef: RecordRef;
        PreviousDepositNoFieldRef: FieldRef;
        PreviousDepositNo: Code[20];
    begin
        DepositHeaderRecRef.Open(DepositsTableId, false, Company.Name);
        if DepositHeaderRecRef.IsEmpty() then
            exit;
        DepositHeaderRecRef.FindSet();
        BankDepositHeaderRecRef.Open(Database::"Bank Deposit Header", false, Company.Name);
        repeat
            PreviousDepositNoFieldRef := DepositHeaderRecRef.Field(BankDepositHeader.FieldNo("No."));
            PreviousDepositNo := PreviousDepositNoFieldRef.Value();
            if not BankDepositHeader.Get(PreviousDepositNo) then begin
                BankDepositHeaderRecRef.Init();
                TransferFields(BankDepositHeaderRecRef, DepositHeaderRecRef);
                BankDepositHeaderRecRef.Insert();
            end;
        until DepositHeaderRecRef.Next() = 0;
        RemoveNAsDeposits(DepositsTableId, Company);
    end;
    local procedure TransferBankRecWorksheets(BankRecHeaderTableId: Integer; BankRecLineTableId: Integer; var Company: Record Company)
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankRecHeaderRecRef: RecordRef;
        BankRecHeaderStatementNoFieldRef: FieldRef;
        BankRecHeaderBankAccountNoFieldRef: FieldRef;
        StatementNo: Code[20];
        BankAccountNo: Code[20];
    begin
        BankRecHeaderRecRef.Open(BankRecHeaderTableId, false, Company.Name);
        if BankRecHeaderRecRef.IsEmpty() then
            exit;
        BankRecHeaderRecRef.FindSet();
        BankAccReconciliation.ChangeCompany(Company.Name);
        repeat
            BankRecHeaderStatementNoFieldRef := BankRecHeaderRecRef.Field(BankAccReconciliation.FieldNo("Statement No."));
            BankRecHeaderBankAccountNoFieldRef := BankRecHeaderRecRef.Field(BankAccReconciliation.FieldNo("Bank Account No."));
            StatementNo := BankRecHeaderStatementNoFieldRef.Value();
            BankAccountNo := BankRecHeaderBankAccountNoFieldRef.Value();
            if not BankAccReconciliation.Get(BankAccReconciliation."Statement Type"::"Bank Reconciliation", BankAccountNo, StatementNo) then
                TransferBankReconciliation(BankRecHeaderRecRef, BankAccountNo, StatementNo, BankRecLineTableId);
        until BankRecHeaderRecRef.Next() = 0;
        RemoveNAsReconciliations(BankRecHeaderTableId, BankRecLineTableId, Company);   
    end;
    
    local procedure TransferBankReconciliation(var BankRecHeaderRecRef: RecordRef; BankAccountNo: Code[20]; StatementNo: Code[20]; BankRecLineTableId: Integer)
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        BankRecLineRecRef: RecordRef;
        BankRecLineFieldRef: FieldRef;
        StatementLineNo: Integer;
    begin
        BankAccReconciliation.ChangeCompany(BankRecHeaderRecRef.CurrentCompany());
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Bank Reconciliation";
        BankAccReconciliation."Bank Account No." := BankAccountNo;
        BankAccReconciliation."Statement No." := StatementNo;
        
        
        BankAccReconciliation."Statement Ending Balance" := GetRecRefFieldFromFieldName(BankRecHeaderRecRef, 'Statement Balance').Value();
        BankAccReconciliation."Statement Date" := GetRecRefFieldFromFieldName(BankRecHeaderRecRef, 'Statement Date').Value();
        BankAccReconciliation."Dimension Set ID" := GetRecRefFieldFromFieldName(BankRecHeaderRecRef, 'Dimension Set ID').Value();
        BankAccReconciliation.Insert();


        UnmatchBankLedgerEntries(BankAccountNo, StatementNo, BankRecHeaderRecRef.CurrentCompany());

        BankRecLineRecRef.Open(BankRecLineTableId, false, BankRecHeaderRecRef.CurrentCompany());
        BankRecLineFieldRef := BankRecLineRecRef.Field(BankAccReconciliationLine.FieldNo("Bank Account No."));
        BankRecLineFieldRef.SetRange(BankAccountNo);
        BankRecLineFieldRef := BankRecLineRecRef.Field(BankAccReconciliationLine.FieldNo("Statement No."));
        BankRecLineFieldRef.SetRange(StatementNo);
        TransferCheckLines(BankRecLineRecRef, StatementLineNo, BankAccountNo, StatementNo);
        TransferDepositAndAdjustmentLines(BankRecLineRecRef, StatementLineNo, BankAccountNo, StatementNo);
    end;

    local procedure TransferCheckLines(var BankRecLineRecRef: RecordRef; var StatementLineNo: Integer; BankAccountNo: Code[20]; StatementNo: Code[20])
    var
        StatementAmount: Decimal;
    begin
        GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Record Type').SetRange(0);
        if BankRecLineRecRef.IsEmpty() then
            exit;
        BankRecLineRecRef.FindSet();
        repeat
            StatementAmount := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Cleared Amount').Value();
            StatementAmount *= -1; // check lines are positive in NA's BankRecLine, although Bank entries are negative
            InsertBankReconciliationLine(BankAccountNo, StatementNo, StatementAmount, BankRecLineRecRef, StatementLineNo);
        until BankRecLineRecRef.Next() = 0;
    end;

    
    local procedure TransferDepositAndAdjustmentLines(var BankRecLineRecRef: RecordRef; var StatementLineNo: Integer; BankAccountNo: Code[20]; StatementNo: Code[20])
    var
        StatementAmount: Decimal;
    begin
        GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Record Type').SetFilter('%1|%2', 1, 2);
        if BankRecLineRecRef.IsEmpty() then
            exit;
        BankRecLineRecRef.FindSet();
        repeat
            StatementAmount := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Cleared Amount').Value();
            InsertBankReconciliationLine(BankAccountNo, StatementNo, StatementAmount, BankRecLineRecRef, StatementLineNo);
        until BankRecLineRecRef.Next() = 0;
    end;

    local procedure InsertBankReconciliationLine(BankAccountNo: Code[20]; StatementNo: Code[20]; StatementAmount: Decimal; var BankRecLineRecRef: RecordRef; var StatementLineNo: Integer)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchBankRecLines: Codeunit "Match Bank Rec. Lines";
        BankLedgerEntryNo: Integer;
    begin
        if not GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Cleared').Value() then
            exit;
        StatementLineNo += 10000;
        BankAccountLedgerEntry.ChangeCompany(BankRecLineRecRef.CurrentCompany());
        BankAccReconciliationLine.ChangeCompany(BankRecLineRecRef.CurrentCompany());
        BankAccReconciliationLine."Bank Account No." := BankAccountNo;
        BankAccReconciliationLine."Statement No." := StatementNo;
        BankAccReconciliationLine."Statement Line No." := StatementLineNo;
        BankAccReconciliationLine."Transaction Date" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Posting Date').Value();
        BankAccReconciliationLine.Description := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Description').Value();
        BankAccReconciliationLine."Statement Amount" := StatementAmount;
        BankAccReconciliationLine."Statement Type" := BankAccReconciliationLine."Statement Type"::"Bank Reconciliation";
        BankAccReconciliationLine."Shortcut Dimension 1 Code" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Shortcut Dimension 1 Code').Value();
        BankAccReconciliationLine."Shortcut Dimension 2 Code" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Shortcut Dimension 2 Code').Value();
        BankAccReconciliationLine."Dimension Set ID" := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Dimension Set ID').Value();
        BankAccReconciliationLine."Applied Entries" := 0;
        BankAccReconciliationLine.Insert();
        BankAccReconciliationLine.Validate("Applied Amount", 0);
        BankLedgerEntryNo := GetRecRefFieldFromFieldName(BankRecLineRecRef, 'Bank Ledger Entry No.').Value();
        if BankLedgerEntryNo <> 0 then
            if CompanyName() = BankRecLineRecRef.CurrentCompany() then
                if BankAccountLedgerEntry.Get(BankLedgerEntryNo) then begin
                    BankAccountLedgerEntry.SetRecFilter();
                    BankAccReconciliationLine.SetRecFilter();
                    MatchBankRecLines.MatchManually(BankAccReconciliationLine, BankAccountLedgerEntry);
                end;
    end;

    local procedure UnmatchBankLedgerEntries(BankAccountNo: Code[20]; StatementNo: Code[20]; CurrentCompanyName: Text)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        CheckLedgerEntry: Record "Check Ledger Entry";
    begin
        if (BankAccountNo = '') or (StatementNo = '') then
            exit;
        BankAccountLedgerEntry.ChangeCompany(CurrentCompanyName);
        CheckLedgerEntry.ChangeCompany(CurrentCompanyName);
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        BankAccountLedgerEntry.SetRange("Statement No.", StatementNo);
        BankAccountLedgerEntry.SetRange(Open, true);
        if not BankAccountLedgerEntry.IsEmpty() then begin
            BankAccountLedgerEntry.FindSet();
            repeat
                BankAccountLedgerEntry."Statement Status" := BankAccountLedgerEntry."Statement Status"::Open;
                BankAccountLedgerEntry."Statement No." := '';
                BankAccountLedgerEntry."Statement Line No." := 0;
                Clear(CheckLedgerEntry);
                CheckLedgerEntry.ChangeCompany(CurrentCompanyName);
                CheckLedgerEntry.SetRange("Bank Account Ledger Entry No.", BankAccountLedgerEntry."Entry No.");
                if not CheckLedgerEntry.IsEmpty() then begin
                    CheckLedgerEntry.FindSet();
                    repeat
                        CheckLedgerEntry."Statement Status" := CheckLedgerEntry."Statement Status"::Open;
                        CheckLedgerEntry."Statement No." := '';
                        CheckLedgerEntry."Statement Line No." := 0;
                        CheckLedgerEntry.Modify();
                    until CheckLedgerEntry.Next() = 0;
                end;
                BankAccountLedgerEntry.Modify();
            until BankAccountLedgerEntry.Next() = 0;
        end;
        Clear(CheckLedgerEntry);
        CheckLedgerEntry.ChangeCompany(CurrentCompanyName);
        CheckLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        CheckLedgerEntry.SetRange("Statement No.", StatementNo);
        CheckLedgerEntry.SetRange(Open, true);
        if CheckLedgerEntry.IsEmpty() then
            exit;
        CheckLedgerEntry.ModifyAll("Statement Status", CheckLedgerEntry."Statement Status"::Open);
        CheckLedgerEntry.ModifyAll("Statement No.", '');
        CheckLedgerEntry.ModifyAll("Statement Line No.", 0);
    end;

    local procedure GetFieldNo(TableId: Integer; FieldName: Text[30]): Integer
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        Field.SetRange(FieldName, FieldName);
        Field.FindFirst();
        exit(Field."No.");
    end;

    local procedure GetRecRefFieldFromFieldName(var RecRef: RecordRef; FieldName: Text[30]): FieldRef
    begin
        exit(RecRef.Field(GetFieldNo(RecRef.Number(), FieldName)));
    end;

    local procedure TransferFields(var TargetRecRef: RecordRef; var SourceRecRef: RecordRef)
    var
        Field: Record Field;
        SourceFieldRef: FieldRef;
        TargetFieldRef: FieldRef;
    begin
        Field.SetRange(TableNo, SourceRecRef.Number());
        repeat
            if TryGetFieldRef(SourceRecRef, SourceFieldRef, Field."No.") and TryGetFieldRef(TargetRecRef, TargetFieldRef, Field."No.") then
                TargetFieldRef.Value(SourceFieldRef.Value());
        until Field.Next() = 0;
    end;

    [TryFunction()]
    local procedure TryGetFieldRef(var RecordRef: RecordRef; var FieldRef: FieldRef; FieldNo: Integer)
    begin
        FieldRef := RecordRef.Field(FieldNo);
    end;

    local procedure SyncFeatureStatusState(FeatureDataUpdateStatus: Record "Feature Data Update Status")
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if FeatureDataUpdateStatus."Feature Key" <> BankDepositFeatureMgt.GetFeatureKeyId() then
            exit;
        if FeatureDataUpdateStatus."Feature Status" = FeatureDataUpdateStatus."Feature Status"::Disabled then
            DisableFeature()
        else
            EnableFeature();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Deposit Feature Mgt.", 'OnPreviousNADepositStateDetected', '', false, false)]
    local procedure OnPreviousNADepositStateDetected()
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if not FeatureDataUpdateStatus.Get(BankDepositFeatureMgt.GetFeatureKeyId(), CompanyName()) then
            exit;
        SyncFeatureStatusState(FeatureDataUpdateStatus);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Feature Data Update Status", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterFeatureDataUpdateStatusModify(var Rec: Record "Feature Data Update Status")
    begin
        SyncFeatureStatusState(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Feature Data Update Status", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterFeatureDataUpdateStatusInsert(var Rec: Record "Feature Data Update Status")
    begin
        SyncFeatureStatusState(Rec);
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure EnableFeature()
    var
        DepositsPageMgt: Codeunit "Deposits Page Mgt.";
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        BankDepositFeatureMgt.EnableDepositActions();
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositsPage, Page::"Bank Deposits");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositPage, Page::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositListPage, Page::"Bank Deposit List");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositReport, Report::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositTestReport, Report::"Bank Deposit Test Report");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::PostedBankDepositListPage, Page::"Posted Bank Deposit List");
        Commit();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure DisableFeature()
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        BankDepositFeatureMgt.DisableDepositActions();
        Commit();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure OpenPageGuard()
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if BankDepositFeatureMgt.IsEnabled() then
            exit;
        PromptFeatureBlockingOpen();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure PromptFeatureBlockingOpen()
    var
        DepositsPageMgt: Codeunit "Deposits Page Mgt.";
    begin
        if not DepositsPageMgt.PromptDepositFeature() then
            Error(FeatureDisabledErr);
        Error('');
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure ShouldSeePostedBankDeposits(): Boolean
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        exit(BankDepositFeatureMgt.IsEnabled() or (not PostedBankDepositHeader.IsEmpty()));
    end;
#endif

    var
        DescriptionTxt: Label 'Feature: Use standardized bank deposits.';
#if not CLEAN21
        FeatureDisabledErr: Label 'This page cannot be used because the Bank Deposits feature is not switched on.';
#endif
}