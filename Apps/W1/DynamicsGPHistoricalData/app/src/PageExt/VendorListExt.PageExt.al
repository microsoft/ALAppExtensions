pageextension 41019 "Vendor List Ext." extends "Vendor List"
{
    actions
    {
        addlast("Ven&dor")
        {
            group(GPHistorical)
            {
                action("GP Payables Docs")
                {
                    ApplicationArea = All;
                    Caption = 'GP Payables Transactions';
                    Image = Documents;
                    RunObject = Page "Hist. Payables Documents";
                    ToolTip = 'View the GP payables transactions.';
                    Visible = GPPayablesDataAvailable;
                }
                action("GP Purchase Recv.")
                {
                    ApplicationArea = All;
                    Caption = 'Receivings Transactions';
                    Image = ReceivablesPayables;
                    RunObject = Page "Hist. Purchase Recv. Headers";
                    ToolTip = 'View the GP purchase receivings transactions.';
                    Visible = GPPurchaseRecvDataAvailable;
                }
            }
        }

        addlast(Category_Category5)
        {
            group(Category_GPGLDetail)
            {
                Caption = 'GP Detail Snapshot';
                ShowAs = Standard;
                Image = Archive;
                Visible = GPHistDataAvailable;

                actionref("GP Payables Docs_Promoted"; "GP Payables Docs")
                {
                }
                actionref("GP Purchase Recv._Promoted"; "GP Purchase Recv.")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HistPurchaseRecvHeader: Record "Hist. Purchase Recv. Header";
        HistPayablesDocument: Record "Hist. Payables Document";
    begin
        if HistPayablesDocument.ReadPermission() then
            GPPayablesDataAvailable := not HistPayablesDocument.IsEmpty();

        if HistPurchaseRecvHeader.ReadPermission() then
            GPPurchaseRecvDataAvailable := not HistPurchaseRecvHeader.IsEmpty();

        GPHistDataAvailable := (GPPayablesDataAvailable or GPPurchaseRecvDataAvailable);
    end;

    var
        GPHistDataAvailable: Boolean;
        GPPayablesDataAvailable: Boolean;
        GPPurchaseRecvDataAvailable: Boolean;
}