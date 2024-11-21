namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Document;

pageextension 8012 "Purchase Invoice" extends "Purchase Invoice"
{
    actions
    {
        addlast(Processing)
        {
            action("Get Vendor Contract Lines")
            {
                ApplicationArea = All;
                Caption = 'Get Vendor Contract Lines';
                Image = GetOrder;
                ToolTip = 'Select Vendor Contract lines and create corresponding invoice lines.';

                trigger OnAction()
                begin
                    Rec.RunGetVendorContractLines();
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(GetVendorContractLines_Promoted; "Get Vendor Contract Lines")
            {
            }
        }
    }
}
