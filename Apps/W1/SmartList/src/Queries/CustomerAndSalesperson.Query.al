query 2451 CustomerAndSalesperson
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Customer and Salesperson';
    QueryCategory = 'Customer List';

    elements
    {
        dataitem(Customer; Customer)
        {
            column(No; "No.")
            {
                Caption = 'No.';
            }
            column(Name; Name)
            {

            }
            column(Territory_Code; "Territory Code")
            {
                Caption = 'Territory Code';
            }
            column(Salesperson_Code; "Salesperson Code")
            {
                Caption = 'Salesperson Code';
            }
            column(Location_Code; "Location Code")
            {
                Caption = 'Location Code';
            }
            dataitem(Salesperson_Purchaser; "Salesperson/Purchaser")
            {
                DataItemLink = Code = Customer."Salesperson Code";
                SqlJoinType = LeftOuterJoin;

                column(Salesperson_Name; Name)
                {
                    Caption = 'Salesperson Name';
                }
                column(E_Mail; "E-Mail")
                {
                    Caption = 'Salesperson E-mail';
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}