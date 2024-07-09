namespace Microsoft.Integration.Shopify;

using System.Telemetry;
using System.DateTime;

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
    AboutTitle = 'About Shopify shop details';
    AboutText = 'Set up your Shopify shop and integrate it with Business Central. Specify which data to synchronize back and forth, such as items, inventory status, customers and orders.';

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
                    AboutTitle = 'Name your shop';
                    AboutText = 'Give your shop a name that will make it easy to find in Business Central. For example, a name might reflect what a shop sells, such as Furniture or Coffee, or the country or region it serves.';
                }
                field("Shopify URL"; Rec."Shopify URL")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies the URL of the Shopify Shop.';
                    AboutTitle = 'Get people to your shop';
                    AboutText = 'Provide the URL that people will use to access your shop. For example, *https://myshop.myshopify.com*.';

                    trigger OnValidate()
                    begin
                        Rec.TestField(Enabled, false);
                        CurrPage.SaveRecord();
                    end;
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    Importance = Promoted;
                    ToolTip = 'Specifies if the service is enabled.';
                    AboutTitle = 'Ready to connect the shop';
                    AboutText = 'We just need the shop name and URL to connect it to Shopify. When you have checked all shop settings, enable the connection here.';

                    trigger OnValidate()
                    var
                        FeatureTelemetry: Codeunit "Feature Telemetry";
                        BulkOperationMgt: Codeunit "Shpfy Bulk Operation Mgt.";
                    begin
                        if not Rec.Enabled then
                            exit;
                        Rec.RequestAccessToken();
#if not CLEAN23
                        if BulkOperationMgt.IsBulkOperationFeatureEnabled() then
#endif
                        BulkOperationMgt.EnableBulkOperations(Rec);
                        Rec."B2B Enabled" := Rec.GetB2BEnabled();
                        Rec.SyncCountries();
                        FeatureTelemetry.LogUptake('0000HUT', 'Shopify', Enum::"Feature Uptake Status"::"Set up");
                    end;
                }
                field(HasAccessKey; Rec.HasAccessToken())
                {
                    ApplicationArea = All;
                    Caption = 'Has AccessKey';
                    Importance = Additional;
                    ShowMandatory = true;
                    ToolTip = 'Specifies if an access key is available for this store.';
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the currency of the Shopify Shop. Enter a currency code only if your online shop uses a different currency than the local currency (LCY). The specified currency must have exchange rates configured. If your online shop uses the same currency as Business Central, leave the field empty.';
                }
                field(LanguageCode; Rec."Language Code")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the language of the Shopify Shop.';
                }
#if not CLEAN23
                field(LogActivated; Rec."Log Enabled")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies whether the log is activated.';
                    Visible = false;
                    ObsoleteReason = 'Replaced with field "Logging Mode"';
                    ObsoleteState = Pending;
                    ObsoleteTag = '23.0';
                }
