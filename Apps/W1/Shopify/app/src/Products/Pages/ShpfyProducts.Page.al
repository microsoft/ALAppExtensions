namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using System.Environment.Configuration;

/// <summary>
/// Page Shpfy Products (ID 30126).
/// </summary>
page 30126 "Shpfy Products"
{

    ApplicationArea = All;
    Caption = 'Shopify Products';
    InsertAllowed = false;
    ModifyAllowed = true;
    PageType = List;
    PromotedActionCategories = 'New, Process, Report, Synchronization';
    SourceTable = "Shpfy Product";
    UsageCategory = Lists;
    AboutTitle = 'About Shopify products';
    AboutText = '**Products** in Shopify is called **items** in Business Central. This is a list of items you sell in your shop. Map each product you want to sell to an item so that you can synchronize their information.';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ShopCode; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the Shopify Shop where these products are synchronized to/from.';
                }
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a unique identifier for the product. Each id is unique across the Shopify system. No two products will have the same id, even if they''re from different shops.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of the product in Shopify. Valid values are: active, archived, draft. If you change this, this will immediately send to Shopify.';

                    trigger OnValidate()
                    var
                        ProductApi: codeunit "Shpfy Product API";
                    begin
                        if Rec.Status <> xRec.Status then begin
                            ProductApi.SetShop(Rec."Shop Code");
                            ProductApi.UpdateProduct(Rec, xRec);
                        end;
                        CurrPage.SaveRecord();
                    end;
                }
                field(ItemNo; Rec."Item No.")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
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

                    trigger OnAssistEdit()
                    var
                        Item: Record Item;
                        ItemList: Page "Item List";
                    begin
                        ItemList.LookupMode := true;
                        if not IsNullGuid(Rec."Item SystemId") then
                            if Item.GetBySystemId(Rec."Item SystemId") then;
                        ItemList.SetRecord(Item);
                        if ItemList.RunModal() = Action::LookupOK then begin
                            ItemList.GetRecord(Item);
                            Rec."Item SystemId" := Item.SystemId;
                            Rec.Modify();
                        end;
                    end;
                }
                field(Title; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the product in Shopify.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description in Shopify.';
                }
                field(SEOTitle; Rec."SEO Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the title in Shopify used for Search Engine Optimization (SEO). If you change this, this will immediately send to Shopify.';

                    trigger OnValidate()
                    var
                        ProductApi: codeunit "Shpfy Product API";
                    begin
                        if Rec."SEO Title" <> xRec."SEO Title" then begin
                            ProductApi.SetShop(Rec."Shop Code");
                            ProductApi.UpdateProduct(Rec, xRec);
                        end;
                        CurrPage.SaveRecord();
                    end;
                }
                field(SEODescription; Rec."SEO Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description in Shopify used for Search Engine Optimization (SEO). If you change this, this will immediately send to Shopify.';

                    trigger OnValidate()
                    var
                        ProductApi: codeunit "Shpfy Product API";
                    begin
                        if Rec."SEO Description" <> xRec."SEO Description" then begin
                            ProductApi.SetShop(Rec."Shop Code");
                            ProductApi.UpdateProduct(Rec, xRec);
                        end;
                        CurrPage.SaveRecord();
                    end;
                }
                field(CreatedAt; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the product was created.';
                }
                field(UpdatedAt; Rec."Updated At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the product was updated.';
                }
                field(ProductType; Rec."Product Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the product type in Shopify.';
                }
                field(Vendor; Rec.Vendor)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the product''s vendor.';
                }
                field(Url; Rec.URL)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the url to the product on the webshop.';
                }
                field(PreviewUrl; Rec."Preview URL")
                {
                    ApplicationArea = All;
                    ExtendedDatatype = URL;
                    ToolTip = 'Specifies the url to preview the product on the webshop.';
                }
            }
            part(Variants; "Shpfy Variants")
            {
                ApplicationArea = All;
                SubPageLink = "Product Id" = field(Id);
            }
        }
        area(factboxes)
        {
            part(ItemInvoicing; "Item Invoicing FactBox")
            {
                ApplicationArea = All;
                Provider = Variants;
                SubPageLink = "No." = field("Item No.");
            }
            part(ItemTags; "Shpfy Tag Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Parent Table No." = const(30127), "Parent Id" = field(Id);
            }
            part(Stock; "Shpfy Inventory FactBox")
            {
                ApplicationArea = All;
                Provider = Variants;
                SubPageLink = "Variant Id" = field(Id);
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

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Manually map products from Shopify with an item.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ShopifyVariant: Record "Shpfy Variant";
                    ItemList: Page "Item List";
                    NullGuid: Guid;
                begin
                    Rec.Testfield(Id);
                    ItemList.LookupMode := true;
                    if ItemList.RunModal() = Action::LookupOK then begin
                        ItemList.GetRecord(Item);
                        Rec."Item SystemId" := Item.SystemId;
                        Rec.Modify();
                        ShopifyVariant.SetRange("Product Id", Rec.Id);
                        if Rec."Has Variants" then
                            ShopifyVariant.SetRange("Item SystemId", NullGuid);
                        ShopifyVariant.ModifyAll("Item SystemId", Rec."Item SystemId");
                    end;
                end;
            }

            action(AutoMapProduct)
            {
                ApplicationArea = All;
                Caption = 'Try Find Product Mapping';
                Image = Relationship;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Automatically try to map the product from Shopify with an item.';

                trigger OnAction()
                var
                    ProductMapping: Codeunit "Shpfy Product Mapping";
                begin

                    ProductMapping.FindMapping(Rec);
                end;
            }

            action(AutoMapProducts)
            {
                ApplicationArea = All;
                Caption = 'Try Find Mappings';
                Image = Relationship;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Automatically try to map Shopify products to D365BC items / variants.';

                trigger OnAction()
                var
                    ProductMapping: Codeunit "Shpfy Product Mapping";
                begin

                    ProductMapping.FindMappings();
                end;
            }

            action(AddItems)
            {
                ApplicationArea = All;
                Caption = 'Add Items';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Select which items you want to create as products in Shopify.';
                AboutTitle = 'Define shop products';
                AboutText = 'Here you select which items in Business Central you wish to push to become products in Shopify. When you select **Add Items** you will get an option to filter and select the items which are then brought into this list and can be synchronized to Shopify.';

                trigger OnAction()
                var
                    AddItems: Report "Shpfy Add Item to Shopify";
                begin
                    AddItems.SetShop(CopyStr(Rec.GetFilter("Shop Code"), 1, 20));
                    AddItems.Run();
                end;
            }

            action(Tags)
            {
                ApplicationArea = All;
                Caption = 'Tags';
                Image = AdjustItemCost;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Add tags to a product. This can be used for filtering and search in Shopify.';

                trigger OnAction()
                var
                    Tag: Record "Shpfy Tag";
                    Tags: Page "Shpfy Tags";
                begin
                    Tag.SetRange("Parent Table No.", Database::"Shpfy Product");
                    Tag.SetRange("Parent Id", Rec.Id);
                    Tags.SetTableView(Tag);
                    Tags.RunModal();
                end;
            }
            action(Metafields)
            {
                ApplicationArea = All;
                Caption = 'Metafields';
                Image = PriceAdjustment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Add metafields to a product. This can be used for adding custom data fields to products in Shopify.';

                trigger OnAction()
                var
                    Metafields: Page "Shpfy Metafields";
                begin
                    Metafields.RunForResource(Database::"Shpfy Product", Rec.Id, Rec."Shop Code");
                end;
            }
            group(Sync)
            {
                action(SyncProducts)
                {
                    ApplicationArea = All;
                    Caption = 'Products';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize products. The direction depends on the settings in the Shopify Shop Card.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.ProductsSync(Rec."Shop Code");
                    end;
                }
                action(SyncProductPrices)
                {
                    ApplicationArea = All;
                    Caption = 'Prices to Shopify';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize prices to Shopify. The standard price calculation is followed for determining the price.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.ProductPricesSync(Rec."Shop Code");
                    end;
                }
                action(SyncImages)
                {
                    ApplicationArea = All;
                    Caption = 'Product Images';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize product images. The direction depends on the settings in the Shopify Shop Card.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.ProductImagesSync(Rec."Shop Code", '');
                    end;
                }
                action(SyncInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Inventory';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize the inventory to Shopify. The inventory in Shopify is compared and updated.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.InventorySync(Rec."Shop Code");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Shop: Record "Shpfy Shop";
        Product: Record "Shpfy Product";
        MyNotifications: Record "My Notifications";
        ShopMgt: Codeunit "Shpfy Shop Mgt.";
        NoItemNotification: Notification;
    begin
        if Shop.Get(Rec.GetFilter("Shop Code")) then begin
            Product.SetRange("Shop Code", Shop.Code);
            if Product.IsEmpty() then
                if MyNotifications.IsEnabled(ShopMgt.GetNoItemNotificationId()) then begin
                    NoItemNotification.Id := ShopMgt.GetNoItemNotificationId();
                    NoItemNotification.Message := NoItemNotificationMsg;
                    NoItemNotification.Scope := NotificationScope::LocalScope;
                    NoItemNotification.SetData('ShopCode', Shop.Code);
                    if (Shop."Sync Item" = Shop."Sync Item"::" ") or (Shop."Sync Item" = Shop."Sync Item"::"To Shopify") then
                        NoItemNotification.AddAction(AddItemsMsg, Codeunit::"Shpfy Sync Products", 'AddItemsToShopifyNotification');
                    if Shop."Sync Item" = Shop."Sync Item"::"From Shopify" then
                        NoItemNotification.AddAction(SyncProductsMsg, Codeunit::"Shpfy Sync Products", 'SyncProductsNotification');
                    NoItemNotification.AddAction(DontShowThisAgainMsg, Codeunit::"Shpfy Shop Mgt.", 'DisableNoItemNotification');
                    NoItemNotification.Send();
                end;
        end;
    end;

    var
        DontShowThisAgainMsg: Label 'Don''t show this again.';
        AddItemsMsg: Label 'Add Items to Shopify';
        SyncProductsMsg: Label 'Sync Products';
        NoItemNotificationMsg: Label 'There isn''t data here yet. Do you want to synchronize products?';
}
