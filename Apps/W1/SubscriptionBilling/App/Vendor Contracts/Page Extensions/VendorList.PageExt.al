namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

pageextension 8057 "Vendor List" extends "Vendor List"
{
    actions
    {
        addlast(creation)
        {
            action(NewContract)
            {
                AccessByPermission = tabledata "Vendor Contract" = RIM;
                ApplicationArea = Basic, Suite;
                Caption = 'Contract';
                Image = FileContract;
                RunObject = page "Vendor Contract";
                RunPageLink = "Buy-from Vendor No." = field("No.");
                RunPageMode = Create;
                ToolTip = 'Create a contract for the vendor.';
            }
        }
        addlast(Category_Category4)
        {
            actionref(NewContract_Promoted; NewContract)
            {
            }
        }
        addlast("Ven&dor")
        {
            action(Contracts)
            {
                AccessByPermission = tabledata "Vendor Contract" = R;
                ApplicationArea = Basic, Suite;
                Caption = 'Contracts';
                Image = FileContract;
                RunObject = page "Vendor Contracts";
                RunPageLink = "Buy-from Vendor No." = field("No.");
                ToolTip = 'View a list of ongoing vendor contracts.';
            }
        }
        addlast(Category_Category5)
        {
            actionref(Contracts_Promoted; Contracts)
            {
            }
        }
    }
}