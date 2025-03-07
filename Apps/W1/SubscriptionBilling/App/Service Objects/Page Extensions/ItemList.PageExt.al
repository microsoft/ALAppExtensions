namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

pageextension 8055 "Item List" extends "Item List"
{
    layout
    {
        addbefore(Control1900383207)
        {
            part(ItemServCommitmentsFactbox; "Item Serv. Commitments Factbox")
            {
                ApplicationArea = All;
                Caption = 'Subscription Packages';
                SubPageLink = "Item No." = field("No.");
            }
        }
    }
    actions
    {
        addlast(Action126)
        {
            action(ServiceCommitments)
            {
                ApplicationArea = All;
                Image = ServiceLedger;
                Caption = 'Subscription Packages';
                ToolTip = 'View or add Subscription Packages for the item.';

                trigger OnAction()
                begin
                    Rec.OpenItemServCommitmentPackagesPage();
                end;
            }
        }
        addlast(Category_Category4)
        {
            actionref(ServiceCommitments_Promoted; ServiceCommitments)
            {
            }
        }
    }
}