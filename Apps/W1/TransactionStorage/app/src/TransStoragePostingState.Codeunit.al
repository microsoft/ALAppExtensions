namespace System.DataAdministration;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using System.Environment;

codeunit 6242 "Trans. Storage Posting State"
{
    SingleInstance = true;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TransactionPosted: Boolean;

    local procedure SetTransactionPosted()
    begin
        TransactionPosted := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGLFinishPosting', '', false, false)]
    local procedure SetTransactionPostedOnAfterGLFinishPosting(GLEntry: Record "G/L Entry"; var GenJnlLine: Record "Gen. Journal Line"; var IsTransactionConsistent: Boolean; FirstTransactionNo: Integer; var GLRegister: Record "G/L Register"; var TempGLEntryBuf: Record "G/L Entry" temporary; var NextEntryNo: Integer; var NextTransactionNo: Integer)
    begin
        SetTransactionPosted();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::LogInManagement, 'OnAfterCompanyClose', '', true, true)]
    local procedure ScheduleTaskToExportOnAfterCompanyClose()
    var
        TransStorageScheduleTask: Codeunit "Trans. Storage Schedule Task";
    begin
        if TransactionPosted then
            TransStorageScheduleTask.ScheduleTaskToExport();
    end;
}