namespace System.DataAdministration;

page 6200 "Transaction Storage Setup"
{
    ApplicationArea = Basic, Suite;
    PageType = Card;
    SourceTable = "Transaction Storage Setup";
    UsageCategory = Administration;
    DataCaptionExpression = '';
    Permissions = tabledata "Transaction Storage Setup" = rim;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Earliest Start Time"; Rec."Earliest Start Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the earliest time when the background job must be run.';
                }
                field("Max. Number of Hours"; Rec."Max. Number of Hours")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the maximum number of hours for the scheduled task to be executed. The specified value must not be less than 3 hours.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then
            Rec.Insert();
    end;
}