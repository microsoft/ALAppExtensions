namespace Microsoft.API.V2;

using Microsoft.Foundation.UOM;
using Microsoft.Inventory.Item;
using Microsoft.Finance.SalesTax;
using Microsoft.Integration.Graph;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Posting;

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
    AboutText = 'Exposes item master data including product descriptions, pricing, unit costs, tax groups, categorization, and real-time inventory levels. Supports full CRUD operations for creating, updating, retrieving, and deleting items, enabling seamless synchronization of product catalogs and inventory between Business Central and external e-commerce, warehouse, or retail systems.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Display Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(displayName2; Rec."Description 2")
                {
                    Caption = 'Display Name 2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Description 2"));
                    end;
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Type));
                    end;
                }
                field(itemCategoryId; Rec."Item Category Id")
                {
                    Caption = 'Item Category Id';

                    trigger OnValidate()
                    begin
                        if Rec."Item Category Id" = BlankGUID then
                            Rec."Item Category Code" := ''
                        else begin
                            if not ItemCategory.GetBySystemId(Rec."Item Category Id") then
                                Error(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            Rec."Item Category Code" := ItemCategory.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Item Category Code"));
                        RegisterFieldSet(Rec.FieldNo("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; Rec."Item Category Code")
                {
                    Caption = 'Item Category Code';

                    trigger OnValidate()
                    begin
                        if ItemCategory.Code <> '' then begin
                            if ItemCategory.Code <> Rec."Item Category Code" then
                                Error(ItemCategoriesValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Item Category Code" = '' then
                            Rec."Item Category Id" := BlankGUID
                        else begin
                            if not ItemCategory.Get(Rec."Item Category Code") then
                                Error(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            Rec."Item Category Id" := ItemCategory.SystemId;
                        end;
                    end;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Blocked));
                    end;
                }
                field(gtin; Rec.GTIN)
                {
                    Caption = 'GTIN';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(GTIN));
                    end;
                }
                field(inventory; InventoryValue)
                {
                    Caption = 'Inventory';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Inventory));
                    end;
                }
                field(unitPrice; Rec."Unit Price")
                {
                    Caption = 'Unit Price';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit Price"));
                    end;
                }
                field(priceIncludesTax; Rec."Price Includes VAT")
                {
                    Caption = 'Price Includes Tax';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Price Includes VAT"));
                    end;
                }
                field(unitCost; Rec."Unit Cost")
                {
                    Caption = 'Unit Cost';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Unit Cost"));
                    end;
                }
                field(taxGroupId; Rec."Tax Group Id")
                {
                    Caption = 'Tax Group Id';

                    trigger OnValidate()
                    begin
                        if Rec."Tax Group Id" = BlankGUID then
                            Rec."Tax Group Code" := ''
                        else begin
                            if not TaxGroup.GetBySystemId(Rec."Tax Group Id") then
                                Error(TaxGroupIdDoesNotMatchATaxGroupErr);

                            Rec."Tax Group Code" := TaxGroup.Code;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        RegisterFieldSet(Rec.FieldNo("Tax Group Id"));
                    end;
                }
                field(taxGroupCode; Rec."Tax Group Code")
                {
                    Caption = 'Tax Group Code';

                    trigger OnValidate()
                    begin
                        if TaxGroup.Code <> '' then begin
                            if TaxGroup.Code <> Rec."Tax Group Code" then
                                Error(TaxGroupValuesDontMatchErr);
                            exit;
                        end;

                        if Rec."Tax Group Code" = '' then
                            Rec."Tax Group Id" := BlankGUID
                        else begin
                            if not TaxGroup.Get(Rec."Tax Group Code") then
                                Error(TaxGroupCodeDoesNotMatchATaxGroupErr);

                            Rec."Tax Group Id" := TaxGroup.SystemId;
                        end;

                        RegisterFieldSet(Rec.FieldNo("Tax Group Code"));
                        RegisterFieldSet(Rec.FieldNo("Tax Group Id"));
                    end;
                }
                field(baseUnitOfMeasureId; Rec."Unit of Measure Id")
                {
                    Caption = 'Base Unit Of Measure Id';

                    trigger OnValidate()
                    begin
                        if not IsNullGuid(Rec."Unit of Measure Id") then
                            if not ValidateUnitOfMeasure.GetBySystemId(Rec."Unit of Measure Id") then
                                Error(UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr);

                        BaseUnitOfMeasureIdValidated := true;

                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Id"));
                        RegisterFieldSet(Rec.FieldNo("Base Unit of Measure"));
                    end;
                }
                field(baseUnitOfMeasureCode; Rec."Base Unit of Measure")
                {
                    Caption = 'Base Unit Of Measure Code';

                    trigger OnValidate()
                    begin
                        if (Rec."Base Unit of Measure" <> '') and (ValidateUnitOfMeasure.Code <> '') then
                            if ValidateUnitOfMeasure.Code <> Rec."Base Unit of Measure" then
                                Error(UnitOfMeasureValuesDontMatchErr);

                        BaseUnitOfMeasureCodeValidated := true;

                        RegisterFieldSet(Rec.FieldNo("Unit of Measure Id"));
                        RegisterFieldSet(Rec.FieldNo("Base Unit of Measure"));
                    end;
                }
                field(generalProductPostingGroupId; Rec."Gen. Prod. Posting Group Id")
                {
                    Caption = 'General Product Posting Group Id';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Prod. Posting Group Id"));
                    end;
                }
                field(generalProductPostingGroupCode; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'General Product Posting Group Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Prod. Posting Group"));
                    end;
                }
                field(inventoryPostingGroupId; Rec."Inventory Posting Group Id")
                {
                    Caption = 'Inventory Posting Group Id';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Inventory Posting Group Id"));
                    end;
                }
                field(inventoryPostingGroupCode; Rec."Inventory Posting Group")
                {
                    Caption = 'Inventory Posting Group Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Inventory Posting Group"));
                    end;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }

                part(inventoryPostingGroup; "APIV2 - Inventory Post. Group")
                {
                    Caption = 'Inventory Posting Group';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'inventoryPostingGroup';
                    EntitySetName = 'inventoryPostingGroups';
                    SubPageLink = SystemId = field("Inventory Posting Group Id");
                }
                part(generalProductPostingGroup; "APIV2 - Gen. Prod. Post. Group")
                {
                    Caption = 'General Product Posting Group';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'generalProductPostingGroup';
                    EntitySetName = 'generalProductPostingGroups';
                    SubPageLink = SystemId = field("Gen. Prod. Posting Group Id");
                }
                part(baseUnitOfMeasure; "APIV2 - Units of Measure")
                {
                    Caption = 'Unit Of Measure';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'unitOfMeasure';
                    EntitySetName = 'unitsOfMeasure';
                    SubPageLink = SystemId = field("Unit of Measure Id");
                }
                part(picture; "APIV2 - Pictures")
                {
                    Caption = 'Picture';
                    Multiplicity = ZeroOrOne;
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = field(SystemId), "Parent Type" = const(Item);
                }
                part(defaultDimensions; "APIV2 - Default Dimensions")
                {
                    Caption = 'Default Dimensions';
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = field(SystemId), "Parent Type" = const(Item);
                }
                part(itemVariants; "APIV2 - Item Variants")
                {
                    Caption = 'Variants';
                    EntityName = 'itemVariant';
                    EntitySetName = 'itemVariants';
                    SubPageLink = "Item Id" = field(SystemId);
                }
                part(documentAttachments; "APIV2 - Document Attachments")
                {
                    Caption = 'Document Attachments';
                    EntityName = 'documentAttachment';
                    EntitySetName = 'documentAttachments';
                    SubPageLink = "Document Id" = field(SystemId), "Document Type" = const(Item);
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
        exit(InsertItem());
    end;

    trigger OnModifyRecord(): Boolean
    var
        Item: Record Item;
    begin
        if IsInsert then
            exit(InsertItem());

        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            UpdateInventory();

        Item.GetBySystemId(Rec.SystemId);

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
        IsInsert := true;
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        ItemCategory: Record "Item Category";
        TaxGroup: Record "Tax Group";
        ValidateUnitOfMeasure: Record "Unit of Measure";
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        InventoryValue: Decimal;
        BlankGUID: Guid;
        BaseUnitOfMeasureIdValidated: Boolean;
        BaseUnitOfMeasureCodeValidated: Boolean;
        IsInsert: Boolean;
        TaxGroupValuesDontMatchErr: Label 'The tax group values do not match to a specific Tax Group.';
        TaxGroupIdDoesNotMatchATaxGroupErr: Label 'The "taxGroupId" does not match to a Tax Group.', Comment = 'taxGroupId is a field name and should not be translated.';
        TaxGroupCodeDoesNotMatchATaxGroupErr: Label 'The "taxGroupCode" does not match to a Tax Group.', Comment = 'taxGroupCode is a field name and should not be translated.';
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific Item Category group.', Comment = 'itemCategoryId is a field name and should not be translated.';
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Comment = 'itemCategoryCode is a field name and should not be translated.';
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';
        UnitOfMeasureIdDoesNotMatchAUnitOfMeasureErr: Label 'The "baseUnitOfMeasureId" does not match to a Unit of Measure.', Comment = 'baseUnitOfMeasureId is a field name and should not be translated.';
        UnitOfMeasureValuesDontMatchErr: Label 'The unit of measure values do not match to a specific Unit of Measure.';

    local procedure InsertItem(): Boolean
    begin
        if TempFieldSet.Get(Database::Item, Rec.FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);

        if not BaseUnitOfMeasureCodeValidated then
            if BaseUnitOfMeasureIdValidated then begin
                Rec.Validate("Base Unit of Measure", Rec."Base Unit of Measure");
                GraphCollectionMgtItem.ModifyItem(Rec, TempFieldSet);
            end else
                GraphCollectionMgtItem.InsertItem(Rec, TempFieldSet)
        else
            GraphCollectionMgtItem.ModifyItem(Rec, TempFieldSet);

        SetCalculatedFields();
        Clear(IsInsert);
        exit(false);
    end;

    local procedure SetCalculatedFields()
    begin
        // Inventory
        InventoryValue := Rec.Inventory;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(Rec.SystemId);
        Clear(InventoryValue);
        Clear(BaseUnitOfMeasureCodeValidated);
        Clear(BaseUnitOfMeasureIdValidated);
        TempFieldSet.DeleteAll();
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
        ItemJournalLine.Validate(Quantity, Abs(InventoryValue - Rec.Inventory));

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
        Rec.Get(Rec."No.");
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

