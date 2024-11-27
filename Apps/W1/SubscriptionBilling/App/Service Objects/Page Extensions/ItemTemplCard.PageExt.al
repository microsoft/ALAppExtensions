namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

pageextension 8095 "Item Templ. Card" extends "Item Templ. Card"
{
    layout
    {
        addlast(PricesAndSales)
        {
            field("Service Commitment Option"; Rec."Service Commitment Option")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether or not service commitments can be linked to this item, or if the item is being used for recurring billing. This is only relevant if you are using Subscription Billing functionalities.';

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }
        addafter(PricesAndSales)
        {
            part(ServiceCommitmentPackages; "Item Templ. Serv. Comm. P.")
            {
                Caption = 'Service Commitment Packages';
                ApplicationArea = All;
                SubPageLink = "Item Template Code" = field(Code);
                Editable = ItemTemplServCommPackEditable;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ItemTemplServCommPackEditable := not (Rec."Service Commitment Option" in ["Item Service Commitment Type"::"Invoicing Item", "Item Service Commitment Type"::"Sales without Service Commitment"]);
    end;

    var
        ItemTemplServCommPackEditable: Boolean;
}