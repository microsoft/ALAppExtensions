query 2506 "Purchasing Rcpt Line Items"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No, Line_No);
    Caption = 'Posted Purchasing Receipt Line Items';

    elements
    {
        dataitem(Purch__Rcpt__Line; "Purch. Rcpt. Line")
        {
            column(Document_No; "Document No.")
            {
                Caption = 'Document No.';
            }

            column(Line_No; "Line No.")
            {
                Caption = 'Line No.';
            }

            column(Type; Type)
            { }

            column(No; "No.")
            {
                Caption = 'No.';
            }

            column(Description; Description)
            { }

            column(Location_Code; "Location Code")
            {
                Caption = 'Location Code';
            }

            column(Expected_Receipt_Date; "Expected Receipt Date")
            {
                Caption = 'Expected Receipt Date';
            }

            column(Quantity; Quantity)
            { }

            column(Unit_of_Measure; "Unit of Measure")
            {
                Caption = 'Unit of Measure';
            }

            column(Unit_Cost_LCY; "Unit Cost (LCY)")
            {
                Caption = 'Unit Cost (LCY)';
            }

            column(Qty_Rcd_Not_Invoiced; "Qty. Rcd. Not Invoiced")
            {
                Caption = 'Qty. Rcd. Not Invoiced';
            }

            column(Quantity_Invoiced; "Quantity Invoiced")
            { Caption = 'Quantity Invoiced'; }

            column(Order_No; "Order No.")
            {
                Caption = 'Order No.';
            }

            column(Order_Line_No; "Order Line No.")
            {
                Caption = 'Order Line No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}