namespace Microsoft.PowerBIReports;

using Microsoft.Finance.RoleCenters;

pageextension 36951 "A/P Administrator RC" extends "A/P Administrator RC"
{
    actions
    {
        addlast(Reporting)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = PowerBI;
                ToolTip = 'Power BI reports for account payable administration.';

                action(PurchasesReport)
                {
                    Caption = 'Purchases Report';
                    Image = PowerBI;
                    RunObject = page "Purchases Report";
                    ToolTip = 'Open a Power BI Report that offers a consolidated view of all purchase report pages, conveniently embedded into a single page for easy access.';
                }
                action(PurchasesOverview)
                {
                    Caption = 'Purchases Overview';
                    Image = PowerBI;
                    RunObject = page "Purchases Overview";
                    ToolTip = 'Open a Power BI Report that provides a comprehensive overview of purchases, including key metrics such as total purchases, purchase amounts by vendor, and purchase amounts by item category.';
                }
                action(PurchasesDecomposition)
                {
                    Caption = 'Purchases Decomposition';
                    Image = PowerBI;
                    RunObject = page "Purchases Decomposition";
                    ToolTip = 'Open a Power BI Report that provides a detailed breakdown of purchases, including purchase amounts by vendor and item category.';
                }
                action(DailyPurchases)
                {
                    Caption = 'Daily Purchases';
                    Image = PowerBI;
                    RunObject = page "Daily Purchases";
                    ToolTip = 'Open a Power BI Report that provides a daily breakdown of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesMovingAverages)
                {
                    Caption = 'Purchases Moving Averages';
                    Image = PowerBI;
                    RunObject = page "Purchases Moving Averages";
                    ToolTip = 'Open a Power BI Report that provides moving averages of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesMovingAnnualTotal)
                {
                    Caption = 'Purchases Moving Total';
                    Image = PowerBI;
                    RunObject = page "Purchases Moving Annual Total";
                    ToolTip = 'Open a Power BI Report that provides moving totals of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesPeriodOverPeriod)
                {
                    Caption = 'Purchases Period Over Period';
                    Image = PowerBI;
                    RunObject = page "Purchases Period-Over-Period";
                    ToolTip = 'Open a Power BI Report that provides a comparison of purchases over different periods, including purchase amounts by vendor and item category.';
                }
                action(PurchasesYearOverYear)
                {
                    Caption = 'Purchases Year-Over-Year';
                    Image = PowerBI;
                    RunObject = page "Purchases Year-Over-Year";
                    ToolTip = 'Open a Power BI Report that provides a year-over-year comparison of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesByItem)
                {
                    Caption = 'Purchases by Item';
                    Image = PowerBI;
                    RunObject = page "Purchases by Item";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by item, including purchase amounts by vendor and item category.';
                }
                action(PurchasesByPurchaser)
                {
                    Caption = 'Purchases by Purchaser';
                    Image = PowerBI;
                    RunObject = page "Purchases by Purchaser";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by purchaser, including purchase amounts by vendor and item category.';
                }
                action(PurchasesByVendor)
                {
                    Caption = 'Purchases by Vendor';
                    Image = PowerBI;
                    RunObject = page "Purchases by Vendor";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by vendor, including purchase amounts by item category.';
                }
                action(PurchasesByLocation)
                {
                    Caption = 'Purchases by Location';
                    Image = PowerBI;
                    RunObject = page "Purchases by Location";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by location, including purchase amounts by vendor and item category.';
                }
                action(PurchaActualVsBudgetQty)
                {
                    Caption = 'Purch. Actual vs. Budget Qty.';
                    Image = PowerBI;
                    RunObject = page "Purch. Actual vs. Budget Qty.";
                    ToolTip = 'Open a Power BI Report that provides a comparison of actual purchases versus budgeted quantities, including purchase amounts by vendor and item category.';
                }
                action(PurchActualVsBudgetAmount)
                {
                    Caption = 'Purch. Actual vs. Budget Amt.';
                    Image = PowerBI;
                    RunObject = page "Purch. Actual vs. Budget Amt.";
                    ToolTip = 'Open a Power BI Report that provides a comparison of actual purchases versus budgeted amounts, including purchase amounts by vendor and item category.';
                }
            }
        }
    }
}
