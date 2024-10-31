namespace Microsoft.DataMigration.GP.HistoricalData;

using Microsoft.Sales.Document;

pageextension 41021 "Hist. Sales Factbox Ext." extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        addlast(Control2)
        {
            field(NoOfHistSalesTrxTile; NumberOfHistSalesTrx)
            {
                ApplicationArea = All;
                Caption = 'GP Sales transactions';
                DrillDownPageID = "Hist. Sales Trx. Headers";
                ToolTip = 'Specifies the number of historical sales transactions that have been posted by the customer.';

                trigger OnDrillDown()
                var
                    HistPageNavigationHandler: Codeunit "Hist. Page Navigation Handler";
                begin
                    HistPageNavigationHandler.NavigateToCustomerSalesTransactions(Rec."No.");
                end;
            }
            field(NoOfHistRecvTrxTile; NumberOfHistRecvTrx)
            {
                ApplicationArea = All;
                Caption = 'GP Receivables transactions';
                DrillDownPageID = "Hist. Receivables Documents";
                ToolTip = 'Specifies the number of historical receivables transactions that have been posted by the customer.';

                trigger OnDrillDown()
                var
                    HistPageNavigationHandler: Codeunit "Hist. Page Navigation Handler";
                begin
                    HistPageNavigationHandler.NavigateToCustomerReceivablesDocuments(Rec."No.");
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        HistSalesTrxHeader: Record "Hist. Sales Trx. Header";
        HistReceivablesDocument: Record "Hist. Receivables Document";
    begin
        if CurrentRecNo <> Rec."No." then begin
            CurrentRecNo := Rec."No.";

            // Number of GP Sales Transactions
            HistSalesTrxHeader.SetRange("Customer No.", Rec."No.");
            NumberOfHistSalesTrx := HistSalesTrxHeader.Count();

            // Number of GP Receivables Transactions
            HistReceivablesDocument.SetRange("Customer No.", Rec."No.");
            NumberOfHistRecvTrx := HistReceivablesDocument.Count();
        end;
    end;

    var
        NumberOfHistSalesTrx: Integer;
        NumberOfHistRecvTrx: Integer;
        CurrentRecNo: Code[20];
}