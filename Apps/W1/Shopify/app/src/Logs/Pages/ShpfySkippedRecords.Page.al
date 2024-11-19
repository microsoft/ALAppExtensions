namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Skipped Records (ID 30166).
/// </summary>
page 30166 "Shpfy Skipped Records"
{
    ApplicationArea = All;
    Caption = 'Shopify Skipped Records';
    PageType = List;
    SourceTable = "Shpfy Skipped Record";
    UsageCategory = Lists;
    Editable = false;
    InsertAllowed = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Table ID"; Rec."Table ID") { }
                field("Table Name"; Rec."Table Name") { }
                field(Description; Rec.Description)
                {
                    trigger OnDrillDown()
                    begin
                        Rec.ShowPage();
                    end;
                }
                field("Skipped Reason"; Rec."Skipped Reason") { }
                field("Shopify Id"; Rec."Shopify Id") { }
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Show_Promoted; Show) { }
            }

            group(Category_Category4)
            {
                Caption = 'Log Entries';

                actionref(Delete7days_Promoted; Delete7days) { }
                actionref(Delete0days_Promoted; Delete0days) { }
            }
        }
        area(Processing)
        {
            action(Show)
            {
                ApplicationArea = All;
                Caption = 'Show Record';
                Image = View;
                ToolTip = 'Show the details of the selected record.';

                trigger OnAction()
                begin
                    Rec.ShowPage();
                end;
            }
            action(Delete7days)
            {
                ApplicationArea = All;
                Caption = 'Delete Entries Older Than 7 Days';
                Image = ClearLog;
                ToolTip = 'Clear the list of skipped records that are older than 7 days.';

                trigger OnAction();
                begin
                    Rec.DeleteEntries(7);
                end;
            }
            action(Delete0days)
            {
                ApplicationArea = All;
                Caption = 'Delete All Entries';
                Image = Delete;
                ToolTip = 'Clear the list of all skipped records.';

                trigger OnAction();
                begin
                    Rec.DeleteEntries(0);
                end;
            }
        }
    }
}
