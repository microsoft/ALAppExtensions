pageextension 4009 "Hybrid O365 Activities" extends "O365 Activities"
{
    layout
    {
        addlast(Control54)
        {
            field("Replication Success Rate"; ReplicationSuccessRate)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Table Migration Success Rate';
                DrillDownPageId = "Intelligent Cloud Management";
                StyleExpr = CueStyle;
                AutoFormatType = 11;
                AutoFormatExpression = '<Precision,0:0><Standard Format,9>%';
                ToolTip = 'Specifies the percentage rate for the number of tables successfully migrated.';
                Visible = false;

                trigger OnDrillDown()
                begin
                    Page.Run(Page::"Intelligent Cloud Management");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        PermissionManager: Codeunit "Permission Manager";
        HybridCueSetupManagement: Codeunit "Hybrid Cue Setup Management";
    begin
        IsIntelligentCloudEnabled := PermissionManager.IsIntelligentCloud();
        if IsIntelligentCloudEnabled then begin
            ReplicationSuccessRate := HybridCueSetupManagement.GetReplicationSuccessRateCueValue();
            CueStyle := Format(HybridCueSetupManagement.GetReplicationSuccessRateCueStyle(ReplicationSuccessRate));
        end;
    end;

    var
        ReplicationSuccessRate: Decimal;
        CueStyle: Text;
        IsIntelligentCloudEnabled: Boolean;
}