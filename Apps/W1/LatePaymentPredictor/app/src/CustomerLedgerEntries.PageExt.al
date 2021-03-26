pageextension 1958 "LPP Customer Ledger Entries" extends "Customer Ledger Entries"
{
    ContextSensitiveHelpPage = 'ui-extensions-late-payment-prediction';
    layout
    {
        addafter("Due Date")
        {
            field("Payment Prediction"; "Payment Prediction")
            {
                Caption = 'Payment Prediction';
                ToolTip = 'Specifies that the payment for this invoice is predicted to be late.';
                visible = IsLPPEnabled;
                ApplicationArea = Basic, Suite;
            }
            field("Prediction Confidence"; "Prediction Confidence")
            {
                Caption = 'Prediction Confidence';
                ToolTip = 'Specifies the reliability of the late payment prediction. High is above 90%, Medium is between 80% and 90%, and Low is less than 80%.';
                visible = IsLPPEnabled;
                ApplicationArea = Basic, Suite;
            }
            field("Prediction Confidence %"; "Prediction Confidence %")
            {
                Caption = 'Prediction Confidence %';
                ToolTip = 'Specifies the percentage that the prediction confidence value is based on.';
                Visible = false;
                ApplicationArea = Basic, Suite;
            }
        }

        addlast(FactBoxes)
        {
            part("Late Payment Prediction FactBox"; "LP Prediction FactBox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Late Payment Prediction';
                SubPageLink = "Document No." = FIELD("Document No.");
            }
        }
    }

    actions
    {
        addafter(ReverseTransaction)
        {
            action("Update Predictions")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Update Payment Predictions';
                ToolTip = 'Update the late payment predictions for all invoices. Predictions are available only if the Late Payment Prediction extension is enabled.';
                Image = PaymentForecast;

                trigger OnAction();
                var
                    LPPredictionMgt: Codeunit "LP Prediction Mgt.";
                begin
                    if not LPPredictionMgt.IsEnabled(true) then
                        exit;

                    Codeunit.Run(Codeunit::"LPP Update");
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        LPPredictionMgt: Codeunit "LP Prediction Mgt.";
    begin
        IsLPPEnabled := LPPredictionMgt.IsEnabled(false);
    end;

    var
        IsLPPEnabled: Boolean;
}