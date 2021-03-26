query 2501 "Vendor And Purchaser"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Vendor and Purchaser';
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
            column(Purchaser_Code; "Purchaser Code")
            {
                Caption = 'Purchaser Code';
            }
            column(Location_Code; "Location Code")
            {
                Caption = 'Location Code';
            }
            dataitem(Salesperson_Purchaser; "Salesperson/Purchaser")
            {
                DataItemLink = Code = Vendor."Purchaser Code";
                SqlJoinType = LeftOuterJoin;

                column(Purchaser_Name; Name)
                {
                    Caption = 'Purchaser Name';
                }
                column(Purchaser_E_Mail; "E-Mail")
                {
                    Caption = 'Purchaser E-mail';
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}