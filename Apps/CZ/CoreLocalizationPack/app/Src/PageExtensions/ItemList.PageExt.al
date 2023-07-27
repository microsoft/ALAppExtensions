pageextension 11769 "Item List CZL" extends "Item List"
{
#if not CLEAN22
#pragma warning disable AL0432
    layout
    {
        addafter("Tariff No.")
        {
            field("Statistic Indication CZL"; Rec."Statistic Indication CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Statistic Indication (Obsolete)';
                ToolTip = 'Specifies the Statistic indication for Intrastat reporting purposes.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
            field("Specific Movement CZL"; Rec."Specific Movement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Specific Movement (Obsolete)';
                ToolTip = 'Specifies the Specific Movement for Intrastat reporting purposes.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
            }
        }
    }
#pragma warning restore AL0432
#endif
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
