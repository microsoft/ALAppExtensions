#if not CLEAN23
namespace Microsoft.DataMigration;

using Microsoft.Projects.RoleCenters;

pageextension 4017 JobProjectManagerRC extends "Job Project Manager RC"
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