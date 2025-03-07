namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;

pageextension 8054 "Item Card" extends "Item Card"
{
    layout
    {
        addbefore("Sales Blocked")
        {
            field("Service Commitment Option"; Rec."Subscription Option")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether or not Subscription Lines can be linked to this item, or if the item is being used for recurring billing. This is only relevant if you are using Subscription Billing functionalities.';

                trigger OnValidate()
                begin
                    SetEditableVariables();
                end;
            }
        }
        addbefore(Control1900383207)
        {
            part(ItemServCommitmentsFactbox; "Item Serv. Commitments Factbox")
            {
                ApplicationArea = All;
                Caption = 'Subscription Packages';
                SubPageLink = "Item No." = field("No.");
            }
        }
        modify("Allow Invoice Disc.")
        {
            Editable = not IsServiceCommitmentItemEditable;
        }
        addlast(Purchase)
        {
            field(UsageDataSupplierRefExists; Rec."Usage Data Suppl. Ref. Exists")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that at least one usage data supplier reference exists for the item. This is only relevant if you are using Subscription Billing functionalities.';

                trigger OnDrillDown()
                var
                    ItemVendor: Record "Item Vendor";
                begin
                    Commit();
                    ItemVendor.SetRange("Item No.", Rec."No.");
                    Page.Run(Page::"Item Vendor Catalog", ItemVendor);
                    CurrPage.Update();
                end;
            }
        }

    }
    actions
    {
        addlast(Navigation_Item)
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

    trigger OnAfterGetRecord()
    begin
        SetEditableVariables();
    end;

    var
        IsServiceCommitmentItemEditable: Boolean;

    local procedure SetEditableVariables()
    var
    begin
        IsServiceCommitmentItemEditable := Rec.IsServiceCommitmentItem();
    end;
}