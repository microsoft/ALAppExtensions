// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Telemetry;

page 10068 "Setup IRIS User ID"
{
    PageType = Card;
    ApplicationArea = BasicUS;
    Extensible = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    Permissions = tabledata "User Params IRIS" = RM;
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            group(General)
            {
                ShowCaption = false;

                grid(GridControl)
                {
                    group(InnerGroup)
                    {
                        ShowCaption = false;

                        field("API Client ID"; IRISAPIClientID)
                        {
                            Caption = 'IRIS API Client ID';
                            ToolTip = 'Specifies the GUID that is used to authenticate and authorize access to the IRS''s Information Returns Intake System (IRIS) API.';
                            Editable = false;
                        }
                        field("User ID"; IRISUserID)
                        {
                            Caption = 'IRIS User ID';
                            ToolTip = 'Specifies the user ID from the IRS Consent App that is required to access the IRS Information Returns Intake System (IRIS) API. Each Business Central user who sends transmissions to the IRIS should use their own User ID.';
                            ShowMandatory = true;
                            ExtendedDatatype = Masked;

                            trigger OnValidate()
                            begin
                                UserParamsIRIS.LockTable();
                                UserParamsIRIS.GetRecord();
                                OAuthClient.SetToken(UserParamsIRIS."IRIS User ID Key", IRISUserID);
                                UserParamsIRIS.Modify();

                                FeatureTelemetry.LogUsage('0000PSO', Helper.GetIRISFeatureName(), UpdateUserIDEventTxt);
                            end;
                        }
                        field(GetIRISUserIDInstructions; GetIRISUserID)
                        {
                            ApplicationArea = All;
                            ToolTip = 'Show instructions on how to get IRIS User ID.';
                            Editable = false;
                            ShowCaption = false;
                            StyleExpr = 'StrongAccent';

                            trigger OnDrillDown()
                            begin
                                Message(GetIRISUserIDInstructionsTxt, KeyVaultClient.GetConsentAppURL());
                            end;
                        }
                    }
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(OpenIRSConsentApp)
            {
                ApplicationArea = BasicUS;
                Caption = 'Open IRS Consent App';
                Image = LinkWeb;
                ToolTip = 'Opens the IRS Consent App in the default web browser.';

                trigger OnAction()
                var
                    ConsentAppURL: Text;
                begin
                    ConsentAppURL := KeyVaultClient.GetConsentAppURL();
                    if ConsentAppURL = '' then
                        ConsentAppURL := ConsentAppURLTxt;
                    Hyperlink(ConsentAppURL);
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenIRSConsentApp_Promoted; OpenIRSConsentApp)
            {
            }
        }
    }

    trigger OnOpenPage()
    begin
        IRISAPIClientID := IRSFormsSetup.GetIRISAPIClientID();

        if UserParamsIRIS.Get(UserSecurityId()) then
            if OAuthClient.TokenExists(UserParamsIRIS."IRIS User ID Key") then
                IRISUserID := CreateGuid();     // random GUID to show that User ID is set

        GetIRISUserID := 'How to get IRIS User ID';
    end;

    var
        IRSFormsSetup: Record "IRS Forms Setup";
        UserParamsIRIS: Record "User Params IRIS";
        Helper: Codeunit "Helper IRIS";
        KeyVaultClient: Codeunit "Key Vault Client IRIS";
        OAuthClient: Codeunit "OAuth Client IRIS";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        IRISAPIClientID: Text[36];
        IRISUserID: Text;
        GetIRISUserID: Text;
        UpdateUserIDEventTxt: Label 'UpdateUserID', Locked = true;
        ConsentAppURLTxt: Label 'https://la.www4.irs.gov/esrv/consent/', Locked = true;
        GetIRISUserIDInstructionsTxt: Label 'To get IRIS User ID:\\  1. Copy IRIS API Client ID to clipboard\  2. Login to IRS Consent App: %1\  3. Select Setup on the API Authorization Management page.\  4. Enter IRIS API Client ID on the A2A Authorization page, grant access to PROD.\ 5. Grant access to TEST if you also want to test sending 1099 forms on sandbox.\ 6. Copy your Full IRIS UserID from the A2A Setup Complete page.\     Example of User ID: "dasmith-345870".\  7. Paste it to the IRIS User ID field on this page.', Comment = '%1 - IRS Consent App URL';
}