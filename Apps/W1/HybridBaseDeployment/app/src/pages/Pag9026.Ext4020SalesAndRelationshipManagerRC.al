pageextension 4020 SalesAndRelationshipManagerRC extends "Sales & Relationship Mgr. RC"
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