namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Skipped Records (ID 30165).
/// </summary>
page 30165 "Shpfy Skipped Records"
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
                field(EntryNo; Rec."Entry No.") { }
                field("Shopify Id"; Rec."Shopify Id") { }
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
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            actionref(Show_Promoted; Show) { }
        }
        area(Processing)
        {
            action(Show)
            {
                ApplicationArea = All;
                Caption = 'Show record';
                Image = View;
                ToolTip = 'Show the details of the selected record.';

                trigger OnAction()
                begin
                    Rec.ShowPage();
                end;
            }
        }
    }
}