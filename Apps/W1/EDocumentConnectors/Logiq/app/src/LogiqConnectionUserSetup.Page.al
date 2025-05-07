// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Logiq;

page 6431 "Logiq Connection User Setup"
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
    Extensible = false;

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
                        if this.IsFullCredentials() then
                            this.CheckCredentialsAndUpdateTokens();
                    end;
                }
                field(Password; this.PasswordTxt)
                {
                    Caption = 'Password';
                    ToolTip = 'Specifies the user password.';
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        if this.PasswordTxt = '' then
                            this.LogiqAuth.DeletePassword(Rec)
                        else
                            this.LogiqAuth.SetIsolatedStorageValue(Rec."Password - Key", this.PasswordTxt, DataScope::User);

                        if this.IsFullCredentials() then
                            this.CheckCredentialsAndUpdateTokens();
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
                    this.LogiqAuth.GetTokens();
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
        if not IsNullGuid(Rec."Password - Key") then
            if this.LogiqAuth.HasToken(Rec."Password - Key", DataScope::User) then
                this.PasswordTxt := '*';
    end;

    local procedure IsFullCredentials(): Boolean
    begin
        exit((Rec.Username <> '') and (this.PasswordTxt <> ''));
    end;

    local procedure CheckCredentialsAndUpdateTokens(): Boolean
    begin
        this.LogiqAuth.DeleteUserTokens(Rec);
        CurrPage.Update();
        this.LogiqAuth.GetTokens();
    end;
}
