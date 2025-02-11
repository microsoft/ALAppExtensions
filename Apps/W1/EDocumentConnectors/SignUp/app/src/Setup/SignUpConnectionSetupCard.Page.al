// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector.SignUp;

using System.Telemetry;
using Microsoft.Foundation.Company;
using System.Environment;

page 6380 SignUpConnectionSetupCard
{
    AdditionalSearchTerms = 'SignUp,electronic document,e-invoice,e-document,external,connection,connector';
    PageType = Card;
    SourceTable = SignUpConnectionSetup;
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
                field(RootID; this.RootID)
                {
                    Caption = 'Root App ID';
                    ToolTip = 'Specifies the root app id token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = this.FieldsVisible;

                    trigger OnValidate()
                    begin
                        this.SignUpAuthentication.StorageSet(Rec."Root App ID", this.RootID);
                    end;
                }
                field(RootSecret; this.RootSecret)
                {
                    Caption = 'Root Secret';
                    ToolTip = 'Specifies the root secret token.';
                    ApplicationArea = Basic, Suite;
                    ExtendedDatatype = Masked;
                    Visible = this.FieldsVisible;

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
                    Visible = this.FieldsVisible;

                    trigger OnValidate()
                    begin
                        this.SignUpAuthentication.StorageSet(Rec."Root Tenant", this.RootTenant);
                    end;
                }
                field(RootUrl; Rec."Root Market URL")
                {
                    Caption = 'Root URL';
                    ToolTip = 'Specifies the root url token.';
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
            action(InitOnboarding01)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open Onboarding';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Create client credentials and open the onboarding process in a web browser.';

                trigger OnAction()
                begin
                    this.SignUpAuthentication.CreateClientCredentials();
                    CurrPage.Update();
                    this.SetPageVariables();
                    Hyperlink(this.SignUpAuthentication.GetRootOnboardingUrl());
                    this.FeatureTelemetry.LogUptake('', this.ExternalServiceTok, Enum::"Feature Uptake Status"::"Set up");
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        this.FieldsVisible := not EnvironmentInformation.IsSaaSInfrastructure();
        this.SignUpAuthentication.InitConnectionSetup();
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
    end;

    [NonDebuggable]
    local procedure SaveSecret(var TokenKey: Guid; Value: SecretText)
    begin
        this.SignUpAuthentication.StorageSet(TokenKey, Value);
    end;

    var
        SignUpAuthentication: Codeunit SignUpAuthentication;
        FeatureTelemetry: Codeunit "Feature Telemetry";
        [NonDebuggable]
        ClientID, ClientSecret, ClientTenant, RootID, RootSecret, RootTenant : Text;
        FieldsVisible: Boolean;
        ExternalServiceTok: Label 'E-Document - SignUp', Locked = true;
        MaskTxt: Label '*', Locked = true;
}