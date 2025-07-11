namespace Microsoft.DataMigration;

page 40033 "Hybrid Migration Log"
{
    PageType = ListPart;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hybrid Replication Summary";
    SourceTableView = sorting("Start Time") order(descending);
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'Migration log';
                Editable = false;

                field("Start Time"; Rec."Start Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the start time of the migration.';
                }
                field("End Time"; Rec."End Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the end time of the migration.';
                }
                field("Trigger Type"; Rec."Trigger Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the trigger type of the migration.';
                    Visible = false;
                }
                field("Replication Type"; Rec.ReplicationType)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of migration.';
                    Visible = false;
                }
                field("Status"; Rec.Status)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status of the migration run.';
                    Visible = false;
                    StyleExpr = StatusExpression;
                }
                field(StatusDisplayName; StatusDisplayName)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the migration run.';
                    StyleExpr = StatusExpression;
                }
                field("Source"; Rec.Source)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the source of the migration run.';
                    Visible = false;
                }
                field("Details"; DetailsValue)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Details';
                    ToolTip = 'Specifies additional details about the migration run.';

                    trigger OnDrillDown()
                    begin
                        if DetailsValue <> '' then
                            Message(DetailsValue);
                    end;
                }
                field(SuccessfulTables; Rec."Tables Successful")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tables Successful';
                    ToolTip = 'Specifies the total number of tables that were successfully copied.';
                    BlankZero = true;

                    trigger OnDrillDown()
                    var
                        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                    begin
                        HybridReplicationStatistics.OpenTablesStatus(DummyHybridReplicationDetail.Status::Successful, Rec);
                    end;
                }

                field(FailedTables; Rec."Tables Failed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tables Failed';
                    ToolTip = 'Specifies the total number of tables that failed copying.';
                    BlankZero = true;

                    trigger OnDrillDown()
                    var
                        HybridReplicationStatistics: Codeunit "Hybrid Replication Statistics";
                    begin
                        HybridReplicationStatistics.OpenTablesStatus(DummyHybridReplicationDetail.Status::Failed, Rec);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateCalculatedValuesForMigrationLogs();
        UpdateProperties();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        UpdateCalculatedValuesForMigrationLogs();
        UpdateProperties();
    end;

    local procedure UpdateCalculatedValuesForMigrationLogs()
    begin
        Rec.CalcFields(Rec.Details, Rec."Tables Failed");
        DetailsValue := Rec.GetDetails();

        StatusDisplayName := Format(Rec.Status);
        if Rec.Status = Rec.Status::UpgradePending then
            StatusDisplayName := Format(Rec.Status::Completed);

        if Rec.Status in [Rec.Status::Completed, Rec.Status::UpgradePending] then
            if Rec."Tables Failed" > 0 then
                StatusDisplayName := Format(Rec.Status::Failed);
    end;

    local procedure UpdateProperties()
    begin
        Clear(TablesWithWarningExpressionTxt);
        if Rec."Tables with Warnings" > 0 then
            TablesWithWarningExpressionTxt := 'Ambiguous';

        Clear(StatusExpression);
        if StatusDisplayName = Format(Rec.Status::Failed) then
            StatusExpression := 'Unfavorable';
    end;

    var
        DummyHybridReplicationDetail: Record "Hybrid Replication Detail";
        DetailsValue: Text;
        StatusExpression: Text;
        TablesWithWarningExpressionTxt: Text;
        StatusDisplayName: Text;
}