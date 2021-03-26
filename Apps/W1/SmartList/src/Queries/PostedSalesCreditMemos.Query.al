query 2461 "Posted Sales Credit Memos"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Posted Sales Credit Memos';

    elements
    {
        dataitem(Sales_Cr_Memo_Header; "Sales Cr.Memo Header")
        {
            column(No; "No.")
            {
                Caption = 'Document Number';
            }
            column(Sell_to_Customer_No; "Sell-to Customer No.")
            {
                Caption = 'Sell to Customer Number';
            }
            column(Bill_to_Customer_No; "Bill-to Customer No.")
            {
                Caption = 'Bill to Customer Number';
            }
            column(Bill_to_Name; "Bill-to Name")
            {
                Caption = 'Bill to Name';
            }
            column(Document_Date; "Document Date")
            {
                Caption = 'Document Date';
            }
            column(Posting_Date; "Posting Date")
            {
                Caption = 'Posted Date';
            }
            column(Posting_Description; "Posting Description")
            {
                Caption = 'Posting Description';
            }
            column(Amount; Amount)
            {
                Caption = 'Amount';
            }
            column(External_Document_No; "External Document No.")
            {
                Caption = 'External Document No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}