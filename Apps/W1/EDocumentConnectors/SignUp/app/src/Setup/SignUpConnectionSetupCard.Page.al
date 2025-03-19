// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Telemetry;
using System.Environment;

page 6440 "SignUp Connection Setup Card"
{
    PageType = Card;
    SourceTable = "SignUp Connection Setup";
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'SignUp Connection Setup';
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ClientID; this.ClientID)
                {
                    Caption = 'Client ID';
                    ToolTip = 'Specifies the client ID token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        this.SignUpAuthentication.StorageSet(Rec."Client ID", this.ClientID);
                    end;
                }
                field(ClientSecret; this.ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        this.SaveSecret(Rec."Client Secret", this.ClientSecret);
                    end;
                }
                field(ClientTenant; this.ClientTenant)
                {
                    Caption = 'Client Tenant';
                    ToolTip = 'Specifies the client tenant.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = this.FieldsVisible;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        this.SignUpAuthentication.StorageSet(Rec."Client Tenant", this.ClientTenant);
                    end;
                }
                field(MarketplaceID; this.MarketplaceID)
                {
                    Caption = 'Marketplace App ID';
                    ToolTip = 'Specifies the Marketplace app id token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = this.FieldsVisible;

                    trigger OnValidate()
                    begin
                        this.SignUpAuthentication.StorageSet(Rec."Marketplace App ID", this.MarketplaceID);
                    end;
                }
                field(MarketplaceSecret; this.MarketplaceSecret)
                {
                    Caption = 'Marketplace Secret';
                    ToolTip = 'Specifies the Marketplace secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = this.FieldsVisible;

                    trigger OnValidate()
                    begin
                        this.SaveSecret(Rec."Marketplace Secret", this.MarketplaceSecret);
                    end;
                }
                field(MarketplaceTenant; this.MarketplaceTenant)
                {
                    Caption = 'Marketplace Tenant ID';
                    ToolTip = 'Specifies the Marketplace tenant id token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = this.FieldsVisible;

                    trigger OnValidate()
                    begin
                        this.SignUpAuthentication.StorageSet(Rec."Marketplace Tenant", this.MarketplaceTenant);
                    end;
                }
                field(MarketplaceUrl; Rec."Marketplace URL")
                {
                    Caption = 'Marketplace URL';
                    ToolTip = 'Specifies the Marketplace url token.';
                    ApplicationArea = Basic, Suite;
                    Visible = this.FieldsVisible;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(ServiceURL; Rec."Service URL")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Environment Type"; Rec."Environment Type")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(InitOnboardingAction)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Onboarding';
                Image = Setup;
                ToolTip = 'Create client credentials and open the onboarding process in a web browser.';

                trigger OnAction()
                begin
                    if IsNullGuid(Rec."Client ID") or IsNullGuid(Rec."Client Secret") then
                        this.SignUpAuthentication.CreateClientCredentials();
                    CurrPage.Update();
                    this.SetPageVariables();
                    Hyperlink(this.SignUpAuthentication.GetMarketplaceOnboardingUrl());
                    this.FeatureTelemetry.LogUptake('0000OR1', this.ExternalServiceTok, Enum::"Feature Uptake Status"::"Set up");
                end;
            }
        }

        area(Promoted)
        {
            actionref(InitOnboarding01_Promoted; InitOnboardingAction) { }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        this.FieldsVisible := not EnvironmentInformation.IsSaaSInfrastructure();
        this.SignUpAuthentication.InitConnectionSetup();
        this.FeatureTelemetry.LogUptake('0000OR2', this.ExternalServiceTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        this.SetPageVariables();
    end;

    local procedure SetPageVariables()
    begin
        if not IsNullGuid(Rec."Client ID") then
            this.ClientID := Rec."Client ID";
        if not IsNullGuid(Rec."Client Secret") then
            this.ClientSecret := Rec."Client Secret";
        if not IsNullGuid(Rec."Client Tenant") then
            this.ClientTenant := Rec."Client Tenant";
        if not IsNullGuid(Rec."Marketplace App ID") then
            this.MarketplaceID := Rec."Marketplace App ID";
        if not IsNullGuid(Rec."Marketplace Secret") then
            this.MarketplaceSecret := Rec."Marketplace Secret";
        if not IsNullGuid(Rec."Marketplace Tenant") then
            this.MarketplaceTenant := Rec."Marketplace Tenant";
    end;

    [NonDebuggable]
    local procedure SaveSecret(var TokenKey: Guid; Value: SecretText)
    begin
        this.SignUpAuthentication.StorageSet(TokenKey, Value);
    end;

    var
        SignUpAuthentication: Codeunit "SignUp Authentication";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        [NonDebuggable]
        ClientID, ClientSecret, ClientTenant, MarketplaceID, MarketplaceSecret, MarketplaceTenant : Text;
        FieldsVisible: Boolean;
        ExternalServiceTok: Label 'E-Document - SignUp', Locked = true;
}