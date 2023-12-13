namespace Microsoft.DataMigration;

#if not CLEAN23

page 4001 "Intelligent Cloud Schedule"
{
    SourceTable = "Intelligent Cloud Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata 4003 = rimd;
    ObsoleteReason = 'Scheduling is not supported and will be removed';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

    layout
    {
        area(Content)
        {
            group(Schedule)
            {
                field("Replication Enabled"; Rec."Replication Enabled")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Activate Schedule';
                    ToolTip = 'Activate Migration Schedule';
                }
                field(Recurrence; Rec.Recurrence)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurrence';
                    ToolTip = 'Specifies the recurrence of the migration schedule.';
                }
                group(Days)
                {
                    Caption = 'Select Days';
                    Visible = (Rec.Recurrence = Rec.Recurrence::Weekly);
                    field(Sunday; Rec.Sunday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Sundays.';
                    }
                    field(Monday; Rec.Monday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Mondays.';
                    }
                    field(Tuesday; Rec.Tuesday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Tuesdays.';
                    }
                    field(Wednesday; Rec.Wednesday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Wednesdays.';
                    }
                    field(Thursday; Rec.Thursday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Thursdays.';
                    }
                    field(Friday; Rec.Friday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Fridays.';
                    }
                    field(Saturday; Rec.Saturday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Saturdays.';
                    }
                }
                field("Time to Run"; Rec."Time to Run")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Start time';
                    ToolTip = 'Specifies the time at which to start the migration.';
                }
            }
        }
    }

    trigger OnModifyRecord(): Boolean
    begin
        if Rec."Replication Enabled" and (Format(Rec."Time to Run") = '') then
            Error(NoScheduleTimeMsg);
        Rec.SetReplicationSchedule();
    end;

    var
        NoScheduleTimeMsg: Label 'You must set a schedule time to continue.';
}


#endif