// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.RoleCenters;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Bank.Reconciliation;
using Microsoft.Bank.Reports;
using Microsoft.Bank.Statement;
using Microsoft.CashFlow.Account;
using Microsoft.CashFlow.Forecast;
using Microsoft.CashFlow.Reports;
using Microsoft.CashFlow.Setup;
using Microsoft.CostAccounting.Account;
using Microsoft.CostAccounting.Allocation;
using Microsoft.CostAccounting.Budget;
using Microsoft.CostAccounting.Ledger;
using Microsoft.CostAccounting.Reports;
using Microsoft.CRM.Contact;
using Microsoft.EServices.EDocument;
using Microsoft.Finance;
using Microsoft.Finance.Analysis;
using Microsoft.Finance.Consolidation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.Deferral;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Budget;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Reports;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Registration;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Insurance;
using Microsoft.FixedAssets.Journal;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.Navigate;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.PaymentTerms;
using Microsoft.Foundation.Period;
using Microsoft.Foundation.Task;
using Microsoft.HumanResources.Employee;
using Microsoft.Intercompany;
using Microsoft.Intercompany.Dimension;
using Microsoft.Intercompany.GLAccount;
using Microsoft.Intercompany.Partner;
using Microsoft.Inventory.Costing;
using Microsoft.Inventory.History;
using Microsoft.Inventory.Intrastat;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Reports;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Reports;
using Microsoft.Purchases.Vendor;
using Microsoft.RoleCenters;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Reminder;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Reports;
using System.Automation;
using System.Email;
using System.Environment;
using System.Threading;
using System.Visualization;
using System.Integration.PowerBI;

