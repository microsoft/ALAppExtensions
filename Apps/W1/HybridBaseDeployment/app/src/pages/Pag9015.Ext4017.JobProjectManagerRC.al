pageextension 4017 JobProjectManagerRC extends "Job Project Manager RC"
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