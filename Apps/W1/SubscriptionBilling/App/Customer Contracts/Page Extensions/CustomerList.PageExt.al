namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

pageextension 8052 "Customer List" extends "Customer List"
{
    actions
    {
        addafter(NewSalesCrMemo)
        {
            action(NewContract)
            {
                AccessByPermission = tabledata "Customer Contract" = RIM;
                ApplicationArea = Basic, Suite;
                Caption = 'Contract';
                Image = FileContract;
                RunObject = Page "Customer Contract";
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