#pragma warning disable AS0032
namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Assembly.Document;
using Microsoft.CostAccounting.Allocation;
using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.Task;
using Microsoft.HumanResources.Absence;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Transfer;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Journal;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;
using Microsoft.Projects.Project.Job;
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
using System.Integration.PowerBI;

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
            group("Gas Emissions")
            {
                Caption = 'Gas Emissions';
                ShowCaption = true;
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
            group("Carbon Equivalent")
            {
                part(CO2eRatioChart; "CO2e Emission Ratio Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CO2e per Month';
                }
            }
            group("Water Management")
            {
                part(WaterRatioChart; "Water Intensity Ratio Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Water';
                }
                part(WaterBarChart; "Water Intensity Bar Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Water Intensity per Month';
                }
                part(WaterTypeBarChart; "Water Type Intensity Bar Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Water Type Intensity';
                }
            }
            group("Waste Management")
            {
                part(WasteRatioChart; "Waste Intensity Ratio Chart")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Waste';
                }
            }
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                AccessByPermission = TableData "Power BI Context Settings" = I;
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Creation)
        {
            action("Sust. Certificate")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Sustainability Certificates";
                Caption = 'Sustainability Certificate';
                ToolTip = 'Executes the Sustainability Certificate action.';
            }
            group("Journals")
            {
                Caption = 'Sustainability';
                action(SustainabilityJournal)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustainability Journal";
                    Caption = 'Sustainability Journal';
                    ToolTip = 'Executes the Sustainability Journal action.';
                    Image = Journal;
                }
                action(RecurringSustainabilityJnl)
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Recurring Sustainability Jnl.";
                    Caption = 'Recurring Sustainability Journals';
                    ToolTip = 'Executes the Recurring Sustainability Journals action.';
                    Image = Journal;
                }
            }
            group(General)
            {
                Caption = 'General';
                action("General Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Journal';
                    RunObject = page "General Journal";
                    Tooltip = 'Open the General Journals page.';
                    Image = Journal;
                }
                action("Recurring General Jnl")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurring General Journal';
                    RunObject = Page "Recurring General Journal";
                    ToolTip = 'Executes the Recurring General Journals action.';
                    Image = Journal;
                }
            }
            group(Purchase)
            {
                Caption = 'Purchase';
                action("Purchase Invoice")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Invoice';
                    RunObject = page "Purchase Invoice";
                    ToolTip = 'Create a new purchase invoice.';
                    Image = NewPurchaseInvoice;
                }
                action("Purchase Order")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Order';
                    RunObject = Page "Purchase Order";
                    ToolTip = 'Create a new purchase order.';
                    Image = NewPurchaseInvoice;
                }
                action("Purchase Credit Memo")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Credit Memo';
                    RunObject = Page "Purchase Credit Memo";
                    ToolTip = 'Create a new purchase credit memo.';
                    Image = CreditMemo;
                }
            }
            group(Production)
            {
                Caption = 'Production';
                action("Consumption Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Consumption Journal';
                    RunObject = page "Consumption Journal";
                    Tooltip = 'Open the Consumption Journals page.';
                    Image = Journal;
                }
                action("Output Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Output Journal';
                    RunObject = Page "Output Journal";
                    Tooltip = 'Open the Output Journals page.';
                    Image = OutputJournal;
                }
                action("Production Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production Journal';
                    RunObject = Page "Production Journal";
                    Tooltip = 'Open the Production Journals page.';
                    Image = Journal;
                }
            }
            group(Tasks)
            {
                Caption = 'Tasks';
                action("Sustainability Scorecards")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Scorecards';
                    RunObject = page "Sustainability Scorecards";
                    Tooltip = 'Open the Scorecards page.';
                    Image = NumberGroup;
                }
                action("Sustainability Goals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Goals';
                    RunObject = Page "Sustainability Goals";
                    Tooltip = 'Open the Goals page.';
                    Image = BankAccountRec;
                }
                action("User Tasks")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'User Tasks';
                    RunObject = Page "User Task List";
                    Tooltip = 'Open the User Tasks page.';
                    Image = Task;
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Navi&gate")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Find entries...';
                    RunObject = Page Navigate;
                    ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                    Image = Navigate;
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
                    RunObject = Page "Sustain. Account Categories";
                    Caption = 'Sust. Account Categories';
                    ToolTip = 'Executes the Sust. Account Categories action.';
                }
                action("Sust. Acc. Subcategory")
                {
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Sustain. Account Subcategories";
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
                    Caption = 'Sust. Scorecards';
                    ToolTip = 'Executes the Sust. Scorecards action.';
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
                    ApplicationArea = Suite;
                    Caption = 'Statistical Accounts';
                    RunObject = page "Statistical Account List";
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
            group(Social)
            {
                action("Employees")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Employees';
                    RunObject = page "Employee List";
                    Tooltip = 'Open the Employees page.';
                }
                action(Qualifications)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Qualifications';
                    RunObject = page "Employee Qualifications";
                    ToolTip = 'Open the list of qualifications that are registered for the employees.';
                }
                action(Absences)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Absences';
                    RunObject = page "Employee Absences";
                    ToolTip = 'View absence information for the employees.';
                }
            }
            group(Operations)
            {
                action("Work Centers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Work Centers';
                    RunObject = page "Work Center List";
                    ToolTip = 'View or edit the list of work centers.';
                }
                action("Machine Centers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Machine Centers';
                    RunObject = Page "Machine Center List";
                    ToolTip = 'View the list of machine centers.';
                }
                action("Production BOM")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Production BOM';
                    RunObject = Page "Production BOM List";
                    ToolTip = 'Open the item''s production bill of material to view or edit its components.';
                }
                action(Routings)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Routings';
                    RunObject = Page "Routing List";
                    ToolTip = 'View or edit operation sequences and process times for produced items.';
                }
                action("Released Production Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Released Production Orders';
                    RunObject = Page "Released Production Orders";
                    ToolTip = 'View the list of released production order that are ready for warehouse activities.';
                }
                action("Finished Production Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Finished Production Orders';
                    RunObject = Page "Finished Production Orders";
                    ToolTip = 'View completed production orders. ';
                }
                action("Transfer Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Transfer Orders';
                    RunObject = Page "Transfer Orders";
                    ToolTip = 'Move inventory items between company locations. With transfer orders, you ship the outbound transfer from one location and receive the inbound transfer at the other location. This allows you to manage the involved warehouse activities and provides more certainty that inventory quantities are updated correctly.';
                }
                action("Assembly Orders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Assembly Orders';
                    RunObject = Page "Assembly Orders";
                    ToolTip = 'View ongoing assembly orders.';
                }
                action(Projects)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Projects';
                    RunObject = Page "Job List";
                    ToolTip = 'Define a project activity by creating a project card with integrated project tasks and project planning lines, structured in two layers. The project task enables you to set up project planning lines and to post consumption to the project. The project planning lines specify the detailed use of resources, items, and various general ledger expenses.';
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
                RunObject = Page "Sustain. Account Categories";
                Caption = 'Sust. Account Categories';
                ToolTip = 'Executes the Sust. Account Categories action.';
            }
            action("SustAccSubcategory")
            {
                ApplicationArea = Basic, Suite;
                RunObject = Page "Sustain. Account Subcategories";
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
#pragma warning restore