page 30008 "APIV2 - Items"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Item';
    EntitySetCaption = 'Items';
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
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Description)
                {
                    Caption = 'DisplayName';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
                }
                field(type; Type)
                {
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Type));
                    end;
                }
                field(itemCategoryId; "Item Category Id")
                {
                    Caption = 'Item Category Id';

                    trigger OnValidate()
                    begin
                        if "Item Category Id" = BlankGUID then
                            "Item Category Code" := ''
                        else begin
                            if not ItemCategory.GetBySystemId("Item Category Id") then
                                Error(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            "Item Category Code" := ItemCategory.Code;
                        end;

                        RegisterFieldSet(FieldNo("Item Category Code"));
                        RegisterFieldSet(FieldNo("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; "Item Category Code")
                {
                    Caption = 'Item Category Code';

                    trigger OnValidate()
                    begin
                        if ItemCategory.Code <> '' then begin
                            if ItemCategory.Code <> "Item Category Code" then
                                Error(ItemCategoriesValuesDontMatchErr);
                            exit;
                        end;

                        if "Item Category Code" = '' then
                            "Item Category Id" := BlankGUID
                        else begin
                            if not ItemCategory.Get("Item Category Code") then
                                Error(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            "Item Category Id" := ItemCategory.SystemId;
                        end;
                    end;
                }
                field(blocked; Blocked)
                {
                    Caption = 'Blocked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Blocked));
                    end;
                }
                field(gtin; GTIN)
                {
                    Caption = 'GTIN';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(GTIN));
                    end;
                }
                field(inventory; InventoryValue)
                {
                    Caption = 'Inventory';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Inventory));
                    end;
                }
                field(unitPrice; "Unit Price")
                {
                    Caption = 'Unit Price';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit Price"));
                    end;
                }
                field(priceIncludesTax; "Price Includes VAT")
                {
                    Caption = 'Price Includes Tax';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Price Includes VAT"));
                    end;
                }
                field(unitCost; "Unit Cost")
                {
                    Caption = 'Unit Cost';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit Cost"));
                    end;
                }
                field(taxGroupId; "Tax Group Id")
                {
                    Caption = 'Tax Group Id';

                    trigger OnValidate()
                    begin
                        if "Tax Group Id" = BlankGUID then
                            "Tax Group Code" := ''
                        else begin
                            if not TaxGroup.GetBySystemId("Tax Group Id") then
                                Error(TaxGroupIdDoesNotMatchATaxGroupErr);

                            "Tax Group Code" := TaxGroup.Code;
                        end;

                        RegisterFieldSet(FieldNo("Tax Group Code"));
                        RegisterFieldSet(FieldNo("Tax Group Id"));
                    end;
                }
                field(taxGroupCode; "Tax Group Code")
                {
                    Caption = 'Tax Group Code';

                    trigger OnValidate()
                    begin
                        if TaxGroup.Code <> '' then begin
                            if TaxGroup.Code <> "Tax Group Code" then
                                Error(TaxGroupValuesDontMatchErr);
                            exit;
                        end;

                        if "Tax Group Code" = '' then
                            "Tax Group Id" := BlankGUID
                        else begin
                            if not TaxGroup.Get("Tax Group Code") then
                                Error(TaxGroupCodeDoesNotMatchATaxGroupErr);

                            "Tax Group Id" := TaxGroup.SystemId;
                        end;

                        RegisterFieldSet(FieldNo("Tax Group Code"));
                        RegisterFieldSet(FieldNo("Tax Group Id"));
                    end;
                }
                field(baseUnitOfMeasureId; "Unit of Measure Id")
                {
                    Caption = 'Base Unit Of Measure Id';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit of Measure Id"));
                    end;
                }
                field(baseUnitOfMeasureCode; "Base Unit of Measure")
                {
                    Caption = 'Base Unit Of Measure Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Base Unit of Measure"));
                    end;
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
                part(baseUnitOfMeasure; "APIV2 - Units of Measure")
                {
                    //TODO - WaitingModernDevProperty, Caption = 'Unit Of Measure';
                    CaptionML = ENU = 'Multiplicity=ZeroOrOne';
                    EntityName = 'unitOfMeasure';
                    EntitySetName = 'unitsOfMeasure';
                    SubPageLink = SystemId = Field("Unit of Measure Id");
                }
                part(picture; "APIV2 - Pictures")
                {
                    //TODO - WaitingModernDevProperty, Caption = 'Picture';
                    CaptionML = ENU = 'Multiplicity=ZeroOrOne';
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(2);
                }
                part(defaultDimensions; "APIV2 - Default Dimensions")
                {
                    Caption = 'Default Dimensions';
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = Field(SystemId), "Parent Type" = const(2);
                }
                part(itemVariants; "APIV2 - Item Variants")
                {
                    Caption = 'Variants';
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
        if TempFieldSet.Get(Database::Item, FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);

        GraphCollectionMgtItem.InsertItem(Rec, TempFieldSet);

        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Item: Record Item;
    begin

        if TempFieldSet.Get(Database::Item, FieldNo(Inventory)) then
            UpdateInventory();

        Item.GetBySystemId(SystemId);

        if "No." = Item."No." then
            Modify(true)
        else begin
            Item.TransferFields(Rec, false);
            Item.Rename("No.");
            TransferFields(Item, true);
        end;

        SetCalculatedFields();

        exit(false);
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
        InventoryValue: Decimal;
        UnitOfMeasureValuesDontMatchErr: Label 'The unit of measure values do not match to a specific Unit of Measure.';
        UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr: Label 'The "unitOfMeasureId" does not match to a Unit of Measure.', Comment = 'unitOfMeasureId is a field name and should not be translated.';
        BlankGUID: Guid;
        TaxGroupValuesDontMatchErr: Label 'The tax group values do not match to a specific Tax Group.';
        TaxGroupIdDoesNotMatchATaxGroupErr: Label 'The "taxGroupId" does not match to a Tax Group.', Comment = 'taxGroupId is a field name and should not be translated.';
        TaxGroupCodeDoesNotMatchATaxGroupErr: Label 'The "taxGroupCode" does not match to a Tax Group.', Comment = 'taxGroupCode is a field name and should not be translated.';
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific Item Category group.', Comment = 'itemCategoryId is a field name and should not be translated.';
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Comment = 'itemCategoryCode is a field name and should not be translated.';
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';

    local procedure SetCalculatedFields()
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // Inventory
        InventoryValue := Inventory;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(SystemId);
        Clear(InventoryValue);
        TempFieldSet.DeleteAll();
    end;

    local procedure UpdateInventory()
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        calcfields(Inventory);
        if Inventory = InventoryValue then
            exit;
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Posting Date", Today());
        ItemJnlLine."Document No." := "No.";

        if Inventory < InventoryValue then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        ItemJnlLine.Validate("Item No.", "No.");
        ItemJnlLine.Validate(Description, Description);
        ItemJnlLine.Validate(Quantity, Abs(InventoryValue - Inventory));

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
        Get("No.");
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Item, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Item;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}

