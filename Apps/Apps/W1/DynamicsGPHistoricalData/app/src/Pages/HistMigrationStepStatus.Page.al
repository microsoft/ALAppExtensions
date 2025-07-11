namespace Microsoft.DataMigration.GP.HistoricalData;

page 41020 "Hist. Migration Step Status"
{
    ApplicationArea = All;
    Caption = 'GP Detail Snapshot Migration Log';
    PageType = List;
    SourceTable = "Hist. Migration Step Status";
    UsageCategory = History;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Step; Rec.Step)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Step field.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date field.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date field.';
                }
            }
        }
    }
}