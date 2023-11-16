namespace Microsoft.DataMigration.API;

using Microsoft.DataMigration;
using System.Telemetry;

page 40021 "Cloud Migration Status API"
{
    PageType = API;
    SourceTable = "Hybrid Replication Summary";
    APIGroup = 'cloudMigration';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    EntityCaption = 'Cloud Migration Status';
    EntitySetCaption = 'Cloud Migration Status';
    EntitySetName = 'cloudMigrationStatus';
    EntityName = 'cloudMigrationStatus';
    DelayedInsert = true;
    Extensible = false;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(id; Rec.SystemId)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'id';
                }
                field(runId; Rec."Run ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Caption = 'Run Id';
                }

                field(startTime; Rec."Start Time")
                {
                    ApplicationArea = All;
                    Caption = 'Start Time';
                }
                field(endTime; Rec."End Time")
                {
                    ApplicationArea = All;
                    Caption = 'End Time';
                }

                field(replicationType; Rec.ReplicationType)
                {
                    ApplicationArea = All;
                    Caption = 'Replication Type';
                }
                field(status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                }
                field(source; Rec.Source)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                }
                field(details; DetailsValue)
                {
                    ApplicationArea = All;
                    Caption = 'Details';
                }

                field(tablesSuccessful; Rec."Tables Successful")
                {
                    ApplicationArea = All;
                    Caption = 'Tables Successful';
                }
                field(tablesFailed; Rec."Tables Failed")
                {
                    ApplicationArea = All;
                    Caption = 'Tables Failed';
                }

                field(tablesRemaining; Rec."Tables Remaining")
                {
                    ApplicationArea = All;
                    Caption = 'Tables Remaining';
                }

                part(additionalDetails; "Cloud Mig Status Detail API")
                {
                    Caption = 'Additional Details';
                    EntityName = 'cloudMigrationStatusDetail';
                    EntitySetName = 'cloudMigrationStatusDetails';
                    SubPageLink = "Run ID" = field("Run ID");
                }
            }
        }
    }

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure RunReplication(var ActionContext: WebServiceActionContext)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        NewRunID: Text;
    begin
        FeatureTelemetry.LogUsage('0000JMN', HybridCloudManagement.GetFeatureTelemetryName(), 'Cloud migration API Replication');
        HybridCloudManagement.VerifyCanStartReplication();
        NewRunID := HybridCloudManagement.RunReplicationAPI(Rec.ReplicationType::Normal);
        Commit();

        HybridReplicationSummary.Get(CopyStr(NewRunID, 1, MaxStrLen(HybridReplicationSummary."Run ID")));
        SetActionResponseToThisPage(ActionContext, HybridReplicationSummary);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure RunDataUpgrade(var ActionContext: WebServiceActionContext)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUsage('0000JMO', HybridCloudManagement.GetFeatureTelemetryName(), 'Cloud migration API Upgrade');
        HybridCloudManagement.RunDataUpgrade(Rec);
        SetActionResponseToThisPage(ActionContext, Rec);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure RefreshStatus(var ActionContext: WebServiceActionContext)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.RefreshReplicationStatus();
        SetActionResponseToThisPage(ActionContext, Rec);
    end;


    [ServiceEnabled]
    [Scope('Cloud')]
    procedure ResetCloudData(var ActionContext: WebServiceActionContext)
    var
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.ResetCloudData();
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure CompleteCloudMigration(var ActionContext: WebServiceActionContext)
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
    begin
        HybridCloudManagement.CompleteCloudMigration();
        FeatureTelemetry.LogUsage('0000JV6', HybridCloudManagement.GetFeatureTelemetryName(), 'Cloud migration API Completed');
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure DisableReplication(var ActionContext: WebServiceActionContext)
    var
        HybridReplicationSummary: Record "Hybrid Replication Summary";
        HybridCloudManagement: Codeunit "Hybrid Cloud Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        HybridCloudManagement.DisableMigrationAPI();
        HybridReplicationSummary.SetCurrentKey("Start Time");
        HybridReplicationSummary.FindLast();
        SetActionResponseToThisPage(ActionContext, HybridReplicationSummary);
        FeatureTelemetry.LogUsage('0000JMP', HybridCloudManagement.GetFeatureTelemetryName(), 'Cloud migration API Disabled');
    end;

    local procedure SetActionResponseToThisPage(var ActionContext: WebServiceActionContext; HybridReplicationSummary: Record "Hybrid Replication Summary")
    begin
        SetActionResponse(ActionContext, Page::"Cloud Mig Product Type API", HybridReplicationSummary.SystemId, HybridReplicationSummary.FieldNo(SystemId));
    end;

    local procedure SetActionResponse(var ActionContext: WebServiceActionContext; PageId: Integer; ActionRunId: Guid; KeyFieldNo: Integer)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(PageId);
        ActionContext.AddEntityKey(KeyFieldNo, ActionRunId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Start Time");
        Rec.Ascending(false);
    end;

    trigger OnAfterGetRecord()
    begin
        DetailsValue := Rec.GetDetails();
    end;

    var
        DetailsValue: Text;
}