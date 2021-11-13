codeunit 79001 "OAuth Client Mock" implements "Email - OAuth Client"
{
    SingleInstance = true;

    internal procedure GetAccessToken(var AccessToken: Text)
    begin
        TryGetAccessToken(AccessToken);
    end;

    internal procedure TryGetAccessToken(var AccessToken: Text): Boolean
    begin
        AccessToken := 'test token';
        exit(true);
    end;
}