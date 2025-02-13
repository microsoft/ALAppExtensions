// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Telemetry;
using System.Environment;

page 6361 "EDoc Ext Connection Setup Card"
{
    PageType = Card;
    SourceTable = "E-Doc. Ext. Connection Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'E-Document External Connection Setup';

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
                    Visible = not IsSaaSInfrastructure;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        PageroAuth.SetClientId(Rec."Client ID", ClientID);
                    end;
                }
                field(ClientSecret; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not IsSaaSInfrastructure;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        PageroAuth.SetClientSecret(Rec."Client Secret", ClientSecret);
                    end;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Pagero Online.';
                    Visible = not IsSaaSInfrastructure;
                }
                field("Redirect URL"; Rec."Redirect URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the redirect URL.';
                    Visible = not IsSaaSInfrastructure;
                }
                field("FileAPI URL"; Rec."FileAPI URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the file API URL.';
                }
                field("Fileparts URL"; Rec."Fileparts URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the fileparts URL.';
                }
                field("DocumentAPI Url"; Rec."DocumentAPI Url")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document API URL.';
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
            action(OpenOAuthSetup)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open OAuth 2.0 setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Opens the OAuth 2.0 setup for the current user.';

                trigger OnAction()
                var
                    PageroAuth: Codeunit "Pagero Auth.";
                begin
                    PageroAuth.OpenOAuthSetupPage();
                    FeatureTelemetry.LogUptake('0000MSD', ExternalServiceTok, Enum::"Feature Uptake Status"::"Set up");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInfo: Codeunit "Environment Information";

    begin
        IsSaaSInfrastructure := EnvironmentInfo.IsSaaSInfrastructure();

        PageroAuth.InitConnectionSetup();
        PageroAuth.IsClientCredsSet(ClientID, ClientSecret);

        FeatureTelemetry.LogUptake('0000LST', ExternalServiceTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    trigger OnClosePage()
    var
    begin
        Rec.TestField("Company Id");
        Rec.TestField("Send Mode");
    end;

    var
        PageroAuth: Codeunit "Pagero Auth.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        [NonDebuggable]
        ClientID, ClientSecret : Text;
        IsSaaSInfrastructure: Boolean;
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
}
