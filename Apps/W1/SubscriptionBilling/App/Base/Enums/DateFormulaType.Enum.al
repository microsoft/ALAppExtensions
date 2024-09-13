namespace Microsoft.SubscriptionBilling;

enum 8061 "Date Formula Type"
{
    Extensible = false;
    Access = Internal;

    value(0; Day)
    {
        Caption = 'Day';
    }
    value(1; Week)
    {
        Caption = 'Week';
    }
    value(2; Month)
    {
        Caption = 'Month';
    }
    value(3; Quarter)
    {
        Caption = 'Quarter';
    }
    value(4; Year)
    {
        Caption = 'Year';
    }
    value(5; CurrentPeriod)
    {
        Caption = 'Current Period';
    }
    value(6; ComplexFormula)
    {
        Caption = 'Complex Formula';
    }
    value(7; Empty)
    {
        Caption = 'Empty';
    }
}
