// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 10538 "MTD OAuth 2.0 Setup" extends "OAuth 2.0 Setup"
{
    layout
    {
        addafter("Request URL Paths")
        {
            group("HMRC VAT Client Tokens")
            {
                Caption = 'Client Tokens';
                Visible = not IsSaaS and IsMTD;
                field("HMRC VAT Client ID"; ClientID)
                {
                    Caption = 'Client ID';
                    ToolTip = 'Specifies the client ID token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    var
                        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
                    begin
                        MTDOAuth20Mgt.SetToken("Client ID", ClientID, Rec.GetTokenDataScope());
                        ClientID := "Client ID";
                    end;
                }
                field("HMRC VAT Client Secret"; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    var
                        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
                    begin
                        MTDOAuth20Mgt.SetToken("Client Secret", ClientSecret, Rec.GetTokenDataScope());
                        ClientSecret := "Client Secret";
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInfo: Codeunit "Environment Information";
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        IsSaas := EnvironmentInfo.IsSaaS();
        IsMTD := MTDOAuth20Mgt.IsMTDOAuthSetup(Rec);
        ClientID := "Client ID";
        ClientSecret := "Client Secret";
    end;

    var
        ClientID: Text;
        ClientSecret: Text;
        IsSaas: Boolean;
        IsMTD: Boolean;
}
