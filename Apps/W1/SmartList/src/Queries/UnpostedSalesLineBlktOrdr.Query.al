#pragma warning disable AA0247
query 2471 "Unposted Sales Line Blkt Ordr"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No, Line_No);
    Caption = 'Unposted Sales Line Items (Blanket Sales Orders)';

    elements
    {
        dataitem(Sales_Line; "Sales Line")
        {
            DataItemTableFilter = "Document Type" = filter ("Blanket Order");

            column(Sell_to_Customer_No; "Sell-to Customer No.")
            {
                Caption = 'Sell to Customer No.';
            }
            column(Bill_to_Customer_No; "Bill-to Customer No.")
            {
                Caption = 'Bill to Customer No.';
            }

            column(Document_No; "Document No.")
            {
                Caption = 'Document No.';
            }

            column(Type; Type)
            { }

            column(No_; "No.")
            {
                Caption = 'No.';
            }

            column(Description; Description)
            {
                Caption = 'Description';
            }
            column(Location_Code; "Location Code")
            {
                Caption = 'Location Code';
            }
            column(Unit_of_Measure; "Unit of Measure")
            {
                Caption = 'Unit of Measure';
            }
            column(Quantity; Quantity)
            {
                Caption = 'Quantity';
            }

            column(Qty__to_Invoice; "Qty. to Invoice")
            {
                Caption = 'Qty. to Invoice';
            }

            column(Outstanding_Quantity; "Outstanding Quantity")
            {
                Caption = 'Outstanding Quantity';
            }
            column(Unit_Price; "Unit Price")
            {
                Caption = 'Unit Price';
            }
            column(Unit_Cost; "Unit Cost")
            {
                Caption = 'Unit Cost';
            }
            column(Line_Discount_Amount; "Line Discount Amount")
            {
                Caption = 'Line Discount Amount';
            }
            column(Amount; Amount)
            {
                Caption = 'Amount';
            }

            column(Amount_Including_VAT; "Amount Including VAT")
            {
            }
            column(Line_No; "Line No.")
            {
                Caption = 'Line No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}
