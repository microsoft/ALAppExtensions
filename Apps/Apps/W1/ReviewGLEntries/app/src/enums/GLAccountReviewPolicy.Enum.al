namespace Microsoft.Finance.GeneralLedger.Review;

enum 22201 "G/L Account Review Policy"
{
    Extensible = true;

    value(0; None)
    {
        Caption = 'None';
    }
    value(1; "Allow Review")
    {
        Caption = 'Allow Review';
    }
    value(2; "Allow Review and Match Balance")
    {
        Caption = 'Allow Review and Match Balance';
    }
}