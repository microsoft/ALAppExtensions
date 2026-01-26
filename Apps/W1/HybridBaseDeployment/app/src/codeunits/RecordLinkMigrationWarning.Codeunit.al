namespace Microsoft.DataMigration;

codeunit 40023 "Record Link Migration Warning" implements "Cloud Migration Warning"
{
    var
        RecordLinkMigrationUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2335385', Locked = true;
        RecordLinkMigrationWarningMsg: Label 'Record link table has not been migrated since the last replication.';

    procedure CheckWarning(): Boolean
    var
        ReplicationRecordLinkBuffer: Record "Replication Record Link Buffer";
        HybridCompanyStatus: Record "Hybrid Company Status";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if HybridCloudManagement.RecordLinkBufferBlocked() then
            exit(false);

        if ReplicationRecordLinkBuffer.IsEmpty() then
            exit(false);

        if not HybridCompanyStatus.Get() then
            exit(true);

        HybridReplicationSummary.SetCurrentKey("Start Time");
        if not HybridReplicationSummary.FindLast() then
            exit(false);

        if not HybridCompanyStatus."Record Link Move Completed" then
            exit(true);

        if HybridCompanyStatus."Last Record Link Move DateTime" < HybridReplicationSummary."End Time" then
            exit(true);

        exit(false);
    end;

    procedure FixWarning()
    begin
        Hyperlink(RecordLinkMigrationUrlLbl);
    end;

    procedure GetWarningMessage(): Text[1024]
    begin
        exit(RecordLinkMigrationWarningMsg);
    end;

    procedure ShowWarning(var CloudMigrationWarning: Record "Cloud Migration Warning"): Text
    var
        SearchCloudMigrationWarning: Record "Cloud Migration Warning";
        HybridCompanyStatus: Record "Hybrid Company Status";
        FilterTxt: Text;
    begin
        SearchCloudMigrationWarning.SetRange("Warning Type", SearchCloudMigrationWarning."Warning Type"::"Record Link");
        if HybridCompanyStatus.Get() then
            SearchCloudMigrationWarning.SetFilter(SystemCreatedAt, '>%1', HybridCompanyStatus."Last Record Link Move DateTime");

        if not SearchCloudMigrationWarning.FindSet() then
            exit;

        repeat
            FilterTxt := FilterTxt + Format(SearchCloudMigrationWarning."Entry No.") + '|'
        until SearchCloudMigrationWarning.Next() = 0;
        FilterTxt := FilterTxt.TrimEnd('|');

        exit(FilterTxt);
    end;

    procedure GetWarningCount(): Integer
    var
        CloudMigrationWarning: Record "Cloud Migration Warning";
        HybridCompanyStatus: Record "Hybrid Company Status";
    begin
        CloudMigrationWarning.SetRange("Warning Type", CloudMigrationWarning."Warning Type"::"Record Link");
        CloudMigrationWarning.SetRange(Ignored, false);
        if HybridCompanyStatus.Get() then
            CloudMigrationWarning.SetFilter(SystemCreatedAt, '>%1', HybridCompanyStatus."Last Record Link Move DateTime");

        exit(CloudMigrationWarning.Count());
    end;
}