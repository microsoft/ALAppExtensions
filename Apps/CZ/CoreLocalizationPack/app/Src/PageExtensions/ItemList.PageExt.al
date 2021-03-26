pageextension 11769 "Item List CZL" extends "Item List"
{
    layout
    {
        addafter("Tariff No.")
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
                Visible = false;
            }
            field("Specific Movement CZL"; Rec."Specific Movement CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
                Visible = false;
            }
        }
    }
    actions
    {
        addafter("Inventory - Sales Back Orders")
        {
            action("Quantity Shipped Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Shipped Check';
                Image = Report;
                RunObject = Report "Quantity Shipped Check CZL";
                ToolTip = 'Verify that all sales shipments are fully invoiced. Report shows a list of sales shipment lines which are not fully invoiced.';
            }
            action("Quantity Received Check CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Quantity Received Check';
                Image = Report;
                RunObject = Report "Quantity Received Check CZL";
                ToolTip = 'Verify that all purchase receipts are fully invoiced. Report shows a list of purchase receipt lines which are not fully invoiced.';
            }
        }
        addlast(Inventory)
        {
            action("Test Tariff Numbers CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test Tariff Numbers';
                Image = TestReport;
                ToolTip = 'Run a test of item tariff numbers.';
                RunObject = Report "Test Tariff Numbers CZL";
            }
        }
    }
}
