namespace Microsoft.DataMigration;

using System.Environment;

codeunit 40024 "Tenant Media Warning" implements "Cloud Migration Warning"
{
    var
        TenantMediaMigrationUrlLbl: Label 'https://go.microsoft.com/fwlink/?linkid=2335185', Locked = true;
        TenantMediaWarningMsg: Label 'Number of records in Tenant Media table decreased after last replication.';

    procedure CheckWarning(): Boolean
    var
        HybridCompanyStatus: Record "Hybrid Company Status";
        TenantMedia: Record "Tenant Media";
    begin
        if not HybridCompanyStatus.Get() then
            exit(false);

        if TenantMedia.Count() < HybridCompanyStatus."Tenant Media Count" then
            exit(true);

        exit(false);
    end;

    procedure FixWarning()
    begin
        Hyperlink(TenantMediaMigrationUrlLbl);
    end;

    procedure GetWarningMessage(): Text[1024]
    begin
        exit(TenantMediaWarningMsg);
    end;

    procedure ShowWarning(var CloudMigrationWarning: Record "Cloud Migration Warning"): Text
    var
        SearchCloudMigrationWarning: Record "Cloud Migration Warning";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        FilterTxt: Text;
    begin
        SearchCloudMigrationWarning.SetRange("Warning Type", SearchCloudMigrationWarning."Warning Type"::"Tenant Media");
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

    procedure GetWarningCount(): Integer
    var
        CloudMigrationWarning: Record "Cloud Migration Warning";
        HybridReplicationSummary: Record "Hybrid Replication Summary";
    begin
        CloudMigrationWarning.SetRange("Warning Type", CloudMigrationWarning."Warning Type"::"Tenant Media");
        CloudMigrationWarning.SetRange(Ignored, false);
        HybridReplicationSummary.SetCurrentKey("Start Time");
        if HybridReplicationSummary.FindLast() then
            CloudMigrationWarning.SetFilter(SystemCreatedAt, '>%1', HybridReplicationSummary."End Time");

        exit(CloudMigrationWarning.Count());
    end;
}