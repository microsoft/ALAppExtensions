query 2510 "Purchasing Trx Invoices"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Posted Purchasing Transactions Invoices';

    elements
    {
        dataitem(Purch_Inv_Header; "Purch. Inv. Header")
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

            column(Vendor_Invoice_No; "Vendor Invoice No.")
            {
                Caption = 'Vendor Invoice No.';
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