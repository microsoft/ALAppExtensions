namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

pageextension 8095 "Item Templ. Card" extends "Item Templ. Card"
{
    layout
    {
        addlast(PricesAndSales)
        {
            field("Service Commitment Option"; Rec."Subscription Option")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether or not Subscription Lines can be linked to this item, or if the item is being used for recurring billing. This is only relevant if you are using Subscription Billing functionalities.';

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
                Caption = 'Subscription Packages';
                ApplicationArea = All;
                SubPageLink = "Item Template Code" = field(Code);
                Editable = ItemTemplServCommPackEditable;
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        ItemTemplServCommPackEditable := not (Rec."Subscription Option" in ["Item Service Commitment Type"::"Invoicing Item", "Item Service Commitment Type"::"Sales without Service Commitment"]);
    end;

    var
        ItemTemplServCommPackEditable: Boolean;
}