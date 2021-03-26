query 2513 "Blanket Purchase Order Lines"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No, Line_No);
    Caption = 'Blanket Purchase Order Lines';

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = filter ("Blanket Order");
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

            column(Unit_of_Measure; "Unit of Measure")
            {
                Caption = 'Unit of Measure';
            }
            column(Quantity; Quantity)
            {

            }
            column(Outstanding_Quantity; "Outstanding Quantity")
            {
                Caption = 'Outstanding Quantity';
            }
            column(Qty_to_Invoice; "Qty. to Invoice")
            {
                Caption = 'Qty. to Invoice';
            }
            column(Qty_to_Receive; "Qty. to Receive")
            {
                Caption = 'Qty. to Receive';
            }
            column(Unit_Cost_LCY; "Unit Cost (LCY)")
            {
                Caption = 'Unit Cost (LCY)';
            }

            column(Unit_Price_LCY_; "Unit Price (LCY)")
            {
                Caption = 'Unit Price (LCY)';
            }
            column(Amount; Amount)
            {

            }
            column(Amount_Including_VAT; "Amount Including VAT")
            {
            }
            column(Outstanding_Amount; "Outstanding Amount")
            {
                Caption = 'Outstanding Amount';
            }
            column(Qty_Rcd_Not_Invoiced; "Qty. Rcd. Not Invoiced")
            {
                Caption = 'Qty. Rcd. Not Invoiced';
            }
            column(Amt_Rcd_Not_Invoiced; "Amt. Rcd. Not Invoiced")
            {
                Caption = 'Amt. Rcd. Not Invoiced';
            }
            column(Quantity_Received; "Quantity Received")
            {
                Caption = 'Quantity Received';
            }
            column(Quantity_Invoiced; "Quantity Invoiced")
            {
                Caption = 'Quantity Invoiced';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}