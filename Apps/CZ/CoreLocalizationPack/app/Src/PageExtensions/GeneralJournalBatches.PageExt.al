pageextension 11777 "General Journal Batches CZL" extends "General Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field("Allow Hybrid Document CZL"; Rec."Allow Hybrid Document CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether disabling balance check by Correction field.';
            }
        }
    }
    actions
    {
        addafter(Action10)
        {
            action("General Ledger Document CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'General Ledger Document';
                Image = Report;
                RunObject = Report "General Ledger Document CZL";
                ToolTip = 'View, print, or send a report of transactions posted to general ledger in form of a document.';
            }
        }
    }
}
