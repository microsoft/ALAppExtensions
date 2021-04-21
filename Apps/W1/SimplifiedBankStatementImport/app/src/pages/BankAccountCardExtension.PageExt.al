pageextension 8850 "Bank Account Card Extension" extends "Bank Account Card"
{
    var
        BankStatementImportFormatEmptyMsg: Label 'A Bank Statement Import Format is not specified for the bank account. You can select an existing format, or create one.';
        NotificationActionLbl: Label 'Set up Bank Statement File Import Format';

    trigger OnOpenPage()
    var
        GeneralLedgerSetupRecordRef: RecordRef;
        AutoMatchFieldRef: FieldRef;
    begin
        if AutoMatchAvailable(GeneralLedgerSetupRecordRef, AutoMatchFieldRef) then
            if not AutoMatchFieldRef.Value() then
                exit;

        CreateEmptyBankStatementImportNotification();
    end;

    local procedure AutoMatchAvailable(var GeneralLedgerSetupRecordRef: RecordRef; var AutoMatchFieldRef: FieldRef): Boolean
    begin
        GeneralLedgerSetupRecordRef.Open(Database::"General Ledger Setup");
        if not GeneralLedgerSetupRecordRef.FieldExist(10120) then
            exit(false);
        GeneralLedgerSetupRecordRef.FindFirst();
        AutoMatchFieldRef := GeneralLedgerSetupRecordRef.Field(10120);
        exit(AutoMatchFieldRef.Type = FieldType::Boolean);
    end;

    local procedure CreateEmptyBankStatementImportNotification()
    var
        SetBankStatementImportFormat: Notification;
    begin
        if Rec."Bank Statement Import Format" = '' then begin
            SetBankStatementImportFormat.Id := GetBankStatementImportFormatNotificationId();
            if SetBankStatementImportFormat.Recall() then;
            SetBankStatementImportFormat.Message := BankStatementImportFormatEmptyMsg;
            SetBankStatementImportFormat.Scope := NotificationScope::LocalScope;
            SetBankStatementImportFormat.AddAction(NotificationActionLbl, Codeunit::"Bank Statement File Wizard", 'RunBankStatementFileWizard');
            SetBankStatementImportFormat.Send();
        end;
    end;

    local procedure GetBankStatementImportFormatNotificationId(): Guid
    begin
        exit('6d84f0cb-e1bb-4576-a4ef-a61297f9c792');
    end;
}