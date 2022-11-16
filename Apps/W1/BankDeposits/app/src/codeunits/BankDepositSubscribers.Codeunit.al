codeunit 1695 "Bank Deposit Subscribers"
{
    Permissions = tabledata "Bank Deposit Header" = rmd,
                  tabledata "Posted Bank Deposit Header" = rm,
                  tabledata "Posted Bank Deposit Line" = rm;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Template", 'OnAfterValidateType', '', false, false)]
    local procedure OnAfterValidateType(var GenJournalTemplate: Record "Gen. Journal Template"; SourceCodeSetup: Record "Source Code Setup")
    begin
        if GenJournalTemplate.Type = GenJournalTemplate.Type::"Bank Deposits" then begin
            GenJournalTemplate."Source Code" := SourceCodeSetup."Bank Deposit";
            GenJournalTemplate."Page ID" := PAGE::"Bank Deposit";
            GenJournalTemplate."Test Report ID" := REPORT::"Bank Deposit Test Report";
            GenJournalTemplate."Posting Report ID" := REPORT::"Bank Deposit";
            GenJournalTemplate."Bal. Account Type" := GenJournalTemplate."Bal. Account Type"::"Bank Account";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Change Global Dimensions", 'OnChangeDimsOnRecord', '', false, false)]
    local procedure HandleOnChangeDimsOnRecord(ChangeGlobalDimLogEntry: Record "Change Global Dim. Log Entry"; var RecRef: RecordRef; var IsHandled: Boolean)
    var
        GlobalDimFieldRef: array[2] of FieldRef;
        OldDimValueCode: array[2] of Code[20];
    begin
        if (RecRef.Number <> Database::"Bank Deposit Header") and (RecRef.Number <> Database::"Posted Bank Deposit Header") and (RecRef.Number <> Database::"Posted Bank Deposit Line") then
            exit;

        if (ChangeGlobalDimLogEntry."Change Type 1" = ChangeGlobalDimLogEntry."Change Type 1"::Replace) and (ChangeGlobalDimLogEntry."Global Dim.2 Field No." = 0) then
            ChangeGlobalDimLogEntry."Change Type 1" := ChangeGlobalDimLogEntry."Change Type 1"::New;
        if (ChangeGlobalDimLogEntry."Change Type 2" = ChangeGlobalDimLogEntry."Change Type 2"::Replace) and (ChangeGlobalDimLogEntry."Global Dim.1 Field No." = 0) then
            ChangeGlobalDimLogEntry."Change Type 2" := ChangeGlobalDimLogEntry."Change Type 2"::New;

        if ChangeGlobalDimLogEntry."Global Dim.1 Field No." = 0 then
            ChangeGlobalDimLogEntry."Change Type 1" := ChangeGlobalDimLogEntry."Change Type 1"::None;
        if ChangeGlobalDimLogEntry."Global Dim.2 Field No." = 0 then
            ChangeGlobalDimLogEntry."Change Type 2" := ChangeGlobalDimLogEntry."Change Type 2"::None;

        ChangeGlobalDimLogEntry.GetFieldRefValues(RecRef, GlobalDimFieldRef, OldDimValueCode);
        ChangeGlobalDimLogEntry.ChangeDimOnRecord(RecRef, 1, GlobalDimFieldRef[1], OldDimValueCode[2]);
        ChangeGlobalDimLogEntry.ChangeDimOnRecord(RecRef, 2, GlobalDimFieldRef[2], OldDimValueCode[1]);
        IsHandled := RecRef.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Deposit-Post", 'OnAfterBankDepositPost', '', true, true)]
    local procedure LogNumberOfPostedDepositLines(BankDepositHeader: Record "Bank Deposit Header"; PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    var
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        Attributes: Dictionary of [Text, Text];
    begin
        PostedBankDepositLine.SetRange("Bank Deposit No.", PostedBankDepositHeader."No.");
        Attributes.Add('Number of lines', Format(PostedBankDepositLine.Count()));
        Session.LogMessage('0000GIB', PostedBankDepositLinesLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Attributes);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Bank Deposit Header", 'OnBeforeUndoPostedBankDeposit', '', true, true)]
    local procedure LogTelemetryOnBeforeUndoPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    var
        Attributes: Dictionary of [Text, Text];
    begin
        Attributes.Add('Bank Deposit Number', Format(PostedBankDepositHeader."No."));
        Session.LogMessage('0000GVJ', OnBeforeUndoPostingBankDepositLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Attributes);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Posted Bank Deposit Header", 'OnAfterUndoPostedBankDeposit', '', true, true)]
    local procedure LogTelemetryOnAfterUndoPostedBankDeposit(var PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    var
        Attributes: Dictionary of [Text, Text];
    begin
        Attributes.Add('Bank Deposit Number', Format(PostedBankDepositHeader."No."));
        Session.LogMessage('0000GVK', OnAfterUndoPostingBankDepositLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Attributes);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Deposit-Post", 'OnBeforeBankDepositPost', '', true, true)]
    local procedure LogNumberOfPostedDepositLinesOnBeforeBankDepositPost(BankDepositHeader: Record "Bank Deposit Header")
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        Attributes: Dictionary of [Text, Text];
    begin
        SourceCodeSetup.Get();
        GenJournalLine.SetRange("Source Code", SourceCodeSetup."Bank Deposit");
        GenJournalLine.SetRange("Source Type", GenJournalLine."Source Type"::"Bank Account");
        GenJournalLine.SetRange("External Document No.", BankDepositHeader."No.");
        Attributes.Add('Number of lines', Format(GenJournalLine.Count()));
        Session.LogMessage('0000GIC', PostingBankDepositLinesLbl, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Attributes);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company-Initialize", 'OnCompanyInitialize', '', true, true)]
    local procedure SetUpBankdepositsOnCompanyInitialize()
    var
        SetupBankDepositReports: Codeunit "Setup Bank Deposit Reports";
    begin
        SetupBankDepositReports.SetupNumberSeries();
        SetupBankDepositReports.SetupJournalTemplateAndBatch();
        SetupBankDepositReports.SetupReportSelections();
    end;

#if not CLEAN21
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Feature Management Facade", 'OnAfterFeatureDisableConfirmed', '', false, false)]
    local procedure HandleOnAfterFeatureDisableConfirmed(FeatureKey: Record "Feature Key")
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankDepositHeader: Record "Bank Deposit Header";
        Company: Record Company;
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if FeatureKey.ID <> BankDepositFeatureMgt.GetFeatureKeyId() then
            exit;

        if Company.FindSet() then
        repeat
            BankAccReconciliation.ChangeCompany(Company.Name);
            BankAccReconciliation.Reset();
            BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Bank Reconciliation");
            BankDepositHeader.ChangeCompany(Company.Name);
            BankDepositHeader.Reset();
            if (not BankDepositHeader.IsEmpty()) or (not BankAccReconciliation.IsEmpty()) then
                Error(EnableFeatureErr, Company.Name);
        until Company.Next() = 0;
    end;
#endif

    var
        PostedBankDepositLinesLbl: Label 'Posted bank deposit - line information', Locked = true;
        PostingBankDepositLinesLbl: Label 'Before posting bank deposit - line information', Locked = true;
        OnBeforeUndoPostingBankDepositLbl: Label 'User is attempting to undo posted bank deposit.', Locked = true;
        OnAfterUndoPostingBankDepositLbl: Label 'User successfully reversed all transactions in posted bank deposit.', Locked = true;
#if not CLEAN21
        EnableFeatureErr: Label 'You must either post or delete all bank deposits and bank account reconciliations for company %1 and every company on this environment before disabling Bank Deposits feature.', Comment = '%1 - Name of the company';
#endif
}