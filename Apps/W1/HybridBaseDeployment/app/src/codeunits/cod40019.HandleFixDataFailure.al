codeunit 40019 "Handle Fix Data Failure"
{
    TableNo = "Replication Run Completed Arg";

    trigger OnRun()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        HybridReplicationSummary.SetAutoCalcFields(Details);
        HybridReplicationSummary.Get(Rec."Run ID");
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Failed;
        HybridReplicationSummary.AddDetails(GetLastErrorText() + GetLastErrorCallStack());
        HybridReplicationSummary.Modify();
        Commit();
    end;

}