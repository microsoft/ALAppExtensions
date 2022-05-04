/// <summary>
/// Page Shpfy Shop Card (ID 30101).
/// </summary>
page 30101 "Shpfy Shop Card"
{
    Caption = 'Shopify Shop Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Related,Synchronization';
    SourceTable = "Shpfy Shop";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this Shopify Shop.';
                }
                field("Shopify URL"; Rec."Shopify URL")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the URL of the Shopify Shop.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field(HasAccessKey; Rec.HasAccessToken())
                {
                    ApplicationArea = All;
                    Caption = 'Has AccessKey';
                    ShowMandatory = true;
                    ToolTip = 'Is an access key available for this store.';
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the currency of the Shopify Shop.';
                }
                field(LanguageCode; Rec."Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the language of the Shopify Shop.';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the service is enabled.';
                }
                field(LogActivated; Rec."Log Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the log is activated.';
                }
                field(AllowBackgroudSyncs; Rec."Allow Background Syncs")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether background syncs are allowed.';
                }
            }
            group(ItemSync)
            {
                Caption = 'Item Synchronization';
                field(SyncItem; Rec."Sync Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies in which direction items are synchronized.';
                }
                field(AutoCreateUnknownItems; Rec."Auto Create Unknown Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if unknown items are automatically created in D365BC when synchronizing from Shopify.';
                }
                field(ShopifyCanUpdateItems; Rec."Shopify Can Update Items")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether Shopify can update items when synchronizing from Shopify.';
                }
                field(CanUpdateShopifyProducts; Rec."Can Update Shopify Products")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether D365BC can update products when synchronizing to Shopify.';
                }
                field(ItemTemplateCode; Rec."Item Template Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies which item template to use when creating unknown items.';
                }

                field(CustomerPriceGroup; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which price should be used for an item in Shopify. The sales price of this customer price group is taken. If no group is entered, the group of the "Customer Template Code" is used.';
                }
                field(CustomerDiscountGroup; Rec."Customer Discount Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies  which discount should be used for an item in Shopify. The sales discount of this customer discount group is taken. If no group is entered, the discount group from the "Customer Template Code" is used.';
                }

                field(SyncItemImages; Rec."Sync Item Images")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether you want to synchronize item images and in which direction.';
                }
                field(SyncItemExtendedText; Rec."Sync Item Extended Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether you want to synchronize extended texts to Shopify.';
                }
                field(SyncItemAttributes; Rec."Sync Item Attributes")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether you want to synchronize item attributes to Shopify.';
                }
                field(UOMAsVariant; Rec."UoM as Variant")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to have the different unit of measures as an variant in Shopify.';
                    Visible = false;
                }
                field(OptionNameForUOM; Rec."Option Name for UoM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant option name for the unit of measure.';
                    Visible = false;
                }
                field(VariantPrefix; Rec."Variant Prefix")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the prefix for variants. The variants you have defined in Shopify are created in Business Central based on an increasing number.';
                }
                field(SKUType; Rec."SKU Mapping")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies if and based on what you want to create variants in D365BC.';
                }
                field(SKUFieldSeparator; Rec."SKU Field Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a field separator for the SKU if you use "Item. No + Variant Code" to create a variant.';
                }
                field(CreateProductStatusValue; Rec."Status for Created Products")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of a product in Shopify when an item is create in Shopify via the sync.';
                }
                field(RemoveProductAction; Rec."Action for Removed Products")
                {
                    ApplicationArea = all;
                    ToolTip = 'Specifies the status of a product in Shopify when an item is removed in Shopify via the sync.';
                }
            }
            group(InventorySync)
            {
                Caption = 'Inventory Synchronization';
                field(InventoryTracket; Rec."Inventory Tracked")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to manage your inventory in Shopify based on D365BC.';
                }
                field(DefaultInventoryPolicy; Rec."Default Inventory Policy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to prevent negative inventory. With "continue" the inventory can go negative, with "Deny" you want to prevent negative inventory.';
                }
            }
            group(CustomerSync)
            {
                Caption = 'Customer Synchronization';
                field(CustomerImportFromShopify; Rec."Customer Import From Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified how Shopify customers are synced to Business Central. If you choose none and there exists no mapping for that customer, the default customer will be used if exists.';
                }
                field(CustomerMappingType; Rec."Customer Mapping Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to map customers.';
                }
                field(AutoCreateUnknownCustomers; Rec."Auto Create Unknown Customers")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if unknown customers are automatically created in D365BC when synchronizing from Shopify.';
                }
                field(CustomerTemplateCode; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies which customer template to use when creating unknown customers and for calculating prices.';
                }

                field(DefaultCustomer; Rec."Default Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default customer when not creating a customer for each webshop user.';
                }
                field(ShopifyCanUpdateCustomer; Rec."Shopify Can Update Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether Shopify can update customers when synchronizing from Shopify.';
                }
                field(ExportCustomerToShopify; Rec."Export Customer To Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to export all customers with a valid e-mail address from D365BC to Shopify.';
                }
                field(CanUpdateShopifyCustomer; Rec."Can Update Shopify Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether D365BC can update customers when synchronizing to Shopify.';
                }

                field(NameSource; Rec."Name Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to synchronize the name of the customer. If the value is empty then the value of Name 2 is taken, and Name 2 will be empty.';
                }
                field(Name2Source; Rec."Name 2 Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to synchronize Name 2 of the customer.';
                }
                field(ContactSource; Rec."Contact Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to synchronize the contact of the customer.';
                }
                field(CountySource; Rec."County Source")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to synchronize the county of the customer.';
                }
            }
            group(OrderProcessing)
            {
                Caption = 'Order Processing';
                field(ShippingCostAccount; Rec."Shipping Charges Account")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'G/L Account for posting the shipping cost.';
                }
                field(SoldGiftCardAccount; Rec."Sold Gift Card Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'G/L Account for to post the sold gift card amounts.';
                }
                field(TipAccount; Rec."Tip Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'G/L Account for post the received tip amount.';
                }
                field(ShopifyOrderNoOnDocLine; Rec."Shopify Order No. on Doc. Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Shopify Order No. is shown in the document line.';
                }
                field(AutoCreateOrders; Rec."Auto Create Orders")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether orders may be created automatically.';
                }
                field(TaxAreaSource; Rec."Tax Area Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tax area source and the sequence to be followed.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Locations)
            {
                ApplicationArea = All;
                Caption = 'Locations';
                Image = Bins;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Shpfy Shop Locations Mapping";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'View the Shopify Shop locations and link them with the related location(s).';
            }
            action(Products)
            {
                ApplicationArea = All;
                Caption = 'Products';
                Image = Item;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Shpfy Products";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'Add, view or edit detailed information for the products that you trade in through Shopify. ';
            }
            action(ShipmentMethods)
            {
                ApplicationArea = All;
                Caption = 'Shipment Method Mapping';
                Image = Translate;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Maps the Shopify shipment methods to the related shipment methods.';

                trigger OnAction()
                var
                    ShipmentMethod: Record "Shpfy Shipment Method Mapping";
                    Shop: Record "Shpfy Shop";
                    ShipmentMethods: Codeunit "Shpfy Shipping Methods";
                begin
                    CurrPage.SaveRecord();
                    Shop := Rec;
                    Shop.SetRecFilter();
                    ShipmentMethods.GetShippingMethods(Shop);
                    ShipmentMethod.SetRange("Shop Code", Rec.Code);
                    Page.Run(Page::"Shpfy Shipment Methods Mapping", ShipmentMethod);
                end;
            }
            action(PaymentMethods)
            {
                ApplicationArea = All;
                Caption = 'Payment Method Mapping';
                Image = SetupPayment;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Shpfy Payment Methods Mapping";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'Maps the Shopify payment methods to the related payment methods and prioritize them.';
            }
            action(Orders)
            {
                ApplicationArea = All;
                Caption = 'Orders';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View your Shopify agreements with customers to sell certain products on certain delivery and payment terms.';

                trigger OnAction()
                var
                    OrderHeader: Record "Shpfy Order Header";
                    Orders: Page "Shpfy Orders";
                begin
                    OrderHeader.SetRange("Shop Code", Rec.Code);
                    Orders.SetTableView(OrderHeader);
                    Orders.Run();
                end;
            }
            action(CustomerTemplates)
            {
                ApplicationArea = All;
                Caption = 'Customer Templates';
                Image = Template;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Shpfy Customer Templates";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'Set up a customer template and default customer per country.';
            }
        }
        area(Processing)
        {
            group(Access)
            {
                action(RequestAccess)
                {
                    ApplicationArea = All;
                    Image = EncryptionKeys;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    Caption = 'Request Access';
                    ToolTip = 'Request Access to your Shopify store.';

                    trigger OnAction()
                    begin
                        Rec.RequestAccessToken();
                    end;
                }
            }
            group(Sync)
            {
                action(SyncProducts)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Products';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize products for this Shopify Shop. The direction depends on the settings in the Shopify Shop Card.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.ProductsSync(Rec.Code);
                    end;
                }
                action(SyncImages)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Product Images';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize product images for this Shopify Shop. The direction depends on the settings in the Shopify Shop Card.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.ProductImagesSync(Rec.Code);
                    end;
                }
                action(SyncInventory)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Inventory';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize the inventory to Shopify.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.InventorySync(Rec.Code);
                    end;
                }
                action(SyncCustomers)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Customers';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize the customers from Shopify. The way customers are imported depends on the settings in the Shopify Shop Card.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.CustomerSync(Rec.Code);
                    end;
                }
                action(SyncPayouts)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Payouts';
                    Image = PaymentHistory;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize all movements of money between a Shopify Payment account balance and a connected bank account.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.PayoutsSync(Rec.Code);
                    end;
                }
                action(SyncAll)
                {
                    ApplicationArea = All;
                    Caption = 'Sync All';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    ToolTip = 'Execute all synchronizations (Products, Product images, Inventory, Customers and payouts) in batch.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.CustomerSync(Rec);
                        BackgroundSyncs.ProductsSync(Rec);
                        BackgroundSyncs.InventorySync(Rec);
                        BackgroundSyncs.ProductImagesSync(Rec);
                    end;
                }
            }

            group(SyncReset)
            {
                Caption = 'Reset Sync';
                Image = ImportExcel;

                action(ResetProducts)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Products Sync';
                    Image = ClearFilter;
                    Tooltip = 'Ensure all products are synced when executing the sync, not just the changes since last sync.';

                    trigger OnAction()
                    begin
                        Rec.SetLastSyncTime("Shpfy Synchronization Type"::Products, GetResetSyncTo(Rec.GetLastSyncTime("Shpfy Synchronization Type"::Products)));
                    end;
                }
                action(ResetCustomers)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Customer Sync';
                    Image = ClearFilter;
                    Tooltip = 'Ensure all customers are synced when executing the sync, not just the changes since last sync.';

                    trigger OnAction()
                    begin
                        Rec.SetLastSyncTime("Shpfy Synchronization Type"::Customers, GetResetSyncTo(Rec.GetLastSyncTime("Shpfy Synchronization Type"::Customers)));
                    end;
                }
                action(ResetOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Orders Sync';
                    Image = ClearFilter;
                    Tooltip = 'Ensure all orders are synced when executing the sync, not just the changes since last sync.';

                    trigger OnAction()
                    begin
                        Rec.SetLastSyncTime("Shpfy Synchronization Type"::Orders, GetResetSyncTo(Rec.GetLastSyncTime("Shpfy Synchronization Type"::Orders)));
                    end;
                }
            }
        }
    }

    local procedure GetResetSyncTo(InitDateTime: DateTime): DateTime
    var
        DateTimeDlg: Page "Date-Time Dialog";
        ResetSyncLbl: Label 'Reset Sync to';
    begin
        DateTimeDlg.SetDateTime(InitDateTime);
        DateTimeDlg.Caption := ResetSyncLbl;
        DateTimeDlg.LookupMode := true;
        if DateTimeDlg.RunModal() = Action::LookupOK then
            exit(DateTimeDlg.GetDateTime());
        exit(InitDateTime);
    end;
}
