namespace Microsoft.Sustainability;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.CBAM;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.CRM;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.Energy;
using Microsoft.Sustainability.EPR;
using Microsoft.Sustainability.ESGReporting;
using Microsoft.Sustainability.ExciseTax;
using Microsoft.Sustainability.FinancialReporting;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Reports;
using Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

permissionset 6211 "Sustainability Read"
{
    Caption = 'Sustainability - Read';
    Access = Public;
    Assignable = true;

    IncludedPermissionSets = "Sustainability - Objects";

    Permissions =
        tabledata "Sustainability Account" = R,
        tabledata "Sustain. Account Category" = R,
        tabledata "Sustain. Account Subcategory" = R,
        tabledata "Sustainability Jnl. Template" = R,
        tabledata "Sustainability Jnl. Batch" = R,
        tabledata "Sustainability Jnl. Line" = R,
        tabledata "Sustainability Ledger Entry" = R,
        tabledata "Sustainability Value Entry" = R,
        tabledata "Sustainability Setup" = R,
        tabledata "Emission Fee" = R,
        tabledata "Sust. Account (Analysis View)" = R,
        tabledata "Sust. Certificate Area" = R,
        tabledata "Sust. Certificate Standard" = R,
        tabledata "Sustainability Certificate" = R,
        tabledata "Sustainability Cue" = R,
        tabledata "Sustainability Goal" = R,
        tabledata "Sustainability Goal Cue" = R,
        tabledata "Sustainability Scorecard" = R,
        tabledata "Sustainability Energy Source" = R,
        tabledata "Sust. ESG Reporting Template" = R,
        tabledata "Sust. ESG Reporting Name" = R,
        tabledata "Sust. ESG Reporting Line" = R,
        tabledata "Sust. Posted ESG Report Header" = R,
        tabledata "Sust. Posted ESG Report Line" = R,
        tabledata "Sust. Assessment" = R,
        tabledata "Sust. Assessment Req. Fact" = R,
        tabledata "Sust. Assessment Requirement" = R,
        tabledata "Sust. Concept" = R,
        tabledata "Sust. ESG Fact" = R,
        tabledata "Sust. ESG Reporting Unit" = R,
        tabledata "Sust. ESG Standard" = R,
        tabledata "Sust. Item Emission Buffer" = R,
        tabledata "Sust. Range Period" = R,
        tabledata "Sust. Requirement Concept" = R,
        tabledata "Sust. Standard" = R,
        tabledata "Sust. Standard Requirement" = R,
        tabledata "Sust. Unit" = R,
        tabledata "Sust. Item Mat. Comp. Header" = R,
        tabledata "Sust. Item Mat. Comp. Line" = R,
        tabledata "Sust. Excise Jnl. Line" = R,
        tabledata "Sust. Excise Journal Batch" = R,
        tabledata "Sust. Excise Journal Template" = R,
        tabledata "Sust. Excise Taxes Trans. Log" = R,
        tabledata "Sustainability Carbon Pricing" = R,
        tabledata "Sustainability EPR Material" = R,
        tabledata "Sust. ESG Concept" = R,
        tabledata "Sust. ESG Range Period" = R,
        tabledata "Sust. ESG Requirement Concept" = R,
        tabledata "Sust. ESG Standard Requirement" = R,
        tabledata "Sustainability Disclaimer" = R;
}