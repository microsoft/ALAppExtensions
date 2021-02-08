pageextension 11769 "Item List CZL" extends "Item List"
{
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
        addfirst(Functions)
        {
            action("Create Stockkeeping Unit CZL")
            {
                AccessByPermission = TableData "Stockkeeping Unit" = R;
                ApplicationArea = Warehouse;
                Caption = '&Create Stockkeeping Unit with Templates';
                Image = CreateSKU;
                Ellipsis = true;
                ToolTip = 'Create an instance of the item at each location that is set up. It is possible to use data templates as part of the Stockkeeping Unit creation process.';

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Create Stockkeeping Unit CZL", true, true, Item);
                end;
            }
        }
    }
}
