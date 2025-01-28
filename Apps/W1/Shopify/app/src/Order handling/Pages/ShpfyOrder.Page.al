namespace Microsoft.Integration.Shopify;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Warehouse.Setup;

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
#if not CLEAN25
                field(RiskLevel; Rec."Risk Level")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the risk level from the Shopify order.';
                    Visible = false;
                    ObsoleteReason = 'This field is not imported.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';
                }
#endif
                field("High Risk"; Rec."High Risk")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies if the order is considered high risk.';
                }
                field(TemplCodeField; Rec."Customer Templ. Code")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Template Code';
                    Lookup = true;
                    TableRelation = "Customer Templ.".Code;
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
                field(ShippingAgentCode; Rec."Shipping Agent Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which shipping agent is used to transport the items on the Shopify Order to the customer.';
                }
                field(ShippingAgentServiceCode; Rec."Shipping Agent Service Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code that represents the default shipping agent service you are using for this Shopify Order.';
                }
                field("Payment Method"; Rec."Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how to make a payment, such as with bank transfer, cash, or check.';
                }
                field("PO Number"; Rec."PO Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purchase order number that is associated with the Shopify order.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the Shopify order is archived by D365BC.';
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
                field(AppName; Rec."App Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'The name of the app used by the channel where you sell your products. A channel can be a platform or a marketplace such as an online store or POS.';
                }
                field(ChannelName; Rec."Channel Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'The name of the channel where you sell your products. A channel can be a platform or a marketplace such as an online store or POS.';
                }
                field(SourceName; Rec."Source Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
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
                field(Edited; Rec.Edited)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies whether the order has had any edits applied.';
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
                    ToolTip = 'Specifies the status of payments associated with the order. Valid values are: pending, authorized, partially paid, paid, partially refunded, refunded, voided.';
                }
                field(FulfillmentStatus; Rec."Fulfillment Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the order''s status in terms of fulfilled line items. Valid values are: fulfilled, in progress, open, pending fulfillment, restocked, unfulfilled, partially fulfilled, on hold.';
                }
                field(ReturnStatus; Rec."Return Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the status or returns assocuated with the order. Valid values are: inspection complete, in progress, no return, returned, return failed, return requested.';
                }
                field(SalesOrderNo; Rec."Sales Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sales order number that has been created for the Shopify Order.';
                    LookupPageId = "Sales Order List";
                }
                field(SalesInvoiceNo; Rec."Sales Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the sales invoice number that has been created for the Shopify Order.';
                    LookupPageId = "Sales Invoice List";
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
            part(LinkedBCDocuments; "Shpfy Linked To Documents")
            {
                ApplicationArea = All;
                Caption = 'Linked Documents';
                SubPageLink = "Shopify Document Type" = const("Shpfy Shop Document Type"::"Shopify Shop Order"), "Shopify Document Id" = field("Shopify Order Id");
            }
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
            part(OrderLineAttributes; "Shpfy Order Lines Attributes")
            {
                ApplicationArea = all;
                Provider = ShopifyOrderLines;
                Caption = 'Order Line Attributes';
                SubPageLink = "Order Id" = field("Shopify Order Id"), "Order Line Id" = field(SystemId);
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
                        if Rec.Processed then
                            Error(ClearProcessedErr);

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
                        if not Rec.B2B then
                            OrderMapping.MapHeaderFields(Rec, Shop, true)
                        else
                            OrderMapping.MapB2BHeaderFields(Rec, Shop, true);
                        CurrPage.Update(false);
                    end;
                }
                action(MarkAsPaid)
                {
                    ApplicationArea = All;
                    Caption = 'Mark as Paid';
                    Image = Payment;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    Enabled = not Rec."Fully Paid";
                    ToolTip = 'Mark the Shopify order as paid.';

                    trigger OnAction()
                    var
                        OrdersApi: Codeunit "Shpfy Orders API";
                        ErrorInfo: ErrorInfo;
                    begin
                        if OrdersApi.MarkAsPaid(Rec."Shopify Order Id", Rec."Shop Code") then
                            Message(MarkAsPaidMsg)
                        else begin
                            ErrorInfo.Message := MarkAsPaidFailedErr;
                            ErrorInfo.AddNavigationAction(LogEntriesLbl);
                            ErrorInfo.PageNo(Page::"Shpfy Log Entries");
                            Error(ErrorInfo);
                        end;
                    end;
                }
                action(CancelOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Order';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Cancel the Shopify order.';

                    trigger OnAction()
                    var
                        CancelOrder: Page "Shpfy Cancel Order";
                        ErrorInfo: ErrorInfo;
                    begin
                        CancelOrder.LookupMode := true;
                        CancelOrder.SetRec(Rec);
                        CancelOrder.RunModal();
                        if CancelOrder.GetResult() then
                            Message(OrderCancelledMsg)
                        else begin
                            ErrorInfo.Message := OrderCancelFailedErr;
                            ErrorInfo.AddNavigationAction(LogEntriesLbl);
                            ErrorInfo.PageNo(Page::"Shpfy Log Entries");
                            Error(ErrorInfo);
                        end;
                    end;
                }
                action(UnlinkProcessedShopifyOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Unlink Processed Documents';
                    Enabled = Rec.Processed;
                    Image = UnLinkAccount;
                    ToolTip = 'Unlink the processed Shopify order from the sales document in Business Central.';

                    trigger OnAction()
                    var
                        ProcessShopifyOrders: Codeunit "Shpfy Process Orders";
                    begin
                        if Confirm(ClearProcessedMsg) then
                            ProcessShopifyOrders.ClearProcessedDocuments(Rec);
                    end;
                }
                action(MarkConflictAsResolved)
                {
                    ApplicationArea = All;
                    Caption = 'Mark Conflict as Resolved';
                    Enabled = Rec."Has Order State Error";
                    Image = Approval;
                    ToolTip = 'Mark the conflict as resolved.';

                    trigger OnAction()
                    var
                        ImportOrder: Codeunit "Shpfy Import Order";
                    begin
                        ImportOrder.MarkOrderConflictAsResolved(Rec);
                        Rec.Modify();
                    end;
                }
                action(ForceSync)
                {
                    ApplicationArea = All;
                    Image = Refresh;
                    Caption = 'Sync order from Shopify';
                    ToolTip = 'Update your Shopify Order with the current data from Shopify.';

                    trigger OnAction()
                    var
                        ImportOrder: Codeunit "Shpfy Import Order";
                    begin
                        ImportOrder.ReimportExistingOrderConfirmIfConflicting(Rec);
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
            action(FulfillmentOrders)
            {
                ApplicationArea = All;
                Caption = 'Fulfillment Orders';
                Image = ShipmentLines;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Shpfy Fulfillment Orders";
                RunPageLink = "Shopify Order Id" = field("Shopify Order Id");
                RunPageMode = View;
                ToolTip = 'View an array of fulfillment orders associated with the Shopify Order.';
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
                    RefundHeader.SetRange("Order Id", Rec."Shopify Order Id");
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
                    ReturnHeader.SetRange("Order Id", Rec."Shopify Order Id");
                    ReturnHeaders.SetTableView(ReturnHeader);
                    ReturnHeaders.Run();
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
            action(Disputes)
            {
                ApplicationArea = All;
                Caption = 'Disputes';
                Image = OrderList;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View the disputes related to order of the selected transaction.';

                trigger OnAction();
                var
                    Dispute: Record "Shpfy Dispute";
                begin
                    Dispute.SetRange("Source Order Id", Rec."Shopify Order Id");
                    Page.Run(Page::"Shpfy Disputes", Dispute);
                end;
            }
            action(TaxLines)
            {
                ApplicationArea = All;
                Caption = 'Tax Lines';
                Image = TaxDetail;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'View the tax lines associated with the Shopify Order.';

                trigger OnAction()
                var
                    OrderLine: Record "Shpfy ORder Line";
                    TaxLine: Record "Shpfy Order Tax Line";
                    FilterTxt: Text;
                begin
                    OrderLine.SetRange("Shopify Order Id", Rec."Shopify Order Id");
                    if OrderLine.FindSet() then
                        repeat
                            FilterTxt += Format(OrderLine."Line Id") + '|';
                        until OrderLine.Next() = 0;
                    FilterTxt := FilterTxt.TrimEnd('|');
                    TaxLine.SetFilter("Parent Id", FilterTxt);
                    Page.Run(Page::"Shpfy Order Tax Lines", TaxLine);
                end;
            }
        }
    }

    var
        CreateShopifyMsg: Label 'Create sales document from Shopify order %1?', Comment = '%1 = Order No.';
        MarkAsPaidMsg: Label 'The order has been marked as paid.';
        ClearProcessedMsg: Label 'This order is already linked to a sales document in Business Central. Do you want to unlink it?';
        ClearProcessedErr: Label 'This order is already linked to a sales document in Business Central.';
        MarkAsPaidFailedErr: Label 'The order could not be marked as paid. You can see the error message from Shopify Log Entries.';
        OrderCancelledMsg: Label 'Order has been cancelled successfully.';
        OrderCancelFailedErr: Label 'The order could not be cancelled. You can see the error message from Shopify Log Entries.';
        LogEntriesLbl: Label 'Log Entries';
        WorkDescription: Text;

    trigger OnAfterGetRecord()
    begin
        WorkDescription := Rec.GetWorkDescription();
    end;

    trigger OnOpenPage()
    begin
    end;
}

