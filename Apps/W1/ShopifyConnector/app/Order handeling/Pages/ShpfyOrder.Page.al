/// <summary>
/// Page Shpfy Order (ID 30113).
/// </summary>
page 30113 "Shpfy Order"
{
    Caption = 'Shopify Order';
    DataCaptionFields = "Shopify Order No.";
    InsertAllowed = false;
    PageType = Document;
    PromotedActionCategories = 'New,Process,Report,Order,Inspect';
    RefreshOnActivate = true;
    SourceTable = "Shpfy Order Header";
    UsageCategory = None;
    layout
    {
        area(content)
        {
            group(General)
            {
                field(ShopCode; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the Shopify Shop from which the order originated.';
                }
                field(ShopifyOrderNo; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the order number from Shopify.';
                }
                field(RiskLevel; Rec."Risk Level")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the risk level from the Shopify order.';
                }
                field(TemplateCodeField; Rec."Customer Template Code")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Template Code';
                    Lookup = true;
                    ShowMandatory = true;
                    TableRelation = "Config. Template Header".Code where("Table Id" = const(18));
                    ToolTip = 'Specifies the code for the template to create a new customer.';
                }
                field(SellToCustomerNo; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the number of the customer who will buy the products.';
                }
                field(ShippingMethod; Rec."Shipping Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how items on the Shopify Order are shipped to the customer.';
                }
                field("Payment Method"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to make a payment, such as with bank transfer, cash, or check.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified if the Shopify order is archived by D365BC.';
                }
                group(SellTo)
                {
                    Caption = 'Sell-to';

                    field(SellToCustomerName; Rec."Sell-to Customer Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = false;
                        ToolTip = 'Specifies the name of the customer who will buy the products.';
                    }
                    field(SellToAddress; Rec."Sell-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        Editable = false;
                        ToolTip = 'Specifies the street address of the buy address.';
                    }
                    field(SellToAddress2; Rec."Sell-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        Editable = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(SellToPostCode; Rec."Sell-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Post Code';
                        Editable = false;
                        ToolTip = 'Specifies the postal code of the buy address.';
                    }
                    field(SellToCity; Rec."Sell-to City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        Editable = false;
                        ToolTip = 'Specifies the city, town, or village of the buy address.';
                    }
                }
                field(Email; Rec.Email)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the customer''s e-mail address.';
                }
                field(PhoneNo; Rec."Phone No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the phone number at the buy address.';
                }
                field(Test; Rec.Test)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether this is a test order.';
                }
                field(CreatedAt; Rec."Created At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the autogenerated date and time when the order was created in Shopify.';
                }
                field(DocumentDate; Rec."Document Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the related document was created.';
                }
                field(UpdatedAt; Rec."Updated At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the date and time when the order was last modified.';
                }
                field(CancelledAt; Rec."Cancelled At")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the date and time when the order was cancelled.';
                }
                field(CancelReason; Rec."Cancel Reason")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the reason why the order was cancelled. Valid values are: customer, fraud, inventory, declined, other.';
                }
                field(SourceName; Rec."Source Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies where the order is originated. Example values: web, pos, iphone, android.';
                }
                field(Confirmed; Rec.Confirmed)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies whether the order has been confirmed.';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether a sales order has been created for the Shopify Order.';
                }
                field(FinancialStatus; Rec."Financial Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the status of payments associated with the order. Valid values are: pending, authorized, partially_paid, paid, partially_refunded, refunded, voided.';
                }
                field(FulfillmentStatus; Rec."Fulfillment Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the order''s status in terms of fulfilled line items. Valid values are: Fulfilled, null, partial, restocked.';
                }
                field(SalesOrderNo; Rec."Sales Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sales order number that has been created for the Shopify Order.';
                }
                field(SalesInvoiceNo; Rec."Sales Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sales invoice number that has been created for the Shopify Order.';
                }
                field("Error"; Rec."Has Error")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether there is an error when creating a sales document.';
                }
                field(ErrorMessage; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the error message if an error has occurred.';
                }
                field(WorkDescription; WorkDescription)
                {
                    ApplicationArea = All;
                    Caption = 'Work Description';
                    MultiLine = true;
                    ToolTip = 'Specifies details or special instructions for the Shopify order. This description is copied to the sales order and the sales invoice.';

                    trigger OnValidate()
                    begin
                        Rec.SetWorkDescription(WorkDescription);
                    end;
                }

            }

            part(ShopifyOrderLines; "Shpfy Order Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Shopify Order Id" = FIELD("Shopify Order Id");
                UpdatePropagation = Both;
            }
            group(InvoiceDetails)
            {
                Caption = 'Invoice Details';
                field(SubtotalAmount; Rec."Subtotal Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sum of the line amounts on all lines in the document minus any discount amounts.';
                }
                field(ShippingCostAmount; Rec."Shipping Charges Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the amount of the shipping cost.';
                }
                field(TotalAmount; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the sum of the line amounts on all lines in the document minus any discount amounts plus the shipping costs.';
                }
                field(VATAmount; Rec."VAT Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sum of tax amounts on all lines in the document.';
                }
                field(DiscountAmount; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sum of all discount amount on all lines in the document.';
                }
                field(VATIncluded; Rec."VAT Included")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if tax is included in the unit price.';
                }
                field(CurrencyCode; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the currency of amounts on the document.';
                }
            }
            group(ShippingAndBilling)
            {
                Caption = 'Shipping and Billing';
                group("Ship-to")
                {
                    Caption = 'Ship-to';
                    field(ShipToName; Rec."Ship-to Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the name that products on the sales order are shipped to.';
                    }
                    field(ShipToAddress; Rec."Ship-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        Editable = false;
                        ToolTip = 'Specifies the address that products on the sales order are shipped to.';
                    }
                    field(ShipToAddress2; Rec."Ship-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        Editable = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(ShipToPostCode; Rec."Ship-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Post Code';
                        Editable = false;
                        ToolTip = 'Specifies the ZIP code of the address that the products are shipped to.';
                    }
                    field(ShipToCity; Rec."Ship-to City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        Editable = false;
                        ToolTip = 'Specifies the city of the customer that the products are shipped to.';
                    }
                    field(ShipToCountryCode; Rec."Ship-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country Code';
                        Editable = false;
                        ToolTip = 'Specifies the country/region code of the address that the items are shipped to.';
                    }
                    field(ShipToCountryName; Rec."Ship-to Country/Region Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Country Name';
                        Editable = false;
                        ToolTip = 'Specifies the name of the customer''s country/region';
                    }
                }
                group(BillTo)
                {
                    Caption = 'Bill-to';
                    field(BillToCustomerNo; Rec."Bill-to Customer No.")
                    {
                        ApplicationArea = All;
                        Caption = 'Customer No.';
                        Editable = true;
                        Importance = Promoted;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number of the customer that you sent the invoice or credit memo to.';
                    }
                    field(BillToName; Rec."Bill-to Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        Editable = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the name of the customer that you sent the invoice or credit memo to.';
                    }
                    field(BillToAddress; Rec."Bill-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Address';
                        Editable = false;
                        ToolTip = 'Specifies the address of the customer that you sent the invoice or credit memo to.';
                    }
                    field(BillToAddress2; Rec."Bill-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Address 2';
                        Editable = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(BillToPostCode; Rec."Bill-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Post Code';
                        Editable = false;
                        ToolTip = 'Specifies the post code of the customer that you sent the invoice or credit memo to.';
                    }
                    field(BillToCity; Rec."Bill-to City")
                    {
                        ApplicationArea = All;
                        Caption = 'City';
                        Editable = false;
                        ToolTip = 'Specifies the city of the customer that you sent the invoice or credit memo to.';
                    }
                    field(BillToCountryCode; Rec."Bill-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Country Code';
                        Editable = false;
                        ToolTip = 'Specifies the country/region code of the customer that you sent the invoice or credit memo to.';
                    }
                    field(BillToCountryName; Rec."Bill-to Country/Region Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Country Name';
                        Editable = false;
                        ToolTip = 'Specifies the name of the customer''s country/region.';
                    }
                }
            }
        }
        area(factboxes)
        {
            part(SalesHistory; "Sales Hist. Sell-to FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Sell-to Customer No.");
            }
            part(CustomerStatistics; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Sell-to Customer No.");
                Visible = false;
            }
            part(CustomerDetails; "Customer Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Sell-to Customer No.");
            }
            part(OrderAttributes; "Shpfy Order Attributes")
            {
                ApplicationArea = all;
                Caption = 'Order Attributes';
                SubPageLink = "Order Id" = field("Shopify Order Id");
            }
            part(OrderTags; "Shpfy Tag Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Parent Table No." = const(30118), "Parent Id" = field("Shopify Order Id");
            }
            part(ItemInvoicing; "Item Invoicing FactBox")
            {
                ApplicationArea = All;
                Provider = ShopifyOrderLines;
                SubPageLink = "No." = field("Item No.");
            }
            part(ItemWarehouse; "Item Warehouse FactBox")
            {
                ApplicationArea = All;
                Provider = ShopifyOrderLines;
                SubPageLink = "No." = field("Item No.");
                Visible = false;
            }
            systempart(Links; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";

                action(FindMappings)
                {
                    ApplicationArea = All;
                    Caption = 'Find Mappings';
                    Image = MapAccounts;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Start to resolve all mappings. (Customer, Item, Payment Method, ...)';

                    trigger OnAction()
                    var
                        Mapping: Codeunit "Shpfy Order Mapping";
                    begin
                        CurrPage.Update(true);
                        Mapping.DoMapping(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(CreateSalesDocument)
                {
                    ApplicationArea = All;
                    Caption = 'Create Sales Document';
                    Image = MakeOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Convert the Shopify Order to a sales order or sales invoice. The sales document will contain the Shopify order number.';

                    trigger OnAction();
                    var
                        ShopifyOrderHeader: Record "Shpfy Order Header";
                        ProcessShopifyOrders: Codeunit "Shpfy Process Orders";
                    begin
                        if Confirm(StrSubstNo(CreateShopifyMsg, Rec."Shopify Order No.")) then begin
                            CurrPage.Update(true);
                            Commit();
                            ShopifyOrderHeader.Get(Rec."Shopify Order Id");
                            ShopifyOrderHeader.SetRecFilter();
                            ProcessShopifyOrders.ProcessShopifyOrders(ShopifyOrderHeader);
                            Rec.Get(Rec."Shopify Order Id");
                        end;
                    end;
                }
                action(CreateNewCustomer)
                {
                    ApplicationArea = All;
                    Caption = 'Create New Customer';
                    Image = Customer;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Create a new customer.';

                    trigger OnAction();
                    var
                        Shop: Record "Shpfy Shop";
                        OrderMapping: Codeunit "Shpfy Order Mapping";
                    begin
                        CurrPage.Update(true);
                        Shop.Get(Rec."Shop Code");
                        OrderMapping.MapHeaderFields(Rec, Shop, true);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
        area(navigation)
        {
            action(Risks)
            {
                ApplicationArea = All;
                Caption = 'Risks';
                Image = Warning;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Order Risks";
                RunPageLink = "Order Id" = field("Shopify Order Id");
                RunPageMode = View;
                ToolTip = 'View the level and message that indicates the results of the fraud check.';
            }
            action(Transactions)
            {
                ApplicationArea = All;
                Caption = 'Transactions';
                Image = Payment;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Order Transactions";
                RunPageLink = "Shopify Order Id" = field("Shopify Order Id");
                RunPageMode = View;
                ToolTip = 'View the transactions created for this  Shopify order that results in exchange of money.';
            }
            action(ShippingCosts)
            {
                ApplicationArea = All;
                Caption = 'Shipping Costs';
                Image = CalculateShipment;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Order Shipping Charges";
                RunPageLink = "Shopify Order Id" = field("Shopify Order Id");
                RunPageMode = View;
                ToolTip = 'View the shipping costs associated to this Shopify Order.';
            }
            action(Fulfillments)
            {
                ApplicationArea = All;
                Caption = 'Fulfillments';
                Image = ShipmentLines;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Order Fulfillments";
                RunPageLink = "Shopify Order Id" = field("Shopify Order Id");
                RunPageMode = View;
                ToolTip = 'View an array of fulfillments associated with the Shopify Order.';
            }
            action(SalesOrder)
            {
                ApplicationArea = All;
                Caption = 'Sales Order';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Open the related sales order.';

                trigger OnAction();
                var
                    SalesHeader: Record "Sales Header";
                    SalesOrder: Page "Sales Order";
                begin
                    Rec.TestField("Sales Order No.");
                    SalesHeader.Get(SalesHeader."Document Type"::Order, Rec."Sales Order No.");
                    SalesOrder.SetRecord(SalesHeader);
                    SalesOrder.Run();
                    ;
                end;
            }
            action(SalesInvoice)
            {
                ApplicationArea = All;
                Caption = 'Sales Invoice';
                Image = Document;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Open the related sales invoice.';

                trigger OnAction();
                var
                    SalesHeader: Record "Sales Header";
                    SalesOrder: Page "Sales Invoice";
                begin
                    Rec.TestField("Sales Invoice No.");
                    SalesHeader.Get(SalesHeader."Document Type"::Invoice, Rec."Sales Invoice No.");
                    SalesOrder.SetRecord(SalesHeader);
                    SalesOrder.Run();
                end;
            }
            action(ShopifyStatusPage)
            {
                ApplicationArea = All;
                Caption = 'Shopify Status Page';
                Image = Web;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Open the order status page from Shopify.';

                trigger OnAction();
                begin
                    Hyperlink(Rec."Order Status URL");
                end;
            }

            action(RetrievedShopifyData)
            {
                ApplicationArea = All;
                Caption = 'Retrieved Shopify Data';
                Image = Entry;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View the data retrieved from Shopify.';

                trigger OnAction();
                var
                    DataCapture: Record "Shpfy Data Capture";
                begin
                    DataCapture.SetCurrentKey("Linked To Table", "Linked To Id");
                    DataCapture.SetRange("Linked To Table", Database::"Shpfy Order Header");
                    DataCapture.SetRange("Linked To Id", Rec.SystemId);
                    Page.Run(Page::"Shpfy Data Capture List", DataCapture);
                end;
            }
        }
    }

    var
        CreateShopifyMsg: Label 'Create sales document from Shopify order %1?', Comment = '%1 = Order No.';
        WorkDescription: Text;

    trigger OnAfterGetRecord()
    begin
        WorkDescription := Rec.GetWorkDescription();
    end;
}

