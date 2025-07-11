namespace Microsoft.DataMigration.GP;

page 41000 "GP 1099 Migration Log"
{
    ApplicationArea = All;
    Caption = 'GP 1099 Migration Log';
    PageType = List;
    SourceTable = "GP 1099 Migration Log";
    UsageCategory = Administration;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor No.';
                    ToolTip = 'Specifies the value of the Vendor No. field.';
                }
                field(IsError; Rec.IsError)
                {
                    ApplicationArea = All;
                    Caption = 'Error';
                    ToolTip = 'Specifies the value of the IsError field.';
                }
                field(WasSkipped; Rec.WasSkipped)
                {
                    Caption = 'Was Skipped';
                    ToolTip = 'Specifies the value of the Skipped field.';
                }
                field("GP 1099 Type"; Rec."GP 1099 Type")
                {
                    Caption = 'GP 1099 Type';
                    ToolTip = 'Specifies the value of the GP 1099 Type field.';
                }
                field("GP 1099 Box No."; Rec."GP 1099 Box No.")
                {
                    Caption = 'GP 1099 Box No.';
                    ToolTip = 'Specifies the value of the GP 1099 Box No. field.';
                }
                field("BC IRS 1099 Code"; Rec."BC IRS 1099 Code")
                {
                    Caption = 'BC IRS 1099 Code';
                    ToolTip = 'Specifies the value of the BC IRS 1099 Code field.';
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

    procedure FilterOnErrors()
    begin
        Rec.SetRange(IsError, true);
    end;
}