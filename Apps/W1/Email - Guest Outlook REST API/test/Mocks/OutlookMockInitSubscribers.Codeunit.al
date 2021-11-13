codeunit 79003 "Outlook Mock Init. Subscribers"
{
    EventSubscriberInstance = Manual;

    var
        OAuthClientMock: Codeunit "OAuth Client Mock";
        OutlookAPIClientMock: Codeunit "Outlook API Client Mock";


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guest Outlook - API Helper", 'OnAfterInitializeClients', '', false, false)]
    local procedure OnAfterInitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    begin
        OutlookAPIClient := OutlookAPIClientMock;
        OAuthClient := OAuthClientMock;
    end;
}

