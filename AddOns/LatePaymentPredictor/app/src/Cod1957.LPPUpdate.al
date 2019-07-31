codeunit 1957 "LPP Update"
{
    trigger OnRun()
    var
        CustomerLedgerEntries: Record "Cust. Ledger Entry";
        LPMLInputData: Record "LP ML Input Data";
        LPMachineLearningSetup: Record "LP Machine Learning Setup";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
    begin
        LPMLInputData.DeleteAll();
        LPMachineLearningSetup.GetSingleInstance();

        // Implementation with bulk prediction
        LPPredictionMgt.PredictIsLateAllPayments(SalesHeader, LPMachineLearningSetup, LPMLInputData);
        LPMLInputData.Reset();

        CustomerLedgerEntries.SetRange("Document Type", CustomerLedgerEntries."Document Type"::Invoice);
        CustomerLedgerEntries.SetFilter("Remaining Amt. (LCY)", '<>0');
        CustomerLedgerEntries.SetRange(Open, true);
        CustomerLedgerEntries.SetFilter("Due Date", '>=%1', WorkDate());
        If CustomerLedgerEntries.FindSet() then
            repeat
                if SalesInvoiceHeader.Get(CustomerLedgerEntries."Document No.") then begin
                    LPMLInputData.SetRange(Number, CustomerLedgerEntries."Document No.");
                    LPMLInputData.FindFirst();
                    if LPMLInputData."Is Late" then
                        CustomerLedgerEntries."Payment Prediction" := CustomerLedgerEntries."Payment Prediction"::Late
                    else
                        CustomerLedgerEntries."Payment Prediction" := CustomerLedgerEntries."Payment Prediction"::"On-Time";
                    CustomerLedgerEntries."Prediction Confidence %" := Round(LPMLInputData.Confidence * 100, 1);
                    CustomerLedgerEntries."Prediction Confidence" := LPPredictionMgt.GetConfidenceOptionFromConfidencePercent(LPMLInputData.Confidence);
                    CustomerLedgerEntries.Modify();
                end;
            until CustomerLedgerEntries.Next() = 0;
        LPMLInputData.DeleteAll();

        LPMachineLearningSetup.GetSingleInstance();
        LPMachineLearningSetup."Last Feature Table Reset" := 0DT; // table will need to be rebuilt
        LPMachineLearningSetup.Modify();
    end;
}