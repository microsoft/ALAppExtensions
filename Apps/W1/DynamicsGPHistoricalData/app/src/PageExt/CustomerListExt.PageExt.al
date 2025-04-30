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
                    Caption = 'Customer Receivables Transactions';
                    Image = Documents;
                    ToolTip = 'View the GP receivables transactions for the customer.';
                    Visible = GPRecvDataAvailable;

                    trigger OnAction()
                    var
                        HistReceivablesDocuments: Page "Hist. Receivables Documents";
                    begin
                        HistReceivablesDocuments.SetFilterCustomerNo(Rec."No.");
                        HistReceivablesDocuments.Run();
                    end;
                }
                action("GP All Rec. Docs")
                {
                    ApplicationArea = All;
                    Caption = 'All Receivables Transactions';
                    Image = ViewWorksheet;
                    RunObject = Page "Hist. Receivables Documents";
                    ToolTip = 'View all GP receivables transactions.';
                    Visible = GPRecvDataAvailable;
                }
                action("GP Sales Trx.")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Sales Transactions';
                    Image = Sales;
                    ToolTip = 'View the GP sales transactions for the customer.';
                    Visible = GPSalesTrxDataAvailable;

                    trigger OnAction()
                    var
                        HistSalesTrxHeaders: Page "Hist. Sales Trx. Headers";
                    begin
                        HistSalesTrxHeaders.SetFilterCustomerNo(Rec."No.");
                        HistSalesTrxHeaders.Run();
                    end;
                }
                action("GP All Sales Trx.")
                {
                    ApplicationArea = All;
                    Caption = 'All Sales Transactions';
                    Image = ViewWorksheet;
                    RunObject = Page "Hist. Sales Trx. Headers";
                    ToolTip = 'View all GP sales transactions.';
                    Visible = GPSalesTrxDataAvailable;
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

                actionref("GP All Rec. Docs_Promoted"; "GP All Rec. Docs")
                {
                }
                actionref("GP All Sales Trx._Promoted"; "GP All Sales Trx.")
                {
                }

                group(Category_GPGLDetail_Selected)
                {
                    Caption = 'Selected Customer';
                    ShowAs = Standard;
                    Image = Customer;
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