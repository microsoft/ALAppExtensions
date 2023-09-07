/// <summary>Implementation of the "Http Authentication" interface for a request that requires basic authentication</summary>
codeunit 2356 "Http Authentication Basic" implements "Http Authentication"
{
    var
        [NonDebuggable]
        GlobalUsername, GlobalPassword : Text;

    [NonDebuggable]
    /// <summary>Initializes the authentication object with the given username and password</summary>
    /// <param name="Username">The username to use for authentication</param>
    /// <param name="Password">The password to use for authentication</param>
    procedure Initialize(Username: Text; Password: Text)
    begin
        Initialize(Username, '', Password);
    end;

    [NonDebuggable]
    /// <summary>Initializes the authentication object with the given username, domain and password</summary>
    /// <param name="Username">The username to use for authentication</param>
    /// <param name="Domain">The domain to use for authentication</param>
    /// <param name="Password">The password to use for authentication</param>
    procedure Initialize(Username: Text; Domain: Text; Password: Text)
    begin
        if Domain = '' then
            GlobalUsername := Username
        else
            GlobalUsername := StrSubstNo('%1\%2', Username, Domain);

        GlobalPassword := Password;
    end;

    /// <summary>Checks if authentication is required for the request</summary>
    /// <returns>Returns true because authentication is required</returns>
    procedure IsAuthenticationRequired(): Boolean;
    begin
        exit(true);
    end;

    [NonDebuggable]
    /// <summary>Gets the authorization headers for the request</summary>
    /// <returns>Returns a dictionary of headers that need to be added to the request</returns>
    procedure GetAuthorizationHeaders() Header: Dictionary of [Text, Text];
    var
        Base64Convert: Codeunit "Base64 Convert";
    begin
        Header.Add('Authorization', StrSubstNo('Basic %1', Base64Convert.ToBase64(StrSubstNo('%1:%2', GlobalUsername, GlobalPassword))));
    end;
}