query 2453 CustomersWithCreditLimit
{
    QueryType = Normal;
    Caption = 'Customers with credit limits';
    QueryCategory = 'Customer List';

    elements
    {
        dataitem(Customer; Customer)
        {
            DataItemTableFilter = "Credit Limit (LCY)" = filter ('>0');
            column(No_; "No.")
            {
                Caption = 'No.';
            }
            column(Name; Name)
            {

            }
            column(Credit_Limit_LCY_; "Credit Limit (LCY)")
            {
                Caption = 'Credit Limit';

            }
            column(Balance_LCY_; "Balance (LCY)")
            {
                Caption = 'Balance';
            }
            column(Balance_Due_LCY_; "Balance Due (LCY)")
            {
                Caption = 'Balance Due';
            }

            dataitem(Salesperson_Purchaser; "Salesperson/Purchaser")
            {
                DataItemLink = Code = Customer."Salesperson Code";
                SqlJoinType = LeftOuterJoin;

                column(SalespersonName; Name)
                {
                    Caption = 'Salesperson Name';
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}