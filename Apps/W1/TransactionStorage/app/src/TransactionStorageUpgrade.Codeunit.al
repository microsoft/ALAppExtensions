namespace System.DataAdministration;

using System.Upgrade;

codeunit 6206 "Transaction Storage Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        TransactStorageExport: Codeunit "Transact. Storage Export";

    trigger OnUpgradePerCompany()
    begin
        UpdateTaskStartTime();
    end;

    local procedure UpdateTaskStartTime()
    var
        TransactionStorageSetup: Record "Transaction Storage Setup";
    begin
        if UpgradeTag.HasUpgradeTag(GetUpdateTaskStartTimeTag()) then
            exit;

        if not TransactionStorageSetup.Get() then
            exit;

        // do not update start time if user changed it earlier
        if TransactionStorageSetup."Earliest Start Time" <> 020000T then
            exit;

        // set different start time for different groups of tenants (2:00 AM - 4:40 AM)
        TransactionStorageSetup."Earliest Start Time" := TransactStorageExport.CalcTenantExportStartTime();
        if TransactionStorageSetup.Modify() then;

        UpgradeTag.SetUpgradeTag(GetUpdateTaskStartTimeTag());
    end;

    procedure GetUpdateTaskStartTimeTag(): Code[250]
    begin
        exit('MS-503020-TransactionStorage-UpdateTaskStartTime-20240229');
    end;
}