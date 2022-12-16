pageextension 41020 "Item List Ext." extends "Item List"
{
    actions
    {
        addlast("Action126")
        {
            group(GPHistorical)
            {
                action("GP Inventory Trx.")
                {
                    ApplicationArea = All;
                    Caption = 'Inventory Transactions';
                    Image = Archive;
                    RunObject = Page "Hist. Inventory Trx. Headers";
                    ToolTip = 'View the GP inventory transactions.';
                }
            }
        }

        addlast(Category_Category4)
        {
            group(Category_GPGLDetail)
            {
                Caption = 'GP Detail Snapshot';
                ShowAs = Standard;
                Image = Archive;
                Visible = GPGLDetailDataExists;

                actionref("GP Inventory Trx._Promoted"; "GP Inventory Trx.")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HistInventoryTrxHeader: Record "Hist. Inventory Trx. Header";
    begin
        if HistInventoryTrxHeader.ReadPermission() then
            GPGLDetailDataExists := not HistInventoryTrxHeader.IsEmpty();
    end;

    var
        GPGLDetailDataExists: Boolean;
}