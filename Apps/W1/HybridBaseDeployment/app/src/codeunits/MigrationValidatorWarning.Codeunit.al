namespace Microsoft.DataMigration;

codeunit 40031 "Migration Validator Warning" implements "Cloud Migration Warning"
{
    var
        MigrationValidatorWarningMsg: Label 'Number of migration validators that had an error during the last migration.';

    procedure CheckWarning(): Boolean
    begin
        exit(GetWarningCount() > 0);
    end;

    procedure FixWarning()
    begin
        // Not sure what to put here.
        // The migration validators should not fail, and if one does it cannot be fixed by the one running the migration.
        // The issue should be reported.
    end;

    procedure ShowWarning(var CloudMigrationWarning: Record "Cloud Migration Warning"): Text
    var
        SearchCloudMigrationWarning: Record "Cloud Migration Warning";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        FilterTxt: Text;
    begin
        SearchCloudMigrationWarning.SetRange("Warning Type", SearchCloudMigrationWarning."Warning Type"::"Migration Validator");
        HybridReplicationSummary.SetCurrentKey("Start Time");
        if HybridReplicationSummary.FindLast() then
            SearchCloudMigrationWarning.SetFilter(SystemCreatedAt, '>%1', HybridReplicationSummary."End Time");

        if not SearchCloudMigrationWarning.FindSet() then
            exit;

        repeat
            FilterTxt := FilterTxt + Format(SearchCloudMigrationWarning."Entry No.") + '|'
        until SearchCloudMigrationWarning.Next() = 0;
        FilterTxt := FilterTxt.TrimEnd('|');

        exit(FilterTxt);
    end;

    procedure GetWarningMessage(): Text[1024]
    begin
        exit(MigrationValidatorWarningMsg);
    end;

    procedure GetWarningCount(): Integer
    var
        CloudMigrationWarning: Record "Cloud Migration Warning";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        CloudMigrationWarning.SetRange("Warning Type", CloudMigrationWarning."Warning Type"::"Migration Validator");
        CloudMigrationWarning.SetRange(Ignored, false);
        HybridReplicationSummary.SetCurrentKey("Start Time");
        if HybridReplicationSummary.FindLast() then
            CloudMigrationWarning.SetFilter(SystemCreatedAt, '>%1', HybridReplicationSummary."End Time");

        exit(CloudMigrationWarning.Count());
    end;
}