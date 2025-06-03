namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Market Catalogs (ID 30171).
/// </summary>
page 30171 "Shpfy Market Catalogs"
{
    ApplicationArea = All;
    Caption = 'Shopify Market Catalogs';
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Catalog";
    UsageCategory = Lists;
    PromotedActionCategories = 'New,Process,Related,Catalog';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the unique identifier for the market catalog in Shopify.';
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the market catalog''s name.';
                    Editable = false;
                }
                field(SyncPrices; Rec."Sync Prices")
                {
                    ToolTip = 'Specifies if the prices are synced to Shopify.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer''s no.  When Customer No. is Selected: Parameters like ''Customer Discount Group'', ''Customer Price Group'', and ''Allow Line Discount'' on the customer card take precedence over catalog settings';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ToolTip = 'Specifies the currency code for the market catalog.';
                }
                field(CustomerPriceGroup; Rec."Customer Price Group")
                {
                    ToolTip = 'Specifies which Customer Price Group is used to calculate the prices in the market catalog.';
                }
                field(CustomerDiscountGroup; Rec."Customer Discount Group")
                {
                    ToolTip = 'Specifies which Customer Discount Group is used to calculate the prices in the market catalog.';
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ToolTip = 'Specifies if the prices are Including VAT.';
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ToolTip = 'Specifies if line discount is allowed while calculating prices for the market catalog.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ToolTip = 'Specifies which Gen. Bus. Posting Group is used to calculate the prices in the market catalog.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ToolTip = 'Specifies which VAT. Bus. Posting Group is used to calculate the prices in the market catalog.';
                    Editable = Rec."Prices Including VAT";
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ToolTip = 'Specifies which Customer Posting Group is used to calculate the prices in the market catalog.';
                }
                field("VAT Country/Region Code"; Rec."VAT Country/Region Code")
                {
                    ToolTip = 'Specifies which VAT Country/Region Code is used to calculate the prices in the market catalog.';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ToolTip = 'Specifies which Tax Area Code is used to calculate the prices in the market catalog.';
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ToolTip = 'Specifies if Tax Liable is used to calculate the prices in the market catalog.';
                }
            }
        }
        area(factboxes)
        {
            part(Markets; "Shpfy Market Catalog Relations")
            {
                Caption = 'Markets';
                SubPageLink = "Shop Code" = field("Shop Code"), "Catalog Id" = field(Id);
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Products)
            {
                Caption = 'Products';
                Image = ItemGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ToolTip = 'View a list of Shopify products for the market catalog.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    CatalogAPI: Codeunit "Shpfy Catalog API";
                begin
                    if Shop.Get(Rec."Shop Code") then begin
                        CatalogAPI.SetShop(Shop);
                        CatalogAPI.SetCatalogType("Shpfy Catalog Type"::Market);
                        Hyperlink(CatalogAPI.GetCatalogProductsURL(Rec.Id));
                    end;
                end;
            }
        }

        area(Processing)
        {
            action(GetMarketCatalogs)
            {
                Caption = 'Get Market Catalogs';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Get market catalogs from Shopify.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    SyncCatalogs: Report "Shpfy Sync Catalogs";
                begin
                    if Rec.GetFilter("Shop Code") <> '' then begin
                        Shop.SetRange(Code, Rec.GetFilter("Shop Code"));
                        SyncCatalogs.SetTableView(Shop);
                        SyncCatalogs.UseRequestPage(false);
                    end;
                    SyncCatalogs.SetCatalogType("Shpfy Catalog Type"::Market);
                    SyncCatalogs.Run();
                end;
            }
            action(PriceSync)
            {
                Caption = 'Sync Prices';
                Image = ImportExport;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Sync prices to Shopify.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    SyncCatalogsPrices: Report "Shpfy Sync Catalog Prices";
                    BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                begin
                    if Rec.GetFilter("Shop Code") <> '' then begin
                        Shop.Get(Rec."Shop Code");
                        if Shop."Allow Background Syncs" then
                            BackgroundSyncs.CatalogPricesSync(Rec."Shop Code", "Shpfy Catalog Type"::Market)
                        else begin
                            Shop.SetRange(Code, Rec.GetFilter("Shop Code"));
                            SyncCatalogsPrices.SetTableView(Shop);
                            SyncCatalogsPrices.UseRequestPage(false);
                            SyncCatalogsPrices.SetCatalogType("Shpfy Catalog Type"::Market);
                            SyncCatalogsPrices.Run();
                        end;
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Catalog Type", "Shpfy Catalog Type"::Market);
    end;
}
