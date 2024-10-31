namespace Microsoft.DataMigration.GP.HistoricalData;

using Microsoft.Purchases.Payables;

pageextension 41022 "Hist. Vendor Factbox Ext." extends "Vendor Hist. Buy-from FactBox"
{
    layout
    {
        addlast(Control1)
        {
            field(NoOfHistPayablesTrxTile; NumberOfHistPayablesTrx)
            {
                ApplicationArea = All;
                Caption = 'GP Payables transactions';
                ToolTip = 'Specifies the number of historical payables transactions that have been posted by the vendor.';

                trigger OnDrillDown()
                var
                    HistPageNavigationHandler: Codeunit "Hist. Page Navigation Handler";
                begin
                    HistPageNavigationHandler.NavigateToVendorPayablesDocuments(Rec."No.");
                end;
            }
            field(NoOfHistReceivingsTrxTile; NumberOfHistReceivingsTrx)
            {
                ApplicationArea = All;
                Caption = 'GP Receivings transactions';
                ToolTip = 'Specifies the number of historical purchase receivings transactions that have been posted by the vendor.';

                trigger OnDrillDown()
                var
                    HistPageNavigationHandler: Codeunit "Hist. Page Navigation Handler";
                begin
                    HistPageNavigationHandler.NavigateToVendorPurchaseRecvTransactions(Rec."No.");
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        HistPayablesDocument: Record "Hist. Payables Document";
        HistPurchaseRecvHeader: Record "Hist. Purchase Recv. Header";
    begin
        if CurrentRecNo <> Rec."No." then begin
            CurrentRecNo := Rec."No.";

            // Number of GP Payables Transactions
            HistPayablesDocument.SetRange("Vendor No.", Rec."No.");
            NumberOfHistPayablesTrx := HistPayablesDocument.Count();

            // Number of GP Receivings Transactions
            HistPurchaseRecvHeader.SetRange("Vendor No.", Rec."No.");
            NumberOfHistReceivingsTrx := HistPurchaseRecvHeader.Count();
        end;
    end;

    var
        NumberOfHistPayablesTrx: Integer;
        NumberOfHistReceivingsTrx: Integer;
        CurrentRecNo: Text;
}