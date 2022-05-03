/// <summary>
/// Codeunit Shpfy Sync Orders (ID 30168).
/// </summary>
codeunit 30168 "Shpfy Sync Orders"
{
    Access = Internal;

    TableNo = "Shpfy Orders to Import";
    SingleInstance = true;

    trigger OnRun()
    var
        OrderHeader: Record "Shpfy Order Header";
        Shop: Record "Shpfy Shop";
        ImportOrder: Codeunit "Shpfy Import Order";
        OrderMapping: Codeunit "Shpfy Order Mapping";
    begin
        if Rec.FindSet(true, false) then
            repeat
                ClearLastError();
                Commit();

                if ImportOrder.Run(Rec) then
                    Rec."Has Error" := false
                else begin
                    Rec."Has Error" := true;
                    Rec.SetErrorInfo();
                end;

                if Rec."Has Error" then
                    Rec.Modify()
                else
                    if OrderHeader.Get(Rec.Id) then begin
                        Rec.Delete();
                        Commit();
                        if OrderMapping.DoMapping(OrderHeader) and (Rec."Import Action" = Rec."Import Action"::New) and Shop."Auto Create Orders" then
                            CreateSalesDocument(OrderHeader);
                    end;
            until Rec.Next() = 0;
    end;



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
