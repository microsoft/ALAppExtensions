#if not CLEAN18
page 4001 "Intelligent Cloud Schedule"
{
    SourceTable = "Intelligent Cloud Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    Permissions = tabledata 4003 = rimd;

    layout
    {
        area(Content)
        {
            group(Schedule)
            {
                field("Replication Enabled"; "Replication Enabled")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Activate Schedule';
                    ToolTip = 'Activate Migration Schedule';
                }
                field(Recurrence; Recurrence)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurrence';
                    ToolTip = 'Specifies the recurrence of the migration schedule.';
                }
                group(Days)
                {
                    Caption = 'Select Days';
                    Visible = (Recurrence = Recurrence::Weekly);
                    field(Sunday; Sunday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Sundays.';
                    }
                    field(Monday; Monday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Mondays.';
                    }
                    field(Tuesday; Tuesday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Tuesdays.';
                    }
                    field(Wednesday; Wednesday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Wednesdays.';
                    }
                    field(Thursday; Thursday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Thursdays.';
                    }
                    field(Friday; Friday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Fridays.';
                    }
                    field(Saturday; Saturday)
                    {
                        ApplicationArea = Basic, Suite;
                        ToolTip = 'Specifies whether to run on Saturdays.';
                    }
                }
                field("Time to Run"; "Time to Run")
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
        if "Replication Enabled" and (Format("Time to Run") = '') then
            Error(NoScheduleTimeMsg);
        SetReplicationSchedule();
    end;

    var
        NoScheduleTimeMsg: Label 'You must set a schedule time to continue.';
}
#endif