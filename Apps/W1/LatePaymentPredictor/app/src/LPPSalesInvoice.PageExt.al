namespace Microsoft.Finance.Latepayment;

using Microsoft.Sales.Document;
pageextension 1957 "LPP Sales Invoice" extends "Sales Invoice"
{
    layout
    {
    }

    actions
    {
        addafter("F&unctions")
        {
            action("Predict Payment")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Predict Payment';
                ToolTip = 'Predict whether the payment for this sales document will be made on time. Predictions are available only if the Late Payment Prediction extension is enabled.';
                Image = PaymentForecast;
                Promoted = true;
                PromotedOnly = true;
                Visible = false;
                PromotedCategory = Category6;

                trigger OnAction();
                var
                    LPPredictionMgt: Codeunit "LP Prediction Mgt.";
                begin
                    Rec.CheckAmountMoreThanZero();
                    LPPredictionMgt.PredictLateShowResult(Rec);
                end;
            }
        }
    }

}