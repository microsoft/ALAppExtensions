pageextension 1959 "LP Activities" extends "O365 Activities"
{
    ContextSensitiveHelpPage = 'ui-extensions-late-payment-prediction';
    layout
    {
        addafter("Overdue Purch. Invoice Amount")
        {
            field("Sales Invoices Predicted Overdue"; NumberSalesInvPredictedToBeLate)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies sales invoices that are predicted to be paid late.';
                Caption = 'Sales Invoices Predicted Overdue';
                trigger OnDrillDown()
                begin
                    DrillDownSalesInvoicePredictedToBeLate();
                end;
            }
        }
    }

    var
        NumberSalesInvPredictedToBeLate: Integer;

    trigger OnOpenPage()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
    begin
        if LPPredictionMgt.IsEnabled(false) then begin
            SetSalesInvoicePredictedToBeLateFilters(CustLedgerEntry);
            NumberSalesInvPredictedToBeLate := CustLedgerEntry.Count();
        end;
    end;

    procedure DrillDownSalesInvoicePredictedToBeLate()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        SetSalesInvoicePredictedToBeLateFilters(CustLedgerEntry);
        Page.Run(Page::"Customer Ledger Entries", CustLedgerEntry);
    end;

    procedure SetSalesInvoicePredictedToBeLateFilters(var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange(Open, TRUE);
        CustLedgerEntry.SetFilter("Due Date", '>%1', WORKDATE());
        CustLedgerEntry.SetFilter("Remaining Amt. (LCY)", '<>0');
        CustLedgerEntry.SetCurrentKey("Remaining Amt. (LCY)");
        CustLedgerEntry.SetRange("Payment Prediction", CustLedgerEntry."Payment Prediction"::Late);
        CustLedgerEntry.Ascending := FALSE;
    end;

}