
codeunit 139764 "Email Logging Mock Subscribers"
{
    EventSubscriberInstance = Manual;

    var
        EmailLoggingOAuthMock: Codeunit "Email Logging OAuth Mock";
        EmailLoggingAPIMock: Codeunit "Email Logging API Mock";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Logging Management", 'OnAfterInitializeOAuthClient', '', false, false)]
    local procedure OnAfterInitializeOAuthClient(var EmailLoggingOAuthClient: interface "Email Logging OAuth Client")
    begin
        EmailLoggingOAuthClient := EmailLoggingOAuthMock;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Logging Management", 'OnAfterInitializeAPIClient', '', false, false)]
    local procedure OnAfterInitializeAPIClient(var EmailLoggngAPIClient: interface "Email Logging API Client")
    begin
        EmailLoggngAPIClient := EmailLoggingAPIMock;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Email Logging Management", 'OnIsEmailLoggingUsingGraphApiFeatureEnabled', '', false, false)]
    local procedure OnIsEmailLoggingUsingGraphApiFeatureEnabled(var FeatureEnabled: Boolean)
    begin
        FeatureEnabled := true;
    end;
}