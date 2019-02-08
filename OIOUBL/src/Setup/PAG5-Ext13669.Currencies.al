pageextension 13669 "OIOUBL-Currencies" extends Currencies
{
    layout
    {
        addafter(CurrencyFactor)
        {
            field("OIOUBL-Currency Code"; "OIOUBL-Currency Code")
            {
                Tooltip = 'Specifies the three character currency code that is required for currencies that are used in electronic invoices.';
                ApplicationArea = Suite;
            }
        }
    }
}