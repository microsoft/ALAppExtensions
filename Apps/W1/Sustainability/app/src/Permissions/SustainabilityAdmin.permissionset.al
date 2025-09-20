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
using Microsoft.Sustainability.Reports;
using Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

permissionset 6212 "Sustainability Admin"
{
    Assignable = true;
    Caption = 'Sustainability - Admin';

    IncludedPermissionSets = "Sustainability Edit";

    Permissions =
        tabledata "Sustainability Setup" = IMD,
        tabledata "Sustainability Account" = IMD,
        tabledata "Sustain. Account Category" = IMD,
        tabledata "Sustain. Account Subcategory" = IMD,
        tabledata "Emission Fee" = IMD,
        tabledata "Sust. Account (Analysis View)" = IMD,
        tabledata "Sust. Certificate Area" = IMD,
        tabledata "Sust. Certificate Standard" = IMD,
        tabledata "Sustainability Certificate" = IMD,
        tabledata "Sustainability Cue" = IMD,
        tabledata "Sustainability Goal" = IMD,
        tabledata "Sustainability Goal Cue" = IMD,
        tabledata "Sustainability Scorecard" = IMD,
        tabledata "Sustainability Energy Source" = IMD,
        tabledata "Sust. ESG Reporting Template" = IMD,
        tabledata "Sust. ESG Reporting Name" = IMD,
        tabledata "Sust. ESG Reporting Line" = IMD,
        tabledata "Sust. Posted ESG Report Header" = IMD,
        tabledata "Sust. Posted ESG Report Line" = IMD,
        tabledata "Sust. Assessment" = IMD,
        tabledata "Sust. Assessment Req. Fact" = IMD,
        tabledata "Sust. Assessment Requirement" = IMD,
        tabledata "Sust. Concept" = IMD,
        tabledata "Sust. ESG Fact" = IMD,
        tabledata "Sust. ESG Reporting Unit" = IMD,
        tabledata "Sust. ESG Standard" = IMD,
        tabledata "Sust. Item Emission Buffer" = IMD,
        tabledata "Sust. Range Period" = IMD,
        tabledata "Sust. Requirement Concept" = IMD,
        tabledata "Sust. Standard" = IMD,
        tabledata "Sust. Standard Requirement" = IMD,
        tabledata "Sust. Unit" = IMD,
        tabledata "Sustainability EPR Material" = IMD,
        tabledata "Sust. Item Mat. Comp. Header" = IMD,
        tabledata "Sust. Item Mat. Comp. Line" = IMD,
        tabledata "Sust. Excise Jnl. Line" = IMD,
        tabledata "Sust. Excise Journal Batch" = IMD,
        tabledata "Sust. Excise Journal Template" = IMD,
        tabledata "Sust. Excise Taxes Trans. Log" = IMD,
        tabledata "Sustainability Carbon Pricing" = IMD,
        tabledata "Sust. ESG Concept" = IMD,
        tabledata "Sust. ESG Range Period" = IMD,
        tabledata "Sust. ESG Requirement Concept" = IMD,
        tabledata "Sust. ESG Standard Requirement" = IMD,
        tabledata "Sustainability Disclaimer" = IMD;
}