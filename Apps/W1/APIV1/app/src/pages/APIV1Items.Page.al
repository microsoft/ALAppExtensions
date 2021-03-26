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
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Description)
                {
                    Caption = 'displayName', Locked = true;
                    ToolTip = 'Specifies the Description for the Item.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Description));
                    end;
                }
                field(type; Type)
                {
                    Caption = 'type', Locked = true;
                    ToolTip = 'Specifies the Type for the Item. Possible values are Inventory and Service.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Type));
                    end;
                }
                field(itemCategoryId; "Item Category Id")
                {
                    Caption = 'itemCategoryId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF "Item Category Id" = BlankGUID THEN
                            "Item Category Code" := ''
                        ELSE BEGIN
                            IF NOT ItemCategory.GetBySystemId("Item Category Id") THEN
                                ERROR(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            "Item Category Code" := ItemCategory.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Item Category Code"));
                        RegisterFieldSet(FIELDNO("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; "Item Category Code")
                {
                    Caption = 'itemCategoryCode', Locked = true;

                    trigger OnValidate()
                    begin
                        IF ItemCategory.Code <> '' THEN BEGIN
                            IF ItemCategory.Code <> "Item Category Code" THEN
                                ERROR(ItemCategoriesValuesDontMatchErr);
                            EXIT;
                        END;

                        IF "Item Category Code" = '' THEN
                            "Item Category Id" := BlankGUID
                        ELSE BEGIN
                            IF NOT ItemCategory.GET("Item Category Code") THEN
                                ERROR(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            "Item Category Id" := ItemCategory.SystemId;
                        END;
                    end;
                }
                field(blocked; Blocked)
                {
                    Caption = 'blocked', Locked = true;
                    ToolTip = 'Specifies whether the item is blocked.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Blocked));
                    end;
                }
                field(baseUnitOfMeasureId; BaseUnitOfMeasureIdGlobal)
                {
                    Caption = 'baseUnitOfMeasureId', Locked = true;

                    trigger OnValidate()
                    begin
                        IF BaseUnitOfMeasureIdGlobal = BlankGUID THEN
                            BaseUnitOfMeasureCode := ''
                        ELSE BEGIN
                            IF NOT ValidateUnitOfMeasure.GetBySystemId(BaseUnitOfMeasureIdGlobal) THEN
                                ERROR(UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr);

                            BaseUnitOfMeasureCode := ValidateUnitOfMeasure.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Unit of Measure Id"));
                        RegisterFieldSet(FIELDNO("Base Unit of Measure"));
                    end;
                }
                field(baseUnitOfMeasure; BaseUnitOfMeasureJSONText)
                {
                    Caption = 'baseUnitOfMeasure', Locked = true;
                    ODataEDMType = 'ITEM-UOM';
                    ToolTip = 'Specifies the Base Unit of Measure.';

                    trigger OnValidate()
                    var
                        UnitOfMeasureFromJSON: Record "Unit of Measure";
                    begin
                        RegisterFieldSet(FIELDNO("Unit of Measure Id"));
                        RegisterFieldSet(FIELDNO("Base Unit of Measure"));

                        IF BaseUnitOfMeasureJSONText = 'null' THEN
                            EXIT;

                        GraphCollectionMgtItem.ParseJSONToUnitOfMeasure(BaseUnitOfMeasureJSONText, UnitOfMeasureFromJSON);

                        IF (ValidateUnitOfMeasure.Code <> '') AND
                           (ValidateUnitOfMeasure.Code <> UnitOfMeasureFromJSON.Code)
                        THEN
                            ERROR(UnitOfMeasureValuesDontMatchErr);
                    end;
                }
                field(gtin; GTIN)
                {
                    Caption = 'GTIN', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(GTIN));
                    end;
                }
                field(inventory; InventoryValue)
                {
                    Caption = 'inventory', Locked = true;
                    ToolTip = 'Specifies the inventory for the item.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Inventory));
                    end;
                }
                field(unitPrice; "Unit Price")
                {
                    Caption = 'unitPrice', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Unit Price"));
                    end;
                }
                field(priceIncludesTax; "Price Includes VAT")
                {
                    Caption = 'priceIncludesTax', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Price Includes VAT"));
                    end;
                }
                field(unitCost; "Unit Cost")
                {
                    Caption = 'unitCost', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Unit Cost"));
                    end;
                }
                field(taxGroupId; "Tax Group Id")
                {
                    Caption = 'taxGroupId', Locked = true;
                    ToolTip = 'Specifies the ID of the tax group.';

                    trigger OnValidate()
                    begin
                        IF "Tax Group Id" = BlankGUID THEN
                            "Tax Group Code" := ''
                        ELSE BEGIN
                            IF NOT TaxGroup.GetBySystemId("Tax Group Id") THEN
                                ERROR(TaxGroupIdDoesNotMatchATaxGroupErr);

                            "Tax Group Code" := TaxGroup.Code;
                        END;

                        RegisterFieldSet(FIELDNO("Tax Group Code"));
                        RegisterFieldSet(FIELDNO("Tax Group Id"));
                    end;
                }
                field(taxGroupCode; "Tax Group Code")
                {
                    Caption = 'taxGroupCode', Locked = true;

                    trigger OnValidate()
                    begin
                        IF TaxGroup.Code <> '' THEN BEGIN
                            IF TaxGroup.Code <> "Tax Group Code" THEN
                                ERROR(TaxGroupValuesDontMatchErr);
                            EXIT;
                        END;

                        IF "Tax Group Code" = '' THEN
                            "Tax Group Id" := BlankGUID
                        ELSE BEGIN
                            IF NOT TaxGroup.GET("Tax Group Code") THEN
                                ERROR(TaxGroupCodeDoesNotMatchATaxGroupErr);

                            "Tax Group Id" := TaxGroup.SystemId;
                        END;

                        RegisterFieldSet(FIELDNO("Tax Group Code"));
                        RegisterFieldSet(FIELDNO("Tax Group Id"));
                    end;
                }
                field(lastModifiedDateTime; "Last DateTime Modified")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
                }
                part(picture; "APIV1 - Pictures")
                {
                    Caption = 'picture';
                    EntityName = 'picture';
                    EntitySetName = 'picture';
                    SubPageLink = Id = FIELD(SystemId);
                }
                part(defaultDimensions; "APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions', Locked = true;
                    EntityName = 'defaultDimensions';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = FIELD(SystemId);
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
        IF TempFieldSet.GET(DATABASE::Item, FIELDNO("Base Unit of Measure")) THEN
            IF BaseUnitOfMeasureJSONText = '' THEN
                BaseUnitOfMeasureJSONText := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Rec, BaseUnitOfMeasureCode);

        IF TempFieldSet.GET(DATABASE::Item, FIELDNO(Inventory)) THEN
            Error(InventoryCannotBeChangedInAPostRequestErr);

        GraphCollectionMgtItem.InsertItem(Rec, TempFieldSet, BaseUnitOfMeasureJSONText);

        SetCalculatedFields();
        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Item: Record Item;
    begin
        IF TempFieldSet.GET(DATABASE::Item, FIELDNO("Base Unit of Measure")) THEN BEGIN
            VALIDATE("Base Unit of Measure", BaseUnitOfMeasureCode);
            IF xRec."Base Unit of Measure" <> "Base Unit of Measure" THEN
                BaseUnitOfMeasureJSONText := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Rec, "Base Unit of Measure");
        END;

        IF TempFieldSet.GET(DATABASE::Item, FIELDNO(Inventory)) THEN
            UpdateInventory();

        Item.GetBySystemId(SystemId);

        GraphCollectionMgtItem.ProcessComplexTypes(
          Rec,
          BaseUnitOfMeasureJSONText
          );

        IF "No." = Item."No." THEN
            MODIFY(TRUE)
        ELSE BEGIN
            Item.TRANSFERFIELDS(Rec, FALSE);
            Item.RENAME("No.");
            TRANSFERFIELDS(Item, TRUE);
        END;

        SetCalculatedFields();

        EXIT(FALSE);
    end;

    trigger OnOpenPage()
    begin
        SetAutoCalcFields(Inventory);
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
        BaseUnitOfMeasureJSONText := GraphCollectionMgtItem.ItemUnitOfMeasureToJSON(Rec, "Base Unit of Measure");
        BaseUnitOfMeasureCode := "Base Unit of Measure";
        IF UnitOfMeasure.GET(BaseUnitOfMeasureCode) THEN
            BaseUnitOfMeasureIdGlobal := UnitOfMeasure.SystemId
        ELSE
            BaseUnitOfMeasureIdGlobal := BlankGUID;

        // Inventory
        InventoryValue := Inventory;
    end;

    local procedure ClearCalculatedFields()
    begin
        CLEAR(SystemId);
        CLEAR(BaseUnitOfMeasureIdGlobal);
        CLEAR(BaseUnitOfMeasureCode);
        CLEAR(BaseUnitOfMeasureJSONText);
        CLEAR(InventoryValue);
        TempFieldSet.DELETEALL();
    end;

    local procedure UpdateInventory()
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        calcfields(Inventory);
        IF Inventory = InventoryValue THEN
            EXIT;
        ItemJnlLine.Init();
        ItemJnlLine.VALIDATE("Posting Date", Today());
        ItemJnlLine."Document No." := "No.";

        IF Inventory < InventoryValue THEN
            ItemJnlLine.VALIDATE("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        ELSE
            ItemJnlLine.VALIDATE("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        ItemJnlLine.VALIDATE("Item No.", "No.");
        ItemJnlLine.VALIDATE(Description, Description);
        ItemJnlLine.VALIDATE(Quantity, ABS(InventoryValue - Inventory));

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
        Get("No.");
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::Item, FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Item;
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;
}

