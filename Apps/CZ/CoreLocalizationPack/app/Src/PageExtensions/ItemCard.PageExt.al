pageextension 31008 "Item Card CZL" extends "Item Card"
{
    actions
    {
        addfirst(Functions)
        {
            action("Create Stockkeeping Unit CZL")
            {
                AccessByPermission = TableData "Stockkeeping Unit" = R;
                ApplicationArea = Warehouse;
                Caption = '&Create Stockkeeping Unit with Templates';
                Image = CreateSKU;
                Ellipsis = true;
                ToolTip = 'Create an instance of the item at each location that is set up. It is possible to use data templates as part of the Stockkeeping Unit creation process.';

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Create Stockkeeping Unit CZL", true, true, Item);
                end;
            }
        }
    }
}
