#if not CLEAN19
#pragma warning disable AL0432
codeunit 31335 "Sync.Dep.Fld-BankExImSetup CZB"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Bank Export/Import Setup", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertBankExportImportSetup(var Rec: Record "Bank Export/Import Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Export/Import Setup", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifyBankExportImportSetup(var Rec: Record "Bank Export/Import Setup")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var BankExportImportSetup: Record "Bank Export/Import Setup")
    var
        PreviousBankExportImportSetup: Record "Bank Export/Import Setup";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if SyncDepFldUtilities.GetPreviousRecord(BankExportImportSetup, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousBankExportImportSetup);

        SyncDepFldUtilities.SyncFields(BankExportImportSetup."Processing Report ID", BankExportImportSetup."Processing Report ID CZB", PreviousBankExportImportSetup."Processing Report ID", PreviousBankExportImportSetup."Processing Report ID CZB");
        DepFieldTxt := BankExportImportSetup."Default File Type";
        NewFieldTxt := BankExportImportSetup."Default File Type CZB";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousBankExportImportSetup."Default File Type", PreviousBankExportImportSetup."Default File Type CZB");
        BankExportImportSetup."Default File Type" := CopyStr(DepFieldTxt, 1, MaxStrLen(BankExportImportSetup."Default File Type"));
        BankExportImportSetup."Default File Type CZB" := CopyStr(NewFieldTxt, 1, MaxStrLen(BankExportImportSetup."Default File Type CZB"));
    end;
}
#endif
