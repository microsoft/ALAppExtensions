query 2553 "Item Purchase Receipts"
{
    QueryType = Normal;
    OrderBy = ascending (Item_No);
    Caption = 'Item Purchase Receipts';

    elements
    {

        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            DataItemTableFilter = Quantity = filter (> 0);

            column(Item_No; "Item No.")
            {
                Caption = 'Item No.';
            }

            column(Posting_Date; "Posting Date")
            {
                Caption = 'Posting Date';
            }

            column(Source_No; "Source No.")
            {
                Caption = 'Source No.';
            }

            column(Document_No; "Document No.")
            {
                Caption = 'Document No.';
            }

            column(Location_Code; "Location Code")
            {
                Caption = 'Location Code';
            }

            column(Quantity; Quantity)
            { }

            column(Remaining_Quantity; "Remaining Quantity")
            {
                Caption = 'Remaining Quantity';
            }

            column(Invoiced_Quantity; "Invoiced Quantity")
            {
                Caption = 'Invoiced Quantity';
            }

            column(Cost_Amount_Actual; "Cost Amount (Actual)")
            {
                Caption = 'Cost Amount (Actual)';
            }

            column(Entry_Type; "Entry Type")
            {
                Caption = 'Entry Type';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}