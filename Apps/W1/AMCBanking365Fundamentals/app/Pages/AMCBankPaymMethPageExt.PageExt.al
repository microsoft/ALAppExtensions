pageextension 20104 "AMC Bank Paym. Meth. Page Ext" extends "Payment Methods"
{

    ContextSensitiveHelpPage = '402';

    layout
    {
        addAfter("Pmt. Export Line Definition")
        {
            field("Bank Payment Type"; Rec."AMC Bank Pmt. Type")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the payment type that the AMC Banking 365 Fundamentals extension requires when you export payments that have the selected payment method.';
            }
        }
    }

}