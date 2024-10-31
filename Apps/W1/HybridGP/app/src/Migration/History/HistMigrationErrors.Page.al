namespace Microsoft.DataMigration.GP;

page 4100 "Hist. Migration Errors"
{
    ApplicationArea = All;
    Caption = 'GP Detail Snapshot Migration Errors';
    PageType = List;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    SourceTable = "GP Hist. Source Error";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(List)
            {
                field(Step; Rec.Step)
                {
                    ApplicationArea = All;
                    Caption = 'Step';
                    ToolTip = 'Specifies the value of the Step field.';
                }
                field("Table Id"; Rec."Table Id")
                {
                    ApplicationArea = All;
                    Caption = 'Table Id';
                    ToolTip = 'Specifies the value of the Table Id field.';
                }
                field("Record Id"; Rec."Record Id")
                {
                    ApplicationArea = All;
                    Caption = 'Record Id';
                    ToolTip = 'Specifies the value of the Record Id field.';
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