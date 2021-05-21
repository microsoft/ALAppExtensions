pageextension 31101 "Responsibility Center Card CZL" extends "Responsibility Center Card"
{
    layout
    {
        addafter(Communication)
        {
            group(PaymentsCZL)
            {
                field("Default Bank Account Code CZL"; Rec."Default Bank Account Code CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default bank account code for payment.';
                }
            }
        }
    }
}
