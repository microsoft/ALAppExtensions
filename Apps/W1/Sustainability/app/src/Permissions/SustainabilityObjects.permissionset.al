namespace Microsoft.Sustainability;

using Microsoft.API.V1;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Calculation;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Emission;
using Microsoft.Sustainability.FinancialReporting;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Posting;
using Microsoft.Sustainability.Reports;
using Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

permissionset 6210 "Sustainability - Objects"
{
    Caption = 'Sustainability - Objects';
    Access = Internal;
    Assignable = false;

    Permissions =
        table "Sustainability Account" = X,
        table "Sustain. Account Category" = X,
        table "Sustain. Account Subcategory" = X,
        table "Sustainability Jnl. Template" = X,
        table "Sustainability Jnl. Batch" = X,
        table "Sustainability Jnl. Line" = X,
        table "Sustainability Ledger Entry" = X,
        table "Sustainability Setup" = X,
        table "Emission Fee" = X,
        table "Sust. Account (Analysis View)" = X,
        table "Sust. Certificate Area" = X,
        table "Sust. Certificate Standard" = X,
        table "Sustainability Certificate" = X,
        table "Sustainability Cue" = X,
        table "Sustainability Goal" = X,
        table "Sustainability Goal Cue" = X,
        table "Sustainability Scorecard" = X,
        page "Chart of Sustain. Accounts" = X,
        page "Collect Amount from G/L Entry" = X,
        page "G/L Accounts Subform" = X,
        page "Sustainability Account Card" = X,
        page "Sustain. Account Categories" = X,
        page "Sustain. Category FactBox" = X,
        page "Sustain. Subcategory FactBox" = X,
        page "Sustainability Account List" = X,
        page "Sustain. Account Subcategories" = X,
        page "Sustainability Jnl. Templates" = X,
        page "Sustainability Jnl. Temp. List" = X,
        page "Sustainability Jnl. Batches" = X,
        page "Sustainability Journal" = X,
        page "Recurring Sustainability Jnl." = X,
        page "Sustainability Ledger Entries" = X,
        page "Sustainability Setup" = X,
        page "Sustain. Jnl. Errors Factbox" = X,
        page "Sustainability Accounts" = X,
        page "Sust. Account Categories" = X,
        page "Sust. Acc. Subcategory" = X,
        page "Sustainability Journal Line" = X,
        page "Sustainability Ledg. Entries" = X,
        page "Emission Fees" = X,
        page "Emission Scope Ratio Chart" = X,
        page "Headline Sustainability RC" = X,
        page "Sust. Accs. (Analysis View)" = X,
        page "Sust. Certificate Areas" = X,
        page "Sust. Certificate Card" = X,
        page "Sust. Certificate Standards" = X,
        page "Sustainability Activities" = X,
        page "Sustainability Certificates" = X,
        page "Sustainability Goal Cue" = X,
        page "Sustainability Goals" = X,
        page "Sustainability Manager RC" = X,
        page "Sustainability Scorecard" = X,
        page "Sustainability Scorecards" = X,
        codeunit "Sustainability Account Mgt." = X,
        codeunit "Sustainability Journal Mgt." = X,
        codeunit "Sustainability Jnl.-Post" = X,
        codeunit "Sustainability Recur Jnl.-Post" = X,
        codeunit "Sustainability Post Mgt" = X,
        codeunit "Sustainability Jnl.-Check" = X,
        codeunit "Sustainability Calculation" = X,
        codeunit "Sustainability Calc. Mgt." = X,
        codeunit "Sustain. Jnl. Errors Mgt." = X,
        codeunit "Check Sust. Jnl. Line. Backgr." = X,
        codeunit "Acc. Sch. Line Mgmt. Helper" = X,
        codeunit "Acc. Schedule Line Subscribers" = X,
        codeunit "Analysis View Entry Subscriber" = X,
        codeunit AnalysisViewEntryToSustEntries = X,
        codeunit "Compute Sust. Goal Cue" = X,
        codeunit "Install Sustainability Setup" = X,
        codeunit "RC Headline Page Sust." = X,
        codeunit "Sust. Acc. Analysis View Mgt." = X,
        codeunit "Sust. Certificate Subscribers" = X,
        codeunit "Sust. Preview Post Instance" = X,
        codeunit "Sust. Preview Post. Subscriber" = X,
        codeunit "Sust. Preview Posting Handler" = X,
        codeunit "Sustainability Chart Mgmt." = X,
        report "Emission By Category" = X,
        report "Emission Per Facility" = X,
        report "Total Emissions" = X,
        report "Batch Update Carbon Emission" = X;
}