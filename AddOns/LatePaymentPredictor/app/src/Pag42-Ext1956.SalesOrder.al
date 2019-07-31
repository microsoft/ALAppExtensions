pageextension 1956 "LPP  Sales Order" extends "Sales Order"
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
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category7;

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