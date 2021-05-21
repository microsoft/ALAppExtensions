pageextension 11795 "Sales & Marketing Mngr. RC CZL" extends "Sales & Marketing Manager RC"
{
    actions
    {
        addlast(Group10)
        {
            action("Quantity Shipped Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Shipped Check';
                Image = Report;
                RunObject = Report "Quantity Shipped Check CZL";
                ToolTip = 'Verify that all sales shipments are fully invoiced. Report shows a list of sales shipment lines which are not fully invoiced.';
            }
        }
    }
}