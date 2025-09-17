// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Foundation.Company;
using System.Environment;

page 10504 "Gov Talk Setup"
{
    Caption = 'GovTalk Setup';
    PageType = StandardDialog;
    SourceTable = "Gov Talk Setup";

    layout
    {
        area(content)
        {
            field(Username; Rec.Username)
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
                ToolTip = 'Specifies username for the connection to the GovTalk service.';
            }
            field(Password; PasswordField)
            {
                ApplicationArea = Basic, Suite;
                ShowMandatory = true;
                ToolTip = 'Specifies password for the connection to the GovTalk service.';
                Caption = 'Password';

                trigger OnValidate()
                begin
                    PasswordModified := true;

                    if PasswordField = '' then
                        exit;

                    ClearTextPassword := PasswordField;
                    PasswordField := PasswordMaskTok;
                end;
            }
            field(Endpoint; Rec.Endpoint)
            {
                ApplicationArea = Basic, Suite;
                ExtendedDatatype = URL;
                ToolTip = 'Specifies the endpoint for the connection to the GovTalk service.';
            }
            field("Test Mode"; Rec."Test Mode")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether to test the connection to the GovTalk service by submitting the EC Sales List or VAT Return reports marked with Test in Live (TIL). The tax authority does not keep submissions you make while in Test Mode. To actually submit the reports this check box must be cleared.';
            }
            field(TermsAndConditionsLbl; TermsAndConditionsLbl)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the Terms and Conditions for the GovTalk service.';
                Caption = 'Terms and Conditions';

                trigger OnDrillDown()
                begin
                    HyperLink(TermsAndConditionsUrlTok);
                end;
            }
            field(CrownCopyright2008Lbl; CrownCopyright2008Lbl)
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies Crown Copyrights.';
                Caption = 'Crown Copyright';

                trigger OnDrillDown()
                begin
                    HyperLink(CrownCopyright2008UrlTok);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        CompanyInformation: Record "Company Information";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        CurrPage.Editable := not (CompanyInformation."Demo Company" and EnvironmentInfo.IsSaaS());
        PasswordModified := false;

        if not IsNullGuid(Rec.Password) then
            PasswordField := PasswordMaskTok;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        if CloseAction = ACTION::Cancel then
            exit;

        CompanyInformation.Get();
        if CompanyInformation."VAT Registration No." = '' then
            Message(NoCompanyVatNoSetupMsg);

        if PasswordModified then begin
            Rec.SavePassword(ClearTextPassword);
            Rec.Modify();
        end;

        Message(ThirdPartyNoticeMsg);
    end;

    var
        NoCompanyVatNoSetupMsg: Label 'GovTalk needs to know which company the documents are for. Before you can submit documents, you must enter your company''s VAT registration number on the Company Information page.';
        [NonDebuggable]
        ClearTextPassword: Text[250];
        PasswordField: Text[250];
        PasswordMaskTok: Label '********', Locked = true;
        TermsAndConditionsLbl: Label 'Terms and conditions', Locked = true;
        TermsAndConditionsUrlTok: Label 'https://go.microsoft.com/fwlink/?linkid=848764 ', Locked = true;
        ThirdPartyNoticeMsg: Label 'You are accessing a third-party website and service. You should review the third-party''''s terms and privacy policy.';
        PasswordModified: Boolean;
        CrownCopyright2008Lbl: Label 'Contains public sector information licensed under the Open Government Licence v3.0.';
        CrownCopyright2008UrlTok: Label 'https://go.microsoft.com/fwlink/?linkid=851743', Locked = true;
}

