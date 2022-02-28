table 4001 "Hybrid Replication Summary"
{
    DataPerCompany = false;
    ReplicateData = false;
    // Do not extend this table
    // Extensible = false;

    fields
    {
        field(1; "Run ID"; Text[50])
        {
            Description = 'The ID of the replication run.';
            DataClassification = SystemMetadata;
        }
        field(2; "Start Time"; DateTime)
        {
            Description = 'The start date time of the replication run.';
            DataClassification = SystemMetadata;
        }
        field(3; "End Time"; DateTime)
        {
            Description = 'The end date time of the replication run.';
            DataClassification = SystemMetadata;
        }
        field(4; "Replication Type"; Option)
        {
            Description = 'The type of trigger for the replication run.';
            OptionMembers = Scheduled,Manual;
            DataClassification = SystemMetadata;
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to Trigger Type';
            ObsoleteTag = '15.4';
        }
        field(5; "Status"; Option)
        {
            Description = 'The status of the replication run.';
            OptionMembers = Failed,InProgress,Completed,UpgradePending,UpgradeInProgress,UpgradeFailed,RepairDataPending;
            OptionCaption = 'Failed,In Progress,Completed,Upgrade Pending,Upgrade in Progress,Upgrade Failed, Data Repair Pending';
            DataClassification = SystemMetadata;
        }
        field(6; "Tables Successful"; Integer)
        {
            Description = 'The number of tables that successfully replicated.';
            FieldClass = FlowField;
            CalcFormula = count("Hybrid Replication Detail" where("Run Id" = field("Run Id"), Status = const(Successful)));
        }
        field(7; "Tables Failed"; Integer)
        {
            Description = 'The number of tables that failed during replication.';
            FieldClass = FlowField;
            CalcFormula = count("Hybrid Replication Detail" where("Run Id" = field("Run Id"), Status = filter(Failed)));
        }
        field(8; "Cloud Ready"; Boolean)
        {
            Description = 'Indicates whether the company data is cloud-ready.';
            DataClassification = SystemMetadata;
        }
        field(9; "Source"; Text[250])
        {
            Description = 'The source for the data replication.';
            DataClassification = SystemMetadata;
        }
        field(10; "Trigger Type"; Option)
        {
            Description = 'The type of trigger that started the replication run.';
            OptionMembers = Unknown,Scheduled,Manual;
            DataClassification = SystemMetadata;
        }
        field(11; "ReplicationType"; Option)
        {
            Caption = 'Migration Type';
            Description = 'The type of migration run.';
            OptionMembers = Normal,Diagnostic,Full,"Azure Data Lake";
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                IntelligentCloudStatus: Record "Intelligent Cloud Status";
            begin
                if "ReplicationType" = "ReplicationType"::Normal then begin
                    IntelligentCloudStatus.SetFilter("Synced Version", '>0');
                    if IntelligentCloudStatus.IsEmpty() then
                        "ReplicationType" := "ReplicationType"::Full;
                end;
            end;
        }
        field(12; "Details"; Blob)
        {
            Description = 'Additional details on the migration run.';
            DataClassification = SystemMetadata;
        }
        field(13; "Tables with Warnings"; Integer)
        {
            Description = 'The number of tables that had warnings during replication.';
            FieldClass = FlowField;
            CalcFormula = count("Hybrid Replication Detail" where("Run Id" = field("Run Id"), Status = filter(Warning)));
        }
        field(14; "Tables Remaining"; Integer)
        {
            Description = 'The number of tables that still remain for the replication.';
            FieldClass = FlowField;
            CalcFormula = count("Hybrid Replication Detail" where("Run Id" = field("Run Id"), Status = filter(NotStarted | InProgress)));
        }

        field(20; "Companies Not Initialized"; Integer)
        {
            Description = 'The number of tables that still remain for the replication.';
            FieldClass = FlowField;
            CalcFormula = count("Hybrid Company" where("Company Initialization Status" = filter(Unknown | "Not Initialized" | "Initialization Failed")));
        }
    }

    keys
    {
        key(PK; "Run ID")
        {
            Clustered = true;
        }

        key(TimeKey; "Start Time")
        {
        }
    }

    procedure CreateInProgressRecord(RunId: Text; ReplicationType: Option);
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        if not HybridReplicationSummary.Get(RunId) then begin
            HybridReplicationSummary.Init();
            HybridReplicationSummary.Validate(ReplicationType, ReplicationType);
            HybridReplicationSummary."Trigger Type" := "Trigger Type"::Manual;
            HybridReplicationSummary."Run ID" := CopyStr(RunId, 1, 50);
            HybridReplicationSummary."Start Time" := CurrentDateTime();
            HybridReplicationSummary.Status := Status::InProgress;
            HybridReplicationSummary.Source := CopyStr(HybridCloudManagement.GetChosenProductName(), 1, 250);
            HybridReplicationSummary.Insert();
        end;
    end;

    procedure AddDetails(Value: Text)
    begin
        if Value = '' then
            exit;
        if Details.HasValue() then
            Value := GetDetails() + '\\' + Value;
        SetDetails(Value);
    end;

    procedure EvaluateStatus(ReplicationStatus: Text)
    begin
        if Evaluate(Status, ReplicationStatus) then
            exit;

        case ReplicationStatus of
            'Cancelled':
                Status := Status::Failed;
            'Succeeded':
                Status := Status::Completed;
        end;
    end;

    procedure GetDetails() Value: Text;
    var
        DetailsInStream: InStream;
    begin
        if Details.HasValue() then begin
            CalcFields(Details);
            Details.CreateInStream(DetailsInStream, TextEncoding::UTF8);
            DetailsInStream.Read(Value);
        end;
    end;

    procedure SetDetails(Value: Text)
    var
        DetailsOutStream: OutStream;
    begin
        Details.CreateOutStream(DetailsOutStream, TextEncoding::UTF8);
        DetailsOutStream.WriteText(Value);
    end;

}