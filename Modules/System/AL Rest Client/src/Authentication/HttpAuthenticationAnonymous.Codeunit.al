/// <summary>Implementation of the "Http Authentication" interface for a anonymous request.</summary>
codeunit 2355 "Http Authentication Anonymous" implements "Http Authentication"
{
    /// <summary>Indicates if authentication is required.</summary>
    /// <returns>False, because no authentication is required.</returns>
    procedure IsAuthenticationRequired(): Boolean
    begin
        exit(false);
    end;

    /// <summary>Gets the authorization headers.</summary>
    /// <returns>Empty dictionary, because no authentication is required.</returns>
    procedure GetAuthorizationHeaders() Header: Dictionary of [Text, Text]
    begin
    end;
}