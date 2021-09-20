codeunit 79003 "Outlook Mock Init. Subscribers"
{
    EventSubscriberInstance = Manual;

    var
        OAuthClientMock: Codeunit "LGS OAuth Client Mock";
        OutlookAPIClientMock: Codeunit "LGS Outlook API Client Mock";


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LGS Guest Outlook - API Helper", 'OnAfterInitializeClients', '', false, false)]
    local procedure OnAfterInitializeClients(var OutlookAPIClient: interface "Email - Outlook API Client"; var OAuthClient: interface "Email - OAuth Client")
    begin
        OutlookAPIClient := OutlookAPIClientMock;
        OAuthClient := OAuthClientMock;
    end;
}

