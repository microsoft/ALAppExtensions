query 2500 "Vendor Order Addresses"
{
    QueryType = Normal;
    OrderBy = ascending (Vendor_No);
    Caption = 'Vendor Order Addresses';
    QueryCategory = 'Vendor List', 'Purchase Quotes', 'Purchase Order List', 'Purchase Invoices';

    elements
    {
        dataitem(Order_Addresses; "Order Address")
        {
            column(Vendor_No; "Vendor No.")
            {
                Caption = 'Vendor No.';
            }

            column(Code; Code)
            { }

            column(Name; Name)
            { }

            column(Contact; Contact)
            { }

            column(Address; Address)
            { }

            column(Address_2; "Address 2")
            {
                Caption = 'Address 2';
            }

            column(City; City)
            { }

            column(County; County)
            { }

            column(Post_Code; "Post Code")
            {
                Caption = 'Post Code';
            }

            column(Country_Region_Code; "Country/Region Code")
            {
                Caption = 'Country/Region Code';
            }

            column(Phone_No; "Phone No.")
            {
                Caption = 'Phone No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}