// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Telemetry;
using System.Environment;

page 6380 ConnectionSetupCard
{
    AdditionalSearchTerms = 'SignUp,electronic document,e-invoice,e-document,external,connection,connector';
    PageType = Card;
    SourceTable = ConnectionSetup;
    ApplicationArea = Basic, Suite;
    UsageCategory = None;
    Caption = 'E-Document External Connection Setup';
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
                    Visible = not this.IsSaaSInfrastructure;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        this.Authentication.StorageSet(Rec."Client ID", this.ClientID);
                    end;
                }
                field(ClientSecret; this.ClientSecret)
                {
                    Caption = 'Client Secret';
                    ToolTip = 'Specifies the client secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not this.IsSaaSInfrastructure;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        this.SaveSecret(Rec."Client Secret", this.ClientSecret)
                    end;
                }
                field(ClientTenant; this.ClientTenant)
                {
                    Caption = 'Client Tenant ID';
                    ToolTip = 'Specifies the client tenant id token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not this.IsSaaSInfrastructure;

                    trigger OnValidate()
                    begin
                        this.Authentication.StorageSet(Rec."Client Tenant", this.ClientTenant);
                    end;
                }
                field(RootID; this.RootID)
                {
                    Caption = 'Root App ID';
                    ToolTip = 'Specifies the root app id token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not this.IsSaaSInfrastructure;

                    trigger OnValidate()
                    begin
                        this.Authentication.StorageSet(Rec."Root App ID", this.RootID);
                    end;
                }
                field(RootSecret; this.RootSecret)
                {
                    Caption = 'Root Secret';
                    ToolTip = 'Specifies the root secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not this.IsSaaSInfrastructure;

                    trigger OnValidate()
                    begin
                        this.SaveSecret(Rec."Root Secret", this.RootSecret)
                    end;
                }
                field(RootTenant; this.RootTenant)
                {
                    Caption = 'Root Tenant ID';
                    ToolTip = 'Specifies the root tenant id token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not this.IsSaaSInfrastructure;

                    trigger OnValidate()
                    begin
                        this.Authentication.StorageSet(Rec."Root Tenant", this.RootTenant);
                    end;
                }
                field(RootUrl; this.RootUrl)
                {
                    Caption = 'Root Url';
                    ToolTip = 'Specifies the root url token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = not this.IsSaaSInfrastructure;

                    trigger OnValidate()
                    begin
                        this.Authentication.StorageSet(Rec."Root Market URL", this.RootUrl);
                    end;
                }
                field("Authentication URL"; Rec."Authentication URL")
                {
                    ApplicationArea = Basic, Suite;
                }
                field(ServiceURL; Rec.ServiceURL)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("Company Id"; Rec."Company Id")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
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
            action(InitOnboarding01)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Onboarding';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Visible = this.IsSaaSInfrastructure;
                ToolTip = 'Create client credentials and open the onboarding process in a web browser.';

                trigger OnAction()
                begin
                    this.Authentication.CreateClientCredentials();
                    CurrPage.Update();
                    this.SetPageVariables();
                    Hyperlink(this.Authentication.GetRootOnboardingUrl());
                    this.FeatureTelemetry.LogUptake('', this.ExternalServiceTok, Enum::"Feature Uptake Status"::"Set up");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        this.IsSaaSInfrastructure := EnvironmentInformation.IsSaaSInfrastructure();
        this.Authentication.InitConnectionSetup();
        if Rec.Get() then
            ;
        this.SetPageVariables();
        this.FeatureTelemetry.LogUptake('', this.ExternalServiceTok, Enum::"Feature Uptake Status"::Discovered);
    end;

    local procedure SetPageVariables()
    begin
        if not IsNullGuid(Rec."Client ID") then
            this.ClientID := this.MaskTxt;
        if not IsNullGuid(Rec."Client Secret") then
            this.ClientSecret := this.MaskTxt;
        if not IsNullGuid(Rec."Client Tenant") then
            this.ClientTenant := this.MaskTxt;
        if not IsNullGuid(Rec."Root App ID") then
            this.RootID := this.MaskTxt;
        if not IsNullGuid(Rec."Root Secret") then
            this.RootSecret := this.MaskTxt;
        if not IsNullGuid(Rec."Root Tenant") then
            this.RootTenant := this.MaskTxt;
        if not IsNullGuid(Rec."Root Market URL") then
            this.RootUrl := this.MaskTxt;
    end;

        [NonDebuggable]
    local procedure SaveSecret(var TokenKey: Guid; Value: SecretText)
    begin
        this.Authentication.StorageSet(TokenKey, Value);
    end;

    var
        Authentication: Codeunit Authentication;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        [NonDebuggable]
        ClientID, ClientSecret, ClientTenant, ClientUrl, RootID, RootSecret, RootTenant, RootUrl : Text;
        IsSaaSInfrastructure: Boolean;
        ExternalServiceTok: Label 'E-Document - SignUp', Locked = true;
        MaskTxt: Label '*', Locked = true;
}