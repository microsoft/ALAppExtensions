codeunit 9141 "SharePoint User Credentials" implements "SharePoint Authorization"
{
    Access = Internal;

    var
        ClientId: Text;
        AadTenantId: Text;
        Login: Text;
        Password: Text;
        AccessToken: Text;
        IdToken: Text;
        ExpiryDate: DateTime;
        Scopes: List of [Text];
        AuthorityTxt: Label 'https://login.microsoftonline.com/{AadTenantId}/oauth2/v2.0/token', Locked = true;
        BearerTxt: Label 'Bearer %1', Locked = true;

    [NonDebuggable]
    procedure SetParameters(NewAadTenantId: Text; NewClientId: Text; NewLogin: Text; NewPassword: Text; NewScopes: List of [Text])
    begin
        NewAadTenantId := AadTenantId;
        ClientId := NewClientId;
        Login := NewLogin;
        Password := NewPassword;
        Scopes := NewScopes;
        AccessToken := '';
        ExpiryDate := 0DT;
    end;

    [NonDebuggable]
    procedure Authorize(var HttpRequestMessage: HttpRequestMessage)
    var
        Headers: HttpHeaders;
    begin
        HttpRequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', GetAuthenticationHeaderValue(GetToken()));
    end;

    local procedure GetToken(): Text
    var
        ErrorText: Text;
    begin
        if (AccessToken = '') or (AccessToken <> '') and (ExpiryDate > CurrentDateTime()) then
            if not AcquireToken(ErrorText) then
                Error(ErrorText)
            else
                ExpiryDate := CurrentDateTime() + (3599 * 1000);

        exit(AccessToken);
    end;

    local procedure AcquireToken(var ErrorText: Text): Boolean
    var
        OAuth2: Codeunit OAuth2;
        IsHandled, IsSuccess : Boolean;
    begin
        OnBeforeGetToken(IsHandled, IsSuccess, ErrorText, AccessToken);
        if not IsHandled then begin
            IsSuccess := OAuth2.AcquireTokensWithUserCredentials(GetAuthorityUrl(AadTenantId), ClientId, Scopes, Login, Password, AccessToken, IdToken);
            if not IsSuccess then
                ErrorText := OAuth2.GetLastErrorMessage();
        end;

        AccessToken := 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSIsImtpZCI6IjJaUXBKM1VwYmpBWVhZR2FYRUpsOGxWMFRPSSJ9.eyJhdWQiOiJodHRwczovL2R5bmF3YXllZy5zaGFyZXBvaW50LmNvbSIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzI4ZDZmOGZkLTEzYTgtNDFjOC05MDRmLTE3M2VmMGJjNWVjZi8iLCJpYXQiOjE2NjEyNTcwNTIsIm5iZiI6MTY2MTI1NzA1MiwiZXhwIjoxNjYxMjYyNDM5LCJhY3IiOiIxIiwiYWlvIjoiQVRRQXkvOFRBQUFBK2pyYWdSblBvZmlKM05iMWF2QkxoOXVWeXJucm5Qb3BYSVovWko1OHRkdDNtVnQ3NDRva1lQQVZGYXIyZ3J1MSIsImFtciI6WyJwd2QiXSwiYXBwX2Rpc3BsYXluYW1lIjoia21pdGVzdC1hcGkiLCJhcHBpZCI6IjcwZGIzNmMyLWFmMWEtNGQwOC1hNmQ3LWEwNGI5YjE1MWRkNiIsImFwcGlkYWNyIjoiMCIsImZhbWlseV9uYW1lIjoiV29vZHMiLCJnaXZlbl9uYW1lIjoiTWFydGluIiwiaWR0eXAiOiJ1c2VyIiwiaXBhZGRyIjoiMjAuMjI1LjM3LjE5MSIsIm5hbWUiOiJNYXJ0aW4gV29vZHMiLCJvaWQiOiIwZTZlMTIyYS05Zjg1LTQwNTQtYmVmYi1mZGMyNGJlMmYxMzUiLCJwdWlkIjoiMTAwMzIwMDBEOEEzNDE2NiIsInJoIjoiMC5BVjhBX2ZqV0tLZ1R5RUdRVHhjLThMeGV6d01BQUFBQUFQRVB6Z0FBQUFBQUFBQmZBSVEuIiwic2NwIjoiQWxsU2l0ZXMuRnVsbENvbnRyb2wgQWxsU2l0ZXMuTWFuYWdlIEFsbFNpdGVzLlJlYWQgQWxsU2l0ZXMuV3JpdGUgRW50ZXJwcmlzZVJlc291cmNlLlJlYWQgRW50ZXJwcmlzZVJlc291cmNlLldyaXRlIE15RmlsZXMuUmVhZCBNeUZpbGVzLldyaXRlIFByb2plY3QuUmVhZCBQcm9qZWN0LldyaXRlIFByb2plY3RXZWJBcHAuRnVsbENvbnRyb2wgU2l0ZXMuU2VhcmNoLkFsbCBUYXNrU3RhdHVzLlN1Ym1pdCBUZXJtU3RvcmUuUmVhZC5BbGwgVGVybVN0b3JlLlJlYWRXcml0ZS5BbGwgVXNlci5SZWFkIFVzZXIuUmVhZC5BbGwgVXNlci5SZWFkV3JpdGUuQWxsIiwic2lkIjoiMjZkOWFhMmItNTkzZi00M2UzLWExZjQtNjlmMzhlNWYwMWM3Iiwic3ViIjoiMXZTcDFfLVlVMG1iZnhUcjNua2FPNUkxWEFDX2dJZE5FZDdwSVVCZVp1byIsInRpZCI6IjI4ZDZmOGZkLTEzYTgtNDFjOC05MDRmLTE3M2VmMGJjNWVjZiIsInVuaXF1ZV9uYW1lIjoibWFydGluLndvb2RzQGZvb2R5Z29vZGllY29ycC5jb20iLCJ1cG4iOiJtYXJ0aW4ud29vZHNAZm9vZHlnb29kaWVjb3JwLmNvbSIsInV0aSI6Ik52V0VDQ2VLckVtSFl6RTBuUmQ5QUEiLCJ2ZXIiOiIxLjAiLCJ3aWRzIjpbImYyZWY5OTJjLTNhZmItNDZiOS1iN2NmLWExMjZlZTc0YzQ1MSIsIjI5MjMyY2RmLTkzMjMtNDJmZC1hZGUyLTFkMDk3YWYzZTRkZSIsIjcyOTgyN2UzLTljMTQtNDlmNy1iYjFiLTk2MDhmMTU2YmJiOCIsIjc1OTQxMDA5LTkxNWEtNDg2OS1hYmU3LTY5MWJmZjE4Mjc5ZSIsImYwMjNmZDgxLWE2MzctNGI1Ni05NWZkLTc5MWFjMDIyNjAzMyIsImQzN2M4YmVkLTA3MTEtNDQxNy1iYTM4LWI0YWJlNjZjZTRjMiIsImZkZDdhNzUxLWI2MGItNDQ0YS05ODRjLTAyNjUyZmU4ZmExYyIsImE5ZWE4OTk2LTEyMmYtNGM3NC05NTIwLThlZGNkMTkyODI2YyIsImYyOGExZjUwLWY2ZTctNDU3MS04MThiLTZhMTJmMmFmNmI2YyIsImZlOTMwYmU3LTVlNjItNDdkYi05MWFmLTk4YzNhNDlhMzhiMSIsImZjZjkxMDk4LTAzZTMtNDFhOS1iNWJhLTZmMGVjODE4OGExMiIsIjExNjQ4NTk3LTkyNmMtNGNmMy05YzM2LWJjZWJiMGJhOGRjYyIsImY3MDkzOGEwLWZjMTAtNDE3Ny05ZTkwLTIxNzhmODc2NTczNyIsIjQ0MzY3MTYzLWViYTEtNDRjMy05OGFmLWY1Nzg3ODc5Zjk2YSIsIjY5MDkxMjQ2LTIwZTgtNGE1Ni1hYTRkLTA2NjA3NWIyYTdhOCIsIjYyZTkwMzk0LTY5ZjUtNDIzNy05MTkwLTAxMjE3NzE0NWUxMCIsIjg4MzUyOTFhLTkxOGMtNGZkNy1hOWNlLWZhYTQ5ZjBjZjdkOSIsIjJiNzQ1YmRmLTA4MDMtNGQ4MC1hYTY1LTgyMmM0NDkzZGFhYyIsIjA5NjRiYjVlLTliZGItNGQ3Yi1hYzI5LTU4ZTc5NDg2MmE0MCIsIjc0ZWY5NzViLTY2MDUtNDBhZi1hNWQyLWI5NTM5ZDgzNjM1MyIsImJhZjM3YjNhLTYxMGUtNDVkYS05ZTYyLWQ5ZDFlNWU4OTE0YiIsImI3OWZiZjRkLTNlZjktNDY4OS04MTQzLTc2YjE5NGU4NTUwOSJdfQ.R8ATak3iGoVy_AS25NaFssNcmiUa0l3_9F1krCeQgIufBKyy6p0jJATi5UuCqRWyPfplDJTN7NqdZyLAusqvwpBI3IWGfoK7wcyHeI0EZMMyq3vJhHQAfPtY_Fk8cj4RlyavffVjX8_boD791MdIYV4RsfirLcg1rYHXNh16xPEqKfXoX9sxE3ITOzpmGvw4RuFbNc8qtZnt8BlAGQ6UL-1VTdbgZAmJT85Yo8x3yxbIVLuThPqWAUmDpcHRAIMF6A1hV4ErAsAKAknNJNL-CHDGFqEoxzK59sAyihgd7d3nQ357HKSlGqzrHqZTWOmlDi_GJ0hEqKkn8wg8N15L-Q';

        exit(IsSuccess);
    end;

    local procedure GetAuthorityUrl(AadTenantId: Text) Url: Text
    begin
        Url := AuthorityTxt;
        Url := Url.Replace('{AadTenantId}', AadTenantId);
    end;

    local procedure GetAuthenticationHeaderValue(AccessToken: Text) Value: Text;
    begin
        Value := StrSubstNo(BearerTxt, AccessToken);
    end;

    [InternalEvent(false, true)]
    local procedure OnBeforeGetToken(var IsHandled: Boolean; var IsSuccess: Boolean; var ErrorText: Text; var AccessToken: Text)
    begin
    end;

}