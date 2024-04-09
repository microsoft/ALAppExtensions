namespace Microsoft.Bank.Deposit;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Company;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GenJnlManagement, 'OnBeforeOpenJournalPageFromBatch', '', false, false)]
    local procedure OnBeforeOpenJournalPageFromBatch(
        var GenJnlBatch: Record "Gen. Journal Batch";
        var GenJnlTemplate: Record "Gen. Journal Template";
        var IsHandled: Boolean)
    begin
        if not (GenJnlTemplate.Type = GenJnlTemplate.Type::"Bank Deposits") then
            exit;

        OpenBankDepositPage(GenJnlBatch, GenJnlTemplate);
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Open Deposit List Page", 'OnOpenDepositListPage', '', false, false)]
    local procedure OnOpenDepositListPage()
    begin
        Page.Run(Page::"Bank Deposit List");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Open Deposits Page", 'OnOpenDepositsPage', '', false, false)]
    local procedure OnOpenDepositsPage()
    begin
        Page.Run(Page::"Bank Deposits");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Open Deposit Page", 'OnOpenDepositPage', '', false, false)]
    local procedure OnOpenDepositPage()
    begin
        Page.Run(Page::"Bank Deposit List");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Open Deposit Report", 'OnOpenDepositReport', '', false, false)]
    local procedure OnOpenDepositReport()
    begin
        Report.Run(Report::"Bank Deposit Test Report");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Open Deposit Test Report", 'OnOpenDepositTestReport', '', false, false)]
    local procedure OnOpenDepositTestReport()
    begin
        Report.Run(Report::"Bank Deposit Test Report");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Open P. Bank Deposits L. Page", 'OnOpenPostedBankDepositsListPage', '', false, false)]
    local procedure OnOpenPostedBankDepositsListPage()
    begin
        Page.Run(Page::"Posted Bank Deposit List");
    end;

    local procedure OpenBankDepositPage(GenJnlBatch: Record "Gen. Journal Batch"; GenJnlTemplate: Record "Gen. Journal Template")
    var
        BankDepositHeader: Record "Bank Deposit Header";
        SetupBankDepositReports: Codeunit "Setup Bank Deposit Reports";
    begin
        BankDepositHeader.SetRange("Journal Template Name", GenJnlTemplate.Name);
        BankDepositHeader.SetRange("Journal Batch Name", GenJnlBatch.Name);
        if BankDepositHeader.IsEmpty() then begin
            SetupBankDepositReports.InsertSetupData();

            BankDepositHeader.Init();
            BankDepositHeader."Journal Template Name" := GenJnlTemplate.Name;
            BankDepositHeader."Journal Batch Name" := GenJnlBatch.Name;
            BankDepositHeader.Insert(true);
        end;

        Page.Run(GenJnlTemplate."Page ID", BankDepositHeader);
    end;

    var
        PostedBankDepositLinesLbl: Label 'Posted bank deposit - line information', Locked = true;
        PostingBankDepositLinesLbl: Label 'Before posting bank deposit - line information', Locked = true;
        OnBeforeUndoPostingBankDepositLbl: Label 'User is attempting to undo posted bank deposit.', Locked = true;
        OnAfterUndoPostingBankDepositLbl: Label 'User successfully reversed all transactions in posted bank deposit.', Locked = true;
}