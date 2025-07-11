namespace Microsoft.Integration.Shopify;

/// <summary>
/// Report Shpfy Sync Orders from Shopify (ID 30104).
/// </summary>
report 30104 "Shpfy Sync Orders from Shopify"
{
    ApplicationArea = All;
    Caption = 'Sync Orders from Shopify';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(Shop; "Shpfy Shop")
        {
            RequestFilterFields = Code;

            dataitem(OrdersToImport; "Shpfy Orders to Import")
            {
                DataItemLink = "Shop Code" = field(Code);
                DataItemLinkReference = Shop;
                RequestFilterFields = "Fully Paid", "Financial Status", "Fulfillment Status", Confirmed, "Import Action", "Attribute Key Filter", "Attribute Key Exists", "Channel Name", "Order No.", "High Risk", "Sell-to Country/Region Code", "Ship-to Country/Region Code", "Bill-to Country/Region Code", "VAT Amount";

                trigger OnPreDataItem()
                var
                    OrdersToImport2: Record "Shpfy Orders to Import";
                begin
                    OrdersToImport2.SetView(ToImportView);
                    OrdersToImport2.SetRange("Shop Id", Shop."Shop Id");
                    OrdersToImport2.SetRange("Shop Code", '');
                    OrdersToImport2.ModifyAll("Shop Code", Shop.Code);
                    Commit();

                    if GuiAllowed then begin
                        ToProcess := OrdersToImport.Count;
                        Dialog.Open(OrderTypeTxt + ProcessMsg, ToProcess);
                        Dialog.Update();
                    end;
                end;

                trigger OnAfterGetRecord()
                var
                    OrderHeader: Record "Shpfy Order Header";
                    ImportOrder: Codeunit "Shpfy Import Order";
                    OrderMapping: Codeunit "Shpfy Order Mapping";
                begin
                    ClearLastError();
                    Commit();

                    if ImportOrder.Run(OrdersToImport) then
                        OrdersToImport."Has Error" := false
                    else begin
                        OrdersToImport."Has Error" := true;
                        OrdersToImport.SetErrorInfo();
                    end;

                    if OrdersToImport."Has Error" then
                        OrdersToImport.Modify()
                    else
                        if OrderHeader.Get(OrdersToImport.Id) then begin
                            OrdersToImport.Delete();
                            Commit();
                            if OrderMapping.DoMapping(OrderHeader) and (OrdersToImport."Import Action" = OrdersToImport."Import Action"::New) then
                                if Shop."Auto Create Orders" then
                                    CreateSalesDocumentForOrders(OrderHeader);
                        end;

                    if GuiAllowed then begin
                        ToProcess -= 1;
                        Dialog.Update();
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    if GuiAllowed then
                        Dialog.Close();
                    if Shop."Auto Create Orders" then
                        ProcessShopifyRefunds();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Clear(OrdersAPI);
                OrdersAPI.GetOrdersToImport(Shop);
            end;
        }
    }

    var
        OrdersAPI: Codeunit "Shpfy Orders API";
        Dialog: Dialog;
        ToImportView: Text;
        ToProcess: Integer;
        OrderTypeTxt: Label 'Shopify Order';
        ProcessMsg: Label ' To Process: #1###########', Comment = '#1 = ToPrgress';

    trigger OnPreReport()
    begin
        ToImportView := OrdersToImport.GetView(false);
    end;

    /// <summary> 
    /// Description for CreateSalesDocumentForOrders.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    local procedure CreateSalesDocumentForOrders(ShopifyOrderHeader: Record "Shpfy Order Header")
    var
        ProcessOrder: Codeunit "Shpfy Process Order";
    begin
        if not ShopifyOrderHeader.Processed then begin
            Commit();
            ClearLastError();
            if not ProcessOrder.Run(ShopifyOrderHeader) then begin
                SelectLatestVersion();
                ShopifyOrderHeader.Get(ShopifyOrderHeader."Shopify Order Id");
                ShopifyOrderHeader."Has Error" := true;
                ShopifyOrderHeader."Error Message" := CopyStr(Format(Time) + ' ' + GetLastErrorText(), 1, MaxStrLen(ShopifyOrderHeader."Error Message"));
                ShopifyOrderHeader."Sales Order No." := '';
                ShopifyOrderHeader."Sales Invoice No." := '';
                ProcessOrder.CleanUpLastCreatedDocument();
            end else begin
                SelectLatestVersion();
                ShopifyOrderHeader.Get(ShopifyOrderHeader."Shopify Order Id");
                ShopifyOrderHeader."Has Error" := false;
                ShopifyOrderHeader."Error Message" := '';
                ShopifyOrderHeader.Processed := true;
            end;
            ShopifyOrderHeader.Modify(true);
            Commit();
        end;
    end;

    local procedure ProcessShopifyRefunds()
    var
        RefundHeader: Record "Shpfy Refund Header";
        IReturnRefundProcess: Interface "Shpfy IReturnRefund Process";
        RefundTypeTxt: Label 'Shopify Refund';
    begin
        if Shop."Return and Refund Process" = "Shpfy ReturnRefund ProcessType"::"Auto Create Credit Memo" then begin
            IReturnRefundProcess := Shop."Return and Refund Process";
            RefundHeader.SetRange("Is Processed", false);
            RefundHeader.SetLoadFields("Refund Id");
            if RefundHeader.FindSet(false) then begin
                if GuiAllowed then begin
                    ToProcess := RefundHeader.Count;
                    Dialog.Open(RefundTypeTxt + ProcessMsg, ToProcess);
                    Dialog.Update();
                end;
                repeat
                    IReturnRefundProcess.CreateSalesDocument("Shpfy Source Document Type"::Refund, RefundHeader."Refund Id");
                    Commit();

                    if GuiAllowed then begin
                        ToProcess -= 1;
                        Dialog.Update();
                    end;
                until RefundHeader.Next() = 0;
                if GuiAllowed then
                    Dialog.Close();
            end;
        end;
    end;
}