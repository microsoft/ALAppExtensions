namespace Microsoft.Integration.Shopify;

using System.Security.Authentication;

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

                    if Hmac().IsEmpty() then
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
                    StartAuthorization();
                end;
            }
        }
    }

    [NonDebuggable]
    local procedure StartAuthorization()
    begin
        CurrPage.OAuthIntegration.StartAuthorization(OAuthRequestUrl.Unwrap());
    end;

    internal procedure SetOAuth2Properties(AuthRequestUrl: SecretText)
    begin
        OAuthRequestUrl := AuthRequestUrl;
    end;

    internal procedure Hmac(): SecretText
    begin
        exit(AuthCodeHmac);
    end;

    internal procedure Store(): Text
    begin
        exit(AuthCodeShop);
    end;

    internal procedure GetAuthorizationCode(): SecretText
    begin
        exit(AuthCodeCode);
    end;

    internal procedure State(): Integer
    begin
        exit(AuthCodeState);
    end;

    [NonDebuggable]
    local procedure SetProperties(Code: SecretText)
    var
        Response: Text;
        ParmValue, PropertyKey, PropertyValue : Text;
        ParmValues: List of [Text];
    begin
        if Code.IsEmpty() then
            exit;

        Response := Code.Unwrap();

        if Response.EndsWith('#') then
            Response := CopyStr(Response, 1, StrLen(Response) - 1);

        ParmValues := Response.Split('&');
        foreach ParmValue in ParmValues do begin
            PropertyKey := ParmValue.Split('=').Get(1);
            PropertyValue := ParmValue.Split('=').Get(2);
            case PropertyKey of
                'hmac':
                    AuthCodeHmac := PropertyValue;
                'shop':
                    AuthCodeShop := PropertyValue;
                'code':
                    AuthCodeCode := PropertyValue;
                'state':
                    Evaluate(AuthCodeState, PropertyValue);
            end;
        end;
    end;

    [Scope('OnPrem')]
    procedure GetAuthError(): Text
    begin
        exit(AuthError);
    end;

    var
        OAuthRequestUrl: SecretText;
        AuthCodeHmac: SecretText;
        AuthCodeShop: Text;
        AuthCodeCode: SecretText;
        AuthCodeState: Integer;
        AuthError: Text;
        NoStateErr: Label 'No state has been returned.';
        AuthCodeErrorLbl: Label 'Error: %1, description: %2', Comment = '%1 = The authorization error message, %2 = The authorization error description';
}