codeunit 40018 "Fix Data OnRun Completed"
{
    TableNo = "Replication Run Completed Arg";

    trigger OnRun()
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        NotificationTextInStream: InStream;
        NotificationText: Text;
    begin
        HybridCloudManagement.RepairCompanionTableRecordConsistency();
        Commit();

        SelectLatestVersion();

        // Mark as completed so we do not break existing flows
        HybridReplicationSummary.Get(Rec."Run ID");
        HybridReplicationSummary.Status := HybridReplicationSummary.Status::Completed;
        HybridReplicationSummary.Modify();
        Commit();

        Rec.SetAutoCalcFields("Notification Text");
        Rec.Get(Rec.RecordId);

        Rec."Notification Text".CreateInStream(NotificationTextInStream);
        NotificationTextInStream.ReadText(NotificationText);
        HybridCloudManagement.OnReplicationRunCompleted(Rec."Run ID", Rec."Subscription ID", NotificationText);

        Rec.Delete();
        Commit();
    end;
}