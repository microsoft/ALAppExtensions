/// <summary>
/// Page Shpfy Orders (ID 30115).
/// </summary>
page 30115 "Shpfy Orders"
{
    ApplicationArea = All;
    Caption = 'Shopify Orders';
    CardPageID = "Shpfy Order";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Order,Manage';
    SourceTable = "Shpfy Order Header";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(ShopifyOrderNo; Rec."Shopify Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number from Shopify';

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Shpfy Order", Rec);
                    end;
                }
                field(ShopCode; Rec."Shop Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Shopify Shop from which the order originated.';
                }
                field(RiskLevel; Rec."Risk Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the risk level from the Shopify order.';
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specified if the Shopify order is archived by D365BC.';
                }
                field(SellToCustomerNo; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who will buy the products and be billed by default.';
                }
                field(SellToCustomerName; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the customer who will buy the products and be billed by default.';
                }
                field(SellToPostCode; Rec."Sell-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the postal code of the buy address.';
                }
                field(SellToCountryCode; Rec."Sell-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies country/region code of the buy address.';
                }
                field(BillToName; Rec."Bill-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the name of the customer who be billed.';
                }
                field(BillToPostCode; Rec."Bill-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the postal code of the billing address.';
                }
                field(BillToCountryCode; Rec."Bill-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the country/region code of the billing address.';
                }
                field(ShipToName; Rec."Ship-to Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the name that products on the sales order are shipped to.';
                }
                field(ShipToPostCode; Rec."Ship-to Post Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the ZIP code of the address that the products are shipped to.';
                }
                field(ShipToCountryCode; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the country/region code of the address that the items are shipped to.';
                }
                field(CreatedAt; Rec."Created At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date and time when the order was created.';
                }
                field(Confirmed; Rec.Confirmed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the order has been confirmed.';
                }
                field(FinancialStatus; Rec."Financial Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the status of payments associated with the order. Valid values are: pending, authorized, partially_paid, paid, partially_refunded, refunded, voided.';
                }
                field(FulfillmentStatus; Rec."Fulfillment Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order''s status in terms of fulfilled line items. Valid values are: Fulfilled, null, partial, restocked.';
                }
                field(TotalAmount; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the sum of the line amounts on all lines in the document minus any discount amounts plus the shipping costs.';
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the order is already processed.';
                }
                field(SalesOrderNo; Rec."Sales Order No.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = true;
                    ToolTip = 'Specifies the sales order number that has been created for the Shopify Order.';
                }
                field(SalesInvoiceNo; Rec."Sales Invoice No.")
                {
                    ApplicationArea = All;
                    Style = Favorable;
                    StyleExpr = true;
                    ToolTip = 'Specifies the sales invoice number that has been created for the Shopify Order.';
                }
                field("Error"; Rec."Has Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether there is an error when creating a sales document.';
                }
                field(ErrorMessage; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = true;
                    ToolTip = 'Specifies the error message if an error has occurred.';
                }
            }
        }
        area(factboxes)
        {
            part(CustomerStatistics; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Sell-to Customer No.");
            }
            part(CustomerDetails; "Customer Details FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Sell-to Customer No.");
            }
            part(OrderTags; "Shpfy Tag Factbox")
            {
                ApplicationArea = All;
                SubPageLink = "Parent Table No." = const(30118), "Parent Id" = field("Shopify Order Id");
            }
            part(OrderAttributes; "Shpfy Order Attributes")
            {
                ApplicationArea = all;
                Caption = 'Order Attributes';
                SubPageLink = "Order Id" = field("Shopify Order Id");
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
            Action(DeleteSelected)
            {
                ApplicationArea = All;
                Caption = 'Delete Selected Rows';
                Image = DeleteRow;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Delete the selected rows.';

                trigger OnAction()
                var
                    OrderHeader: Record "Shpfy Order Header";
                begin
                    CurrPage.SetSelectionFilter(OrderHeader);
                    OrderHeader.DeleteAll(true);
                end;
            }
            Action(SyncOrdersFromShopify)
            {
                ApplicationArea = All;
                Caption = 'Sync Orders From Shopify';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Synchronize orders from Shopify.';

                trigger OnAction();
                var
                    Shop: Record "Shpfy Shop";
                    BackgroundSyncs: Codeunit "Shpfy Background Syncs";
                begin
                    if Rec.GetFilter("Shop Code") <> '' then
                        Shop.SetFilter(Code, Rec.GetFilter("Shop Code"));
                    BackgroundSyncs.OrderSync(Shop);
                end;
            }
            Action(CreateSalesDocuments)
            {
                ApplicationArea = All;
                Caption = 'Create Sales Documents';
                Image = MakeOrder;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Convert the Shopify Order to a sales order or sales invoice. The sales document will contain the Shopify order number.';

                trigger OnAction();
                var
                    ShopifyOrderHeader: Record "Shpfy Order Header";
                    ProcessShopifyOrders: Codeunit "Shpfy Process Orders";
                begin
                    if Confirm(ConfirmLbl) then begin
                        CurrPage.SetSelectionFilter(ShopifyOrderHeader);
                        ProcessShopifyOrders.ProcessShopifyOrders(ShopifyOrderHeader);
                        CurrPage.Update(false);
                    end;
                end;
            }
        }
        area(navigation)
        {
            group(ShopifyOrder)
            {
                Caption = 'Shopify Order';
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
                Action(SalesOrder)
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
                    end;
                }
                Action(SalesInvoice)
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
                Action(ShopifyStatusPage)
                {
                    ApplicationArea = All;
                    Caption = 'Shopify Status Page';
                    Image = Web;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ToolTip = 'Open the order status page from Shopify.';

                    trigger OnAction();
                    begin
                        Hyperlink(Rec."Order Status URL");
                    end;
                }
            }
        }
    }

    var
        ConfirmLbl: Label 'Create sales document(s) from the selected Shopify order(s)?';
}

