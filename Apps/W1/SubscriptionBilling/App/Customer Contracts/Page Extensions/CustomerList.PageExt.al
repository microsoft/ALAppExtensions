namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

pageextension 8052 "Customer List" extends "Customer List"
{
    actions
    {
        addlast(creation)
        {
            action(NewContract)
            {
                AccessByPermission = tabledata "Customer Contract" = RIM;
                ApplicationArea = Basic, Suite;
                Caption = 'Contract';
                Image = FileContract;
                RunObject = page "Customer Contract";
                RunPageLink = "Sell-to Customer No." = field("No.");
                RunPageMode = Create;
                ToolTip = 'Create a contract for the customer.';
            }
        }
        addlast(Category_Category5)
        {
            actionref(NewContract_Promoted; NewContract)
            {
            }
        }
        addlast("&Customer")
        {
            action(Contracts)
            {
                AccessByPermission = tabledata "Customer Contract" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Contracts';
                Image = FileContract;
                RunObject = page "Customer Contracts";
                RunPageLink = "Sell-to Customer No." = field("No.");
                ToolTip = 'View a list of ongoing customer contracts.';
            }
            action(ServiceObjects)
            {
                AccessByPermission = tabledata "Service Object" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Service Objects';
                Image = ServiceItem;
                RunObject = page "Service Object";
                RunPageLink = "End-User Customer No." = field("No.");
                ToolTip = 'View a list of service objects for the customer.';
            }
        }
        addlast(Category_Category7)
        {
            actionref(Contracts_Promoted; Contracts)
            {
            }
            actionref(ServiceObjects_Promoted; ServiceObjects)
            {
            }
        }
        addlast(reporting)
        {
            action(OverviewOfContractComponents)
            {
                Caption = 'Overview of contract components';
                ToolTip = 'View a detailed list of services for the selected customer(s).';
                Image = QualificationOverview;
                ApplicationArea = All;
                RunObject = Report "Overview Of Contract Comp";
            }
        }
    }
}