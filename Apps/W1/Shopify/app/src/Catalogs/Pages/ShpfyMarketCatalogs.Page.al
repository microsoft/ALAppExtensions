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
                field(Id; Rec.Id) { }
                field(Name; Rec.Name) { }
                field(SyncPrices; Rec."Sync Prices") { }
                field("Customer No."; Rec."Customer No.") { }
                field("Currency Code"; Rec."Currency Code") { }
                field(CustomerPriceGroup; Rec."Customer Price Group") { }
                field(CustomerDiscountGroup; Rec."Customer Discount Group") { }
                field("Prices Including VAT"; Rec."Prices Including VAT") { }
                field("Allow Line Disc."; Rec."Allow Line Disc.") { }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group") { }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    Editable = Rec."Prices Including VAT";
                }
                field("Customer Posting Group"; Rec."Customer Posting Group") { }
                field("VAT Country/Region Code"; Rec."VAT Country/Region Code") { }
                field("Tax Area Code"; Rec."Tax Area Code") { }
                field("Tax Liable"; Rec."Tax Liable") { }
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
