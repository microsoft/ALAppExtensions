/// <summary>
/// Codeunit Shpfy Initialize Test (ID 30502).
/// </summary>
codeunit 135601 "Shpfy Initialize Test"
{
    //EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        Any: Codeunit Any;
        Assert: Codeunit "Library Assert";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        _AccessToken: Text;
        IsInitilized: Boolean;

    trigger OnRun()
    begin
        if not IsInitilized then
            CreateShop();
        Commit();
    end;

    internal procedure CreateShop(): Record "Shpfy Shop"
    var
        Shop: Record "Shpfy Shop";
        UrlTxt: Label 'https://%1.myshopify.com', Comment = '%1 = Shop name', Locked = true;
    begin
        Shop.Init();
        Shop.Code := Any.AlphanumericText(MaxStrLen(Shop.Code));
        Shop."Shopify URL" := StrSubstNo(UrlTxt, Any.AlphabeticText(20));
        Shop.Insert();
        CommunicationMgt.SetShop(Shop);
        CommunicationMgt.SetTestInProgress(true);
        IsInitilized := true;
        exit(Shop);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnGetAccessToken', '', true, false)]
    local procedure OnGetAccessToken(var AccessToken: Text)
    begin
        if _AccessToken = '' then
            _AccessToken := Any.AlphanumericText(50);
        AccessToken := _AccessToken;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Communication Events", 'OnClientSend', '', true, false)]
    local procedure OnClientSend(HttpRequestMsg: HttpRequestMessage; var HttpResponseMsg: HttpResponseMessage)
    begin
        TestRequestHeaderContainsAccessToken(HttpRequestMsg);
    end;

    local procedure TestRequestHeaderContainsAccessToken(HttpRequestMsg: HttpRequestMessage)
    var
        Headers: HttpHeaders;
        ShopifyAccessTokenTxt: Label 'X-Shopify-Access-Token', Locked = true;
        Values: Array[1] of Text;
    begin
        HttpRequestMsg.GetHeaders(Headers);
        Assert.IsTrue(Headers.Contains(ShopifyAccessTokenTxt), 'access token doesn''t exist');
        Headers.GetValues(ShopifyAccessTokenTxt, Values);
        Assert.IsTrue(Values[1] = _AccessToken, 'invalid access token');
    end;

}
