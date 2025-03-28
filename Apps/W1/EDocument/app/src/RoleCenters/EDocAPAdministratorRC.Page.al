namespace Microsoft.eServices.EDocument;

using System.Automation;
using Microsoft.Intercompany;
using Microsoft.RoleCenters;
using Microsoft.Purchases.Reports;
using System.Threading;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Purchases.Setup;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item.Catalog;

page 6101 "E-Doc. A/P Administrator RC"
{
    Caption = 'E-Doc. A/P Administrator';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(HeadlineRCAPAdministtrator; "E-Doc. Headline RC A/P Admin")
            {
                ApplicationArea = Basic, Suite;
            }
            part(EDocAPAdministratorActivities; "E-Doc. A/P Admin Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            // part(O365Activities; "O365 Activities")
            // {
            //     // AccessByPermission = TableData "Activities Cue" = I;
            //     ApplicationArea = Basic, Suite;
            // }
            part(ApprovalsActivities; "Approvals Activities")
            {
                ApplicationArea = Suite;
            }
            part("Intercompany Activities"; "Intercompany Activities")
            {
                ApplicationArea = Intercompany;
            }
            part(JobQueueActivities; "Job Queue Activities")
            {
                ApplicationArea = Basic, Suite;
            }
            part(TeamMemberActvities; "Team Member Activities No Msgs")
            {
                ApplicationArea = Suite;
            }
            part("Report Inbox Part"; "Report Inbox Part")
            {
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(Vendors)
            {
                Caption = 'Vendors';
                ToolTip = 'View and manage vendors.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Vendor List";
            }
            action(PurchaseOrders)
            {
                Caption = 'Purchase Orders';
                ToolTip = 'View and manage purchase orders.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Purchase Orders";
            }
            action(PurchaseInvoices)
            {
                Caption = 'Purchase Invoices';
                ToolTip = 'View and manage purchase invoices.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Purchase Invoices";
            }
            action(PurchaseCreditMemos)
            {
                Caption = 'Purchase Credit Memos';
                ToolTip = 'View and manage purchase credit memos.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Purchase Credit Memos";
            }
            action(PurchaseReturnOrders)
            {
                Caption = 'Purchase Return Orders';
                ToolTip = 'View and manage purchase return orders.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Purchase Return Orders";
            }
        }
        area(Sections)
        {
            group(PostedDocuments)
            {
                Caption = 'Posted Documents';

                action("Posted Purchase Invoices")
                {
                    Caption = 'Posted Purchase Invoices';
                    ToolTip = 'View and manage posted purchase invoices.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Posted Purchase Invoices";
                }
                action("Posted Purchase Credit Memos")
                {
                    Caption = 'Posted Purchase Credit Memos';
                    ToolTip = 'View and manage posted purchase credit memos.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Posted Purchase Credit Memos";
                }
            }
            group(ViewPurchaseDocuments)
            {
                Caption = 'Purchase Documents';

                action("Purchase Quotes")
                {
                    Caption = 'Purchase Quotes';
                    ToolTip = 'View and manage purchase quotes.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Quotes";
                }
                action("Purchase Orders")
                {
                    Caption = 'Purchase Orders';
                    ToolTip = 'View and manage purchase orders.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Orders";
                }
                action("Purchase Invoices")
                {
                    Caption = 'Purchase Invoices';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Invoices";
                    ToolTip = 'View and manage purchase invoices.';
                }
                action("Purchase Credit Memos")
                {
                    Caption = 'Purchase Credit Memos';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Credit Memos";
                    ToolTip = 'View and manage purchase credit memos.';
                }
            }
            group(IncommingDocuments)
            {
                Caption = 'Incoming Documents';

                action("Incoming Documents")
                {
                    Caption = 'Incoming Documents';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Incoming Documents";
                    ToolTip = 'Handle incoming documents, such as vendor invoices in PDF or as image files, that you can manually or automatically convert to document records, such as purchase invoices. The external files that represent incoming documents can be attached at any process stage, including to posted documents and to the resulting vendor, customer, and general ledger entries.';
                }
            }
            group(SectionReports)
            {
                Caption = 'Reports';

                action("Purchase Statistics")
                {
                    Caption = 'Purchase Statistics';
                    ApplicationArea = Basic, Suite;
                    RunObject = Report "Purchase Statistics";
                    ToolTip = 'Run the Purchase Statistics report.';
                }
            }
        }
        area(Creation)
        {
            action(CreateVendor)
            {
                Caption = 'Create Vendor';
                ToolTip = 'Create a new vendor.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Vendor Card";
                RunPageMode = Create;
            }
            action(CreatePayment)
            {
                Caption = 'Create Payment (placeholder)';
                ToolTip = 'Create a new payment.';
                ApplicationArea = Basic, Suite;
                RunObject = Page "Payment Journal";
                RunPageMode = Create;
            }
            group(CreatePurchaseDocuments)
            {
                Caption = 'Purchase Documents';

                action("Create Purchase Order")
                {
                    Caption = 'Create Purchase Order';
                    ToolTip = 'Create a new purchase order.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Order";
                    RunPageMode = Create;
                }
                action("Create Purchase Invoice")
                {
                    Caption = 'Create Purchase Invoice';
                    ToolTip = 'Create a new purchase invoice.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Invoice";
                    RunPageMode = Create;
                }
                action("Create Purchase Credit Memo")
                {
                    Caption = 'Create Purchase Credit Memo';
                    ToolTip = 'Create a new purchase credit memo.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Credit Memo";
                    RunPageMode = Create;
                }
                action("Create Purchase Return Order")
                {
                    Caption = 'Create Purchase Return Order';
                    ToolTip = 'Create a new purchase return order.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Return Order";
                    RunPageMode = Create;
                }
                // TODO: Uncomment when the page is available
                // action("Create Contract")
                // {
                //     Caption = 'Create Contract';
                //     ToolTip = 'Create a new contract.';
                //     ApplicationArea = Basic, Suite;
                //     RunObject = Page "Contract";
                //     RunPageMode = Create;
                // }
            }
        }
        area(Processing)
        {
            group(Journals)
            {
                Caption = 'Journals';

                action("Payment Reconciliation Journal")
                {
                    Caption = 'Payment Reconciliation Journal';
                    ToolTip = 'Open payment reconciliation journal.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Payment Reconciliation Journal";
                }
                action("Purchase Journal")
                {
                    Caption = 'Purchase Journal';
                    ToolTip = 'Post any purchase transaction for the vendor.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchase Journal";
                }
                action("Payment Journal")
                {
                    Caption = 'Payment Journal';
                    ToolTip = 'Pay your vendors by filling the payment journal automatically according to payments due, and potentially export all payment to your bank for automatic processing.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Payment Journal";
                }
                action("General Journal")
                {
                    Caption = 'General Journal';
                    ToolTip = 'Prepare to post any transaction to the company books.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "General Journal";
                }
            }
            group(Setup)
            {
                Caption = 'Setup';

                action(PurchAndPayablesSetup)
                {
                    Caption = 'Purchases & Payables Setup';
                    ToolTip = 'Set up the purchasing and payables features.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchases & Payables Setup";
                }
                action(GeneralLedgerSetup)
                {
                    Caption = 'General Ledger Setup';
                    ToolTip = 'Set up the general ledger features.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "General Ledger Setup";
                }
                action(StandardPurchaseCodes)
                {
                    Caption = 'Standard Purchase Codes';
                    ToolTip = 'Set up standard purchase codes.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Standard Purchase Codes";
                }
                action(PurchasingCodes)
                {
                    Caption = 'Purchasing Codes';
                    ToolTip = 'Set up purchasing codes.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Page "Purchasing Codes";
                }
            }
            group(ActionBarReports)
            {
                Caption = 'Reports';

                action("Aged Accounts Payable")
                {
                    Caption = 'Aged Accounts Payable';
                    ToolTip = 'View the aged accounts payable report.';
                    ApplicationArea = Basic, Suite;
                    RunObject = Report "Aged Accounts Payable";
                }
            }

        }
    }
}