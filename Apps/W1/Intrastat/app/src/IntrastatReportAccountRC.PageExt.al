pageextension 4815 "Intrastat Report Account RC" extends "Accountant Role Center"
{
    actions
    {
        addlast(Action172)
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
        addlast(embedding)
        {
            action(IntrastatReportsEmb)
            {
                ApplicationArea = BasicEU, BasicNO, BasicCH;
                Caption = 'Intrastat Reports';
                RunObject = Page "Intrastat Report List";
                ToolTip = 'Report your trade with other EU countries/regions for Intrastat reporting.';
            }
        }
        addlast(History)
        {
            action(IntrastatReportHistory)
            {
                ApplicationArea = BasicEU, BasicNO, BasicCH;
                Caption = '&Intrastat Reports (Reported)';
                RunObject = Page "Intrastat Report List";
                RunPageView = sorting("No.") where(Reported = const(true));
                Image = ListPage;
                ToolTip = 'Show reported Intrastats.';
            }
        }
    }
}