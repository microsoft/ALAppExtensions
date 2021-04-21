query 2557 "Items Overdue For Count"
{
    QueryType = Normal;
    OrderBy = ascending (No);
    Caption = 'Items Overdue For Count';
    QueryCategory = 'Item List';

    elements
    {
        dataitem(Item; Item)
        {
            DataItemTableFilter = "Next Counting Start Date" = filter (<> 0DT);
            column(No; "No.")
            {
                Caption = 'No.';
            }

            column(Description; Description)
            { }

            column(Inventory; Inventory)
            { }

            column(Type; Type)
            { }

            column(Next_Counting_Start_Date; "Next Counting Start Date")
            {
                Caption = 'Next Counting Start Date';
            }

            column(Phys_Invt_Counting_Period_Code; "Phys Invt Counting Period Code")
            {
                Caption = 'Phys Invt Counting Period Code';
            }

            column(Last_Counting_Period_Update; "Last Counting Period Update")
            {
                Caption = 'Last Counting Period Update';
            }

            column(Last_Phys_Invt_Date; "Last Phys. Invt. Date")
            {
                Caption = 'Last Phys. Invt. Date';
            }
        }
    }

    trigger OnBeforeOpen()
    var
    begin
        SetFilter(Next_Counting_Start_Date, '<%1', Today());
    end;
}