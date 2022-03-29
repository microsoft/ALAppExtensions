codeunit 139765 "Email Logging OAuth Mock" implements "Email Logging OAuth Client"
{
    Access = Internal;
    SingleInstance = true;

    internal procedure Initialize()
    begin
    end;

    internal procedure Initialize(ClientId: Text; ClientSecret: Text; RedirectUrl: Text)
    begin
    end;

    internal procedure GetAccessToken(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text)
    begin
        TryGetAccessToken(PromptInteraction, AccessToken);
    end;

    internal procedure TryGetAccessToken(PromptInteraction: Enum "Prompt Interaction"; var AccessToken: Text): Boolean
    begin
        exit(TryGetAccessToken(AccessToken));
    end;

    internal procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessToken(AccessToken);
    end;

    internal procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        AccessToken := 'test token';
        exit(true);
    end;

    internal procedure GetApplicationType(): Enum "Email Logging App Type"
    begin
        exit(Enum::"Email Logging App Type"::"Third Party");
    end;

    internal procedure GetLastErrorMessage(): Text
    begin
        exit('');
    end;
}