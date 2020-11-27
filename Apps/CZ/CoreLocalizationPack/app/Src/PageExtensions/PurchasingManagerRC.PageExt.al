pageextension 11794 "Purchasing Manager RC CZL" extends "Purchasing Manager Role Center"
{
    actions
    {
        addlast(Group3)
        {
            action("Quantity Received Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Received Check';
                Image = Report;
                RunObject = Report "Quantity Received Check CZL";
                ToolTip = 'Verify that all purchase receipts are fully invoiced. Report shows a list of purchase receipt lines which are not fully invoiced.';
            }
        }
    }
}