query 2512 "Blanket Purchase Orders"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Blanket Purchase Orders';

    elements
    {
        dataitem(Purchase_Header; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = filter ("Blanket Order");
            column(No; "No.")
            {
                Caption = 'No.';
            }
            column(Status; Status)
            { }

            column(Buy_from_Vendor_No; "Buy-from Vendor No.")
            {
                Caption = 'Buy-from Vendor No.';
            }

            column(Buy_from_Vendor_Name; "Buy-from Vendor Name")
            {
                Caption = 'Buy-from Vendor Name';
            }
            column("Pay_to_Vendor_No"; "Pay-to Vendor No.")
            {
                Caption = 'Pay to Vendor No';
            }

            column("Pay_to_Name"; "Pay-to Name")
            {
                Caption = 'Pay to Name';
            }
            column("Order_Date"; "Order Date")
            {
                Caption = 'Order Date';
            }
            column("Expected_Receipt_Date"; "Expected Receipt Date")
            {
                Caption = 'Expected Receipt Date';
            }
            column(Document_Date; "Document Date")
            {
                Caption = 'Document Date';
            }

            column(Vendor_Invoice_No; "Vendor Invoice No.")
            {
                Caption = 'Vendor Invoice No.';
            }

            column(Location_Code; "Location Code")
            {
                Caption = 'Location Code';
            }
            column(Amount; Amount)
            {
            }
            column("Amount_Including_VAT"; "Amount Including VAT")
            {
            }

        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}