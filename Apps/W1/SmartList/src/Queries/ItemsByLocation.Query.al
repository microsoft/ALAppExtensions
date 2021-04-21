query 2554 "Items By Location"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Items By Location';
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

            dataitem(Item_Ledger_Entry; "Item Ledger Entry")
            {
                DataItemLink = "Item No." = Item."No.";

                column(Location_Code; "Location Code")
                {
                    Caption = 'Location Code';
                }

                column(Remaining_Quantity; "Remaining Quantity")
                {
                    Caption = 'Remaining Quantity';
                    Method = Sum;
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}