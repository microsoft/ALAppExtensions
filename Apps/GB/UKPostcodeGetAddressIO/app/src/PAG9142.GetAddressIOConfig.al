// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 9142 "GetAddress.io Config"
{
    PageType = StandardDialog;
    SourceTable = 9092;

    layout
    {
        area(content)
        {
            field("API Key"; APIKeyText)
            {
                ApplicationArea = Basic, Suite;

                trigger OnValidate()
                begin
                    ValidateApiKey();

                    SaveAPIKey(APIKey, APIKeyText);
                    UpdateAPIField();
                end;
            }
            field("Endpoint URL"; EndpointURL)
            {
                ApplicationArea = Basic, Suite;
            }
            field(TermsAndConditions; TermsAndCondsLbl)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ShowCaption = false;

                trigger OnDrillDown()
                begin
                    HYPERLINK(TermsAndCondsUrlTok);
                    TermsAndCondsRead := TRUE;
                end;
            }
            field(GetAPIKey; GetAPIKeyLbl)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ShowCaption = false;

                trigger OnDrillDown()
                begin
                    HYPERLINK(APIKeyUrlTok);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateAPIField();
    end;

    trigger OnOpenPage()
    begin
        TermsAndCondsRead := FALSE;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        IF CloseAction = ACTION::Cancel THEN
            EXIT(TRUE);

        ValidateApiKey();
        IF APIKeyText = '' THEN
            ERROR(EmptyAPIKeyErr);

        IF NOT TermsAndCondsRead THEN
            MESSAGE(ThirdPartyNoticeMsg);

        EXIT(NOT ISNULLGUID(APIKey));
    end;

    var
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
        IF ISNULLGUID(APIKey) THEN
            APIKeyText := ''
        ELSE
            APIKeyText := '****************';
    end;

    local procedure ValidateApiKey()
    begin
        IF APIKeyText = '' THEN
            ERROR(EmptyAPIKeyErr);
    end;
}

