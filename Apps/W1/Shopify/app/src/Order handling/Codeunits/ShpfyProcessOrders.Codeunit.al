namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Process Orders (ID 30167).
/// </summary>
codeunit 30167 "Shpfy Process Orders"
{
    Access = Internal;

    TableNo = "Shpfy Shop";

    var
        Shop: Record "Shpfy Shop";
        ShopifyOrderFilter: Text;

    trigger OnRun()
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
    begin
        Shop := Rec;
        ShopifyOrderHeader.Reset();
        if ShopifyOrderFilter <> '' then
            ShopifyOrderHeader.SetView(ShopifyOrderFilter);
        ShopifyOrderHeader.SetRange(Processed, false);
        ShopifyOrderHeader.SetRange("Shop Code", Rec.Code);
        ShopifyOrderHeader.SetCurrentKey("Shop Code", Processed);
        ProcessShopifyOrders(ShopifyOrderHeader);
        ProcessShopifyRefunds();
    end;

    /// <summary>
    /// SetShopifyOrderFilter.
    /// </summary>
    /// <param name="FilterString">Text.</param>
    internal procedure SetShopifyOrderFilter(FilterString: Text)
    begin
        ShopifyOrderFilter := FilterString;
    end;

    /// <summary> 
    /// Process Shopify Order.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure ProcessShopifyOrder(ShopifyOrderHeader: Record "Shpfy Order Header")
    var
        ProcessOrder: Codeunit "Shpfy Process Order";
    begin
        if not ShopifyOrderHeader.Processed then begin
            if not ProcessOrder.Run(ShopifyOrderHeader) then begin
                ShopifyOrderHeader.Get(ShopifyOrderHeader."Shopify Order Id");
                ShopifyOrderHeader."Has Error" := true;
                ShopifyOrderHeader."Error Message" := CopyStr(Format(Time) + ' ' + GetLastErrorText(), 1, MaxStrLen(ShopifyOrderHeader."Error Message"));
                ShopifyOrderHeader."Sales Order No." := '';
                ShopifyOrderHeader."Sales Invoice No." := '';
                ProcessOrder.CleanUpLastCreatedDocument();
            end else begin
                ShopifyOrderHeader.Get(ShopifyOrderHeader."Shopify Order Id");
                ShopifyOrderHeader."Has Error" := false;
                ShopifyOrderHeader."Error Message" := '';
                ShopifyOrderHeader.Processed := true;
            end;
            ShopifyOrderHeader.Modify(true);
            Commit();
        end;
    end;

    /// <summary> 
    /// Process Shopify Orders.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    internal procedure ProcessShopifyOrders(var ShopifyOrderHeader: Record "Shpfy Order Header")
    begin
        Commit();
        if ShopifyOrderHeader.FindSet() then
            repeat
                ProcessShopifyOrder(ShopifyOrderHeader);
            until ShopifyOrderHeader.Next() = 0;
    end;

    local procedure ProcessShopifyRefunds()
    var
        RefundHeader: Record "Shpfy Refund Header";
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
    begin
        if Shop."Return and Refund Process" = "Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo" then begin
            IReturnRefundProcess := Shop."Return and Refund Process";
            RefundHeader.SetRange("Is Processed", false);
            RefundHeader.SetLoadFields("Refund Id");
            if RefundHeader.FindSet(false) then
                repeat
                    IReturnRefundProcess.CreateSalesDocument("Shpfy Source Document Type"::Refund, RefundHeader."Refund Id");
                    Commit();
                until RefundHeader.Next() = 0;
        end;
    end;
}