#endif
                field(LoggingMode; Rec."Logging Mode")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies whether the log is activated.';
                }
                field(AllowBackgroudSyncs; Rec."Allow Background Syncs")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies whether background syncs are allowed.';
                }
                field("Allow Outgoing Requests"; Rec."Allow Outgoing Requests")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Caption = 'Allow Data Sync to Shopify';
                    ToolTip = 'Specifies whether syncing data to Shopify is enabled.';
                }
                field("Shopify Admin API Version"; ApiVersion)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Caption = 'Shopify Admin API Version';
                    ToolTip = 'Specifies the version of Shopify Admin API used by current version of the Shopify connector.';
                    Editable = false;
                }
                field("API Version Expiry Date"; ApiVersionExpiryDate)
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    Caption = 'Update API Version Before';
                    ToolTip = 'Specifies the date on which Business Central will no longer support Shopify Admin API version. To continue to use your integration, upgrade to the latest version of Business Central before this date.';
                    Editable = false;
                }
            }
            group(ItemSync)
            {
                Caption = 'Item/Product Synchronization';
                AboutTitle = 'Set up synchronization for items';
                AboutText = '**Products** in Shopify are called **Items** in Business Central. Define how to synchronize items in *this* shop with Business Central. If one of the apps doesn''t have this data, you can quickly export items from Business Central to Shopify and vice versa.';

                field(SyncItem; Rec."Sync Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies in which direction items are synchronized.';
                    Importance = Promoted;
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
                    Editable = Rec."Sync Item" = rec."Sync Item"::"To Shopify";
                }
                field(ItemTemplCode; Rec."Item Templ. Code")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies which item template to use when creating unknown items.';
                    Editable = Rec."Auto Create Unknown Items";
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
                field(SyncItemMarketingText; Rec."Sync Item Marketing Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether you want to synchronize marketing texts to Shopify.';
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
                    Editable = (Rec."SKU Mapping" = Rec."SKU Mapping"::"Variant Code") or (Rec."SKU Mapping" = Rec."SKU Mapping"::"Item No. + Variant Code");
                }
                field(SKUType; Rec."SKU Mapping")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if and based on what you want to create variants in D365BC.';
                    Importance = Promoted;
                }
                field(SKUFieldSeparator; Rec."SKU Field Separator")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a field separator for the SKU if you use "Item. No + Variant Code" to create a variant.';
                    Editable = Rec."SKU Mapping" = Rec."SKU Mapping"::"Item No. + Variant Code";
                }
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
                field(CreateProductStatusValue; Rec."Status for Created Products")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of a product in Shopify when an item is create in Shopify via the sync.';
                }
                field(RemoveProductAction; Rec."Action for Removed Products")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of a product in Shopify via the sync when an item is removed in Shopify or an item is blocked in Business Central.';
                }
                field("Items Mapped to Products"; Rec."Items Mapped to Products")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if only the items that are mapped to Shopify products/Shopify variants are synchronized from Posted Sales Invoices to Shopify.';
                }
            }
            group(PriceSynchronization)
            {
                Caption = 'Price Synchronization';
                field(CustomerPriceGroup; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Price Group is used to calculate the prices in Shopify.';
                    Importance = Promoted;
                }
                field(CustomerDiscountGroup; Rec."Customer Discount Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Discount Group is used to calculate the prices in Shopify.';
                    Importance = Promoted;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the prices calculate for Shopify are Including VAT.';
                    Importance = Additional;
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if line discount is allowed while calculating prices for Shopify.';
                    Importance = Additional;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Gen. Bus. Posting Group is used to calculate the prices in Shopify.';
                    Importance = Additional;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which VAT. Bus. Posting Group is used to calculate the prices in Shopify.';
                    Importance = Additional;
                    Editable = Rec."Prices Including VAT";
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Posting Group is used to calculate the prices in Shopify.';
                    Visible = false;
                }
                field("VAT Country/Region Code"; Rec."VAT Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which VAT Country/Region Code is used to calculate the prices in Shopify.';
                    Visible = false;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Tax Area Code is used to calculate the prices in Shopify.';
                    Visible = false;
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Tax Liable is used to calculate the prices in Shopify.';
                    Visible = false;
                }
                field("Sync Prices"; Rec."Sync Prices")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if prices are synchronized to Shopify with product sync.';
                }
            }
            group(CustomerSync)
            {
                Caption = 'Customer Synchronization';
                AboutTitle = 'Set up synchronization for customers';
                AboutText = 'Specify how to synchronize customers between Shopify and Business Central. You can auto-create Shopify customers on Business Central or use the same customer entity for every sales order. When connected, Business Central can also update customer information in Shopify.';
                field(CustomerImportFromShopify; Rec."Customer Import From Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how Shopify customers are synced to Business Central. If you choose none and there exists no mapping for that customer, the default customer will be used if exists.';
                    Importance = Promoted;
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
                field(CustomerTemplCode; Rec."Customer Templ. Code")
                {
                    Caption = 'Customer/Company Template Code';
                    ToolTip = 'Specifies which customer template to use when creating unknown customers.';
                    ShowMandatory = true;
                    ApplicationArea = All;
                }
                field(DefaultCustomer; Rec."Default Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default customer when not creating a customer for each webshop user.';
                    Importance = Promoted;
                }
                field(ShopifyCanUpdateCustomer; Rec."Shopify Can Update Customer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether Shopify can update customers when synchronizing from Shopify.';
                }
#if not CLEAN24
                field(ExportCustomerToShopify; Rec."Export Customer To Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to export all customers with a valid e-mail address from D365BC to Shopify.';
                    Visible = false;
                    ObsoleteReason = 'Replaced with action Add Customers in Shopify Customers page.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '24.0';
                }
#endif
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
                    ToolTip = 'Specifies how to synchronize the county of the customer/company.';
                }
            }
            group("B2B Company Synchronization")
            {
                Visible = Rec."B2B Enabled";
                field("Company Import From Shopify"; Rec."Company Import From Shopify")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how Shopify companies are synced to Business Central.';
                    Importance = Promoted;
                }
                field("Company Mapping Type"; Rec."Company Mapping Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to map companies.';
                }
                field("Auto Create Unknown Companies"; Rec."Auto Create Unknown Companies")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if unknown companies are automatically created in D365BC when synchronizing from Shopify.';
                }
                field("Default Company No."; Rec."Default Company No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default customer when not creating a company for each B2B company.';
                }
                field("Shopify Can Update Companies"; Rec."Shopify Can Update Companies")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether Shopify can update companies when synchronizing from Shopify.';
                }
                field("Can Update Shopify Companies"; Rec."Can Update Shopify Companies")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether D365BC can update companies when synchronizing to Shopify.';
                }
                field("Default Customer Permission"; Rec."Default Contact Permission")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default customer permission for new companies.';
                }
                field("Auto Create Catalog"; Rec."Auto Create Catalog")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether a catalog is automatically created for new companies.';
                }
            }
            group(OrderProcessing)
            {
                Caption = 'Order Synchronization and Processing';
                AboutTitle = 'Set up your order flow';
                AboutText = 'Define how new orders in Shopify flow into Business Central. For example, you can require that Shopify orders are approved before they become a sales order or invoice in Business Central. You can also define how to post shipping revenue, and the address that determines where you pay taxes.';
                field(AutoSyncOrders; Rec."Order Created Webhooks")
                {
                    ApplicationArea = All;
                    Editable = Rec.Enabled;
                    Caption = 'Auto Sync Orders';
                    ToolTip = 'Specifies whether to automatically synchronize orders when they’re created in Shopify. Shopify will notify Business Central that orders are ready. Business Central will schedule the Sync Orders from Shopify job on the Job Queue Entries page. The user account of the person who turns on this toggle will be used to run the job. That user must have permission to create background tasks in the job queue.';
                }
                field(SyncOrderJobQueueUser; Rec."Order Created Webhook User")
                {
                    ApplicationArea = All;
                    Caption = 'Sync Order Job Queue User';
                    ToolTip = 'Specifies the user who will run the Sync Orders from Shopify job on the Job Queue Entries page. This is the user who turned on the Auto Import Orders from Shopify toggle.';
                }
                field(ShippingCostAccount; Rec."Shipping Charges Account")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the G/L Account for posting the shipping cost.';
                    Importance = Promoted;
                }
                field(SoldGiftCardAccount; Rec."Sold Gift Card Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the G/L Account for to post the sold gift card amounts.';
                }
                field(TipAccount; Rec."Tip Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the G/L Account for post the received tip amount.';
                }
                field(ShopifyOrderNoOnDocLine; Rec."Shopify Order No. on Doc. Line")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Shopify Order No. is shown in the document line.';
                }
                field(AutoCreateOrders; Rec."Auto Create Orders")
                {
                    Caption = 'Auto Create Sales Orders';
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether orders may be created automatically.';
                }
                field(AutoReleaseSalesOrders; rec."Auto Release Sales Orders")
                {
                    Caption = 'Auto Release Sales Orders';
                    ApplicationArea = All;
                    ToolTip = 'Specifies if a Sales Order should be releases after creation';
                }
                field(TaxAreaSource; Rec."Tax Area Priority")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the tax area source and the sequence to be followed.';
                }
                field(SendShippingConfirmation; Rec."Send Shipping Confirmation")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the customer is notified when the shipment is synchronized to Shopify.';
                }
