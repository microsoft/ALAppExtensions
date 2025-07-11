namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Customer;

/// <summary>
/// Page Shpfy Customers (ID 30107).
/// </summary>
page 30107 "Shpfy Customers"
{
    ApplicationArea = All;
    Caption = 'Shopify Customers';
    CardPageId = "Shpfy Customer Card";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Customer";
    UsageCategory = Lists;
    PromotedActionCategories = 'New,Process,Related,Customer';

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique identifier for the customer in Shopify.';
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
                field(FirstName; Rec."First Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s first name.';
                }
                field(LastName; Rec."Last Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s last name.';
                }
                field(EMail; Rec.Email)
                {
                    ApplicationArea = All;
                    ToolTip = 'The unique email address of the customer. Attempting to assign the same email address to multiple customers returns an error.';
                }
                field(Phone; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s telephone number.';
                }
                field(State; Rec.State)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the state of a customer''s account with a shop. The default value is disabled. Valid values are: disabled, invited, enabled and declined.';
                }
                field(VeriefiedEmail; Rec."Verified Email")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the customer has verified their e-mail address.';
                }
                field(Note; Rec.GetNote())
                {
                    Caption = 'Note';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a note about the customer in Shopify.';
                }
                field(AcceptsMarketing; Rec."Accepts Marketing")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the customer consented to receive e-mail updates from the shop.';
                }
            }
        }
        area(FactBoxes)
        {
            part(CustomerTags; "Shpfy Tag Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Parent Table No." = const(30105), "Parent Id" = field(Id);
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
                RunPageLink = "Customer Id" = Field(Id);
                ToolTip = 'View a list of Shopify orders for the customer.';
            }
        }

        area(Processing)
        {
            action(AddCustomer)
            {
                ApplicationArea = All;
                Caption = 'Add Customers';
                Image = AddAction;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Select which customers you want to create in Shopify. Only customers with an e-mail address will be created.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    AddCustomerToShopify: Report "Shpfy Add Customer to Shopify";
                begin
                    Shop.SetFilter("Shop Id", Rec.GetFilter("Shop Id"));
                    if Shop.FindFirst() then
                        AddCustomerToShopify.SetShop(Shop.Code);
                    AddCustomerToShopify.Run();
                end;
            }
            action(Sync)
            {
                ApplicationArea = All;
                Caption = 'Synchronize Customers';
                Image = ImportExport;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'Synchronize the customers with Shopify. The way customers are synchronized depends on the settings in the Shopify Shop Card.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                    ShopFilter: Text;
                begin
                    ShopFilter := Rec.GetFilter("Shop Id");
                    if ShopFilter = '' then
                        BackgroundSyncs.CustomerSync()
                    else begin
                        Shop.SetFilter("Shop Id", ShopFilter);
                        if Shop.FindFirst() then
                            BackgroundSyncs.CustomerSync(Shop.Code);
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
                ToolTip = 'Add metafields to a customer. This can be used for adding custom data fields to customers in Shopify.';

                trigger OnAction()
                var
                    Shop: Record "Shpfy Shop";
                    Metafields: Page "Shpfy Metafields";
                begin
                    Shop.SetRange("Shop Id", Rec."Shop Id");
                    Shop.FindFirst();
                    Metafields.RunForResource(Database::"Shpfy Customer", Rec.Id, Shop.Code);
                end;
            }
        }
    }
}
