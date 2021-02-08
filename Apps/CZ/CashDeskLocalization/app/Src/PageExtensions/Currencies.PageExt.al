pageextension 31150 "Currencies CZP" extends Currencies
{
    actions
    {
        addlast(navigation)
        {
            action(NominalValuesCZP)
            {
                Caption = 'Nominal Values';
                ApplicationArea = Basic, Suite;
                Image = Currencies;
                RunObject = Page "Currency Nominal Values CZP";
                RunPageLink = "Currency Code" = field(Code);
                RunPageMode = View;
                Tooltip = 'Define the currency nominal values used in the cash desks.';
            }
        }
    }
}
