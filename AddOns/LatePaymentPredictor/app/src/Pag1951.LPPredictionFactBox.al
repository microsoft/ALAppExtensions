page 1951 "LP Prediction FactBox"
{
    PageType = CardPart;
    SourceTable = "Cust. Ledger Entry";
    ContextSensitiveHelpPage = 'ui-extensions-late-payment-prediction';
    layout
    {
        area(Content)
        {
            field(Prediction; "Payment Prediction")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Prediction';
                ToolTip = 'Specifies that the payment for this invoice is predicted to be late.';
            }
            field(Confidence; "Prediction Confidence")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Confidence';
                ToolTip = 'Specifies the reliability of the late payment prediction. High is above 90%, Medium is between 80% and 90%, and Low is less than 80%.';
            }
            field(PredictionConfidencePercentage; "Prediction Confidence %")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Confidence %';
                ToolTip = 'Specifies the percentage that the prediction confidence value is based on.';
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Setup';
                Image = Setup;
                ToolTip = 'Manage settings for the Late Payment Prediction extension.';
                RunObject = Page "LP Machine Learning Setup";
            }

            action(Customer)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customer';
                Image = Customer;
                ToolTip = 'Open details for the customer.';
                RunObject = Page "Customer Card";
                RunPageLink = "No." = field("Customer No.");
            }
        }
    }

}
