query 2464 "Posted Sales C Memo Line Item"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No, Line_No);
    Caption = 'Posted Sales Credit Memo Line Items';

    elements
    {
        dataitem(Sales_Cr_Memo_Line; "Sales Cr.Memo Line")
        {
            column(Sell_to_Customer_No; "Sell-to Customer No.")
            {
                Caption = 'Sell to Customer Number';
            }
            column(Bill_to_Customer_No; "Bill-to Customer No.")
            {
                Caption = 'Bill to Customer Number';
            }

            column(Document_No; "Document No.")
            {
                Caption = 'Document Number';
            }

            column(Type; Type)
            { }

            column(No; "No.")
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
                Caption = 'Line Number';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}