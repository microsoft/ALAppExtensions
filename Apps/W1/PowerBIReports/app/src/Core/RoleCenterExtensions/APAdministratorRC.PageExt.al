// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.PowerBIReports;
using Microsoft.Finance.RoleCenters;
using Microsoft.PowerBIReports;


pageextension 36951 "A/P Administrator RC" extends "Acc. Payable Administrator RC"
{
    actions
    {
        addlast(Reporting)
        {
            group("PBI Reports")
            {
                Caption = 'Power BI Reports';
                Image = AnalysisView;
                ToolTip = 'Power BI reports for account payable administration.';

                action(PurchasesReport)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Report (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Report";
                    ToolTip = 'Open a Power BI Report that offers a consolidated view of all purchase report pages, conveniently embedded into a single page for easy access.';
                }
                action(PurchasesOverview)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Overview (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Overview";
                    ToolTip = 'Open a Power BI Report that provides a comprehensive overview of purchases, including key metrics such as total purchases, purchase amounts by vendor, and purchase amounts by item category.';
                }
                action(PurchasesDecomposition)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Decomposition (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Decomposition";
                    ToolTip = 'Open a Power BI Report that provides a detailed breakdown of purchases, including purchase amounts by vendor and item category.';
                }
                action(DailyPurchases)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Daily Purchases (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Daily Purchases";
                    ToolTip = 'Open a Power BI Report that provides a daily breakdown of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesMovingAverages)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Moving Averages (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Moving Averages";
                    ToolTip = 'Open a Power BI Report that provides moving averages of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesMovingAnnualTotal)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Moving Total (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Moving Annual Total";
                    ToolTip = 'Open a Power BI Report that provides moving totals of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesPeriodOverPeriod)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Period Over Period (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Period-Over-Period";
                    ToolTip = 'Open a Power BI Report that provides a comparison of purchases over different periods, including purchase amounts by vendor and item category.';
                }
                action(PurchasesYearOverYear)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases Year-Over-Year (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases Year-Over-Year";
                    ToolTip = 'Open a Power BI Report that provides a year-over-year comparison of purchases, including purchase amounts by vendor and item category.';
                }
                action(PurchasesByItem)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Item (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases by Item";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by item, including purchase amounts by vendor and item category.';
                }
                action(PurchasesByPurchaser)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Purchaser (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases by Purchaser";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by purchaser, including purchase amounts by vendor and item category.';
                }
                action(PurchasesByVendor)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Vendor (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases by Vendor";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by vendor, including purchase amounts by item category.';
                }
                action(PurchasesByLocation)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchases by Location (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purchases by Location";
                    ToolTip = 'Open a Power BI Report that provides a breakdown of purchases by location, including purchase amounts by vendor and item category.';
                }
                action(PurchaActualVsBudgetQty)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Actual vs. Budget Qty. (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purch. Actual vs. Budget Qty.";
                    ToolTip = 'Open a Power BI Report that provides a comparison of actual purchases versus budgeted quantities, including purchase amounts by vendor and item category.';
                }
                action(PurchActualVsBudgetAmount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purch. Actual vs. Budget Amt. (Power BI)';
                    Image = PowerBI;
                    RunObject = page "Purch. Actual vs. Budget Amt.";
                    ToolTip = 'Open a Power BI Report that provides a comparison of actual purchases versus budgeted amounts, including purchase amounts by vendor and item category.';
                }
            }
        }
    }
}