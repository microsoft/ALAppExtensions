namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

pageextension 8057 "Vendor List" extends "Vendor List"
{
    actions
    {
        addafter(NewPurchaseCrMemo)
        {
            action(NewContract)
            {
                AccessByPermission = tabledata "Vendor Contract" = RIM;
                ApplicationArea = Basic, Suite;
                Caption = 'Contract';
                Image = FileContract;
                RunObject = Page "Vendor Contract";
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
    }
}