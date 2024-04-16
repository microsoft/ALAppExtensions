namespace Microsoft.Bank.BankAccount;
pageextension 31232 "Payment Methods CZL" extends "Payment Methods"
{
    layout
    {
        addlast(Control1)
        {
            field("Print QR Payment CZL"; Rec."Print QR Payment CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether to print a code for QR payment on Sales Invoices and Advances with given payment method.';
            }
        }
    }
}