page 31210 "Accountant CZ Role Center CZL"
{
    Caption = 'Accountant CZ', Comment = 'Use same translation as ''Profile Description'' (if applicable)';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part("Headline RC Accountant"; "Headline RC Accountant")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("Finance Performance"; "Finance Performance")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("Accountant Activities"; "Accountant Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Intercompany Activities"; "Intercompany Activities")
            {
                ApplicationArea = Intercompany;
                Visible = false;
            }
            part("User Tasks Activities"; "User Tasks Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Email Activities"; "Email Activities")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("Approvals Activities"; "Approvals Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Team Member Activities"; "Team Member Activities")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("My Accounts"; "My Accounts")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("My Job Queue"; "My Job Queue")
            {
                ApplicationArea = Basic, Suite;
            }
            part("Help And Chart Wrapper"; "Help And Chart Wrapper")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("Cash Flow Forecast Chart"; "Cash Flow Forecast Chart")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part("Report Inbox Part"; "Report Inbox Part")
            {
                AccessByPermission = tabledata "Report Inbox" = IMD;
                ApplicationArea = Basic, Suite;
            }
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                ApplicationArea = Basic, Suite;
            }
            systempart(MyNotes; MyNotes)
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action("Chart of Accounts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Chart of Accounts';
                RunObject = page "Chart of Accounts";
                ToolTip = 'View or edit chart of accounts.';
            }
            action("Contacts")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Contacts';
                RunObject = page "Contact List";
                ToolTip = 'View or edit contacts.';
            }
            action(Vendors)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = page "Vendor List";
                ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that the vendor grants you if certain conditions are met.';
            }
            action("Purchase Invoices")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Invoices';
                Image = Invoice;
                RunObject = page "Purchase Invoices";
                ToolTip = 'Create purchase invoices to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase invoices dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase invoices can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
            }
            action("Purchase Credit Memos")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Credit Memos';
                RunObject = page "Purchase Credit Memos";
                ToolTip = 'Create purchase credit memos to mirror sales credit memos that vendors send to you for incorrect or damaged items that you have paid for and then returned to the vendor. If you need more control of the purchase return process, such as warehouse documents for the physical handling, use purchase return orders, in which purchase credit memos are integrated. Purchase credit memos can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature. Note: If you have not yet paid for an erroneous purchase, you can simply cancel the posted purchase invoice to automatically revert the financial transaction.';
            }
            action(Customers)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Customers';
                Image = Customer;
                RunObject = page "Customer List";
                ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
            }
            action("Sales Invoices")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Invoices';
                RunObject = page "Sales Invoice List";
                ToolTip = 'Register your sales to customers and invite them to pay according to the delivery and payment terms by sending them a sales invoice document. Posting a sales invoice registers shipment and records an open receivable entry on the customer''s account, which will be closed when payment is received. To manage the shipment process, use sales orders, in which sales invoicing is integrated.';
            }
            action("Sales Credit Memos")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Credit Memos';
                RunObject = page "Sales Credit Memos";
                ToolTip = 'Revert the financial transactions involved when your customers want to cancel a purchase or return incorrect or damaged items that you sent to them and received payment for. To include the correct information, you can create the sales credit memo from the related posted sales invoice or you can create a new sales credit memo with copied invoice information. If you need more control of the sales return process, such as warehouse documents for the physical handling, use sales return orders, in which sales credit memos are integrated. Note: If an erroneous sale has not been paid yet, you can simply cancel the posted sales invoice to automatically revert the financial transaction.';
            }
            action("Incoming Documents")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Incoming Documents';
                Image = Documents;
                RunObject = page "Incoming Documents";
                ToolTip = 'Handle incoming documents, such as vendor invoices in PDF or as image files, that you can manually or automatically convert to document records, such as purchase invoices. The external files that represent incoming documents can be attached at any process stage, including to posted documents and to the resulting vendor, customer, and general ledger entries.';
            }
            action(Reminders)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reminders';
                Image = Reminder;
                RunObject = page "Reminder List";
                ToolTip = 'Remind customers about overdue amounts based on reminder terms and the related reminder levels. Each reminder level includes rules about when the reminder will be issued in relation to the invoice due date or the date of the previous reminder and whether interests are added. Reminders are integrated with finance charge memos, which are documents informing customers of interests or other money penalties for payment delays.';
            }
            action("Finance Charge Memos")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finance Charge Memos';
                Image = FinChargeMemo;
                RunObject = page "Finance Charge Memo List";
                ToolTip = 'Send finance charge memos to customers with delayed payments, typically following a reminder process. Finance charges are calculated automatically and added to the overdue amounts on the customer''s account according to the specified finance charge terms and penalty/interest amounts.';
            }
            action("VAT Returns")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'VAT Returns';
                RunObject = page "VAT Report List";
                ToolTip = 'Prepare the VAT Return report so you can submit VAT amounts to a tax authority.';
                Visible = false;
            }
            action(Budgets)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Budgets';
                RunObject = page "G/L Budget Names";
                ToolTip = 'View or edit estimated amounts for a range of accounting periods.';
            }
            action(Items)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Items';
                RunObject = page "Item List";
                ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions.';
            }
            action(FixedAssets)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Fixed Assets';
                RunObject = page "Fixed Asset List";
                ToolTip = 'Manage periodic depreciation of your machinery or machines, keep track of your maintenance costs, manage insurance policies related to fixed assets, and monitor fixed asset statistics.';
            }
        }
        area(Sections)
        {
            group(Finance)
            {
                Caption = 'Finance';
                Image = Journals;
                ToolTip = 'Collect and make payments, prepare statements, and reconcile bank accounts.';
                action("G/L Account Categories")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Account Categories';
                    RunObject = page "G/L Account Categories";
                    ToolTip = 'Personalize the structure of your financial statements by mapping general ledger accounts to account categories. You can create category groups by indenting subcategories under them. Each grouping shows a total balance. When you choose the Generate Financial Reports action, the row definitions for the underlying financial reports are updated. The next time you run one of these reports, such as the balance statement, new totals and subentries are added, based on your changes.';
                }
                action(Currencies)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Currencies';
                    Image = Currency;
                    RunObject = page Currencies;
                    ToolTip = 'View the different currencies that you trade in or update the exchange rates by getting the latest rates from an external service provider.';
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    RunObject = page Dimensions;
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';
                }
                action(Employees)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Employees';
                    RunObject = page "Employee List";
                    ToolTip = 'View or modify employees'' details and related information, such as qualifications and pictures, or register and analyze employee absence. Keeping up-to-date records about your employees simplifies personnel tasks. For example, if an employee''s address changes, you register this on the employee card.';
                    Visible = false;
                }
                action(Deferrals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Deferrals';
                    RunObject = page "Deferral Template List";
                    ToolTip = 'Distribute revenues or expenses to the relevant accounting periods instead of the date of posting the transaction. Set up a deferral template for the resource, item, or G/L account that the revenue or expense will be posted for. When you post the related sales or purchase document, the revenue or expense is deferred to the involved accounting periods, according to a deferral schedule that is governed by settings in the deferral template and the posting date.';
                }
                action(Partners)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Partners';
                    RunObject = page "IC Partner List";
                    ToolTip = 'Set up each company or department within the group of companies as an intercompany partner of type Vendor or Customer. Intercompany partners can then be inserted on regular sales and purchase documents or journal lines that are exchanged through the intercompany inbox/outbox system and posted to agreed accounts in an intercompany chart of accounts.';
                    Visible = false;
                }
                action("IC Chart of Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'IC Chart of Accounts';
                    RunObject = page "IC Chart of Accounts";
                    ToolTip = 'Manage intercompany transactions within your group of companies in an aligned chart of accounts that uses the same account numbers and settings. In the setup phase, the parent company of the group can create a simplified version of their own chart of accounts and exports it to an XML file that each subsidiary can quickly implement.';
                    Visible = false;
                }
                action("Intercompany Dimensions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Intercompany Dimensions';
                    RunObject = page "IC Dimensions";
                    ToolTip = 'Enable companies within a group to exchange transactions with dimensions and to perform financial analysis by dimensions across the group. The parent company of the group can create a simplified version of their own set of dimensions and export them to an XML file that each subsidiary can import into the intercompany Dimensions window and then map them to their own dimensions.';
                    Visible = false;
                }
                action("Number Series")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Number Series';
                    RunObject = page "No. Series";
                    ToolTip = 'View or edit the number series that are used to organize transactions.';
                }
            }
            group(Journals)
            {
                Caption = 'Journals';
                Image = Journals;
                ToolTip = 'Post financial transactions.';
                action("General Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Journals';
                    Image = Journal;
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(General), Recurring = const(false));
                    ToolTip = 'Post financial transactions directly to general ledger accounts and other accounts, such as bank, customer, vendor, and employee accounts. Posting with a general journal always creates entries on general ledger accounts. This is true even when, for example, you post a journal line to a customer account, because an entry is posted to a general ledger receivables account through a posting group.';
                }
                action("Recurring General Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurring General Journals';
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(General), Recurring = const(true));
                    ToolTip = 'Define how to post transactions that recur with few or no changes to general ledger, bank, customer, vendor, or fixed asset accounts';
                }
                action("Purchase Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Journals';
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Purchases), Recurring = const(false));
                    ToolTip = 'Post any purchase-related transaction directly to a vendor, bank, or general ledger account instead of using dedicated documents. You can post all types of financial purchase transactions, including payments, refunds, and finance charge amounts. Note that you cannot post item quantities with a purchase journal.';
                }
                action("Sales Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Journals';
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Sales), Recurring = const(false));
                    ToolTip = 'Post any sales-related transaction directly to a customer, bank, or general ledger account instead of using dedicated documents. You can post all types of financial sales transactions, including payments, refunds, and finance charge amounts. Note that you cannot post item quantities with a sales journal.';
                }
                action("IC General Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'IC General Journals';
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Intercompany), Recurring = const(false));
                    ToolTip = 'Post intercompany transactions. IC general journal lines must contain either an IC partner account or a customer or vendor account that has been assigned an intercompany partner code.';
                    Visible = false;
                }
                action("Posted General Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted General Journals';
                    RunObject = page "Posted General Journal";
                    ToolTip = 'Open the list of posted general journal lines.';
                }
            }
            group("Cash Management")
            {
                Caption = 'Cash Management';
                action("Bank Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Accounts';
                    Image = BankAccount;
                    RunObject = page "Bank Account List";
                    ToolTip = 'View or set up detailed information about your bank account, such as which currency to use, the format of bank files that you import and export as electronic payments, and the numbering of checks.';
                }
                action(CashReceiptJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Receipt Journals';
                    Image = Journals;
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const("Cash Receipts"), Recurring = const(false));
                    ToolTip = 'Register received payments by manually applying them to the related customer, vendor, or bank ledger entries. Then, post the payments to G/L accounts and thereby close the related ledger entries.';
                    Visible = false;
                }
                action(PaymentJournals)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Journals';
                    Image = Journals;
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Payments), Recurring = const(false));
                    ToolTip = 'Register payments to vendors. A payment journal is a type of general journal that is used to post outgoing payment transactions to G/L, bank, customer, vendor, employee, and fixed assets accounts. The Suggest Vendor Payments functions automatically fills the journal with payments that are due. When payments are posted, you can export the payments to a bank file for upload to your bank if your system is set up for electronic banking. You can also issue computer checks from the payment journal.';
                }
                action("Direct Debit Collections")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Direct Debit Collections';
                    RunObject = page "Direct Debit Collections";
                    ToolTip = 'Instruct your bank to withdraw payment amounts from your customer''s bank account and transfer them to your company''s account. A direct debit collection holds information about the customer''s bank account, the affected sales invoices, and the customer''s agreement, the so-called direct-debit mandate. From the resulting direct-debit collection entry, you can then export an XML file that you send or upload to your bank for processing.';
                    Visible = false;
                }
                action("Payment Recon. Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Recon. Journals';
                    Image = ApplyEntries;
                    RunObject = page "Pmt. Reconciliation Journals";
                    ToolTip = 'Reconcile unpaid documents automatically with their related bank transactions by importing a bank statement feed or file. In the payment reconciliation journal, incoming or outgoing payments on your bank are automatically, or semi-automatically, applied to their related open customer or vendor ledger entries. Any open bank account ledger entries related to the applied customer or vendor ledger entries will be closed when you choose the Post Payments and Reconcile Bank Account action. This means that the bank account is automatically reconciled for payments that you post with the journal.';
                    Visible = false;
                }
                action("Bank Acc. Statements")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Acc. Statements';
                    Image = BankAccountStatement;
                    RunObject = page "Bank Account Statement List";
                    ToolTip = 'View statements for selected bank accounts. For each bank transaction, the report shows a description, an applied amount, a statement amount, and other information.';
                    Visible = false;
                }
                action("Payment Terms")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Terms';
                    Image = Payment;
                    RunObject = page "Payment Terms";
                    ToolTip = 'Set up the payment terms that you select from customer cards or sales documents to define when the customer must pay, such as within 14 days.';
                }
                action(BankAccountReconciliations)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Account Reconciliations';
                    Image = BankAccountRec;
                    RunObject = page "Bank Acc. Reconciliation List";
                    ToolTip = 'Reconcile bank accounts in your system with bank statements received from your bank.';
                    Visible = false;
                }
            }
            group("Fixed Asset")
            {
                Caption = 'Fixed Assets';
                Image = FixedAssets;
                ToolTip = 'Manage depreciation and insurance of your fixed assets.';
                action("Fixed Assets")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fixed Assets';
                    RunObject = page "Fixed Asset List";
                    ToolTip = 'Manage periodic depreciation of your machinery or machines, keep track of your maintenance costs, manage insurance policies related to fixed assets, and monitor fixed asset statistics.';
                }
                action("Fixed Assets G/L Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fixed Assets G/L Journals';
                    RunObject = page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Assets),
                                        Recurring = const(false));
                    ToolTip = 'Post fixed asset transactions, such as acquisition and depreciation, in integration with the general ledger. The FA G/L Journal is a general journal, which is integrated into the general ledger.';
                }
                action("Fixed Assets Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fixed Assets Journals';
                    RunObject = page "FA Journal Batches";
                    RunPageView = where(Recurring = const(false));
                    ToolTip = 'Post fixed asset transactions, such as acquisition and depreciation book without integration to the general ledger.';
                }
                action("Fixed Assets Reclass. Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fixed Assets Reclass. Journals';
                    RunObject = page "FA Reclass. Journal Batches";
                    ToolTip = 'Transfer, split, or combine fixed assets by preparing reclassification entries to be posted in the fixed asset journal.';
                }
                action("FA Registers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'FA Registers';
                    Image = GLRegisters;
                    RunObject = page "FA Registers";
                    ToolTip = 'View posted FA ledger entries.';
                }
                action(Insurance)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insurance';
                    RunObject = page "Insurance List";
                    ToolTip = 'Manage insurance policies for fixed assets and monitor insurance coverage.';
                }
                action("Insurance Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insurance Journals';
                    RunObject = page "Insurance Journal Batches";
                    ToolTip = 'Post entries to the insurance coverage ledger.';
                }
                action("Recurring Fixed Asset Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Recurring Fixed Asset Journals';
                    RunObject = page "FA Journal Batches";
                    RunPageView = where(Recurring = const(true));
                    ToolTip = 'Post recurring fixed asset transactions, such as acquisition and depreciation book without integration to the general ledger.';
                }
            }
            group("Posted Documents")
            {
                Caption = 'Posted Documents';
                Image = FiledPosted;
                ToolTip = 'View the posting history for sales, shipments, and inventory.';
                action("Posted Purchase Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Invoices';
                    RunObject = page "Posted Purchase Invoices";
                    ToolTip = 'Open the list of posted purchase invoices.';
                }
                action("Posted Purchase Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = page "Posted Purchase Credit Memos";
                    ToolTip = 'Open the list of posted purchase credit memos.';
                }
                action("Posted Sales Invoices")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action("Posted Sales Credit Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
                action("Issued Reminders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issued Reminders';
                    Image = OrderReminder;
                    RunObject = page "Issued Reminder List";
                    ToolTip = 'Open the list of issued reminders.';
                }
                action("Issued Fin. Charge Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Issued Fin. Charge Memos';
                    Image = PostedMemo;
                    RunObject = page "Issued Fin. Charge Memo List";
                    ToolTip = 'Open the list of issued finance charge memos.';
                }
            }
            group("Cash Flow")
            {
                Caption = 'Cash Flow';
                Image = CashFlow;
                ToolTip = 'View the cash flow forecasts, chart of accounts and revenues and expenses.';
                action("Cash Flow Forecasts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Forecasts';
                    RunObject = page "Cash Flow Forecast List";
                    ToolTip = 'Combine various financial data sources to find out when a cash surplus or deficit might happen or whether you should pay down debt, or borrow to meet upcoming expenses.';
                }
                action("Chart of Cash Flow Accounts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Chart of Cash Flow Accounts';
                    RunObject = page "Chart of Cash Flow Accounts";
                    ToolTip = 'View a chart contain a graphical representation of one or more cash flow accounts and one or more cash flow setups for the included general ledger, purchase, sales, services, or fixed assets accounts.';
                }
                action("Cash Flow Manual Revenues")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Manual Revenues';
                    RunObject = page "Cash Flow Manual Revenues";
                    ToolTip = 'Record manual revenues, such as rental income, interest from financial assets, or new private capital to be used in cash flow forecasting.';
                }
                action("Cash Flow Manual Expenses")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Manual Expenses';
                    RunObject = page "Cash Flow Manual Expenses";
                    ToolTip = 'Record manual expenses, such as salaries, interest on credit, or planned investments to be used in cash flow forecasting.';
                }
            }
            group("Cost Accounting")
            {
                Caption = 'Cost Accounting';
                ToolTip = 'Allocate actual and budgeted costs of operations, departments, products, and projects to analyze the profitability of your company.';
                action("Cost Types")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Types';
                    RunObject = page "Chart of Cost Types";
                    ToolTip = 'View the chart of cost types with a structure and functionality that resembles the general ledger chart of accounts. You can transfer the general ledger income statement accounts or create your own chart of cost types.';
                }
                action("Cost Centers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Centers';
                    RunObject = page "Chart of Cost Centers";
                    ToolTip = 'Manage cost centers, which are departments and profit centers that are responsible for costs and income. Often, there are more cost centers set up in cost accounting than in any dimension that is set up in the general ledger. In the general ledger, usually only the first level cost centers for direct costs and the initial costs are used. In cost accounting, additional cost centers are created for additional allocation levels.';
                }
                action("Cost Objects")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Objects';
                    RunObject = page "Chart of Cost Objects";
                    ToolTip = 'Set up cost objects, which are products, product groups, or services of a company. These are the finished goods of a company that carry the costs. You can link cost centers to departments and cost objects to projects in your company.';
                }
                action("Cost Allocations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Allocations';
                    RunObject = page "Cost Allocation Sources";
                    ToolTip = 'Manage allocation rules to allocate costs and revenues between cost types, cost centers, and cost objects. Each allocation consists of an allocation source and one or more allocation targets. For example, all costs for the cost type Electricity and Heating are an allocation source. You want to allocate the costs to the cost centers Workshop, Production, and Sales, which are three allocation targets.';
                }
                action("Cost Budgets")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Budgets';
                    RunObject = page "Cost Budget Names";
                    ToolTip = 'Set up cost accounting budgets that are created based on cost types just as a budget for the general ledger is created based on general ledger accounts. A cost budget is created for a certain period of time, for example, a fiscal year. You can create as many cost budgets as needed. You can create a new cost budget manually, or by importing a cost budget, or by copying an existing cost budget as the budget base.';
                }
                action("Cost Accounting Registers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Accounting Registers';
                    RunObject = page "Cost Registers";
                    ToolTip = 'View auditing details for all cost accounting entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
            }
        }
        area(Creation)
        {
            action("Purchase Invoice")
            {
                AccessByPermission = tabledata "Purchase Header" = IMD;
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Invoice';
                RunObject = page "Purchase Invoice";
                RunPageMode = Create;
                ToolTip = 'Create a new purchase invoice.';
            }
            action("Purchase Credit Memo")
            {
                AccessByPermission = tabledata "Purchase Header" = IMD;
                ApplicationArea = Basic, Suite;
                Caption = 'Purchase Credit Memo';
                RunObject = page "Purchase Credit Memo";
                RunPageMode = Create;
                ToolTip = 'Create a new purchase credit memo.';
            }
            action("Sales Invoice")
            {
                AccessByPermission = tabledata "Sales Header" = IMD;
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Invoice';
                RunObject = page "Sales Invoice";
                RunPageMode = Create;
                ToolTip = 'Create a new sales invoice.';
            }
            action("Sales Credit Memo")
            {
                AccessByPermission = tabledata "Sales Header" = IMD;
                ApplicationArea = Basic, Suite;
                Caption = 'Sales Credit Memo';
                RunObject = page "Sales Credit Memo";
                RunPageMode = Create;
                ToolTip = 'Create a new sales credit memo.';
            }
            action("G/L Journal Entry")
            {
                AccessByPermission = tabledata "G/L Entry" = IMD;
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Journal Entry';
                RunObject = page "General Journal";
                ToolTip = 'Prepare to post any transaction to the company books.';
            }
        }
        area(Processing)
        {
            group(Analysis)
            {
                Caption = 'Analysis';
                action("Analysis Views")
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Analysis Views';
                    Image = AnalysisView;
                    RunObject = page "Analysis View List";
                    ToolTip = 'Analyze amounts in your general ledger by their dimensions using analysis views that you have set up.';
                }
                action("Account Schedules")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Financial Reporting';
                    Image = CalculateBalanceAccount;
                    RunObject = page "Financial Reports";
                    ToolTip = 'Get insight into the financial data stored in your chart of accounts. Financial reports analyze figures in G/L accounts, and compare general ledger entries with general ledger budget entries. For example, you can view the general ledger entries as percentages of the budget entries. Financial reports provide the data for core financial statements and views, such as the Cash Flow chart.';
                }
            }
            group(Tasks)
            {
                Caption = 'Tasks';
                action("Calculate Depreciation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Calculate Depreciation';
                    Ellipsis = true;
                    Image = CalculateDepreciation;
                    RunObject = report "Calculate Depreciation";
                    ToolTip = 'Calculate depreciation according to the conditions that you define. If the fixed assets that are included in the batch job are integrated with the general ledger (defined in the depreciation book that is used in the batch job), the resulting entries are transferred to the fixed assets general ledger journal. Otherwise, the batch job transfers the entries to the fixed asset journal. You can then post the journal or adjust the entries before posting, if necessary.';
                }
                action("Bank Account Reconciliation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Account Reconciliation';
                    Image = BankAccountRec;
                    RunObject = page "Bank Acc. Reconciliation";
                    ToolTip = 'View the entries and the balance on your bank accounts against a statement from the bank.';
                    Visible = false;
                }
                action("Payment Reconciliation Journals")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Payment Reconciliation Journals';
                    Image = ApplyEntries;
                    RunObject = page "Pmt. Reconciliation Journals";
                    RunPageMode = View;
                    ToolTip = 'Reconcile unpaid documents automatically with their related bank transactions by importing a bank statement feed or file. In the payment reconciliation journal, incoming or outgoing payments on your bank are automatically, or semi-automatically, applied to their related open customer or vendor ledger entries. Any open bank account ledger entries related to the applied customer or vendor ledger entries will be closed when you choose the Post Payments and Reconcile Bank Account action. This means that the bank account is automatically reconciled for payments that you post with the journal.';
                    Visible = false;
                }
                action("Adjust Cost - Item Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Adjust Cost - Item Entries';
                    Ellipsis = true;
                    Image = AdjustEntries;
                    RunObject = report "Adjust Cost - Item Entries";
                    ToolTip = 'Adjust inventory values in value entries so that you use the correct adjusted cost for updating the general ledger and so that sales and profit statistics are up to date.';
                }
                action("Post Inventory Cost to G/L")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Post Inventory Cost to G/L';
                    Ellipsis = true;
                    Image = PostInventoryToGL;
                    RunObject = report "Post Inventory Cost to G/L";
                    ToolTip = 'Record the quantity and value changes to the inventory in the item ledger entries and the value entries when you post inventory transactions, such as sales shipments or purchase receipts.';
                }
                action("Create Reminders")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create Reminders';
                    Ellipsis = true;
                    Image = CreateReminders;
                    RunObject = report "Create Reminders";
                    ToolTip = 'Create reminders for one or more customers with overdue payments.';
                }
                action("Create Finance Charge Memos")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create Finance Charge Memos';
                    Ellipsis = true;
                    Image = CreateFinanceChargememo;
                    RunObject = report "Create Finance Charge Memos";
                    ToolTip = 'Create finance charge memos for one or more customers with overdue payments.';
                }
                action("Import Tariff Numbers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Tariff Numbers';
                    Ellipsis = true;
                    Image = XMLFile;
                    RunObject = report "Import Tariff Numbers XML CZL";
                    ToolTip = 'Run import tariff numbers in XML format.';
                }
            }
            group(VAT)
            {
                Caption = 'VAT';
                action("VAT Statements")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Statements';
                    Image = VATStatement;
                    RunObject = page "VAT Statement Names";
                    ToolTip = 'View a statement of posted VAT amounts, calculate your VAT settlement amount for a certain period, such as a quarter, and prepare to send the settlement to the tax authorities.';
                }
                action("VAT Control Reports")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Control Reports';
                    Image = PrintVAT;
                    RunObject = page "VAT Ctrl. Report List CZL";
                    ToolTip = 'View a VAT control reports.';
                }
                action("VIES Declarations")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VIES Declarations';
                    Image = BulletList;
                    RunObject = page "VIES Declarations CZL";
                    ToolTip = 'View a VIES declarations.';
                }
                action("VAT Control Report Sections")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Control Report Sections';
                    Image = SetupList;
                    RunObject = page "VAT Ctrl. Report Sections CZL";
                    ToolTip = 'View and set sections for VAT control reports.';
                }
                action("VAT Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Entries';
                    Image = VATLedger;
                    RunObject = page "VAT Entries";
                    ToolTip = 'Views all VAT entries.';
                }
                action("VAT Periods")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Periods';
                    RunObject = page "VAT Periods CZL";
                    Image = Period;
                    ToolTip = 'View and set VAT periods.';
                }
                action("Get All Unreliable Payers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Get All Unreliable Payers';
                    RunObject = report "Unreliable Payer Get All CZL";
                    Ellipsis = true;
                    Image = LinkWeb;
                    ToolTip = 'Run batch import to get unreliable payer status for all vendors.';
                }
                action("Calc. and Post VAT Settlement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Calc. and Post VAT Settlement';
                    Image = SettleOpenTransactions;
                    RunObject = report "Calc. and Post VAT Settlement";
                    Ellipsis = true;
                    ToolTip = 'Close open VAT entries and transfers purchase and sales VAT amounts to the VAT settlement account. For every VAT posting group, the batch job finds all the VAT entries in the VAT Entry table that are included in the filters in the definition window.';
                }
                action("Non-Deductible VAT Setup CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Non-Deductible VAT Setup';
                    Image = VATPostingSetup;
                    RunObject = page "Non-Deductible VAT Setup CZL";
                    ToolTip = 'Set up VAT coefficient correction.';
                }
                action("VAT Coeff. Correction CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Coefficient Correction';
                    Image = AdjustVATExemption;
                    RunObject = report "VAT Coeff. Correction CZL";
                    ToolTip = 'The report recalculate the value of non-deductible VAT according to settlement coeffiecient on VAT entries.';
                }
                action("VAT Return Period List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Return Periods';
                    Image = Period;
                    RunObject = page "VAT Return Period List";
                    Tooltip = 'Open the VAT return periods page.';
                }
                action("VAT Report List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Returns';
                    Image = VATStatement;
                    RunObject = Page "VAT Report List";
                    ToolTip = 'Prepare the VAT Return report so you can submit VAT amounts to a tax authority.';
                }
            }
            group(History)
            {
                Caption = 'History';
                action(Navigate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Find Entries';
                    Image = Navigate;
                    Ellipsis = true;
                    RunObject = page Navigate;
                    ShortcutKey = 'Ctrl+Alt+Q';
                    ToolTip = 'Find entries and documents that exist for the document number and posting date on the selected document. (Formerly this action was named Navigate.)';
                }
                action("G/L Registers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Registers';
                    Image = GLRegisters;
                    RunObject = page "G/L Registers";
                    ToolTip = 'View auditing details for all general ledger entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
                action("Cost Accounting Budget Registers")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Accounting Budget Registers';
                    Image = Register;
                    RunObject = page "Cost Budget Registers";
                    ToolTip = 'View auditing details for all cost accounting budget entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                    Visible = false;
                }
                action("General Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Ledger Entries';
                    Image = GeneralLedger;
                    RunObject = page "General Ledger Entries";
                    ToolTip = 'View all general ledger entries.';
                }
                action("Vendor Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Ledger Entries';
                    Image = VendorLedger;
                    RunObject = page "Vendor Ledger Entries";
                    ToolTip = 'View all vendor ledger entries.';
                }
                action("Customer Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer Ledger Entries';
                    Image = CustomerLedger;
                    RunObject = page "Customer Ledger Entries";
                    ToolTip = 'View all customer ledger entries.';
                }
                action("FA Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fixed Asset Ledger Entries';
                    Image = FixedAssetLedger;
                    RunObject = page "FA Ledger Entries";
                    ToolTip = 'View all fixed asset ledger entries.';
                }
                action("Item Ledger Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Ledger Entries';
                    Image = ItemLedger;
                    RunObject = page "Item Ledger Entries";
                    ToolTip = 'View all item ledger entries.';
                }
                action("Value Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Value Entries';
                    Image = ItemLedger;
                    RunObject = page "Value Entries";
                    ToolTip = 'View all value entries.';
                }
                action("EET Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'EET Entries';
                    Image = Entries;
                    RunObject = page "EET Entries CZL";
                    ToolTip = 'View all item ledger entries.';
                }
            }
            group("Fiscal Year")
            {
                Caption = 'Fiscal Year';
                action("Adjust Exchange Rates")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Adjust Exchange Rates';
                    Ellipsis = true;
                    Image = AdjustExchangeRates;
                    RunObject = codeunit "Exch. Rate Adjmt. Run Handler";
                    ToolTip = 'Adjust general ledger, customer, vendor, and bank account entries to reflect a more updated balance if the exchange rate has changed since the entries were posted.';
                }
                action("Accounting Periods")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Accounting Periods';
                    Image = AccountingPeriods;
                    RunObject = page "Accounting Periods";
                    ToolTip = 'Set up the number of accounting periods, such as 12 monthly periods, within the fiscal year and specify which period is the start of the new fiscal year.';
                }
                action("Close Income Statement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Close Income Statement';
                    Image = CloseYear;
                    RunObject = report "Close Income Statement";
                    Ellipsis = true;
                    ToolTip = 'Run batch to close income statement.';
                }
                action("Open Balance Sheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open Balance Sheet';
                    Image = CreateYear;
                    RunObject = report "Open Balance Sheet CZL";
                    Ellipsis = true;
                    ToolTip = 'Run batch to open balance sheet.';
                }
                action("Close Balance Sheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Close Balance Sheet';
                    Image = CloseYear;
                    RunObject = report "Close Balance Sheet CZL";
                    Ellipsis = true;
                    ToolTip = 'Run batch to close balance sheet.';
                }
                action("Run Consolidation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Run Consolidation';
                    Ellipsis = true;
                    Image = ImportDatabase;
                    RunObject = report "Import Consolidation from DB";
                    ToolTip = 'Run the Consolidation report.';
                    Visible = false;
                }
            }
        }
        area(Reporting)
        {
            group("General Ledger Reports")
            {
                Caption = 'General Ledger Reports';
                action("Turnover Report by Global Dimensions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Turnover Report by Global Dimensions';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Turnover Rpt. by Gl. Dim. CZL";
                    ToolTip = 'View, print, or send the turnover report by global dimensions.';
                }
                action("G/L Trial Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'G/L Trial Balance';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Trial Balance";
                    ToolTip = 'View, print, or send a report that shows the balances for the general ledger accounts, including the debits and credits. You can use this report to ensure accurate accounting practices.';
                }
                action("Detail Trial Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Detail Trial Balance';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Detail Trial Balance";
                    ToolTip = 'View, print, or send a report that shows a detailed trial balance for general ledger accounts. You can use the report at the close of an accounting period or fiscal year.';
                }
                action("General Ledger")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Ledger';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "General Ledger CZL";
                    ToolTip = 'View, print, or send the general ledger report.';
                }
                action("General Journal")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Journal';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "General Journal CZL";
                    ToolTip = 'View, print, or send the general journal report.';
                }
                action("General Ledger Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'General Ledger Document';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "General Ledger Document CZL";
                    ToolTip = 'View, print, or send the general ledger document report.';
                }
                action("Accounting Sheets")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Accounting Sheets';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Accounting Sheets CZL";
                    ToolTip = 'View, print, or send the accounting sheets report.';
                    Visible = false;
                }
                action("Balance Sheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance Sheet';
                    Image = Report;
                    RunObject = report "Balance Sheet CZL";
                    ToolTip = 'View a report that shows your company''s assets, liabilities, and equity.';
                    Visible = false;
                }
                action("Income Statement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Income Statement';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Income Statement CZL";
                    ToolTip = 'View a report that shows your company''s income and expenses.';
                    Visible = false;
                }
                action(Budget)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Budget';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report Budget;
                    ToolTip = 'View or edit estimated amounts for a range of accounting periods.';
                    Visible = false;
                }
                action("Trial Balance/Budget")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Trial Balance/Budget';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Trial Balance/Budget";
                    ToolTip = 'View a trial balance in comparison to a budget. You can choose to see a trial balance for selected dimensions. You can use the report at the close of an accounting period or fiscal year.';
                    Visible = false;
                }
                action("Trial Balance by Period")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Trial Balance by Period';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Trial Balance by Period";
                    ToolTip = 'Show the opening balance by general ledger account, the movements in the selected period of month, quarter, or year, and the resulting closing balance.';
                    Visible = false;
                }
                action("Fiscal Year Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Fiscal Year Balance';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Fiscal Year Balance";
                    ToolTip = 'View, print, or send a report that shows balance sheet movements for selected periods. The report shows the closing balance by the end of the previous fiscal year for the selected ledger accounts. It also shows the fiscal year until this date, the fiscal year by the end of the selected period, and the balance by the end of the selected period, excluding the closing entries. The report can be used at the close of an accounting period or fiscal year.';
                    Visible = false;
                }
                action("Balance Comp. - Prev. Year")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Balance Comp. - Prev. Year';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Balance Comp. - Prev. Year";
                    ToolTip = 'View a report that shows your company''s assets, liabilities, and equity compared to the previous year.';
                    Visible = false;
                }
                action("Closing Trial Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Closing Trial Balance';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Closing Trial Balance";
                    ToolTip = 'View, print, or send a report that shows this year''s and last year''s figures as an ordinary trial balance. The closing of the income statement accounts is posted at the end of a fiscal year. The report can be used in connection with closing a fiscal year.';
                    Visible = false;
                }
                action("Dimensions - Total")
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions - Total';
                    Image = Report;
                    RunObject = report "Dimensions - Total";
                    ToolTip = 'View how dimensions or dimension sets are used on entries based on total amounts over a specified period and for a specified analysis view.';
                    Visible = false;
                }
            }
            group("Cash Management Reports")
            {
                Caption = 'Cash Management Reports';
                action("Reconcile Bank Account Entry")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reconcile Bank Account Entry';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Recon. Bank Account Entry CZL";
                    ToolTip = 'View, print, or send the reconciliaion bank account entry report.';
                }
                action("Bank Detail Trial Balance")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bank Detail Trial Balance';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Bank Acc. - Detail Trial Bal.";
                    ToolTip = 'View, print, or send a report that shows a detailed trial balance for selected bank accounts. You can use the report at the close of an accounting period or fiscal year.';
                    Visible = false;
                }
            }
            group("VAT Reports")
            {
                Caption = 'VAT Reports';
                action("Documentation for VAT")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Documentation for VAT';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Documentation for VAT CZL";
                    ToolTip = 'View, print, or send the documentation for VAT report.';
                }
                action("VAT Documents List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Documents List';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "VAT Documents List CZL";
                    ToolTip = 'View, print, or send the VAT documents list report.';
                }
                action("VAT Reconciliation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Reconciliation';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "G/L VAT Reconciliation CZL";
                    ToolTip = 'View, print, or send the G/L VAT reconciliation report.';
                }
                action("Unreliable Payer List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Unreliable Payer List';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Unreliable Payer List CZL";
                    ToolTip = 'View, print, or send the list of unreliable VAT payers.';
                }
                action("VAT Registration No. Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Registration No. Check';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "VAT Registration No. Check";
                    ToolTip = 'Use an EU VAT number validation service to validated the VAT number of a business partner.';
                }
                action("VAT Statement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Statement';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "VAT Statement";
                    ToolTip = 'View a statement of posted VAT and calculate the duty liable to the customs authorities for the selected period.';
                }
                action("VAT Exceptions")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Exceptions';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "VAT Exceptions";
                    ToolTip = 'View the VAT entries that were posted and placed in a general ledger register in connection with a VAT difference. The report is used to document adjustments made to VAT amounts that were calculated for use in internal or external auditing.';
                    Visible = false;
                }
                action("VAT - VIES Declaration Tax Auth")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT - VIES Declaration Tax Auth';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "VAT- VIES Declaration Tax Auth";
                    ToolTip = 'View information to the customs and tax authorities for sales to other EU countries/regions. If the information must be printed to a file, you can use the VAT- VIES Declaration Disk report.';
                    Visible = false;
                }
                action("EC Sales List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'EC Sales List';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "EC Sales List";
                    ToolTip = 'Calculate VAT amounts from sales, and submit the amounts to a tax authority.';
                    Visible = false;
                }
            }
            group("Payable Reports")
            {
                Caption = 'Payable Reports';
                action("Open Vendor Entries at Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open Vendor Entries at Date';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Open Vend. Entries to Date CZL";
                    ToolTip = 'View, print, or send the open vendor entries to date report.';
                }
                action("Vendor Balance Reconciliation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Balance Reconciliation';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Vendor-Bal. Reconciliation CZL";
                    ToolTip = 'View, print, or send the vendor balance reconciliation report.';
                }
                action("Vendor - Top 10")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor - Top 10';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Vendor - Top 10 List";
                    ToolTip = 'View, print, or send the vendor - top 10 report.';
                }
                action("Quantity Received Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity Received Check';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Quantity Received Check CZL";
                    ToolTip = 'View, print, or send the quantity received check report.';
                }
                action("Aged Accounts Payable")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Aged Accounts Payable';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Aged Accounts Payable";
                    ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                    Visible = false;
                }
            }
            group("Receivable Reports")
            {
                Caption = 'Receivable Reports';
                action("Open Customer Entries at Date")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open Customer Entries at Date';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Open Cust. Entries to Date CZL";
                    ToolTip = 'View, print, or send the open customer entries to date report.';
                }
                action("Customer Balance Reconciliation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer Balance Reconciliation';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Cust.- Bal. Reconciliation CZL";
                    ToolTip = 'View, print, or send the customer balance reconciliation report.';
                }
                action("Customer - Top 10")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer - Top 10';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Customer - Top 10 List";
                    ToolTip = 'View, print, or send the customer - top 10 report.';
                }
                action("Quantity Shipped Check")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Quantity Shipped Check';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Quantity Shipped Check CZL";
                    ToolTip = 'View, print, or send the quantity shipped check report.';
                }
                action("Aged Accounts Receivable")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Aged Accounts Receivable';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Aged Accounts Receivable";
                    ToolTip = 'View an overview of when your receivables from customers are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
                    Visible = false;
                }
            }
            group("Inventory Reports")
            {
                Caption = 'Inventory Reports';
                action("Inventory Valuation")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Inventory Valuation';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Inventory Valuation";
                    ToolTip = 'View, print, or send the inventory valuation report.';
                }
                action("Posted Inventory Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Inventory Document';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Posted Inventory Document CZL";
                    ToolTip = 'View, print, or send the posted inventory document report.';
                }
                action("Physical Inventory Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Physical Inventory Document';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Phys. Inventory Document CZL";
                    ToolTip = 'View, print, or send the physical inventory document report.';
                }
            }
            group("Fixed Asset Reports")
            {
                Caption = 'Fixed Asset Reports';
            }
            group("Other Reports")
            {
                Caption = 'Other Reports';
                action("Reconcile Cust. and Vend. Accs")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reconcile Cust. and Vend. Accs';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Reconcile Cust. and Vend. Accs";
                    ToolTip = 'View if a certain general ledger account reconciles the balance on a certain date for the corresponding posting group. The report shows the accounts that are included in the reconciliation with the general ledger balance and the customer or the vendor ledger balance for each account and shows any differences between the general ledger balance and the customer or vendor ledger balance.';
                    Visible = false;
                }
                action("Statement of Cash Flows")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statement of Cash Flows';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Statement of Cashflows";
                    ToolTip = 'View a financial statement that shows how changes in balance sheet accounts and income affect the company''s cash holdings, displayed for operating, investing, and financing activities respectively.';
                }
                action("Cash Flow Date List")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cash Flow Date List';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Cash Flow Date List";
                    ToolTip = 'View forecast entries for a period of time that you specify. The registered cash flow forecast entries are organized by source types, such as receivables, sales orders, payables, and purchase orders. You specify the number of periods and their length.';
                }
                action("Statement of Retained Earnings")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Statement of Retained Earnings';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Retained Earnings Statement";
                    ToolTip = 'View a report that shows your company''s changes in retained earnings for a specified period by reconciling the beginning and ending retained earnings for the period, using information such as net income from the other financial statements.';
                }
                action("Cost Accounting P/L Statement")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Accounting P/L Statement';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Cost Acctg. Statement";
                    ToolTip = 'View the credit and debit balances per cost type, together with the chart of cost types.';
                }
                action("CA P/L Statement per Period")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CA P/L Statement per Period';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Cost Acctg. Stmt. per Period";
                    ToolTip = 'View profit and loss for cost types over two periods with the comparison as a percentage.';
                }
                action("CA P/L Statement with Budget")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'CA P/L Statement with Budget';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Cost Acctg. Statement/Budget";
                    ToolTip = 'View a comparison of the balance to the budget figures and calculates the variance and the percent variance in the current accounting period, the accumulated accounting period, and the fiscal year.';
                }
                action("Cost Accounting Analysis")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cost Accounting Analysis';
                    Ellipsis = true;
                    Image = Report;
                    RunObject = report "Cost Acctg. Analysis";
                    ToolTip = 'View balances per cost type with columns for seven fields for cost centers and cost objects. It is used as the cost distribution sheet in Cost accounting. The structure of the lines is based on the chart of cost types. You define up to seven cost centers and cost objects that appear as columns in the report.';
                }
            }
        }
    }
}
