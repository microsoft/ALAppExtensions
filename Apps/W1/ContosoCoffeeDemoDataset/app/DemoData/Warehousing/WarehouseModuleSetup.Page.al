page 4766 "Warehouse Module Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Warehouse Module Setup';
    SourceTable = "Warehouse Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(Locations)
            {
                field("Location Bin"; Rec."Location Bin")
                {
                    ToolTip = 'Specifies the code of the location for the Basic Location scenarios.';
                }
                field("Location Adv Logistics"; Rec."Location Adv Logistics")
                {
                    ToolTip = 'Specifies the code of the location for the Simple Logistics scenarios.';
                }
                field("Location Directed Pick"; Rec."Location Directed Pick")
                {
                    ToolTip = 'Specifies the code of the location for the Advanced Logistics scenarios.';
                }
                field("Location In-Transit"; Rec."Location In-Transit")
                {
                    ToolTip = 'Specifies the code of the location for the Advanced Logistics scenarios.';
                }
            }

            group("Master Data")
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number to use for the scenarios.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ToolTip = 'Specifies vendor number to use for the scenarios.';
                }
                field("Item 1 No."; Rec."Item 1 No.")
                {
                    ToolTip = 'Specifies the main number to use for the scenarios.';
                }
                field("Item 2 No."; Rec."Item 2 No.")
                {
                    ToolTip = 'Specifies extra item number to use for the scenarios.';
                }
                field("Item 3 No."; Rec."Item 3 No.")
                {
                    ToolTip = 'Specifies extra item number to use for the scenarios with item tracking.';
                }

            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}