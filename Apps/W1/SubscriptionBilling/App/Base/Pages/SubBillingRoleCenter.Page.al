namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Purchases.Vendor;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Projects.Project.Job;
using Microsoft.Projects.Project.Journal;
using Microsoft.Projects.Project.Ledger;
using Microsoft.Projects.Project.Planning;
using Microsoft.Projects.Resources.Ledger;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Ledger;

page 8084 "Sub. Billing Role Center"
{

    Caption = 'Subscription & Recurring Billing';
    PageType = RoleCenter;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(rolecenter)
        {
            part(Headline; "Sub. Billing Headline RC")
            {
                ApplicationArea = Jobs;
            }
            part(ManagementActivities; "Sub. Billing Activities")
            {
                ApplicationArea = Jobs;
            }
        }
    }
    actions
    {
        area(Sections)
        {
            group(SalesAndPurchases)
            {
                Caption = 'Sales & Purchases';
                action(SalesOrder)
                {
                    Caption = 'Sales Orders';
                    Image = Order;
                    RunObject = page "Sales Order List";
                    ToolTip = 'Executes the Sales Orders action.';
                }
                action(SalesInvoices)
                {
                    Caption = 'Sales Invoices';
                    Image = Invoice;
                    RunObject = Page "Sales Invoice List";
                    ToolTip = 'Register your sales to customers and invite them to pay according to the delivery and payment terms by sending them a sales invoice document. Posting a sales invoice registers shipment and records an open receivable entry on the customer''s account, which will be closed when payment is received. To manage the shipment process, use sales orders, in which sales invoicing is integrated.';
                }
                action(SalesCreditMemos)
                {
                    Caption = 'Sales Credit Memos';
                    RunObject = Page "Sales Credit Memos";
                    ToolTip = 'Revert the financial transactions involved when your customers want to cancel a purchase or return incorrect or damaged items that you sent to them and received payment for. To include the correct information, you can create the sales credit memo from the related posted sales invoice or you can create a new sales credit memo with copied invoice information. If you need more control of the sales return process, such as warehouse documents for the physical handling, use sales return orders, in which sales credit memos are integrated. Note: If an erroneous sale has not been paid yet, you can simply cancel the posted sales invoice to automatically revert the financial transaction.';
                }
                action(PurchaseOrders)
                {
                    ApplicationArea = Suite;
                    Caption = 'Purchase Orders';
                    RunObject = Page "Purchase Order List";
                    ToolTip = 'Create purchase orders to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase orders dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase orders allow partial receipts, unlike with purchase invoices, and enable drop shipment directly from your vendor to your customer. Purchase orders can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
                }
                action(PurchaseInvoices)
                {
                    ApplicationArea = Suite;
                    Caption = 'Purchase Invoices';
                    RunObject = Page "Purchase Invoices";
                    ToolTip = 'Create purchase invoices to mirror sales documents that vendors send to you. This enables you to record the cost of purchases and to track accounts payable. Posting purchase invoices dynamically updates inventory levels so that you can minimize inventory costs and provide better customer service. Purchase invoices can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature.';
                }
                action(PurchaseCreditMemos)
                {
                    ApplicationArea = Suite;
                    Caption = 'Purchase Credit Memos';
                    RunObject = Page "Purchase Credit Memos";
                    ToolTip = 'Create purchase credit memos to mirror sales credit memos that vendors send to you for incorrect or damaged items that you have paid for and then returned to the vendor. If you need more control of the purchase return process, such as warehouse documents for the physical handling, use purchase return orders, in which purchase credit memos are integrated. Purchase credit memos can be created automatically from PDF or image files from your vendors by using the Incoming Documents feature. Note: If you have not yet paid for an erroneous purchase, you can simply cancel the posted purchase invoice to automatically revert the financial transaction.';
                }
            }
            group(Job)
            {
                Caption = 'Projects';
                Image = Job;
                ToolTip = 'Create, plan, and execute tasks in project management. ';
                action(Jobs)
                {
                    Caption = 'Projects';
                    Image = Job;
                    RunObject = Page "Job List";
                    ToolTip = 'Define a project activity by creating a project card with integrated project tasks and project planning lines, structured in two layers. The project task enables you to set up project planning lines and to post consumption to the project. The project planning lines specify the detailed use of resources, items, and various general ledger expenses.';
                }
                action(Open)
                {
                    Caption = 'Open';
                    RunObject = Page "Job List";
                    RunPageView = where(Status = filter(Open));
                    ToolTip = 'Open the card for the selected record.';
                }
                action(JobsPlannedAndQuotd)
                {
                    Caption = 'Planned and Quoted';
                    RunObject = Page "Job List";
                    RunPageView = where(Status = filter(Quote | Planning));
                    ToolTip = 'Open the list of all planned and quoted projects.';
                }
                action(JobsComplet)
                {
                    Caption = 'Completed';
                    RunObject = Page "Job List";
                    RunPageView = where(Status = filter(Completed));
                    ToolTip = 'Open the list of all completed projects.';
                }
                action(JobsUnassign)
                {
                    Caption = 'Unassigned';
                    RunObject = Page "Job List";
                    RunPageView = where("Person Responsible" = filter(''));
                    ToolTip = 'Open the list of all unassigned projects.';
                }
                action(JobTasks)
                {
                    ApplicationArea = Suite;
                    Caption = 'Project Tasks';
                    RunObject = Page "Job Task List";
                    ToolTip = 'Open the list of ongoing project tasks. Project tasks represent the actual work that is performed in a project, and they enable you to set up project planning lines and to post consumption to the project.';
                }
                action(JobRegister)
                {
                    Caption = 'Project Registers';
                    Image = JobRegisters;
                    RunObject = Page "Job Registers";
                    ToolTip = 'View auditing details for all project ledger entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
                action(JobPlanningLines)
                {
                    Caption = 'Project Planning Lines';
                    RunObject = Page "Job Planning Lines";
                    ToolTip = 'Open the list of ongoing project planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (budget) or you can specify what you actually agreed with your customer that he should pay for the project (billable).';
                }
                action(JobJournals)
                {
                    Caption = 'Project Journals';
                    RunObject = Page "Job Journal Batches";
                    RunPageView = where(Recurring = const(false));
                    ToolTip = 'Record project expenses or usage in the project ledger, either by reusing project planning lines or by manual entry.';
                }
                action(JobGLJournals)
                {
                    Caption = 'Project G/L Journals';
                    RunObject = Page "General Journal Batches";
                    RunPageView = where("Template Type" = const(Jobs),
                                        Recurring = const(false));
                    ToolTip = 'Record project expenses or usage in project accounts in the general ledger. For expenses or usage of type G/L Account, use the project G/L journal instead of the project journal.';
                }
                action(RecurringJobJournals)
                {
                    Caption = 'Recurring Project Journals';
                    RunObject = Page "Job Journal Batches";
                    RunPageView = where(Recurring = const(true));
                    ToolTip = 'Reuse preset journal lines to record recurring project expenses or usage in the project ledger.';
                }
            }
            group(PostedDocuments)
            {
                Caption = 'Posted Documents';
                Image = FiledPosted;
                ToolTip = 'View the posting history for sales, shipments, and inventory.';
                action(PostedSalesInvoices)
                {
                    Caption = 'Posted Sales Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    ToolTip = 'Open the list of posted sales invoices.';
                }
                action(PostedSalesCreditMemos)
                {
                    Caption = 'Posted Sales Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    ToolTip = 'Open the list of posted sales credit memos.';
                }
                action(PostedPurchaseInvoices)
                {
                    Caption = 'Posted Purchase Invoices';
                    RunObject = Page "Posted Purchase Invoices";
                    ToolTip = 'Open the list of posted purchase credit memos.';
                }
                action(PostedPurchaseCreditMemos)
                {
                    Caption = 'Posted Purchase Credit Memos';
                    RunObject = Page "Posted Purchase Credit Memos";
                    ToolTip = 'Open the list of posted purchase credit memos.';
                }
                action(GLRegisters)
                {
                    Caption = 'G/L Registers';
                    Image = GLRegisters;
                    RunObject = Page "G/L Registers";
                    ToolTip = 'View auditing details for all G/L entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
                action(JobRegisters)
                {
                    Caption = 'Project Registers';
                    Image = JobRegisters;
                    RunObject = Page "Job Registers";
                    ToolTip = 'View auditing details for all item ledger entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
                action(ItemRegisters)
                {
                    Caption = 'Item Registers';
                    Image = ItemRegisters;
                    RunObject = Page "Item Registers";
                    ToolTip = 'View auditing details for all item ledger entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
                action(ResourceRegisters)
                {
                    Caption = 'Resource Registers';
                    Image = ResourceRegisters;
                    RunObject = Page "Resource Registers";
                    ToolTip = 'View auditing details for all resource ledger entries. Every time an entry is posted, a register is created in which you can see the first and last number of its entries in order to document when entries were posted.';
                }
            }
            group("Setup")
            {
                Caption = 'Setup';
                Image = Setup;
                ToolTip = 'View the setup.';
                action(ServiceContractSetup)
                {
                    Caption = 'Service Contract Setup';
                    Image = ServiceAgreement;
                    RunObject = Page "Service Contract Setup";
                    ToolTip = 'View or edit Service Contract Setup.';
                }
                action(ContractTypes)
                {
                    Caption = 'Contract Types';
                    Image = FileContract;
                    RunObject = Page "Contract Types";
                    ToolTip = 'View or edit Contract Types.';
                }
                action(ServiceCommitmentTemplates)
                {
                    Caption = 'Service Commitment Templates';
                    Image = Template;
                    RunObject = Page "Service Commitment Templates";
                    ToolTip = 'View or edit Service Commitment Templates.';
                }
                action(ServiceCommitmentPackages)
                {
                    Caption = 'Service Commitment Packages';
                    Image = Template;
                    RunObject = Page "Service Commitment Packages";
                    ToolTip = 'View or edit Service Commitment Packages.';
                }
            }
        }
        area(embedding)
        {
            action(CustomersList)
            {
                ApplicationArea = Jobs;
                Caption = 'Customers';
                Image = Customer;
                RunObject = Page "Customer List";
                ToolTip = 'View or edit detailed information for the customers that you trade with. From each customer card, you can open related information, such as sales statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
            }
            action(VendorsList)
            {
                ApplicationArea = Jobs;
                Caption = 'Vendors';
                Image = Vendor;
                RunObject = Page "Vendor List";
                ToolTip = 'View or edit detailed information for the vendors that you trade with. From each vendor card, you can open related information, such as purchase statistics and ongoing orders, and you can define special prices and line discounts that you grant if certain conditions are met.';
            }
            action(JobsList)
            {
                ApplicationArea = Jobs;
                Caption = 'Projects';
                Image = Job;
                RunObject = Page "Job List";
                ToolTip = 'Define a project activity by creating a project card with integrated project tasks and project planning lines, structured in two layers. The project task enables you to set up project planning lines and to post consumption to the project. The project planning lines specify the detailed use of resources, items, and various general ledger expenses.';
            }

            action(ItemsList)
            {
                ApplicationArea = Jobs;
                Caption = 'Items';
                Image = Item;
                RunObject = Page "Item List";
                ToolTip = 'View or edit detailed information for the products that you trade in. The item card can be of type Inventory or Service to specify if the item is a physical unit or a labor time unit. Here you also define if items in inventory or on incoming orders are automatically reserved for outbound documents and whether order tracking links are created between demand and supply to reflect planning actions.';
            }
            action(ServiceObjectsList)
            {
                ApplicationArea = Jobs;
                Caption = 'Service Objects';
                Image = ServiceSetup;
                RunObject = Page "Service Objects";
                ToolTip = 'Detailed information on the Service Objects. The Service Objects shows the article for which it was created and the services that belong to it. The amount and the details of the provision can be seen. The service recipient indicates to which customer the service item was sold. Different delivery and billing addresses provide information about who the item was delivered to and who received the invoice. In addition, the services are shown in detail and can be edited.';
            }
            action(CustomerContractsList)
            {
                ApplicationArea = Jobs;
                Caption = 'Customer Contracts';
                Image = Customer;
                RunObject = Page "Customer Contracts";
                ToolTip = 'Detailed information on Customer Contracts that include recurring services. A Customer Contract is used to calculate these services based on the parameters specified in the service. The services are presented in detail and can be edited. In addition, commercial information as well as delivery and billing addresses can be stored in a Contract.';
            }
            action(VendorContractsList)
            {
                ApplicationArea = Jobs;
                Caption = 'Vendor Contracts';
                Image = Vendor;
                RunObject = Page "Vendor Contracts";
                ToolTip = 'Detailed information on Vendor Contracts that include recurring services. A Vendor Contract is used to calculate these services based on the parameters specified in the service. The services are presented in detail and can be edited. In addition, commercial information can be stored in a Contract.';
            }
        }
        area(processing)
        {
            action(RecurringBilling)
            {
                ApplicationArea = Jobs;
                Caption = 'Recurring Billing';
                RunObject = Page "Recurring Billing";
                ToolTip = 'Opens the page for creating billing proposals for Recurring Services.';
            }
            group(New)
            {
                Caption = 'New';
                action(ServiceCommitmentTemplate)
                {
                    Caption = 'Service Commitment Template';
                    Image = ApplyTemplate;
                    RunObject = Page "Service Commitment Templates";
                    RunPageMode = Create;
                    ToolTip = 'Create a new Service Commitment Template.';
                }
                action(ServiceCommitmentPackage)
                {
                    Caption = 'Service Commitment Package';
                    Image = ServiceLedger;
                    RunObject = Page "Service Commitment Package";
                    RunPageMode = Create;
                    ToolTip = 'Create a new Service Commitment Package.';
                }
                action(CustomerContract)
                {
                    Caption = 'Customer Contract';
                    Image = NewOrder;
                    RunObject = Page "Customer Contract";
                    RunPageMode = Create;
                    ToolTip = 'Create a new Customer Contract.';
                }
                action(VendorContract)
                {
                    Caption = 'Vendor Contract';
                    Image = NewOrder;
                    RunObject = Page "Vendor Contract";
                    RunPageMode = Create;
                    ToolTip = 'Create a new Vendor Contract.';
                }
            }
            group(History)
            {
                Caption = 'History';
                action("Posted Customer Contract Invoices")
                {
                    Caption = 'Posted Customer Contract Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Invoices";
                    RunPageView = where("Recurring Billing" = const(true));
                    ToolTip = 'Open the list of Posted Sales Invoices for Customer Contracts.';
                }
                action("Posted Customer Contract Credit Memos")
                {
                    Caption = 'Posted Customer Contract Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Sales Credit Memos";
                    RunPageView = where("Recurring Billing" = const(true));
                    ToolTip = 'Open the list of Posted Sales Credit Memos for Customer Contracts.';
                }
                action("Posted Vendor Contract Invoices")
                {
                    Caption = 'Posted Vendor Contract Invoices';
                    Image = PostedOrder;
                    RunObject = Page "Posted Purchase Invoices";
                    RunPageView = where("Recurring Billing" = const(true));
                    ToolTip = 'Open the list of Posted Purchase Invoices for Vendor Contracts.';
                }
                action("Posted Vendor Contract Credit Memos")
                {
                    Caption = 'Posted Vendor Contract Credit Memos';
                    Image = PostedOrder;
                    RunObject = Page "Posted Purchase Credit Memos";
                    RunPageView = where("Recurring Billing" = const(true));
                    ToolTip = 'Open the list of Posted Purchase Credit Memos for Vendor Contracts.';
                }
            }
        }
    }
}