#if not CLEAN24
                field(ReplaceOrderAttributeValue; Rec."Replace Order Attribute Value")
                {
                    ApplicationArea = All;
                    Caption = 'Feature Update: Enable Longer Order Attribute Value Length';
                    ToolTip = 'Specifies if the connector stores order attribute values in a new field with a length of 2048 characters. Starting from version 27.0, this new field will be the only option available. However, until version 27.0 administrators can choose to continue using the old field if needed.';
                    Enabled = not ReplaceOrderAttributeValueDisabled;
                    ObsoleteReason = 'This feature will be enabled by default with version 27.0.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '24.0';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
#endif
                field("Posted Invoice Sync"; Rec."Posted Invoice Sync")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the posted sales invoices can be synchronized to Shopify.';
                }
            }
            group(ReturnsAndRefunds)
            {
                Caption = 'Return and Refund Processing';
                AboutText = 'Define how Returns and Refunds in Shopify flow into Business Central.';

                field("Return and Refund Process"; Rec."Return and Refund Process")
                {
                    ApplicationArea = All;
                    Caption = 'Process Type';
                    ToolTip = 'Specifies how returns and refunds from Shopify are handles in Business Central. The import process is always done within the import of a Shopify order.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                group(HandlingOfReturns)
                {
                    ShowCaption = false;
                    Visible = IsReturnRefundsVisible;

                    field("Return Location Priority"; Rec."Return Location Priority")
                    {
                        ApplicationArea = All;
                        Caption = 'Return Location Priority';
                        ToolTip = 'Specifies the priority of the return location.';
                    }
                    field("Location Code of Returns"; Rec."Return Location")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies location code for returned goods.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }

                    field("G/L Account Instead of Item"; Rec."Refund Acc. non-restock Items")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies a G/L Account No. for goods where you don''t want to have an inventory correction.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("G/L Account for Amt. diff."; Rec."Refund Account")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies a G/L Account No. for the difference in the total refunded amount and the total amount of the items.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
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
            action(PaymentTerms)
            {
                ApplicationArea = All;
                Caption = 'Payment Terms Mapping';
                Image = SuggestPayment;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = page "Shpfy Payment Terms Mapping";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'Maps the Shopify payment terms to the related payment terms and prioritize them.';
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
            action(Refunds)
            {
                ApplicationArea = All;
                Caption = 'Refunds';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View your Shopify refunds.';

                trigger OnAction()
                var
                    RefundHeader: Record "Shpfy Refund Header";
                    RefundHeaders: Page "Shpfy Refunds";
                begin
                    RefundHeader.SetRange("Shop Code", Rec.Code);
                    RefundHeaders.SetTableView(RefundHeader);
                    RefundHeaders.Run();
                end;
            }
            action(Returns)
            {
                ApplicationArea = All;
                Caption = 'Returns';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View your Shopify returns.';

                trigger OnAction()
                var
                    ReturnHeader: Record "Shpfy Return Header";
                    ReturnHeaders: Page "Shpfy Returns";
                begin
                    ReturnHeader.SetRange("Shop Code", Rec.Code);
                    ReturnHeaders.SetTableView(ReturnHeader);
                    ReturnHeaders.Run();
                end;
            }
            action(Customers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                Image = Customer;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Customers";
                RunPageLink = "Shop Id" = field("Shop Id");
                ToolTip = 'Add, view or edit detailed information for the customers. ';
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
            action(Companies)
            {
                ApplicationArea = All;
                Caption = 'Companies';
                Image = Company;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Companies";
                RunPageLink = "Shop Id" = field("Shop Id");
                ToolTip = 'Add, view or edit detailed information for the companies.';
                Visible = Rec."B2B Enabled";
            }
            action(Catalogs)
            {
                ApplicationArea = All;
                Caption = 'Catalogs';
                Image = ItemGroup;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Catalogs";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'View a list of Shopify catalogs for the shop.';
                Visible = Rec."B2B Enabled";
            }
            action(Languages)
            {
                ApplicationArea = All;
                Caption = 'Languages';
                Image = Translations;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Languages";
                RunPageLink = "Shop Code" = field(Code);
                ToolTip = 'View a list of Shopify Languages for the shop.';
            }
        }
        area(Processing)
        {
            group(Access)
            {
                action(RequestAccessNew)
                {
                    ApplicationArea = All;
                    Image = EncryptionKeys;
                    Caption = 'Request Access';
                    ToolTip = 'Request Access to your Shopify store.';

                    trigger OnAction()
                    begin
                        Rec.RequestAccessToken();
                    end;
                }
                action(TestConnection)
                {
                    ApplicationArea = All;
                    Image = Setup;
                    Caption = 'Test Connection';
                    ToolTip = 'Test connection to your Shopify store.';
                    Enabled = Rec.Enabled;

                    trigger OnAction()
                    begin
                        if Rec.TestConnection() then
                            Message('Connection successful.');
                    end;
                }
                action(ClearApiVersionExpiryDateCache)
                {
                    ApplicationArea = All;
                    Image = ClearLog;
                    Caption = 'Clear API Version Expiry Date Cache';
                    ToolTip = 'Clears the API version expiry date cache for this Shopify Shop. This will force the API version to be re-evaluated the next time the API is called.';
                    Enabled = Rec.Enabled;

                    trigger OnAction()
                    var
                        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
                    begin
                        CommunicationMgt.ClearApiVersionCache();
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
                        BackgroundSyncs.ProductImagesSync(Rec.Code, '');
                    end;
                }
                action(SyncProductPrices)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Prices';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize prices to Shopify. The standard price calculation is followed for determining the price.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.ProductPricesSync(Rec.Code);
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
                action(SyncCompanies)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Companies';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize the companies with Shopify. The way companies are synchronized depends on the B2B settings in the Shopify Shop Card.';
                    Visible = Rec."B2B Enabled";

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.CompanySync(Rec.Code);
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
                action(SyncOrders)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Orders';
                    Image = Import;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize orders from Shopify.';

                    trigger OnAction();
                    var
                        Shop: Record "Shpfy Shop";
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        Shop.SetFilter(Code, Rec.Code);
                        BackgroundSyncs.OrderSync(Shop);
                    end;
                }
                action(SyncShipments)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Shipments';
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize shipments to Shopify.';

                    trigger OnAction();
                    begin
                        Report.Run(Report::"Shpfy Sync Shipm. to Shopify");
                    end;
                }
                action(SyncPostedSalesInvoices)
                {
                    ApplicationArea = All;
                    Ellipsis = true;
                    Caption = 'Sync Posted Sales Invoices';
                    Image = Export;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize posted sales invoices to Shopify. Synchronization will be performed only if the Posted Invoice Sync field is enabled in the Shopify shop.';

                    trigger OnAction();
                    var
                        ExportInvoicetoShpfy: Report "Shpfy Sync Invoices to Shpfy";
                    begin
                        ExportInvoicetoShpfy.SetShop(Rec.Code);
                        ExportInvoicetoShpfy.Run();
                    end;
                }
                action(SyncDisputes)
                {
                    ApplicationArea = All;
                    Caption = 'Sync Disputes';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Synchronize dispute information with related payment transactions.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.DisputesSync(Rec.Code);
                    end;
                }
                action(SyncAll)
                {
                    ApplicationArea = All;
                    Caption = 'Sync All';
                    Image = ImportExport;
                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedOnly = true;
                    ToolTip = 'Execute all synchronizations (Products, Product images, Inventory, Customers and payouts) in batch.';

                    trigger OnAction()
                    var
                        BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    begin
                        BackgroundSyncs.CustomerSync(Rec);
                        BackgroundSyncs.ProductsSync(Rec);
                        BackgroundSyncs.InventorySync(Rec);
                        BackgroundSyncs.ProductImagesSync(Rec, '');
                        BackgroundSyncs.ProductPricesSync(Rec);
                        if Rec."B2B Enabled" then begin
                            BackgroundSyncs.CompanySync(Rec);
                            BackgroundSyncs.CatalogPricesSync(Rec, '');
                        end;
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
                action(ResetCompanies)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Company Sync';
                    Image = ClearFilter;
                    Tooltip = 'Ensure all companies are synced when executing the sync, not just the changes since last sync.';

                    trigger OnAction()
                    begin
                        Rec.SetLastSyncTime("Shpfy Synchronization Type"::Companies, GetResetSyncTo(Rec.GetLastSyncTime("Shpfy Synchronization Type"::Companies)));
                    end;
                }
            }
            action(CreateFulfillmentService)
            {
                ApplicationArea = All;
                Caption = 'Create Shopify Fulfillment Service';
                Image = CreateInventoryPickup;
                ToolTip = 'Create Shopify Fulfillment Service';

                trigger OnAction()
                var
                    FullfillmentOrdersAPI: Codeunit "Shpfy Fulfillment Orders API";
                begin
                    FullfillmentOrdersAPI.RegisterFulfillmentService(Rec);
                end;
            }
        }
    }

    var
        IsReturnRefundsVisible: Boolean;
        ApiVersion: Text;
        ApiVersionExpiryDate: Date;
        ExpirationNotificationTxt: Label 'Shopify API version 30 days before expiry notification sent.', Locked = true;
        BlockedNotificationTxt: Label 'Shopify API version expired notification sent.', Locked = true;
        CategoryTok: Label 'Shopify Integration', Locked = true;
