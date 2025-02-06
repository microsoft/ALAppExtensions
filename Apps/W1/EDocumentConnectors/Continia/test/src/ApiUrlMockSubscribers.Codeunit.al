namespace Microsoft.EServices.EDocumentConnector.Continia;

codeunit 148201 "Api Url Mock Subscribers"
{
    EventSubscriberInstance = Manual;

    internal procedure SetCoBaseCaseUrl(NewUrl: Text)
    begin
        CoBaseCaseUrl := NewUrl;
    end;

    internal procedure SetCdnBaseCaseUrl(NewUrl: Text)
    begin
        CdnBaseCaseUrl := NewUrl;
    end;

    internal procedure SetCoApiWith200ResponseCodeCase()
    begin
        ValidateCoBaseUrlInitialized();
        SetCoBaseCaseUrl(StrSubstNo('%1/200', CoBaseUrl));
    end;

    internal procedure SetCoApiWith200ResponseCodeCase(NewBaseUrl: Text)
    begin
        CoBaseUrl := NewBaseUrl;
        SetCoApiWith200ResponseCodeCase();
    end;

    internal procedure SetCoApiCaseUrlSegment(UrlSegment: Text)
    begin
        ValidateCoBaseUrlInitialized();
        SetCoBaseCaseUrl(StrSubstNo('%1/%2', CoBaseUrl, UrlSegment));
    end;

    internal procedure SetCdnApiWith200ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/200', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith201ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/201', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith200ResponseCodeCase(NewBaseUrl: Text)
    begin
        CdnBaseUrl := NewBaseUrl;
        SetCdnApiWith200ResponseCodeCase();
    end;

    internal procedure SetCdnApiWith400ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/400', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith401ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/401', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith404ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/404', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith409ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/409', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith422ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/422', CdnBaseUrl));
    end;

    internal procedure SetCdnApiWith500ResponseCodeCase()
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/500', CdnBaseUrl));
    end;

    internal procedure SetCdnApiCaseUrlSegment(UrlSegment: Text)
    begin
        ValidateCdnBaseUrlInitialized();
        SetCdnBaseCaseUrl(StrSubstNo('%1/%2', CdnBaseUrl, UrlSegment));
    end;

    local procedure ValidateCoBaseUrlInitialized()
    begin
        if CoBaseUrl = '' then
            Error('Continia Online Base Url is not initialized.');
    end;

    local procedure ValidateCdnBaseUrlInitialized()
    begin
        if CdnBaseUrl = '' then
            Error('Continia Delivery Network Base Url is not initialized.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Api Url Mgt.", OnGetCOBaseUrl, '', true, true)]
    local procedure OnGetCOBaseUrl(var ReturnUrl: Text; var Handled: Boolean)
    begin
        ReturnUrl := CoBaseCaseUrl;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Api Url Mgt.", OnGetCDNBaseUrl, '', true, true)]
    local procedure OnGetCDNBaseUrl(var ReturnUrl: Text; var Handled: Boolean)
    begin
        ReturnUrl := CdnBaseCaseUrl;
        Handled := true;
    end;

    var
        CoBaseUrl, CdnBaseUrl, CoBaseCaseUrl, CdnBaseCaseUrl : Text;
}