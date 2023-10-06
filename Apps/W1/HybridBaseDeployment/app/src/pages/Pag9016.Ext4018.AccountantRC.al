namespace Microsoft.DataMigration;

using Microsoft.Finance.RoleCenters;

#if not CLEAN23
pageextension 4018 AccountantRC extends "Accountant Role Center"
{
    ObsoleteReason = 'Intelligent Cloud Insights is discontinued';
    ObsoleteState = Pending;
    ObsoleteTag = '23.0';

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