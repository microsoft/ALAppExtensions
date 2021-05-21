query 2458 "Unposted Sales Trx Credit Memo"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Unposted Sales Transactions (Credit Memos)';

    elements
    {
        dataitem(Sales_Header; "Sales Header")
        {
            DataItemTableFilter = "Document Type" = filter ("Credit Memo");
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
                Caption = 'Posting Date';
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