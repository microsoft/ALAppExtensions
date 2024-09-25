// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.Avalara;

using System.Telemetry;

page 6372 "Connection Setup Card"
{
    PageType = Card;
    SourceTable = "Connection Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'Avalara Connection Setup';
    Permissions = tabledata "Connection Setup" = rm;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ClientID; ClientID)
                {
                    Caption = 'Client ID';
                    ToolTip = 'Specifies the client ID.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        AvalaraAuth.SetClientId(Rec."Client ID - Key", ClientID);
                    end;
                }
                field(ClientSecret; ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        AvalaraAuth.SetClientSecret(Rec."Client Secret - Key", ClientSecret);
                    end;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Avalara.';
                }
                field("API URL"; Rec."API URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Avalara''s api.';
                }
                field("Sandbox Authentication URL"; Rec."Sandbox Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Avalara sandbox.';
                }
                field("Sandbox API URL"; Rec."Sandbox API URL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the URL to connect to Avalara sandbox api.';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company name.';
                    Editable = false;
                }
                field("Company Id"; Rec."Company Id")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company ID.';
                    Editable = false;
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
            action(SelectCompanyId)
            {
                ApplicationArea = Basic, Suite;
                Image = SelectEntries;
                Caption = 'Select Avalara Company Id';
                ToolTip = 'Select Avalara company for service.';

                trigger OnAction()
                begin
                    AvalaraProcessing.UpdateCompanyId(Rec);
                    CurrPage.Update();
                end;
            }
            action(SelectMandate)
            {
                ApplicationArea = Basic, Suite;
                Image = SelectEntries;
                Caption = 'Select Avalara Mandate';
                ToolTip = 'Select Avalara company for service.';

                trigger OnAction()
                begin
                    AvalaraProcessing.UpdateMandate();
                end;
            }
        }
        area(Promoted)
        {
            actionref(SelectCompanyIdRef; SelectCompanyId)
            {
            }
            actionref(SelectMandateRef; SelectMandate)
            {
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000NHL', AvalaraProcessing.GetAvalaraTok(), Enum::"Feature Uptake Status"::Discovered);
        AvalaraAuth.CreateConnectionSetupRecord();
        AvalaraAuth.IsClientCredsSet(ClientID, ClientSecret);
    end;

    trigger OnClosePage()
    begin
        Rec.TestField("Company Id");
    end;

    var

        AvalaraAuth: Codeunit "Authenticator";
        AvalaraProcessing: Codeunit Processing;
        [NonDebuggable]
        ClientID, ClientSecret : Text;
}
