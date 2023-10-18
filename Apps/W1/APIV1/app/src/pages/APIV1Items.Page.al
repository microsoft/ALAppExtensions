namespace Microsoft.API.V1;

using Microsoft.Finance.SalesTax;
using Microsoft.Foundation.UOM;
using Microsoft.Integration.Graph;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Posting;

page 20008 "APIV1 - Items"
{
    APIVersion = 'v1.0';
    Caption = 'items', Locked = true;
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'item';
    EntitySetName = 'items';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Item;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'displayName', Locked = true;
                    ToolTip = 'Specifies the Description for the Item.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(type; Rec.Type)
                {
                    Caption = 'type', Locked = true;
                    ToolTip = 'Specifies the Type for the Item. Possible values are Inventory and Service.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Type));
                    end;
                }
                field(itemCategoryId; Rec."Item Category Id")
                {
                    Caption = 'itemCategoryId', Locked = true;

                    trigger OnValidate()
                    begin
                        if Rec."Item Category Id" = BlankGUID then
                            Rec."Item Category Code" := ''
                        else begin
                            if not ItemCategory.GetBySystemId(Rec."Item Category Id") then
                                error(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            Rec."Item Category Code" := ItemCategory.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Item Category Code"));
                        RegisterFieldSet(Rec.FieldNo("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'itemCategoryCode', Locked = true;

                    trigger OnValidate()
                    begin
                        if ItemCategory.Code <> '' then begin
                            if ItemCategory.Code <> Rec."Item Category Code" then
                                error(ItemCategoriesValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Item Category Code" = '' then
                            Rec."Item Category Id" := BlankGUID
                        else begin
                            if not ItemCategory.GET(Rec."Item Category Code") then
                                error(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            Rec."Item Category Id" := ItemCategory.SystemId;
                        end;
                    end;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'blocked', Locked = true;
                    ToolTip = 'Specifies whether the item is blocked.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }
                field(baseUnitOfMeasureId; BaseUnitOfMeasureIdGlobal)
                {
                    Caption = 'baseUnitOfMeasureId', Locked = true;

                    trigger OnValidate()
                    begin
                        if BaseUnitOfMeasureIdGlobal = BlankGUID then
                            BaseUnitOfMeasureCode := ''
                        else begin
                            if not ValidateUnitOfMeasure.GetBySystemId(BaseUnitOfMeasureIdGlobal) then
                                error(UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr);

                            BaseUnitOfMeasureCode := ValidateUnitOfMeasure.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Id"));
                        RegisterFieldSet(Rec.FieldNo("Base Unit of Measure"));
                    end;
                }
                field(baseUnitOfMeasure; BaseUnitOfMeasureJSONText)
                {
                    Caption = 'baseUnitOfMeasure', Locked = true;
#pragma warning disable AL0667
                    ODataEDMType = 'ITEM-UOM';
#pragma warning restore
                    ToolTip = 'Specifies the Base Unit of Measure.';

                    trigger OnValidate()
                    var
                        UnitOfMeasureFromJSON: Record "Unit of Measure";
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Id"));
                        RegisterFieldSet(Rec.FieldNo("Base Unit of Measure"));

                        if BaseUnitOfMeasureJSONText = 'null' then
                            exit;

                        GraphCollectionMgtItem.ParseJSONToUnitOfMeasure(BaseUnitOfMeasureJSONText, UnitOfMeasureFromJSON);

                        if (ValidateUnitOfMeasure.Code <> '') and
                           (ValidateUnitOfMeasure.Code <> UnitOfMeasureFromJSON.Code)
                        then
                            error(UnitOfMeasureValuesDontMatchErr);
                    end;
                }
                field(gtin; Rec.GTIN)
                {
                    Caption = 'GTIN', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(GTIN));
                    end;
                }
                field(inventory; InventoryValue)
                {
                    Caption = 'inventory', Locked = true;
                    ToolTip = 'Specifies the inventory for the item.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Inventory));
                    end;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'unitPrice', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit Price"));
                    end;
                }
                field(priceIncludesTax; Rec."Price Includes VAT")
                {
                    Caption = 'priceIncludesTax', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Price Includes VAT"));
                    end;
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'unitCost', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit Cost"));
                    end;
                }
                field(taxGroupId; Rec."Tax Group Id")
                {
                    Caption = 'taxGroupId', Locked = true;
                    ToolTip = 'Specifies the ID of the tax group.';

                    trigger OnValidate()
                    begin
                        if Rec."Tax Group Id" = BlankGUID then
                            Rec."Tax Group Code" := ''
                        else begin
                            if not TaxGroup.GetBySystemId(Rec."Tax Group Id") then
                                error(TaxGroupIdDoesNotMatchATaxGroupErr);

                            Rec."Tax Group Code" := TaxGroup.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        RegisterFieldSet(Rec.FieldNo("Tax Group Id"));
                    end;
                }
                field(taxGroupCode; Rec."Tax Group Code")
                {
                    Caption = 'taxGroupCode', Locked = true;

                    trigger OnValidate()
                    begin
                        if TaxGroup.Code <> '' then begin
                            if TaxGroup.Code <> Rec."Tax Group Code" then
                                error(TaxGroupValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Tax Group Code" = '' then
                            Rec."Tax Group Id" := BlankGUID
                        else begin
                            if not TaxGroup.GET(Rec."Tax Group Code") then
                                error(TaxGroupCodeDoesNotMatchATaxGroupErr);

                            Rec."Tax Group Id" := TaxGroup.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        RegisterFieldSet(Rec.FieldNo("Tax Group Id"));
                    end;
                }
                field(lastModifiedDateTime; Rec."Last DateTime Modified")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                part(picture; "APIV1 - Pictures")
                {
                    Caption = 'picture';
                    EntityName = 'picture';
                    EntitySetName = 'picture';
                    SubPageLink = Id = field(SystemId);
                }
                part(defaultDimensions; "APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimensions';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = field(SystemId);
                }
                part(itemVariants; "APIV1 - Item Variants")
                {
                    Caption = 'Variants', Locked = true;
                    EntityName = 'itemVariant';
                    EntitySetName = 'itemVariants';
                    SubPageLink = "Item Id" = field(SystemId);
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if TempFieldSet.GET(DATABASE::Item, Rec.FieldNo("Base Unit of Measure")) then
            if BaseUnitOfMeasureJSONText = '' then
                BaseUnitOfMeasureJSONText := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Rec, BaseUnitOfMeasureCode);

        if TempFieldSet.GET(DATABASE::Item, Rec.FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);

#pragma warning disable AL0432
        GraphCollectionMgtItem.InsertItem(Rec, TempFieldSet, BaseUnitOfMeasureJSONText);
#pragma warning restore

        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Item: Record Item;
    begin
        if TempFieldSet.GET(DATABASE::Item, Rec.FieldNo("Base Unit of Measure")) then begin
            Rec.Validate("Base Unit of Measure", BaseUnitOfMeasureCode);
            if xRec."Base Unit of Measure" <> Rec."Base Unit of Measure" then
                BaseUnitOfMeasureJSONText := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Rec, Rec."Base Unit of Measure");
        end;

        if TempFieldSet.GET(DATABASE::Item, Rec.FieldNo(Inventory)) then
            UpdateInventory();

        Item.GetBySystemId(Rec.SystemId);

        GraphCollectionMgtItem.ProcessComplexTypes(
          Rec,
          BaseUnitOfMeasureJSONText
          );

        if Rec."No." = Item."No." then
            Rec.Modify(true)
        else begin
            Item.TransferFields(Rec, false);
            Item.Rename(Rec."No.");
            Rec.TransferFields(Item, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnOpenPage()
    begin
        Rec.SetAutoCalcFields(Inventory);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        ValidateUnitOfMeasure: Record "Unit of Measure";
        ItemCategory: Record "Item Category";
        TaxGroup: Record "Tax Group";
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        BaseUnitOfMeasureCode: Code[10];
        BaseUnitOfMeasureJSONText: Text;
        InventoryValue: Decimal;
        UnitOfMeasureValuesDontMatchErr: Label 'The unit of measure values do not match to a specific Unit of Measure.', Locked = true;
        UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr: Label 'The "unitOfMeasureId" does not match to a Unit of Measure.', Locked = true;
        BaseUnitOfMeasureIdGlobal: Guid;
        BlankGUID: Guid;
        TaxGroupValuesDontMatchErr: Label 'The tax group values do not match to a specific Tax Group.', Locked = true;
        TaxGroupIdDoesNotMatchATaxGroupErr: Label 'The "taxGroupId" does not match to a Tax Group.', Locked = true;
        TaxGroupCodeDoesNotMatchATaxGroupErr: Label 'The "taxGroupCode" does not match to a Tax Group.', Locked = true;
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific ItemCategory group.', Locked = true;
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Locked = true;
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';

    local procedure SetCalculatedFields()
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // UOM
        BaseUnitOfMeasureJSONText := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Rec, Rec."Base Unit of Measure");
        BaseUnitOfMeasureCode := Rec."Base Unit of Measure";
        if UnitOfMeasure.GET(BaseUnitOfMeasureCode) then
            BaseUnitOfMeasureIdGlobal := UnitOfMeasure.SystemId
        else
            BaseUnitOfMeasureIdGlobal := BlankGUID;

        // Inventory
        InventoryValue := Rec.Inventory;
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(Rec.SystemId);
        CLEAR(BaseUnitOfMeasureIdGlobal);
        CLEAR(BaseUnitOfMeasureCode);
        CLEAR(BaseUnitOfMeasureJSONText);
        CLEAR(InventoryValue);
        TempFieldSet.DELETEALL();
    end;

    local procedure UpdateInventory()
    var
        ItemJournalLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        Rec.calcfields(Inventory);
        if Rec.Inventory = InventoryValue then
            exit;
        ItemJournalLine.Init();
        ItemJournalLine.Validate("Posting Date", Today());
        ItemJournalLine."Document No." := Rec."No.";

        if Rec.Inventory < InventoryValue then
            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.");

        ItemJournalLine.Validate("Item No.", Rec."No.");
        ItemJournalLine.Validate(Description, Rec.Description);
        ItemJournalLine.Validate(Quantity, ABS(InventoryValue - Rec.Inventory));

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
        Rec.Get(Rec."No.");
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.GET(DATABASE::Item, FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Item;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.insert(true);
    end;
}


