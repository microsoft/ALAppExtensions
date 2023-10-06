namespace Microsoft.API.V1;

using Microsoft.Inventory.Item;

page 20052 "APIV1 - Item Variants"
{
    APIVersion = 'v1.0';
    Caption = 'itemVariants', Locked = true;
    DelayedInsert = true;
    EntityName = 'itemVariant';
    EntitySetName = 'itemVariants';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Variant";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(itemId; Rec."Item Id")
                {
                    Caption = 'itemId', Locked = true;

                    trigger OnValidate()
                    begin
                        if not IsNullGuid(Item.SystemId) then
                            if Item.SystemId <> Rec."Item Id" then
                                Error(ItemValuesDontMatchErr);

                        if Rec.GetFilter("Item Id") <> '' then
                            if Rec."Item Id" <> Rec.GetFilter("Item Id") then
                                Error(ItemValuesDontMatchErr);

                        if Rec."Item Id" = BlankGuid then
                            Rec."Item No." := ''
                        else
                            if not Item.GetBySystemId(Rec."Item Id") then
                                Error(ItemIdDoesNotMatchAnEmployeeErr);
                    end;
                }
                field(itemNumber; Rec."Item No.")
                {
                    Caption = 'itemNumber', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Item No." = '' then
                            Rec."Item Id" := BlankGuid
                        else
                            if not Item.Get(Rec."Item No.") then
                                Error(ItemNumberDoesNotMatchAnEmployeeErr);

                        if Rec.GetFilter("Item Id") <> '' then
                            if Item.SystemId <> Rec.GetFilter("Item Id") then
                                Error(ItemValuesDontMatchErr);
                    end;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(description; Rec.Description)
                {
                    Caption = 'description', Locked = true;
                }
            }
        }

    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec.HasFilter() then
            Rec.Validate("Item Id", Rec.GetFilter("Item Id"));
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.GetBySystemId(Rec.SystemId);
        if Rec."Item No." = ItemVariant."Item No." then
            Rec.Modify(true)
        else begin
            ItemVariant.TransferFields(Rec, false);
            ItemVariant.Rename(Rec."Item No.", Rec."Code");
            Rec.TransferFields(ItemVariant, true);
        end;
        exit(false);
    end;

    var
        Item: Record Item;
        ItemIdDoesNotMatchAnEmployeeErr: Label 'The "itemId" does not match to an Item.', Locked = true;
        ItemNumberDoesNotMatchAnEmployeeErr: Label 'The "itemNumber" does not match to an Item.', Locked = true;
        ItemValuesDontMatchErr: Label 'The item values do not match to a specific Item.', Locked = true;
        BlankGuid: Guid;
}
