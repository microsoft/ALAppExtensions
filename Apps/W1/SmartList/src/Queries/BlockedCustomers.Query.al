query 2452 "Blocked Customers"
{
    QueryType = Normal;
    QueryCategory = 'Customer List';
    Caption = 'Blocked Customers';

    elements
    {
        dataitem(DataItemName; Customer)
        {

            DataItemTableFilter = Blocked = filter (<> ' ');
            column(No_; "No.")
            {
                Caption = 'No.';
            }
            column(Name; Name)
            {

            }
            column(Blocked; Blocked)
            {

            }
            column(Privacy_Blocked; "Privacy Blocked")
            {
                Caption = 'Privacy Blocked';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}