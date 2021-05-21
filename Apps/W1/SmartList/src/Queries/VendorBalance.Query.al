query 2504 "Vendor Balance"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Vendor Balance';
    QueryCategory = 'Vendor List';

    elements
    {
        dataitem(Vendor; Vendor)
        {
            column(No; "No.")
            {
                Caption = 'No.';
            }
            column(Name; Name)
            {

            }
            column(Address; Address)
            {

            }
            column(Address_2; "Address 2")
            {
                Caption = 'Address 2';
            }
            column(City; City)
            {

            }
            column(Post_Code; "Post Code")
            {
                Caption = 'Post Code';
            }
            column(Country_Region_Code; "Country/Region Code")
            {
                Caption = 'Country/Region Code';
            }
            dataitem(Vendor_Ledger_Entry; "Vendor Ledger Entry")
            {
                DataItemLink = "Vendor No." = Vendor."No.";
                SqlJoinType = LeftOuterJoin;

                column(Remaining_Amt_LCY; "Remaining Amt. (LCY)")
                {
                    Caption = 'Balance';
                    Method = Sum;
                    ReverseSign = true;
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}