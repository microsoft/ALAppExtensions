query 2450 "Customer Ship To Addresses"
{
    QueryType = Normal;
    OrderBy = ascending (Customer_No);
    Caption = 'Customer Ship To Addresses';
    QueryCategory = 'Customer List';

    elements
    {
        dataitem(Ship_to_Addresses; "Ship-to Address")
        {
            column(Customer_No; "Customer No.")
            {
                Caption = 'Customer No.';
            }
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
            column(Phone_No_; "Phone No.")
            {
                Caption = 'Phone No.';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}