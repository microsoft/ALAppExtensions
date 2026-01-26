namespace Microsoft.DataMigration.GP.HistoricalData;

using Microsoft.Purchases.Vendor;

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
                    Caption = 'Vendor Payables Transactions';
                    Image = Documents;
                    ToolTip = 'View the GP payables transactions for the vendor.';
                    Visible = GPPayablesDataAvailable;

                    trigger OnAction()
                    var
                        HistPayablesDocuments: Page "Hist. Payables Documents";
                    begin
                        HistPayablesDocuments.SetFilterVendorNo(Rec."No.");
                        HistPayablesDocuments.Run();
                    end;
                }
                action("GP All Payables Docs")
                {
                    ApplicationArea = All;
                    Caption = 'All Payables Transactions';
                    Image = ViewWorksheet;
                    RunObject = Page "Hist. Payables Documents";
                    ToolTip = 'View all GP payables transactions.';
                    Visible = GPPayablesDataAvailable;
                }
                action("GP Purchase Recv.")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Receivings Transactions';
                    Image = ReceivablesPayables;
                    ToolTip = 'View the GP purchase receivings transactions for the vendor.';
                    Visible = GPPurchaseRecvDataAvailable;

                    trigger OnAction()
                    var
                        HistPurchaseRecvHeaders: Page "Hist. Purchase Recv. Headers";
                    begin
                        HistPurchaseRecvHeaders.SetFilterVendorNo(Rec."No.");
                        HistPurchaseRecvHeaders.Run();
                    end;
                }
                action("GP All Purchase Recv.")
                {
                    ApplicationArea = All;
                    Caption = 'All Receivings Transactions';
                    Image = ViewWorksheet;
                    RunObject = Page "Hist. Purchase Recv. Headers";
                    ToolTip = 'View all GP purchase receivings transactions.';
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

                actionref("GP All Payables Docs_Promoted"; "GP All Payables Docs")
                {
                }
                actionref("GP All Purchase Recv._Promoted"; "GP All Purchase Recv.")
                {
                }

                group(Category_GPGLDetail_Selected)
                {
                    Caption = 'Selected Vendor';
                    ShowAs = Standard;
                    Image = Vendor;
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