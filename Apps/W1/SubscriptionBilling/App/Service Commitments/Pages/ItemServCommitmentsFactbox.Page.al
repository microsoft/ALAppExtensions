namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

page 8062 "Item Serv. Commitments Factbox"
{
    Caption = 'Service Commitments';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Item Serv. Commitment Package";
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
                    ToolTip = 'Specifies a description of the service commitment package.';
                }
                field(Standard; Rec.Standard)
                {
                    ToolTip = 'Specifies whether the package service commitments should be automatically added to the sales process when the item is sold. If the checkbox is not set, the package service commitments can be added manually in the sales process.';
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
                ApplicationArea = Jobs;
                Image = ServiceLedger;
                Caption = 'Service Commitments';
                ToolTip = 'View or add service commitments for the item.';

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
