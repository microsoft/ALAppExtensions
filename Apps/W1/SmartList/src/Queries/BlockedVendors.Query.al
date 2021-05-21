query 2502 "Blocked Vendors"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Blocked Vendors';
    QueryCategory = 'Vendor List';

    elements
    {
        dataitem(DataItemName; Vendor)
        {
            DataItemTableFilter = Blocked = filter (<> ' ');
            column(No; "No.")
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