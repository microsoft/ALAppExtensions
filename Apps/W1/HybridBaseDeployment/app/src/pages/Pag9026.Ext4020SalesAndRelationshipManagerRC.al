#if not CLEAN18
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
                    Visible = false;
                    ObsoleteTag = '18.1';
                    ObsoleteReason = 'Intelligent Cloud Insights is discontinued.';
                    ObsoleteState = Pending;
                    ApplicationArea = Basic, Suite;
                    Image = CompanyInformation;
                    RunObject = page "Intelligent Cloud Insights";
                }
            }
        }
    }
}
#endif