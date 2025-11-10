namespace Microsoft.API.V2;

using Microsoft.Inventory.Item;

page 30052 "APIV2 - Item Variants"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Item Variant';
    EntitySetCaption = 'Item Variants';
    DelayedInsert = true;
    EntityName = 'itemVariant';
    EntitySetName = 'itemVariants';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Variant";
    Extensible = false;
    AboutText = 'Exposes item variant data including codes, descriptions, and status flags for managing different product configurations such as size or color. Supports full CRUD operations to synchronize and maintain variant records across e-commerce catalogs, inventory systems, and external sales channels, enabling accurate stock management and product catalog integration.';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(itemId; Rec."Item Id")
                {
                    Caption = 'Item Id';

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
                    Caption = 'Item No.';

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
                    Caption = 'Code';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
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
        ItemIdDoesNotMatchAnEmployeeErr: Label 'The "itemId" does not match to an Item.', Comment = 'itemId is a field name and should not be translated.';
        ItemNumberDoesNotMatchAnEmployeeErr: Label 'The "itemNumber" does not match to an Item.', Comment = 'itemNumber is a field name and should not be translated.';
        ItemValuesDontMatchErr: Label 'The item values do not match to a specific Item.';
        BlankGuid: Guid;
}