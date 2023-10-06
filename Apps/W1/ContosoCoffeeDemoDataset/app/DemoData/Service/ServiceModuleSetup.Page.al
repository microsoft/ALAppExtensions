page 4763 "Service Module Setup"
{
    PageType = Card;
    ApplicationArea = Service;
    Caption = 'Service Module Setup';
    SourceTable = "Service Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("Master Data")
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number to use for the scenarios.';
                }
                field("Item 1 No."; Rec."Item 1 No.")
                {
                    ToolTip = 'Specifies the main number to use for the scenarios.';
                }
                field("Service Item 1 No."; Rec."Service Item 1 No.")
                {
                    ToolTip = 'Specifies extra item number to use for the scenarios.';
                }
                field("Service Item 2 No."; Rec."Service Item 2 No.")
                {
                    ToolTip = 'Specifies extra item number to use for the scenarios.';
                }
                field("Resource 1 No."; Rec."Resource 1 No.")
                {
                    ToolTip = 'Specifies the resource number to use for the small unit scenarios.';
                }
                field("Resource 2 No."; Rec."Resource 2 No.")
                {
                    ToolTip = 'Specifies the resource number to use for the large unit scenarios.';
                }
            }
            group(Locations)
            {
                field("Service Location"; Rec."Service Location")
                {
                    ToolTip = 'Specifies the location code to use for the scenarios.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}