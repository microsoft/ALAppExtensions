pageextension 31202 "Accountant CZ Role Center CZC" extends "Accountant CZ Role Center CZL"
{
    actions
    {
        addafter("Finance Charge Memos")
        {
            action("Compensations CZC")
            {
                Caption = 'Compensations';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View and edit compensations.';
                RunObject = Page "Compensation List CZC";
            }
        }
        addafter("Issued Fin. Charge Memos")
        {
            action("Posted Compensations CZC")
            {
                Caption = 'Posted Compensations';
                ApplicationArea = Basic, Suite;
                ToolTip = 'View posted compensations.';
                RunObject = Page "Posted Compensation List CZC";
            }
        }
    }
}
