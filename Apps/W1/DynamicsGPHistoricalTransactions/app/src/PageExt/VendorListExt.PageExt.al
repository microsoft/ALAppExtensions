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
                    Image = Archive;
                    RunObject = Page "Hist. Payables Documents";
                    ToolTip = 'View the GP payables transactions.';
                }
                action("GP Purchase Recv.")
                {
                    ApplicationArea = All;
                    Caption = 'Receivings Transactions';
                    Image = Archive;
                    RunObject = Page "Hist. Purchase Recv. Headers";
                    ToolTip = 'View the GP purchase receivings transactions.';
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
                Visible = GPGLDetailDataExists;

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
        if HistPurchaseRecvHeader.ReadPermission() and HistPayablesDocument.ReadPermission() then
            GPGLDetailDataExists := (not HistPurchaseRecvHeader.IsEmpty() or
                                    not HistPayablesDocument.IsEmpty());
    end;

    var
        GPGLDetailDataExists: Boolean;
}