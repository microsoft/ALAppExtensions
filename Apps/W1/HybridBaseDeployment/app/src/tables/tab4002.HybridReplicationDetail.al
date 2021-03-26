table 4002 "Hybrid Replication Detail"
{
    DataPerCompany = false;
    ReplicateData = false;

    // This table is populated during the replication process and as such can not be extended.
    Extensible = false;

    fields
    {
        field(1; "Run ID"; Text[50])
        {
            Description = 'The ID of the replication run.';
            TableRelation = "Hybrid Replication Summary"."Run ID";
            DataClassification = SystemMetadata;
        }
        field(2; "Table Name"; Text[250])
        {
            Description = 'The name of the table that was replicated.';
            DataClassification = SystemMetadata;
        }
        field(3; "Company Name"; Text[250])
        {
            Description = 'The name of the company for which the table data was replicated.';
            DataClassification = SystemMetadata;
        }
        field(4; "Start Time"; DateTime)
        {
            Description = 'The start date time of the table replication.';
            DataClassification = SystemMetadata;
        }
        field(5; "End Time"; DateTime)
        {
            Description = 'The end date time of the table replication.';
            DataClassification = SystemMetadata;
        }
        field(8; "Status"; Option)
        {
            Description = 'The status of the table replication.';
            OptionMembers = Failed,InProgress,Successful,Warning,NotStarted;
            OptionCaption = 'Failed,In Progress,Successful,Warning,Not Started';
            DataClassification = SystemMetadata;
        }
        field(10; "Errors"; Blob)
        {
            Description = 'Any errors that occured during the replication.';
            DataClassification = SystemMetadata;
            ObsoleteReason = 'Moved to the "Error Message" text field.';
            ObsoleteState = Removed;
            ObsoleteTag = '16.0';
        }
        field(11; "Error Code"; Text[10])
        {
            Description = 'The error code for any errors that occured during the replication.';
            DataClassification = SystemMetadata;
        }
        field(12; "Error Message"; Text[2048])
        {
            Description = 'Any errors that occured during the replication.';
            DataClassification = SystemMetadata;
        }
        field(14; "Records Copied"; Integer)
        {
            Description = 'The number of records that were copied for this table.';
            DataClassification = SystemMetadata;
        }
        field(15; "Total Records"; Integer)
        {
            Description = 'The total number of records in the source table.';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Run ID", "Table Name", "Company Name")
        {
            Clustered = true;
        }

        key(TableKey; "Table Name", "Company Name")
        {
        }

        key(Status; Status, "Company Name", "Table Name")
        {
        }
    }

    procedure GetCopiedRecords() Records: Integer
    var
        IntelligentCloudStatus: Record "Intelligent Cloud Status";
        TableRecordRef: RecordRef;
    begin
        Records := "Records Copied";
        if (Records > 0) or (Status <> Status::InProgress) or ("Total Records" < 10000) then
            exit;

        // Use a wild card for the company name since the Company Name value
        // doesn't necessarily match what's in the SQL table name.
        IntelligentCloudStatus.SetFilter("Table Name", '%1|%2', '*$' + "Table Name", "Table Name");
        IntelligentCloudStatus.SetRange("Company Name", "Company Name");

        // Don't attempt to get the count of a blocked table (will fail)
        IntelligentCloudStatus.SetRange(Blocked, false);

        // Only look at the record count if this is the initial migration for a table.
        if IntelligentCloudStatus.FindFirst() and (IntelligentCloudStatus."Synced Version" = 0) then begin
            TableRecordRef.Open(IntelligentCloudStatus."Table Id", false, "Company Name");
            Records := TableRecordRef.Count();
        end;
    end;

    procedure SetFailureStatus(RunId: Text[50]; TableName: Text[250]; CompanyName: Text[250]; FailureMessage: Text)
    var
        HybridReplicationDetail: Record "Hybrid Replication Detail";
    begin
        if not HybridReplicationDetail.Get(RunId, TableName, CompanyName) then begin
            HybridReplicationDetail.Init();
            HybridReplicationDetail."Table Name" := TableName;
            HybridReplicationDetail."Run ID" := RunId;
            HybridReplicationDetail."Company Name" := CompanyName;
            HybridReplicationDetail.Status := HybridReplicationDetail.Status::Failed;
            HybridReplicationDetail."Error Message" := CopyStr(FailureMessage, 1, 2048);
            HybridReplicationDetail.Insert();
        end else
            if HybridReplicationDetail.Status = HybridReplicationDetail.Status::Successful then begin
                HybridReplicationDetail.Status := HybridReplicationDetail.Status::Failed;
                HybridReplicationDetail."Error Message" := CopyStr(FailureMessage, 1, 2048);
                HybridReplicationDetail.Modify();
            end;
    end;
}