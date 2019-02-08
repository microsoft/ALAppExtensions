pageextension 13619 PaymentMethods extends "Payment Methods"
{
    layout
    {
        addafter("Pmt. Export Line Definition")
        {
            field("Payment Type Validation"; PaymentTypeValidation)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the FIK code when the payment is processed using the Danish bank standard, FIK.';
            }
        }
    }
}

