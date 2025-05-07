namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

page 8062 "Item Serv. Commitments Factbox"
{
    Caption = 'Subscription Packages Lines';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Item Subscription Package";
    PageType = ListPart;
    RefreshOnActivate = true;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription Package.';
                }
                field(Standard; Rec.Standard)
                {
                    ToolTip = 'Specifies whether the package Subscription Lines should be automatically added to the sales process when the item is sold. If the checkbox is not set, the package Subscription Lines can be added manually in the sales process.';
                }
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ServiceCommitments)
            {
                ApplicationArea = All;
                Image = ServiceLedger;
                Caption = 'Subscription Lines';
                ToolTip = 'View or add Subscription Lines for the item.';

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item.Get(Rec."Item No.");
                    Item.OpenItemServCommitmentPackagesPage();
                end;
            }
        }
    }
}
