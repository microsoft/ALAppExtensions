#pragma warning disable AA0247
page 5377 "E-Document Module Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'E-Document Module Setup';
    SourceTable = "E-Document Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("Master Data")
            {
                field("Vendor No. 1"; Rec."Vendor No. 1")
                {
                    ToolTip = 'Specifies vendor 1 number to use for the scenarios.';
                }
                field("Vendor No. 2"; Rec."Vendor No. 2")
                {
                    ToolTip = 'Specifies vendor 2 number to use for the scenarios.';
                }
                field("Vendor No. 3"; Rec."Vendor No. 3")
                {
                    ToolTip = 'Specifies vendor 3 number to use for the scenarios.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}
