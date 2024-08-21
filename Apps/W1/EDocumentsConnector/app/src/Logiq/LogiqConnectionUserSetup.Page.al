namespace Microsoft.EServices.EDocumentConnector.Logiq;

page 6381 "Logiq Connection User Setup"
{
    Caption = 'Logiq Connection User Setup';
    PageType = Card;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ShowFilter = false;
    SourceTable = "Logiq Connection User Setup";
    UsageCategory = None;
    ApplicationArea = Basic, Suite;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Username; Rec.Username)
                {
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if IsFullCredentials() then
                            CheckCredentialsAndUpdateTokens();
                    end;
                }
                field(Password; PasswordTxt)
                {
                    Caption = 'Password';
                    ToolTip = 'Specifies the user password.';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if PasswordTxt = '' then
                            Rec.DeletePassword()
                        else
                            LogiqAuth.SetIsolatedStorageValue(Rec.Password, PasswordTxt, DataScope::User);

                        if IsFullCredentials() then
                            CheckCredentialsAndUpdateTokens();
                    end;
                }
                field("Access Token Expiration"; Rec."Access Token Expiration")
                {
                    Editable = false;
                }
                field("Refresh Token Expiration"; Rec."Refresh Token Expiration")
                {
                    Editable = false;
                }
                field("API Engine"; Rec."API Engine")
                {
                }
                field("Document Transfer Endpoint"; Rec."Document Transfer Endpoint")
                {
                }
                field("Document Status Endpoint"; Rec."Document Status Endpoint")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get Tokens")
            {
                ApplicationArea = All;
                Caption = 'Get Tokens';
                ToolTip = 'Get Logiq access tokens for current user.';
                Image = Setup;

                trigger OnAction()
                begin
                    LogiqAuth.GetTokens();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref("Get Tokens_Promoted"; "Get Tokens")
                {
                }
            }
        }
    }

    var
        LogiqAuth: Codeunit "Logiq Auth";
        [NonDebuggable]
        PasswordTxt: Text;

    trigger OnOpenPage()
    begin
        if not IsNullGuid(Rec.Password) then
            if LogiqAuth.HasToken(Rec.Password, DataScope::User) then
                PasswordTxt := '*';
    end;

    local procedure IsFullCredentials(): Boolean
    begin
        exit((Rec.Username <> '') and (PasswordTxt <> ''));
    end;

    local procedure CheckCredentialsAndUpdateTokens(): Boolean
    begin
        Rec.DeleteUserTokens();
        CurrPage.Update();
        LogiqAuth.GetTokens();
    end;
}
