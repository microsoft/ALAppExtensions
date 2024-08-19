namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;

/// <summary>
/// Page Shpfy Variants (ID 30127).
/// </summary>
page 30127 "Shpfy Variants"
{

    Caption = 'Shopify Variants';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    SourceTable = "Shpfy Variant";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique numeric identifier for the product variant. Each product has always one variant.';
                }
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Item Card";
                    ToolTip = 'Specifies the item number.';

                    trigger OnDrillDown()
                    var
                        Item: Record Item;
                        ItemCard: Page "Item Card";
                    begin
                        if Item.GetBySystemId(Rec."Item SystemId") then begin
                            Item.SetRecFilter();
                            ItemCard.SetTableView(Item);
                            ItemCard.Run();
                        end;
                    end;
                }
                field(VariantCode; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Item Variants";
                    ToolTip = 'Specifies the code of the item variant.';

                    trigger OnDrillDown()
                    var
                        ItemVariant: Record "Item Variant";
                        ItemVariants: Page "Item Variants";
                    begin
                        if ItemVariant.GetBySystemId(Rec."Item Variant SystemId") then begin
                            ItemVariant.SetRecFilter();
                            ItemVariants.SetTableView(ItemVariant);
                            ItemVariants.Run();
                        end;
                    end;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title of the product variant. The title field is a concatenation of the option1, option2, and option3 fields.';
                }
                field(OptionName1; Rec."Option 1 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the custom properties that a shop owner uses to define product variants. You can define three options for a product variant.';
                }
                field(OptionValue1; Rec."Option 1 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the first option.';
                }
                field(OptionName2; Rec."Option 2 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the custom properties that a shop owner uses to define product variants. You can define three options for a product variant.';
                }
                field(OptionValue2; Rec."Option 2 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the second option.';
                }
                field(OptionName3; Rec."Option 3 Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the custom properties that a shop owner uses to define product variants. You can define three options for a product variant.';
                }
                field(OptionValue3; Rec."Option 3 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the third option.';
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price of a product variant.';
                }
                field(Barcode; Rec.Barcode)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the barcode, UPC, or ISBN number for the product.';
                }
                field(AvailableForSales; Rec."Available For Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the variants is available for sales.';
                }
                field(SKU; Rec.SKU)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the product variant in the shop.';
                }
                field(CreatedAt; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the product variant was created.';
                }
                field(UpdatedAt; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the product variant was last modified.';
                }
                field(InventoryPolicy; Rec."Inventory Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether customers are allowed to place an order for the product variant when it is out of stock. Valid values are: deny, continue.';
                }
                field(Taxable; Rec.Taxable)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a tax is charged when the product variant is sold.';
                }
                field(TaxCode; Rec."Tax Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Avalara tax code for the product variant. This parameter applies only to the stores that have the Avalara AvaTax app installed.';
                }
                field(UnitCost; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost of one unit for the variant.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the weight of the product variant.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MapProduct)
            {
                ApplicationArea = All;
                Caption = 'Map Product';
                Image = Relationship;
                ToolTip = 'Manually map products from Shopify with an item.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ItemList: Page "Item List";
                begin
                    Rec.Testfield(Id);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal() = Action::LookupOK then begin
                        ItemList.GetRecord(Item);
                        Rec."Item SystemId" := Item.SystemId;
                        Clear(Rec."Item Variant SystemId");
                        Rec."Mapped By Item" := true;
                        Rec.Modify();
                    end;
                end;
            }

            action(MapVariant)
            {
                ApplicationArea = All;
                Caption = 'Map Variant';
                Image = Relationship;
                ToolTip = 'Manually map products from Shopify with an item.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ItemVariant: Record "Item Variant";
                    ItemVariantList: Page "Item Variants";
                begin
                    Rec.Testfield(Id);
                    if Item.GetBySystemId(Rec."Item SystemId") then begin
                        ItemVariantList.LookupMode := true;
                        ItemVariant.SetRange("Item No.", Item."No.");
                        ItemVariantList.SetTableView(ItemVariant);
                        if ItemVariantList.RunModal() = Action::LookupOK then begin
                            ItemVariantList.GetRecord(ItemVariant);
                            Rec."Item Variant SystemId" := ItemVariant.SystemId;
                            Rec."Mapped By Item" := false;
                            Rec.Modify();
                        end;
                    end;
                end;
            }
            action(Metafields)
            {
                ApplicationArea = All;
                Caption = 'Metafields';
                Image = PriceAdjustment;
                ToolTip = 'Add metafields to a variant. This can be used for adding custom data fields to variants in Shopify.';

                trigger OnAction()
                var
                    Metafields: Page "Shpfy Metafields";
                begin
                    Metafields.RunForResource(Database::"Shpfy Variant", Rec.Id, Rec."Shop Code");
                end;
            }
            action(AddItemsAsVariants)
            {
                ApplicationArea = All;
                Caption = 'Add Items as Shopify Variants';
                Image = AddAction;
                ToolTip = 'Add existing items as new Shopify variants for the selected parent product.';

                trigger OnAction()
                var
                    AddItemAsVariant: Report "Shpfy Add Item As Variant";
                    ParentProductId: BigInteger;
                begin
                    Rec.FilterGroup(4);
                    Evaluate(ParentProductId, Rec.GetFilter("Product Id"));
                    Rec.FilterGroup(0);

                    AddItemAsVariant.SetParentProduct(ParentProductId);
                    AddItemAsVariant.Run();
                end;
            }
        }
    }
}
