page 4764 "Jobs Module Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Contoso Coffee Project Demo Data';
    SourceTable = "Jobs Module Setup";
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
                field("Item 1 No."; Rec."Item Machine No.")
                {
                    ToolTip = 'Specifies the main number to use for the scenarios.';
                }
                field("Item 2 No."; Rec."Item Consumable No.")
                {
                    ToolTip = 'Specifies extra item number to use for the scenarios.';
                }
                field("Item 3 No."; Rec."Item Service No.")
                {
                    ToolTip = 'Specifies service item number to use for the scenarios.';
                }
                field("Item 4 No."; Rec."Item Supply No.")
                {
                    ToolTip = 'Specifies s item number to use for the scenarios.';
                }
                field("Resource L1 No."; Rec."Resource Installer No.")
                {
                    ToolTip = 'Specifies the local resource number to use for the small unit scenarios.';
                }
            }
            group("Posting Setup")
            {
                Caption = 'Posting Setup';
                field("Job Posting Group"; Rec."Job Posting Group")
                {
                    ToolTip = 'Specifies the value of the job posting group code used on jobs.';
                }
            }
            group(Locations)
            {
                field("Service Location"; Rec."Job Location")
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