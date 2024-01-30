namespace Microsoft.Integration.Shopify;

page 30161 "Shpfy Resolve Order Conflicts"
{
    SourceTable = "Shpfy Order Header";
    InsertAllowed = false;
    Editable = false;
    PageType = Document;
    UsageCategory = None;

    layout
    {
        area(Content)
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
            }
            group(CurrentValues)
            {
                Caption = 'Current order in Business Central';
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the order has been closed in Shopify.';
                }
                field(Unpaid; Rec.Unpaid)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies whether the order has been paid in Shopify.';
                }
                field("Subtotal Amount"; Rec."Subtotal Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the subtotal amount of the order in Shopify.';
                }
                field("Total Amount"; Rec."Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the total amount of the order in Shopify.';
                }
                field("Presentment Total Amount"; Rec."Presentment Total Amount")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the total presentment amount of the order in Shopify.';
                }
            }
            part(ShopifyOrderLines; "Shpfy Order Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Shopify Order Id" = field("Shopify Order Id");
                Editable = false;
            }
            group(IncomingValues)
            {
                Caption = 'Retrieved order from Shopify';
                field(IncomingClosed; TempRetrievedOrderHeader.Closed)
                {
                    ApplicationArea = All;
                    Caption = 'Closed';
                    Editable = false;
                    ToolTip = 'Specifies whether the order has been closed in Shopify.';
                }
                field(IncomingUnpaid; TempRetrievedOrderHeader.Unpaid)
                {
                    ApplicationArea = All;
                    Caption = 'Unpaid';
                    Editable = false;
                    ToolTip = 'Specifies whether the order has been paid in Shopify.';
                }
                field("Incoming Subtotal Amount"; TempRetrievedOrderHeader."Subtotal Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Subtotal Amount';
                    Editable = false;
                    ToolTip = 'Specifies the subtotal amount of the order in Shopify.';
                }
                field("Incoming Total Amount"; TempRetrievedOrderHeader."Total Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount';
                    Editable = false;
                    ToolTip = 'Specifies the total amount of the order in Shopify.';
                }
                field("Incoming Presentment Total Amount"; TempRetrievedOrderHeader."Presentment Total Amount")
                {
                    ApplicationArea = All;
                    Caption = 'Presentment Total Amount';
                    Editable = false;
                    ToolTip = 'Specifies the total presentment amount of the order in Shopify.';
                }
            }
            part(ShopifyLatestRetrievedLines; "Shpfy Retrieved Lines Subform")
            {
                ApplicationArea = All;
                Caption = 'Latest Retrieved Order Lines';
                Editable = false;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(MarkedAsResolved)
            {
                ApplicationArea = All;
                Image = TaskList;
                Caption = 'Marked as Resolved';
                ToolTip = 'If you have updated appropriately the processed Business Central documents, you can mark this conflict as resolved and update you Shopify Order with the data from Shopify.';

                trigger OnAction()
                begin
                    ImportOrder.MarkOrderConflictAsResolvedAndReimport(Rec);
                    CurrPage.Close();
                end;
            }
        }
        area(Promoted)
        {
            actionref(MarkedAsResolved_Promoted; MarkedAsResolved)
            {
            }
        }
    }
    trigger OnOpenPage()
    var
    begin
        RefreshRetrievedOrder();
    end;

    var
        TempRetrievedOrderHeader: Record "Shpfy Order Header" temporary;
        TempRetrievedOrderLine: Record "Shpfy Order Line" temporary;
        ImportOrder: Codeunit "Shpfy Import Order";

    local procedure RefreshRetrievedOrder()
    begin
        ImportOrder.SetShop(Rec."Shop Code");
        ImportOrder.RetrieveOrderAndOrderLines(Rec."Shopify Order Id", TempRetrievedOrderHeader, TempRetrievedOrderLine);
        CurrPage.ShopifyLatestRetrievedLines.Page.SetRetrievedLines(TempRetrievedOrderLine);
    end;

}