pageextension 4021 SalesManagerRC extends "Sales Manager Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group("Intelligent Cloud Insights")
            {
                Caption = 'Intelligent Cloud Insights';
                action("Intelligent Cloud Insight")
                {
                    Caption = 'Intelligent Cloud Insights';
                    ToolTip = 'Launch the Intelligent Cloud Insights page.';
                    ApplicationArea = Basic, Suite;
                    Image = CompanyInformation;
                    RunObject = page "Intelligent Cloud Insights";
                }
            }
        }
    }
}