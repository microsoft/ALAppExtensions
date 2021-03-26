query 2460 "Posted Sales Invoices"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Posted Sales Invoices';

    elements
    {
        dataitem(Sales_Invoice_Header; "Sales Invoice Header")
        {
            column(No; "No.")
            {
                Caption = 'Document Number';
            }
            column(Sell_to_Customer_No_; "Sell-to Customer No.")
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
            column(External_Document_No_; "External Document No.")
            {
                Caption = 'External Document No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}