pageextension 41018 "Customer List Ext." extends "Customer List"
{
    actions
    {
        addlast("&Customer")
        {
            group(GPHistorical)
            {
                action("GP Rec. Docs")
                {
                    ApplicationArea = All;
                    Caption = 'Receivables Transactions';
                    Image = Archive;
                    RunObject = Page "Hist. Receivables Documents";
                    ToolTip = 'View the GP receivables transactions.';
                }
                action("GP Sales Trx.")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Transactions';
                    Image = Archive;
                    RunObject = Page "Hist. Sales Trx. Headers";
                    ToolTip = 'View the GP sales transactions.';
                }
            }
        }

        addlast(Category_Category7)
        {
            group(Category_GPGLDetail)
            {
                Caption = 'GP Detail Snapshot';
                ShowAs = Standard;
                Image = Archive;
                Visible = GPGLDetailDataExists;

                actionref("GP Rec. Docs_Promoted"; "GP Rec. Docs")
                {
                }
                actionref("GP Sales Trx._Promoted"; "GP Sales Trx.")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
        HistReceivablesDocument: Record "Hist. Receivables Document";
    begin
        if HistSalesTrxHeader.ReadPermission() and HistReceivablesDocument.ReadPermission() then
            GPGLDetailDataExists := (not HistSalesTrxHeader.IsEmpty() or
                                    not HistReceivablesDocument.IsEmpty());
    end;

    var
        GPGLDetailDataExists: Boolean;
}