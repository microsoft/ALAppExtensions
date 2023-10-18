// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Foundation.Address;

using System.Telemetry;

page 9142 "GetAddress.io Config"
{
    PageType = StandardDialog;
    SourceTable = "Postcode GetAddress.io Config";

    layout
    {
        area(content)
        {
            field("API Key"; APIKeyText)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'API Key for GetAddress.io';
                ShowCaption = false;

                trigger OnValidate()
                begin
                    ValidateApiKey();

                    Rec.SaveAPIKey(Rec.APIKey, APIKeyText);
                    UpdateAPIField();
                end;
            }
            field("Endpoint URL"; Rec.EndpointURL)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Endpoint URL for GetAddress.io';
            }
            field(TermsAndConditions; TermsAndCondsLbl)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ShowCaption = false;

                trigger OnDrillDown()
                begin
                    HyperLink(TermsAndCondsUrlTok);
                    TermsAndCondsRead := true;
                end;
            }
            field(GetAPIKey; GetAPIKeyLbl)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ShowCaption = false;

                trigger OnDrillDown()
                begin
                    HyperLink(APIKeyUrlTok);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateAPIField();
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        TermsAndCondsRead := false;
        FeatureTelemetry.LogUptake('0000FW8', 'GetAddress.io UK Postcodes', Enum::"Feature Uptake Status"::Discovered);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::Cancel then
            exit(true);

        ValidateApiKey();

        if not TermsAndCondsRead then
            Message(ThirdPartyNoticeMsg);

        exit(not IsNullGuid(Rec.APIKey));
    end;

    var
        [NonDebuggable]
        APIKeyText: Text[250];
        TermsAndCondsRead: Boolean;
        EmptyAPIKeyErr: Label 'You must provide an API key.';
        APIKeyUrlTok: Label 'https://getaddress.io/#pricing-table', Locked = true;
        GetAPIKeyLbl: Label 'Get API Key';
        TermsAndCondsLbl: Label 'Terms and conditions';
        TermsAndCondsUrlTok: Label 'https://go.microsoft.com/fwlink/?linkid=842141', Locked = true;
        ThirdPartyNoticeMsg: Label 'You are accessing a third-party website and service. You should review the third-party''s terms and privacy policy.';

    local procedure UpdateAPIField()
    begin
        if IsNullGuid(Rec.APIKey) then
            APIKeyText := ''
        else
            APIKeyText := '****************';
    end;

    local procedure ValidateApiKey()
    begin
        if APIKeyText = '' then
            Error(EmptyAPIKeyErr);
    end;
}

