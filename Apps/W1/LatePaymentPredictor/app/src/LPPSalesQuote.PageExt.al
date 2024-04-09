namespace Microsoft.Finance.Latepayment;

using Microsoft.Sales.Document;
pageextension 1955 "LPP Sales Quote" extends "Sales Quote"
{
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
                Visible = false;

                trigger OnAction();
                var
                    LPPredictionMgt: Codeunit "LP Prediction Mgt.";
                begin
                    CheckAmountMoreThanZero();
                    LPPredictionMgt.PredictLateShowResult(Rec);
                end;

            }
        }
    }

}