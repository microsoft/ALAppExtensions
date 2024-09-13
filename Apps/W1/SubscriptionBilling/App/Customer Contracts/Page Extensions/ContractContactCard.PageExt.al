namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;

pageextension 8003 "Contract Contact Card" extends "Contact Card"
{
    layout
    {
        addafter(Control31)
        {
            part(ContractsContactRBFactbox; "Contact Billing Factbox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = field("No.");
            }
        }
    }
    actions
    {
        addlast(reporting)
        {
            action(OverviewOfContractComponents)
            {
                Caption = 'Overview of contract components';
                ToolTip = 'Show a detailed list of services for the selected contact.';
                Image = QualificationOverview;
                ApplicationArea = All;

                trigger OnAction()
                var
                    CustomerContract: Record "Customer Contract";
                    OverviewOfContractComp: Report "Overview Of Contract Comp";
                begin
                    CustomerContract.SetRange("Sell-to Contact No.", Rec."No.");
                    OverviewOfContractComp.SetTableView(CustomerContract);
                    OverviewOfContractComp.Run();
                end;
            }
        }
    }
}