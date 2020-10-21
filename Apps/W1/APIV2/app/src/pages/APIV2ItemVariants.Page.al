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

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(itemId; "Item Id")
                {
                    Caption = 'Item Id';

                    trigger OnValidate()
                    begin
                        if not IsNullGuid(Item.SystemId) then
                            if Item.SystemId <> "Item Id" then
                                Error(ItemValuesDontMatchErr);

                        if GetFilter("Item Id") <> '' then
                            if "Item Id" <> GetFilter("Item Id") then
                                Error(ItemValuesDontMatchErr);

                        if "Item Id" = BlankGuid then
                            "Item No." := ''
                        else
                            if not Item.GetBySystemId("Item Id") then
                                Error(ItemIdDoesNotMatchAnEmployeeErr);
                    end;
                }
                field(itemNumber; "Item No.")
                {
                    Caption = 'Item No.';

                    trigger OnValidate()
                    begin
                        if "Item No." = '' then
                            "Item Id" := BlankGuid
                        else
                            if not Item.Get("Item No.") then
                                Error(ItemNumberDoesNotMatchAnEmployeeErr);

                        if GetFilter("Item Id") <> '' then
                            if Item.SystemId <> GetFilter("Item Id") then
                                Error(ItemValuesDontMatchErr);
                    end;
                }
                field("code"; Code)
                {
                    Caption = 'Code';
                }
                field(description; Description)
                {
                    Caption = 'Description';
                }
            }
        }

    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if HasFilter() then
            Validate("Item Id", GetFilter("Item Id"));
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemVariant: Record "Item Variant";
    begin
        ItemVariant.GetBySystemId(Rec.SystemId);

        if "Item No." = ItemVariant."Item No." then
            Modify(true)
        else begin
            ItemVariant.TransferFields(Rec, false);
            ItemVariant.Rename("Item No.", "Code");
            TransferFields(ItemVariant, true);
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