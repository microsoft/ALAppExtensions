page 149008 "BCPT Log Entry API"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'performancToolkit';
    APIVersion = 'v1.0';

    Caption = 'BCPT Logs Entry API';

    EntityCaption = 'bcptLogEntry';
    EntitySetCaption = 'bcptLogEntry';
    EntityName = 'bcptLogEntry';
    EntitySetName = 'bcptLogEntries';

    SourceTable = "BCPT Log Entry";
    ODataKeyFields = SystemId;

    Extensible = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("bcptCode"; Rec."BCPT Code")
                {
                    Caption = 'BCPT Code';
                    Editable = false;
                    NotBlank = true;
                    TableRelation = "BCPT Header";
                }
                field("lineNumber"; Rec."BCPT Line No.")
                {
                    Caption = 'Line No.';
                }
                field("tag"; Rec.Tag)
                {
                    Caption = 'Tag';
                }
                field("version"; Rec.Version)
                {
                    Caption = 'Version No.';
                }
                field("entryNumber"; Rec."Entry No.")
                {
                    Caption = 'Entry No.';
                }
                field("startTime"; Rec."Start Time")
                {
                    Caption = 'Start Time';
                }
                field("endTime"; Rec."End Time")
                {
                    Caption = 'End Time';
                }
                field("codeunitID"; Rec."Codeunit ID")
                {
                    Caption = 'Codeunit ID';
                }
                field("codeunitName"; Rec."Codeunit Name")
                {
                    Caption = 'Codeunit Name';
                }
                field("sessionId"; Rec."Session No.")
                {
                    Caption = 'Session No.';
                }
                field("operation"; Rec.Operation)
                {
                    Caption = 'Operation';
                }
                field("message"; Rec.Message)
                {
                    Caption = 'Message';
                }
                field("durationMin"; Rec."Duration (ms)")
                {
                    Caption = 'Duration (ms)';

                }
                field("numberOfSQLStmts"; Rec."No. of SQL Statements")
                {
                    Caption = 'No. of SQL Statements';
                }
                field("status"; Rec.Status)
                {
                    Caption = 'Status';
                }
            }
        }
    }
}