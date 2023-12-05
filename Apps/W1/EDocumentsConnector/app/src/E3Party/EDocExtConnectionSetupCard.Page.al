// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using System.Security.Authentication;
using System.Telemetry;

page 6361 "EDoc Ext Connection Setup Card"
{
    PageType = Card;
    SourceTable = "E-Doc. Ext. Connection Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;
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

                    trigger OnValidate()
                    begin
                        PageroAuth.SetToken(Rec."Client ID", ClientID, DataScope::Company);
                        ClientID := Rec."Client ID";
                        PageroAuth.UpdatePageroOAuthSetupsWithClientIDAndSecret(Rec."Client ID", Rec."Client Secret", ClientIDText, ClientSecretText);
                    end;
                }
                field(ClientSecret; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;

                    trigger OnValidate()
                    begin
                        PageroAuth.SetToken(Rec."Client Secret", ClientSecret, DataScope::Company);
                        ClientSecret := Rec."Client Secret";
                        PageroAuth.UpdatePageroOAuthSetupsWithClientIDAndSecret(Rec."Client ID", Rec."Client Secret", ClientIDText, ClientSecretText);
                    end;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Pagero Online.';
                }
                field("Redirect URL"; Rec."Redirect URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the redirect URL.';
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
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec."OAuth Feature GUID" := CreateGuid();
            Rec."Authentication URL" := AuthURLTxt;
            Rec."FileAPI URL" := FileAPITxt;
            Rec."DocumentAPI Url" := DocumentAPITxt;
            Rec."Fileparts URL" := FilepartAPITxt;
            Rec.Insert();
        end;

        FeatureTelemetry.LogUptake('0000LST', ExternalServiceTok, Enum::"Feature Uptake Status"::Discovered);
        ClientID := Rec."Client ID";
        ClientSecret := Rec."Client Secret";
    end;

    var
        PageroAuth: Codeunit "Pagero Auth.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ExternalServiceTok: Label 'ExternalServiceConnector', Locked = true;
        [NonDebuggable]
        ClientID: Text;
        [NonDebuggable]
        ClientSecret: Text;
        [NonDebuggable]
        ClientIDText: Text;
        [NonDebuggable]
        ClientSecretText: Text;
        AuthURLTxt: Label 'https://auth.pageroonline.com/oauth2', Locked = true;
        FileAPITxt: Label 'https://api.pageroonline.com/file/v1/files', Locked = true;
        DocumentAPITxt: Label 'https://api.pageroonline.com/document/v1/documents', Locked = true;
        FilepartAPITxt: Label 'https://api.pageroonline.com/file/v1/fileparts', Locked = true;
}
