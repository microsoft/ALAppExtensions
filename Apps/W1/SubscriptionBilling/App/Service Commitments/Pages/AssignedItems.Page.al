namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using Microsoft.Inventory.Item;

page 8063 "Assigned Items"
{
    Caption = 'Assigned Items';
    PageType = List;
    SourceTable = "Item Serv. Commitment Package";
    Editable = false;
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the number of the item.';
                }
                field(Description; Item.Description)
                {
                    ToolTip = 'Specifies a description of the item.';
                    Caption = 'Description';
                }
                field(BaseUnitOfMeasure; Item."Base Unit of Measure")
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    ToolTip = 'Specifies the base unit used to measure the item, such as piece, box, or pallet. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                    Caption = 'Base Unit of Measure';
                }
                field(UnitPrice; Item."Unit Price")
                {
                    ApplicationArea = Invoicing, Basic, Suite;
                    ToolTip = 'Specifies the price for one unit of the item, in LCY.';
                    Caption = 'Unit Price';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(AssignItemsAction)
            {
                Caption = 'Assign New Items';
                Image = NewItem;
                ToolTip = 'Assign new items to the Service Commitment Package.';

                trigger OnAction()
                begin
                    AssignItems(CopyStr(Rec.GetFilter(Code), 1, MaxStrLen(Rec.Code)));
                end;
            }
            action(RemoveItemsAction)
            {
                Caption = 'Remove Items';
                Image = Delete;
                ToolTip = 'Removes the assignment of items to the Service Commitment Package.';

                trigger OnAction()
                var
                    ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
                begin
                    CurrPage.SetSelectionFilter(ItemServCommitmentPackage);
                    RemoveItems(ItemServCommitmentPackage);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(AssignItemsAction_Promoted; AssignItemsAction)
                {
                }
                actionref(RemoveItemsAction_Promoted; RemoveItemsAction)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if not Item.Get(Rec."Item No.") then
            Item.Init();
    end;

    var
        Item: Record Item;
        DeletionQst: Label 'Do you really want to delete assignment of the selected item(s)?';

    internal procedure AssignItems(PackageCode: Code[20])
    var
        Item2: Record Item;
        ItemServCommitmentPackage: Record "Item Serv. Commitment Package";
        ContractsItemManagement: Codeunit "Contracts Item Management";
        ItemList: Page "Item List";
    begin
        Item2.SetRange("Service Commitment Option", Enum::"Item Service Commitment Type"::"Sales with Service Commitment", Enum::"Item Service Commitment Type"::"Service Commitment Item");
        if Item2.FindSet() then
            repeat
                if not ItemServCommitmentPackage.Get(Item2."No.", PackageCode) then
                    Item2.Mark(true);
            until Item2.Next() = 0;
        Item2.MarkedOnly(true);
        ItemList.SetTableView(Item2);
        ItemList.LookupMode(true);
        if ItemList.RunModal() = Action::LookupOK then begin
            Item2.SetFilter("No.", ItemList.GetSelectionFilter());
            if Item2.FindSet() then
                repeat
                    ContractsItemManagement.InsertItemServiceCommitmentPackage(Item2, PackageCode, false);
                until Item2.Next() = 0;
        end;
    end;

    internal procedure RemoveItems(var ItemServCommitmentPackage: Record "Item Serv. Commitment Package")
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if ConfirmManagement.GetResponse(DeletionQst, false) then
            ItemServCommitmentPackage.DeleteAll(false);
    end;
}
