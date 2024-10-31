namespace Microsoft.DataMigration.GP.HistoricalData;

using Microsoft.Sales.Customer;

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
                    Image = Documents;
                    ToolTip = 'View the GP receivables transactions.';
                    Visible = GPRecvDataAvailable;

                    trigger OnAction()
                    var
                        HistReceivablesDocuments: Page "Hist. Receivables Documents";
                    begin
                        HistReceivablesDocuments.SetFilterCustomerNo(Rec."No.");
                        HistReceivablesDocuments.Run();
                    end;
                }
                action("GP Sales Trx.")
                {
                    ApplicationArea = All;
                    Caption = 'Sales Transactions';
                    Image = Sales;
                    ToolTip = 'View the GP sales transactions.';
                    Visible = GPSalesTrxDataAvailable;

                    trigger OnAction()
                    var
                        HistSalesTrxHeaders: Page "Hist. Sales Trx. Headers";
                    begin
                        HistSalesTrxHeaders.SetFilterCustomerNo(Rec."No.");
                        HistSalesTrxHeaders.Run();
                    end;
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
                Visible = GPHistDataAvailable;

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
        if HistSalesTrxHeader.ReadPermission() then
            GPSalesTrxDataAvailable := not HistSalesTrxHeader.IsEmpty();

        if HistReceivablesDocument.ReadPermission() then
            GPRecvDataAvailable := not HistReceivablesDocument.IsEmpty();

        GPHistDataAvailable := (GPSalesTrxDataAvailable or GPRecvDataAvailable);
    end;

    var
        GPHistDataAvailable: Boolean;
        GPSalesTrxDataAvailable: Boolean;
        GPRecvDataAvailable: Boolean;
}