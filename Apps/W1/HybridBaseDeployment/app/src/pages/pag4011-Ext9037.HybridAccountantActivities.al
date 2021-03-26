pageextension 4011 "Hybrid Accountant Activities" extends "Accountant Activities"
{
    layout
    {
        addlast(Control36)
        {
            field("Replication Success Rate"; "Replication Success Rate")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Table Migration Success Rate';
                DrillDownPageId = "Intelligent Cloud Management";
                StyleExpr = CueStyle;
                ToolTip = 'Specifies the percentage rate for the number of tables successfully migrated.';
                Visible = IsIntelligentCloudEnabled;
            }
        }
    }

    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
    begin
        IsIntelligentCloudEnabled := PermissionManager.IsIntelligentCloud();
    end;

    trigger OnAfterGetRecord()
    var
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        if FieldActive("Replication Success Rate") then begin
            "Replication Success Rate" := HybridCueSetupManagement.GetReplicationSuccessRateCueValue();
            CueStyle := Format(HybridCueSetupManagement.GetReplicationSuccessRateCueStyle("Replication Success Rate"));
        end;
    end;

    var
        CueStyle: Text;
        IsIntelligentCloudEnabled: Boolean;
}