query 2550 Items
{
    QueryType = Normal;
    OrderBy = ascending (No_);
    Caption = 'Blocked Items';
    QueryCategory = 'Item List';

    elements
    {
        dataitem(Item; Item)
        {
            DataItemTableFilter = Blocked = filter (true);
            column(No_; "No.")
            {
                Caption = 'No.';
            }

            column(Description; Description)
            {

            }

            column(Blocked; Blocked)
            {

            }

            column(Item_Category_Code; "Item Category Code")
            {
                Caption = 'Item Category Code';
            }

            column(Base_Unit_of_Measure; "Base Unit of Measure")
            {
                Caption = 'Base Unit of Measure';
            }

            column(Type; Type)
            {

            }

            column(Shelf_No; "Shelf No.")
            {
                Caption = 'Shelf No.';
            }

            column(Unit_Cost; "Unit Cost")
            {
                Caption = 'Unit Cost';
            }

            column(Standard_Cost; "Standard Cost")
            {
                Caption = 'Standard Cost';
            }

            column(Costing_Method; "Costing Method")
            {
                Caption = 'Costing Method';
            }

            column(Unit_Price; "Unit Price")
            {
                Caption = 'Unit Price';
            }
        }
    }

    trigger OnBeforeOpen()
    begin

    end;
}