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
                SubPageLink = "Parent Table No." = const(70007604), "Parent Id" = field(Id);
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
                RunObject = Page "Shpfy Orders";
                RunPageLink = "Customer Id" = Field(Id);
                ToolTip = 'View a list of Shopify orders for the customer.';
            }
        }

        area(Processing)
        {
            action(Sync)
            {
                ApplicationArea = All;
                Caption = 'Start Customer Sync';
                Image = ImportExport;
                Promoted = true;
                PromotedOnly = true;
                ToolTip = 'Synchronize the customers from Shopify. The way customers are imported depends on the settings in the Shopify Shop Card.';

                trigger OnAction()
                var
                    BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                begin
                    BackgroundSyncs.CustomerSync();
                end;

            }
        }
    }
}
