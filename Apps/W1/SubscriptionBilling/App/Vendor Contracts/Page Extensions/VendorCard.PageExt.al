namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

pageextension 8056 "Vendor Card" extends "Vendor Card"
{
    actions
    {
        addlast(creation)
        {
            action(NewContract)
            {
                AccessByPermission = tabledata "Vendor Subscription Contract" = RIM;
                ApplicationArea = Basic, Suite;
                Caption = 'Subscription Contract';
                Image = FileContract;
                RunObject = page "Vendor Contract";
                RunPageLink = "Buy-from Vendor No." = field("No.");
                RunPageMode = Create;
                ToolTip = 'Create a Subscription Contract for the vendor.';
            }
        }
        addlast(Category_Category6)
        {
            actionref(NewContract_Promoted; NewContract)
            {
            }
        }
        addlast("Ven&dor")
        {
            action(Contracts)
            {
                AccessByPermission = tabledata "Vendor Subscription Contract" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Subscription Contracts';
                Image = FileContract;
                RunObject = page "Vendor Contracts";
                RunPageLink = "Buy-from Vendor No." = field("No.");
                ToolTip = 'View a list of ongoing Vendor Subscription Contracts.';
            }
        }
        addlast(Category_Category9)
        {
            actionref(Contracts_Promoted; Contracts)
            {
            }
        }
    }
}