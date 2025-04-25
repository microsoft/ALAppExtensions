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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the market catalog in Shopify.';
                    Editable = false;
                }
                field("Market Id"; Rec."Market Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the market in Shopify.';
                    Editable = false;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the market catalog''s name.';
                    Editable = false;
                }
                field(SyncPrices; Rec."Sync Prices")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the prices are synced to Shopify.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s no.  When Customer No. is Selected: Parameters like ''Customer Discount Group'', ''Customer Price Group'', and ''Allow Line Discount'' on the customer card take precedence over catalog settings';
                }
                field(CustomerPriceGroup; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Price Group is used to calculate the prices in the market catalog.';
                }
                field(CustomerDiscountGroup; Rec."Customer Discount Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Discount Group is used to calculate the prices in the market catalog.';
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the prices are Including VAT.';
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if line discount is allowed while calculating prices for the market catalog.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Gen. Bus. Posting Group is used to calculate the prices in the market catalog.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which VAT. Bus. Posting Group is used to calculate the prices in the market catalog.';
                    Editable = Rec."Prices Including VAT";
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Posting Group is used to calculate the prices in the market catalog.';
                }
                field("VAT Country/Region Code"; Rec."VAT Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which VAT Country/Region Code is used to calculate the prices in the market catalog.';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Tax Area Code is used to calculate the prices in the market catalog.';
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Tax Liable is used to calculate the prices in the market catalog.';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Products)
            {
                ApplicationArea = All;
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
                        CatalogAPI.SetCatalogType(Rec."Catalog Type");
                        Hyperlink(CatalogAPI.GetCatalogProductsURL(Rec."Market Id"));
                    end;
                end;
            }
        }

        area(Processing)
        {
            action(GetMarketCatalogs)
            {
                ApplicationArea = All;
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
                    SyncCatalogs.SetCatalogType(Rec."Catalog Type");
                    SyncCatalogs.Run();
                end;
            }
            action(PriceSync)
            {
                ApplicationArea = All;
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
                            BackgroundSyncs.CatalogPricesSync(Rec."Shop Code", Rec.GetFilter("Company SystemId"), Rec."Catalog Type")
                        else begin
                            Shop.SetRange(Code, Rec.GetFilter("Shop Code"));
                            SyncCatalogsPrices.SetTableView(Shop);
                            SyncCatalogsPrices.UseRequestPage(false);
                        end;
                    end;
                    SyncCatalogsPrices.SetCatalogType(Rec."Catalog Type");
                    SyncCatalogsPrices.Run();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Catalog Type", "Shpfy Catalog Type"::Market);
    end;
}
