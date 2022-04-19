/// <summary>
/// Page Shpfy Authentication (ID 30135).
/// </summary>
page 30135 "Shpfy Authentication"
{
    Extensible = false;
    Caption = 'Waiting for a response - do not close this page';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    UsageCategory = None;
    PageType = NavigatePage;


    layout
    {
        area(Content)
        {
            usercontrol(OAuthIntegration; OAuthControlAddIn)
            {
                ApplicationArea = All;
                trigger AuthorizationCodeRetrieved(Code: Text)
                begin
                    SetProperties(Code);

                    if Hmac() = '' then
                        AuthError := AuthError + NoStateErr;

                    CurrPage.Close();
                end;

                trigger AuthorizationErrorOccurred(error: Text; desc: Text);
                begin
                    AuthError := StrSubstNo(AuthCodeErrorLbl, error, desc);
                    CurrPage.Close();
                end;

                trigger ControlAddInReady();
                begin
                    CurrPage.OAuthIntegration.StartAuthorization(OAuthRequestUrl);
                end;
            }
        }
    }

    [NonDebuggable]
    internal procedure SetOAuth2Properties(AuthRequestUrl: Text)
    begin
        OAuthRequestUrl := AuthRequestUrl;
    end;

    [NonDebuggable]
    internal procedure Hmac(): Text
    begin
        exit(GetPropertyFromCode('hmac'));
    end;

    [NonDebuggable]
    internal procedure Store(): Text
    begin
        exit(GetPropertyFromCode('shop'));
    end;

    [NonDebuggable]
    internal procedure Timestamp(): Text
    begin
        exit(GetPropertyFromCode('timestamp'));
    end;

    [NonDebuggable]
    internal procedure GetAuthorizationCode(): Text
    begin
        exit(GetPropertyFromCode('code'));
    end;

    [NonDebuggable]
    internal procedure Host(): Text
    begin
        exit(GetPropertyFromCode('host'));
    end;

    [NonDebuggable]
    internal procedure State(): Integer
    var
        StateValue: Integer;
    begin
        if Evaluate(StateValue, GetPropertyFromCode('state')) then
            exit(StateValue);
    end;

    [NonDebuggable]
    local procedure SetProperties(Code: Text)
    var
        ParmValue: Text;
        ParmValues: List of [Text];
    begin
        Clear(OAuthProperties);
        if Code = '' then
            exit;

        if Code.EndsWith('#') then
            Code := CopyStr(Code, 1, StrLen(Code) - 1);

        ParmValues := Code.Split('&');
        foreach ParmValue in ParmValues do
            OAuthProperties.Add(ParmValue.Split('=').Get(1), ParmValue.Split('=').Get(2));
    end;

    [NonDebuggable]
    local procedure GetPropertyFromCode(Property: Text): Text
    begin
        if OAuthProperties.ContainsKey(Property) then
            exit(OAuthProperties.Get(Property));
    end;

    var
        [NonDebuggable]
        OAuthRequestUrl: Text;
        [NonDebuggable]
        OAuthProperties: Dictionary of [Text, Text];
        [NonDebuggable]
        AuthError: Text;
        NoStateErr: Label 'No state has been returned.';
        AuthCodeErrorLbl: Label 'Error: %1, description: %2', Comment = '%1 = The authorization error message, %2 = The authorization error description';
}