namespace Microsoft.SubscriptionBilling;

using Microsoft.Sales.Customer;

pageextension 8051 "Customer Card" extends "Customer Card"
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
        addlast(Category_Category4)
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
                ToolTip = 'Show a detailed list of services for the selected contract.';
                Image = QualificationOverview;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CustomerContract: Record "Customer Contract";
                    OverviewOfContractComponents: Report "Overview Of Contract Comp";
                begin
                    CustomerContract.SetRange("Sell-to Customer No.", Rec."No.");
                    OverviewOfContractComponents.SetTableView(CustomerContract);
                    OverviewOfContractComponents.Run();
                end;
            }
        }
    }
}