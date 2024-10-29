// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Tietoevry;

using System.Telemetry;
using System.Environment;

page 6380 "Connection Setup Card"
{
    PageType = Card;
    SourceTable = "Connection Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'Tietoevry Connection Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ClientID; ClientID)
                {
                    Caption = 'Client ID';
                    ToolTip = 'Specifies the client ID token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
#if not DOCKER
                    Visible = not IsSaaS;
#endif                    
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        TietoevryAuth.SetClientId(Rec."Client ID", ClientID);
                    end;
                }
                field(ClientSecret; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
#if not DOCKER
                    Visible = not IsSaaS;
#endif
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        TietoevryAuth.SetClientSecret(Rec."Client Secret", ClientSecret);
                    end;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Tietoevry Online.';
                    Visible = not IsSaaS;
                }
                field("Inbound API Url"; Rec."Inbound API URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the inbound API URL.';
                }
                field("Outbound API Url"; Rec."Outbound API URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the outbound API URL.';
                }
                field("Company Id"; Rec."Company Id")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company ID.';
                    ShowMandatory = true;
                }
                field("Send Mode"; Rec."Send Mode")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the send mode.';
                    ShowMandatory = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(TestOAuthSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Test OAuth 2.0 setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Tests the OAuth 2.0 setup.';

                trigger OnAction()
                var
                    TietoevryAuth: Codeunit Authenticator;
                begin
                    TietoevryAuth.TestOAuth2Setup();
                    FeatureTelemetry.LogUptake('0000MSD', ExternalServiceTok, Enum::"Feature Uptake Status"::"Set up");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInfo: Codeunit "Environment Information";

    begin
        IsSaaS := EnvironmentInfo.IsSaaS();

        TietoevryAuth.InitConnectionSetup();
        TietoevryAuth.IsClientCredsSet(ClientID, ClientSecret);

        FeatureTelemetry.LogUptake('0000LST', ExternalServiceTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    trigger OnClosePage()
    var
    begin
        Rec.TestField("Company Id");
        Rec.TestField("Send Mode");
    end;

    var
        TietoevryAuth: Codeunit Authenticator;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        [NonDebuggable]
        ClientID, ClientSecret : Text;
        IsSaaS: Boolean;
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
}
