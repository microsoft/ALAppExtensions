query 2465 "Customer And Contact"
{
    QueryType = Normal;
    OrderBy = ascending (No_);
    QueryCategory = 'Customer List';
    Caption = 'Customer And Contact';

    elements
    {
        dataitem(Customer; Customer)
        {
            column(No_; "No.")
            {
                Caption = 'No.';
            }
            column(Name; Name)
            {

            }
            column(Primary_Contact_No_; "Primary Contact No.")
            {
                Caption = 'Primary Contact No.';
            }
            dataitem(Contact; Contact)
            {
                DataItemLink = "No." = Customer."Primary Contact No.";
                SqlJoinType = InnerJoin;

                column(ContactName; Name)
                {
                    Caption = 'Contact Name';
                }

                column(Phone_No_; "Phone No.")
                {
                    Caption = 'Contact Phone No.';
                }

                column(E_Mail; "E-Mail")
                {
                    Caption = 'Contact E-mail';
                }
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}