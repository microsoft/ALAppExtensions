namespace Microsoft.DataMigration;

codeunit 40018 "Fix Data OnRun Completed"
{
    TableNo = "Replication Run Completed Arg";

    trigger OnRun()
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.RepairCompanionTableRecordConsistency();
        Commit();

        SelectLatestVersion();
    end;
}