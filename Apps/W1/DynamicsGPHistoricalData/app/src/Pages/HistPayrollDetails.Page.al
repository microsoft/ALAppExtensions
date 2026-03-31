namespace Microsoft.DataMigration.GP.HistoricalData;

page 41031 "Hist. Payroll Details"
{
    ApplicationArea = All;
    Caption = 'Historical Gen. Journal Line Payroll Details';
    PageType = Card;
    SourceTable = "Hist. Payroll Details";
    UsageCategory = None;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Orig. Document No."; Rec."Orig. Document No.")
                {
                    ToolTip = 'Specifies the value of the Orig. Document No. field.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ToolTip = 'Specifies the value of the Source No. field.';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ToolTip = 'Specifies the value of the Source Name field.';
                }
            }
        }
    }
}