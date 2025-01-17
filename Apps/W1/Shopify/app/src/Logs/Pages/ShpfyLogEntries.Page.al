namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Log Entries (ID 30119).
/// </summary>
page 30119 "Shpfy Log Entries"
{
    ApplicationArea = All;
    Caption = 'Shopify Log Entries';
    CardPageID = "Shpfy Log Entry Card";
    Description = 'The Synchronization log between your Shopify store and Dynamics 365 Business Central.';
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Log Entries';
    SourceTable = "Shpfy Log Entry";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(EntryNo; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specific number series when the entry was created.';
                }
                field(DateAndTime; Rec."Date and Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and the time when this entry was created.';
                }
                field("Time"; Rec.Time)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when this entry was created.';
                }
                field("UserId"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                }
                field(URL; Rec.URL)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL with the data requested from.';
                }
                field(RequestPreview; Rec."Request Preview")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the request preview.';
                }
                field(ResponsePreview; Rec."Response Preview")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the response preview.';
                }
                field(HasError; Rec."Has Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the request has errors.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Delete7days)
            {
                ApplicationArea = All;
                Caption = 'Delete Entries Older Than 7 Days';
                Image = ClearLog;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Clear the list of log entries that are older than 7 days.';

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
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Clear the list of all log entries.';

                trigger OnAction();
                begin
                    Rec.DeleteEntries(0);
                end;
            }
        }
    }
}

