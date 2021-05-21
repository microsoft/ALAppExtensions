query 2511 "Purchasing Trx Crdt Memos"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Posted Purchasing Transactions Credit Memos';

    elements
    {
        dataitem(Purch__Cr__Memo_Hdr_; "Purch. Cr. Memo Hdr.")
        {
            column(No; "No.")
            {
                Caption = 'No.';
            }

            column("Pay_to_Vendor_No"; "Pay-to Vendor No.")
            {
                Caption = 'Pay to Vendor No.';
            }

            column("Pay_to_Name"; "Pay-to Name")
            {
                Caption = 'Pay to Name';
            }

            column("Expected_Receipt_Date"; "Expected Receipt Date")
            {
                Caption = 'Expected Receipt Date';
            }

            column(Due_Date; "Due Date")
            {
                Caption = 'Due Date';
            }

            column(Amount; Amount)
            {
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}