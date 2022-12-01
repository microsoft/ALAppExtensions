pageextension 4816 "Intrastat Report Bus.Man. RC" extends "Business Manager Role Center"
{
    actions
    {
        addlast(Action39)
        {
            action(IntrastatReports)
            {
                ApplicationArea = BasicEU, BasicNO, BasicCH;
                Caption = 'Intrastat Reports';
                RunObject = Page "Intrastat Report List";
                Image = ListPage;
                ToolTip = 'Summarize the value of your purchases and sales with business partners in the EU for statistical purposes and prepare to send it to the relevant authority.';
            }
        }
    }
}