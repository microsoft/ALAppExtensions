namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Page Shpfy Companies (ID 30156).
/// </summary>
page 30156 "Shpfy Companies"
{
    ApplicationArea = All;
    Caption = 'Shopify Companies';
    CardPageId = "Shpfy Company Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Company";
    UsageCategory = Lists;
    PromotedActionCategories = 'New,Process,Related,Company';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the company in Shopify.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    ToolTip = 'Specifies the customer number.';

                    trigger OnDrillDown()
                    var
                        Customer: Record Customer;
                        CustomerCard: Page "Customer Card";
                    begin
                        if Customer.GetBySystemId(Rec."Customer SystemId") then begin
                            Customer.SetRecFilter();
                            CustomerCard.SetTableView(Customer);
                            CustomerCard.Run();
                        end;
                    end;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the company''s name.';
                }
                field("External Id"; Rec."External Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the external ID of the company.';
                }
                field(Note; Rec.GetNote())
                {
                    Caption = 'Note';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a note about the company in Shopify.';
                }
            }
        }
        area(FactBoxes)
        {
            part(MainContact; "Shpfy Main Contact Factbox")
            {
                ApplicationArea = All;
                SubPageLink = Id = field("Main Contact Customer Id");
            }
            part(Locations; "Shpfy Comp. Locations Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Company SystemId" = field(SystemId);
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(CustomerCard)
            {
                ApplicationArea = All;
                Caption = 'Customer Card';
                Image = Customer;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                ToolTip = 'View or edit detailed information about the customer.';

                trigger OnAction()
                var
                    Customer: Record Customer;
                begin
                    if Customer.GetBySystemId(Rec."Customer SystemId") then begin
                        Customer.SetRecFilter();
                        Page.Run(Page::"Customer Card", Customer);
                    end;
                end;
            }

            action(ShopifyOrders)
            {
                ApplicationArea = All;
                Caption = 'Shopify Orders';
                Image = OrderList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "Shpfy Orders";
                RunPageLink = "Customer Id" = field(Id);
                ToolTip = 'View a list of Shopify orders for the company.';
            }
            action(ShopifyCatalogs)
            {
                ApplicationArea = All;
                Caption = 'Shopify Catalogs';
                Image = ItemGroup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "Shpfy Catalogs";
                RunPageLink = "Company SystemId" = field(SystemId);
                ToolTip = 'View a list of Shopify catalogs for the company.';
            }
            action(ShopifyLocations)
            {
                ApplicationArea = All;
                Caption = 'Shopify Locations';
                Image = Warehouse;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Category4;
                RunObject = Page "Shpfy Comp. Locations";
                RunPageLink = "Company SystemId" = field(SystemId);
                ToolTip = 'View a list of Shopify company locations.';
            }
        }

        area(Processing)
        {
            action(AddCompany)
            {
                ApplicationArea = All;
                Caption = 'Add Company';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Select which customers you want to create as companies in Shopify. Only customers with an e-mail address will be created.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    AddCompanyToShopify: Report "Shpfy Add Company to Shopify";
                begin
                    Shop.SetFilter("Shop Id", Rec.GetFilter("Shop Id"));
                    if Shop.FindFirst() then
                        AddCompanyToShopify.SetShop(Shop.Code);
                    AddCompanyToShopify.Run();
                end;
            }
            action(Sync)
            {
                ApplicationArea = All;
                Caption = 'Synchronize Companies';
                Image = ImportExport;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronize the companies with Shopify. The way companies are synchronized depends on the B2B settings in the Shopify Shop Card.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    ShopFilter: Text;
                begin
                    ShopFilter := Rec.GetFilter("Shop Id");
                    if ShopFilter = '' then
                        BackgroundSyncs.CompanySync()
                    else begin
                        Shop.SetFilter("Shop Id", ShopFilter);
                        if Shop.FindFirst() then
                            BackgroundSyncs.CompanySync(Shop.Code);
                    end;
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
                ToolTip = 'Add metafields to a company. This can be used for adding custom data fields to companies in Shopify.';

                trigger OnAction()
                var
                    Metafields: Page "Shpfy Metafields";
                begin
                    Metafields.RunForResource(Database::"Shpfy Company", Rec.Id, Rec."Shop Code");
                end;
            }
        }
    }
}