#if not CLEAN24
        ReplaceOrderAttributeValueDisabled: Boolean;
#endif
        ScopeChangeConfirmLbl: Label 'The access scope of shop %1 for the Shopify connector has changed. Do you want to request a new access token?', Comment = '%1 - Shop Code';

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShopMgt: Codeunit "Shpfy Shop Mgt.";
        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";

        ApiVersionExpiryDateTime: DateTime;
    begin
        FeatureTelemetry.LogUptake('0000HUU', 'Shopify', Enum::"Feature Uptake Status"::Discovered);
        if Rec.Enabled then begin
            ApiVersion := CommunicationMgt.GetApiVersion();
            ApiVersionExpiryDateTime := CommunicationMgt.GetApiVersionExpiryDate();
            ApiVersionExpiryDate := DT2Date(ApiVersionExpiryDateTime);
            if CurrentDateTime() > ApiVersionExpiryDateTime then begin
                ShopMgt.SendBlockedNotification();
                Session.LogMessage('0000KNZ', BlockedNotificationTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
            end else
                if Round((ApiVersionExpiryDateTime - CurrentDateTime()) / 1000 / 3600 / 24, 1) <= 30 then begin
                    ShopMgt.SendExpirationNotification(ApiVersionExpiryDate);
                    Session.LogMessage('0000KO0', ExpirationNotificationTxt, Verbosity::Warning, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', CategoryTok);
                end;

            if AuthenticationMgt.CheckScopeChange(Rec) then
                if Confirm(StrSubstNo(ScopeChangeConfirmLbl, Rec.Code)) then begin
                    Rec.RequestAccessToken();
                    Rec."B2B Enabled" := Rec.GetB2BEnabled();
                    Rec.Modify();
                end else begin
                    Rec.Enabled := false;
                    Rec.Modify();
                end;
        end;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CheckReturnRefundsVisible();
#if not CLEAN24
        CheckReplaceOrderAttributeValueDisabled();
#endif
    end;

    local procedure GetResetSyncTo(InitDateTime: DateTime): DateTime
    var
        DateTimeDialog: Page "Date-Time Dialog";
        ResetSyncLbl: Label 'Reset Sync to';
    begin
        DateTimeDialog.SetDateTime(InitDateTime);
        DateTimeDialog.Caption := ResetSyncLbl;
        DateTimeDialog.LookupMode := true;
        if DateTimeDialog.RunModal() = Action::LookupOK then
            exit(DateTimeDialog.GetDateTime());
        exit(InitDateTime);
    end;

    local procedure CheckReturnRefundsVisible()
    begin
        IsReturnRefundsVisible := Rec."Return and Refund Process" <> "Shpfy ReturnRefund ProcessType"::" ";
    end;

#if not CLEAN24
    local procedure CheckReplaceOrderAttributeValueDisabled()
    var
        OrderHeader: Record "Shpfy Order Header";
        OrderAttribute: Record "Shpfy Order Attribute";
    begin
        if Rec."Replace Order Attribute Value" then begin
            OrderHeader.SetRange("Shop Code", Rec.Code);
            if OrderHeader.FindSet() then
                repeat
                    OrderAttribute.SetRange("Order Id", OrderHeader."Shopify Order Id");
                    if not OrderAttribute.IsEmpty() then begin
                        ReplaceOrderAttributeValueDisabled := true;
                        exit;
                    end;
                until OrderHeader.Next() = 0;
        end;
    end;
#endif
}

