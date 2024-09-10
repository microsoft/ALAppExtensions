namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.API.V1;
using Microsoft.CostAccounting.Allocation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Foundation.Address;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Certificate;
using Microsoft.Sustainability.Journal;
using Microsoft.Sustainability.Ledger;
using Microsoft.Sustainability.Reports;
using Microsoft.Sustainability.Scorecard;
using Microsoft.Sustainability.Setup;

page 6235 "Sustainability Manager RC"
{
    PageType = RoleCenter;
    Caption = 'Sustainability Manager';

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "Headline Sustainability RC")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Activities; "Sustainability Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(Goal; "Sustainability Goal Cue")
            {
                ApplicationArea = Basic, Suite;
            }
            group("Emission By Scope")
            {
                Caption = 'CO2 Emission By Scope';
                part(CO2RatioChart; "Emission Scope Ratio Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2';
                }
                part(CH4RatioChart; "CH4 Emission Ratio Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CH4';
                }
                part(N2ORatioChart; "N2O Emission Ratio Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'N2O';
                }
            }
        }
    }

    actions
    {
        area(Creation)
        {
            group("Journals")
            {
                Caption = 'Journals';
                action(SustainabilityJournal)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Journal";
                    Caption = 'Sustainability Journal';
                    ToolTip = 'Executes the Sustainability Journal action.';
                }
                action(RecurringSustainabilityJnl)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Recurring Sustainability Jnl.";
                    Caption = 'Recurring Sustainability Journals';
                    ToolTip = 'Executes the Recurring Sustainability Journals action.';
                }
            }
        }
        area(Reporting)
        {
            group("Reports")
            {
                Caption = 'Reports';
                action(TotalEmissions)
                {
                    Caption = 'Total Emissions';
                    RunObject = report "Total Emissions";
                    Image = Report;
                    ToolTip = 'View total emissions details.';
                    ApplicationArea = Basic, Suite;
                }
                action(EmissionByCategory)
                {
                    Caption = 'Emission By Category';
                    RunObject = report "Emission By Category";
                    Image = Report;
                    ToolTip = 'View emissions details by category.';
                    ApplicationArea = Basic, Suite;
                }
                action(EmissionPerFacility)
                {
                    Caption = 'Emission Per Facility';
                    RunObject = report "Emission Per Facility";
                    Image = Report;
                    ToolTip = 'View emissions details by responsibility center.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(Sections)
        {
            group(Sustainability)
            {
                Caption = 'Sustainability';
                action("Sust. Chart of Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Chart of Sustain. Accounts";
                    Caption = 'Chart of Sustain. Accounts';
                    ToolTip = 'Executes the Chart of Sustain. Accounts action.';
                }
                action("Sust. Account Categories")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sust. Account Categories";
                    Caption = 'Sust. Account Categories';
                    ToolTip = 'Executes the Sust. Account Categories action.';
                }
                action("Sust. Acc. Subcategory")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sust. Acc. Subcategory";
                    Caption = 'Sust. Acc. Subcategory';
                    ToolTip = 'Executes the Sust. Acc. Subcategory action.';
                }
                action("Sustainability Journal")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Journal";
                    Caption = 'Sustainability Journals';
                    ToolTip = 'Executes the Sustainability Journals action.';
                }
                action("Recurring Sustainability Jnl.")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Recurring Sustainability Jnl.";
                    Caption = 'Recurring Sust. Journals';
                    ToolTip = 'Executes the Recurring Sust. Journals action.';
                }
                action("Sustainability Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Ledger Entries";
                    Caption = 'Sust. Ledger Entries';
                    ToolTip = 'Executes the Sust. Ledger Entries action.';
                }
                action("Scorecards")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Scorecards";
                    Caption = 'Sust. Scoredcards';
                    ToolTip = 'Executes the Sust. Scoredcards action.';
                }
                action("Goals")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Goals";
                    Caption = 'Sust. Goals';
                    ToolTip = 'Executes the Sust. Goals action.';
                }
                action("Certificates")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Certificates";
                    Caption = 'Certificates';
                    ToolTip = 'Executes the Certificates action.';
                }
                action("Sustainability Setup")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Setup";
                    Caption = 'Sust. Setup';
                    ToolTip = 'Executes the Sust. Setup action.';
                }
            }
            group(Finance)
            {
                action("Chart of Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chart of Accounts';
                    RunObject = page "Chart of Accounts";
                    Tooltip = 'Open the Chart of Accounts page.';
                }
                action("General Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Journals';
                    RunObject = page "General Journal";
                    Tooltip = 'Open the General Journals page.';
                }
                action("Posted General Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted General Journals';
                    RunObject = page "Posted General Journal";
                    Tooltip = 'Open the Posted General Journals page.';
                }
                action("Financial Reporting")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Financial Reporting';
                    RunObject = page "Financial Reports";
                    Tooltip = 'Open the Financial Reporting page.';
                }
                action("Budgets")
                {
                    ApplicationArea = Suite;
                    Caption = 'G/L Budgets';
                    RunObject = page "G/L Budget Names";
                    Tooltip = 'Open the G/L Budgets page.';
                }
                action("Currencies")
                {
                    ApplicationArea = Suite;
                    Caption = 'Currencies';
                    RunObject = page "Currencies";
                    Tooltip = 'Open the Currencies page.';
                }
                action("Dimensions")
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    RunObject = page "Dimensions";
                    Tooltip = 'Open the Dimensions page.';
                }
                action("Statistical Accounts")
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Statistical Accounts';
                    RunObject = page "Dimensions";
                    Tooltip = 'Open the Statistical Accounts page.';
                }
                action("Allocations")
                {
                    ApplicationArea = CostAccounting;
                    Caption = 'Cost Allocations';
                    RunObject = page "Cost Allocation Sources";
                    Tooltip = 'Open the Cost Allocations page.';
                }
                action("Countries/Regions")
                {
                    ApplicationArea = CostAccounting;
                    Caption = 'Countries/Regions';
                    RunObject = page "Countries/Regions";
                    Tooltip = 'Open the Countries/Regions page.';
                }
                action("Responsibility Centers")
                {
                    ApplicationArea = CostAccounting;
                    Caption = 'Responsibility Centers';
                    RunObject = page "Responsibility Center List";
                    Tooltip = 'Open the Responsibility Centers page.';
                }
            }
            group(Purchasing)
            {
                action("Purchasing Vendors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendors';
                    RunObject = page "Vendor List";
                    ToolTip = 'Executes the Vendors action.';
                }
                action("Purchasing Items")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Items';
                    RunObject = page "Item List";
                    ToolTip = 'Executes the Items action.';
                }
                action("Item Charges")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Charges';
                    RunObject = page "Item Charges";
                    ToolTip = 'Executes the Item Charges action.';
                }
                action("Orders")
                {
                    ApplicationArea = Suite;
                    Caption = 'Purchase Orders';
                    RunObject = page "Purchase Order List";
                    ToolTip = 'Executes the Purchase Orders action.';
                }
                action("Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Invoices';
                    RunObject = page "Purchase Invoices";
                    ToolTip = 'Executes the Purchase Invoices action.';
                }
                action("Posted Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = page "Posted Purchase Invoices";
                    ToolTip = 'Executes the Posted Purchase Invoices action.';
                }
            }
        }
        area(Embedding)
        {
            action("SustChartOfAccounts")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Chart of Sustain. Accounts";
                Caption = 'Chart of Sust. Accounts';
                ToolTip = 'Executes the Chart of Sust. Accounts action.';
            }
            action("SustAccountCategories")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Sust. Account Categories";
                Caption = 'Sust. Account Categories';
                ToolTip = 'Executes the Sust. Account Categories action.';
            }
            action("SustAccSubcategory")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Sust. Acc. Subcategory";
                Caption = 'Sust. Acc. Subcategory';
                ToolTip = 'Executes the Sust. Acc. Subcategory action.';
            }
            action(Items)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Items';
                Image = Item;
                RunObject = Page "Item List";
                ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions.';
            }
            action(Vendors)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendors';
                Image = Item;
                RunObject = Page "Vendor List";
                ToolTip = 'Executes the Vendors action.';
            }
        }
    }
}