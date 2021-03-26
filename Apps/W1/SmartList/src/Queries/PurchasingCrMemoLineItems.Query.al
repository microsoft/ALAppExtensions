query 2515 "Purchasing Cr Memo Line Items"
{
    QueryType = Normal;
    OrderBy = ascending (Document_No, Line_No);
    Caption = 'Posted Purchasing Credit Memo Line Items';

    elements
    {
        dataitem(Purch_Cr_Memo_Line; "Purch. Cr. Memo Line")
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

            column(Unit_Cost; "Unit Cost")
            {
                Caption = 'Unit Cost';
            }

            column(Unit_Price_LCY; "Unit Price (LCY)")
            {
                Caption = 'Unit Price (LCY)';
            }
            column(Amount; Amount)
            { }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}