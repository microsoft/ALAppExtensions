namespace Microsoft.SubscriptionBilling;

using Microsoft.CRM.Contact;

pageextension 8002 "Contract Contact List" extends "Contact List"
{
    layout
    {
        addafter(Control128)
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
                ToolTip = 'View a detailed list of services for the selected contact(s).';
                Image = QualificationOverview;
                ApplicationArea = All;
                RunObject = Report "Overview Of Contract Comp";
            }
        }
    }
}
