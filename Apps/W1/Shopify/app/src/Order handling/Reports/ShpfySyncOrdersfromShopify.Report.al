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
                RequestFilterFields = "Fully Paid", "Risk Level", "Financial Status", "Fulfillment Status", Confirmed, "Import Action", "Attribute Key Filter", "Attribute Key Exists";

                trigger OnPreDataItem()
                begin
                    if GuiAllowed then begin
                        ToProcess := OrdersToImport.Count;
                        Window.Open(ProcessMsg, ToProcess);
                        Window.Update();
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
                            if OrderMapping.DoMapping(OrderHeader) and (OrdersToImport."Import Action" = OrdersToImport."Import Action"::New) and Shop."Auto Create Orders" then
                                CreateSalesDocument(OrderHeader);
                        end;

                    if GuiAllowed then begin
                        ToProcess -= 1;
                        Window.Update();
                    end;
                end;

                trigger OnPostDataItem()
                begin
                    if GuiAllowed then
                        Window.Close();
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
        Window: Dialog;
        ToProcess: Integer;
        ProcessMsg: Label 'To Process: #1###########', Comment = '#1 = ToPrgress';

    /// <summary> 
    /// Description for CreateSalesDocument.
    /// </summary>
    /// <param name="ShopifyOrderHeader">Parameter of type Record "Shopify Order Header".</param>
    local procedure CreateSalesDocument(ShopifyOrderHeader: Record "Shpfy Order Header")
    var
        ProcessShopifyOrder: Codeunit "Shpfy Process Order";
    begin
        if not ShopifyOrderHeader.Processed then begin
            Commit();
            ClearLastError();
            if not ProcessShopifyOrder.Run(ShopifyOrderHeader) then begin
                SelectLatestVersion();
                ShopifyOrderHeader.Get(ShopifyOrderHeader."Shopify Order Id");
                ShopifyOrderHeader."Has Error" := true;
                ShopifyOrderHeader."Error Message" := CopyStr(Format(Time) + ' ' + GetLastErrorText(), 1, MaxStrLen(ShopifyOrderHeader."Error Message"));
                ShopifyOrderHeader."Sales Order No." := '';
                ShopifyOrderHeader."Sales Invoice No." := '';
                ProcessShopifyOrder.CleanUpLastCreatedDocument();
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
}