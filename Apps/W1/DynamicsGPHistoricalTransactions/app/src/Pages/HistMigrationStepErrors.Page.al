page 41018 "Hist. Migration Step Errors"
{
    ApplicationArea = All;
    Caption = 'GP Detail Snapshot Migration Errors';
    PageType = List;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Hist. Migration Step Error";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Error Date"; Rec."Error Date")
                {
                    ApplicationArea = All;
                    Caption = 'Error Date';
                    ToolTip = 'Specifies the value of the Error Date field.';
                }
                field(Step; Rec.Step)
                {
                    ApplicationArea = All;
                    Caption = 'Step';
                    ToolTip = 'Specifies the value of the Step field.';
                }
                field(Reference; Rec.Reference)
                {
                    ApplicationArea = All;
                    Caption = 'Reference';
                    ToolTip = 'Specifies the value of the Reference field.';
                }
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                    Caption = 'Error Code';
                    ToolTip = 'Specifies the value of the Error Code field.';
                }
                field("Error Message"; Rec.GetErrorMessage())
                {
                    ApplicationArea = All;
                    Caption = 'Error Message';
                    ToolTip = 'Specifies the value of the Error Message field.';
                }
            }
        }
    }
}