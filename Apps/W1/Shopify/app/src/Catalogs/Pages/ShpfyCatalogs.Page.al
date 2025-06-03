namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Catalogs (ID 30159).
/// </summary>
page 30159 "Shpfy Catalogs"
{
    ApplicationArea = All;
    Caption = 'Shopify B2B Catalogs';
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
                field("Customer No."; Rec."Customer No.") { }
                field(Name; Rec.Name) { }
                field("Company Name"; Rec."Company Name")
                {
                    Caption = 'Company';
                    Editable = false;
                }
                field(SyncPrices; Rec."Sync Prices") { }
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
                ToolTip = 'View a list of Shopify products for the catalog.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    CatalogAPI: Codeunit "Shpfy Catalog API";
                begin
                    if Shop.Get(Rec."Shop Code") then begin
                        CatalogAPI.SetShop(Shop);
                        CatalogAPI.SetCatalogType("Shpfy Catalog Type"::Company);
                        Hyperlink(CatalogAPI.GetCatalogProductsURL(Rec.Id));
                    end;
                end;
            }
        }

        area(Processing)
        {
            action(GetCatalogs)
            {
                ApplicationArea = All;
                Caption = 'Get Catalogs';
                Image = Import;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Get catalogs from Shopify.';

                trigger OnAction()
                var
                    ShopifyCompany: Record "Shpfy Company";
                    SyncCatalogs: Report "Shpfy Sync Catalogs";
                begin
                    if Rec.GetFilter("Company SystemId") <> '' then begin
                        ShopifyCompany.GetBySystemId(Rec.GetFilter("Company SystemId"));
                        SyncCatalogs.SetCompany(ShopifyCompany);
                        SyncCatalogs.UseRequestPage(false);
                    end;
                    SyncCatalogs.SetCatalogType("Shpfy Catalog Type"::Company);
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
                    if Rec.GetFilter("Company SystemId") <> '' then
                        BackgroundSyncs.CatalogPricesSync(Rec."Shop Code", Rec.GetFilter("Company SystemId"), "Shpfy Catalog Type"::Company)
                    else begin
                        Shop.SetRange(Code, Rec."Shop Code");
                        SyncCatalogsPrices.SetTableView(Shop);
                        SyncCatalogsPrices.SetCatalogType("Shpfy Catalog Type"::Company);
                        SyncCatalogsPrices.Run();
                    end;
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetRange("Catalog Type", "Shpfy Catalog Type"::"Company");
    end;
}
