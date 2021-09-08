page 149007 "BCPT Suite Line API"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'performancToolkit';
    APIVersion = 'v1.0';

    Caption = 'BCPT Suite Lines API';

    EntityCaption = 'bcptSuiteLine';
    EntitySetCaption = 'bcptSuiteLine';
    EntityName = 'bcptSuiteLine';
    EntitySetName = 'bcptSuiteLines';

    SourceTable = "BCPT Line";
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
                field("codeunitID"; Rec."Codeunit ID")
                {
                    Caption = 'Codeunit ID';
                }
                field("numberOfSessions"; Rec."No. of Sessions")
                {
                    Caption = 'No. of Sessions';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field("minimumUserDelay"; Rec."Min. User Delay (ms)")
                {
                    Caption = 'Min. User Delay (ms)';
                }
                field("maximumUserDelay"; Rec."Max. User Delay (ms)")
                {
                    Caption = 'Max. User Delay (ms)';
                }
                field("delayBetweenIterations"; Rec."Delay (sec. btwn. iter.)")
                {
                    Caption = 'Delay between iterations (sec.)';
                }
                field("delayType"; Rec."Delay Type")
                {
                    Caption = 'Delay Type';
                }
                field("runInForeground"; Rec."Run in Foreground")
                {
                    Caption = 'Run in Foreground';
                }
                field("noOfRunningSessions"; Rec."No. of Running Sessions")
                {
                    Caption = 'No. of Running Sessions';
                }
                field(parameters; Rec.Parameters)
                {
                    Caption = 'Parameters';
                }
            }
        }
    }
}