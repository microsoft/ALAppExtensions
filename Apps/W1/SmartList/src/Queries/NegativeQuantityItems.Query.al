query 2556 "Negative Quantity Items"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Negative Quantity Items';
    QueryCategory = 'Item List';

    elements
    {
        dataitem(Item; Item)
        {
            column(No; "No.")
            {
                Caption = 'No.';
            }

            column(Description; Description)
            { }

            column(Inventory; Inventory)
            { }

            column(Qty_on_Purch_Order; "Qty. on Purch. Order")
            {
                Caption = 'Qty. on Purch. Order';
            }
        }
    }

    trigger OnBeforeOpen()
    var
    begin
        SetFilter(Inventory, '<%1', 0);
    end;
}