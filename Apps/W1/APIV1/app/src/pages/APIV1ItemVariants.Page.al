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
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(itemId; "Item Id")
                {
                    Caption = 'itemId', Locked = true;

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
                    Caption = 'itemNumber', Locked = true;

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
                    Caption = 'code', Locked = true;
                }
                field(description; Description)
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
        ItemIdDoesNotMatchAnEmployeeErr: Label 'The "itemId" does not match to an Item.', Locked = true;
        ItemNumberDoesNotMatchAnEmployeeErr: Label 'The "itemNumber" does not match to an Item.', Locked = true;
        ItemValuesDontMatchErr: Label 'The item values do not match to a specific Item.', Locked = true;
        BlankGuid: Guid;
}