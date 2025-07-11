namespace Microsoft.DataMigration.GP;

using Microsoft.DataMigration;

codeunit 40020 "Hybrid Handle GP Upgrade Error"
{
    TableNo = "Hybrid Replication Summary";

    trigger OnRun()
    begin
        MarkUpgradeFailed(Rec);
    end;

    internal procedure MarkUpgradeFailed(var HybridReplicationSummary: Record "Hybrid Replication Summary")
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        FailureMessageOutStream: OutStream;
    begin
        HybridCompanyStatus.Get(CompanyName);
        HybridCompanyStatus."Upgrade Status" := HybridCompanyStatus."Upgrade Status"::Failed;
        HybridCompanyStatus."Upgrade Failure Message".CreateOutStream(FailureMessageOutStream);
        FailureMessageOutStream.Write(GetLastErrorText());
        HybridCompanyStatus.Modify();
        Commit();

        HybridReplicationSummary.Find();
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::UpgradeFailed;
        HybridReplicationSummary.Modify();
    end;
}