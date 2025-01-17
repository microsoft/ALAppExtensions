namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Catalogs (ID 30159).
/// </summary>
page 30159 "Shpfy Catalogs"
{
    ApplicationArea = All;
    Caption = 'Shopify Catalogs';
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
                    ToolTip = 'Specifies the unique identifier for the catalog in Shopify.';
                    Editable = false;
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the customer''s no.  When Customer No. is Selected: Parameters like ''Customer Discount Group'', ''Customer Price Group'', and ''Allow Line Discount'' on the customer card take precedence over catalog settings';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the catalog''s name.';
                    Editable = false;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'Company';
                    ToolTip = 'Specifies the name of the company that the catalog belongs to.';
                    Editable = false;
                }
                field(SyncPrices; Rec."Sync Prices")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the prices are synced to Shopify.';
                }
                field(CustomerPriceGroup; Rec."Customer Price Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Price Group is used to calculate the prices in the catalog.';
                }
                field(CustomerDiscountGroup; Rec."Customer Discount Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Discount Group is used to calculate the prices in the catalog.';
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the prices are Including VAT.';
                }
                field("Allow Line Disc."; Rec."Allow Line Disc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if line discount is allowed while calculating prices for the catalog.';
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Gen. Bus. Posting Group is used to calculate the prices in the catalog.';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which VAT. Bus. Posting Group is used to calculate the prices in the catalog.';
                    Editable = Rec."Prices Including VAT";
                }
                field("Customer Posting Group"; Rec."Customer Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Customer Posting Group is used to calculate the prices in the catalog.';
                }
                field("VAT Country/Region Code"; Rec."VAT Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which VAT Country/Region Code is used to calculate the prices in the catalog.';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which Tax Area Code is used to calculate the prices in the catalog.';
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if Tax Liable is used to calculate the prices in the catalog.';
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
                ToolTip = 'View a list of Shopify products for the catalog.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    CatalogAPI: Codeunit "Shpfy Catalog API";
                begin
                    if Shop.Get(Rec."Shop Code") then begin
                        CatalogAPI.SetShop(Shop);
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
                        BackgroundSyncs.CatalogPricesSync(Rec."Shop Code", Rec.GetFilter("Company SystemId"))
                    else begin
                        Shop.SetRange(Code, Rec."Shop Code");
                        SyncCatalogsPrices.SetTableView(Shop);
                        SyncCatalogsPrices.Run();
                    end;
                end;
            }
        }
    }
}
