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
                field(EntryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specific number series when the entry was created.';
                }
                field("Shopify Id"; Rec."Shopify Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify Id of the skipped record.';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table ID of the skipped record.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Table Name of the skipped record.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the skipped record.';


                    trigger OnDrillDown()
                    begin
                        Rec.ShowPage();
                    end;
                }
                field("Skipped Reason"; Rec."Skipped Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason why the record was skipped.';
                }
                field("Created On"; Rec."Created On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the record was created.';
                }
                field("Created Time"; Rec."Created Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the record was created.';
                }
            }
        }
    }
}