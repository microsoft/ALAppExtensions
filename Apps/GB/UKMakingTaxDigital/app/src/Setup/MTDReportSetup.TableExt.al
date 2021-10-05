// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

tableextension 10539 "MTD Report Setup" extends "VAT Report Setup"
{
    fields
    {
        field(10530; "MTD OAuth Setup Option"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Production,Sandbox;
        }
        field(10531; "MTD Gov Test Scenario"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(10532; "MTD Disable FraudPrev. Headers"; Boolean)
        {
            DataClassification = CustomerContent;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10533; "MTD FP WinClient Due DateTime"; DateTime)
        {
            Editable = false;
            DataClassification = CustomerContent;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10534; "MTD FP WebClient Due DateTime"; DateTime)
        {
            Editable = false;
            DataClassification = CustomerContent;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10535; "MTD FP Batch Due DateTime"; DateTime)
        {
            Editable = false;
            DataClassification = CustomerContent;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10536; "MTD FP WinClient Json"; Blob)
        {
            DataClassification = EndUserIdentifiableInformation;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10537; "MTD FP WebClient Json"; Blob)
        {
            DataClassification = EndUserIdentifiableInformation;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10538; "MTD FP Batch Json"; Blob)
        {
            DataClassification = EndUserIdentifiableInformation;
#if CLEAN19
            ObsoleteState = Removed;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Pending;
            ObsoleteTag = '19.0';
#endif
            ObsoleteReason = 'Replaced by configurable Fraud Prevention Headers Setup page';
        }
        field(10539; "MTD Enabled"; Boolean)
        {
            Caption = 'Enabled';

            trigger OnValidate()
            var
                CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
            begin
                if not xRec."MTD Enabled" and "MTD Enabled" then
                    "MTD Enabled" := CustomerConsentMgt.ConfirmUserConsent();
            end;
        }
    }

    internal procedure GetMTDOAuthSetupCode(): Code[20]
    var
        MTDOAuth20Mgt: Codeunit "MTD OAuth 2.0 Mgt";
    begin
        case "MTD OAuth Setup Option" of
            "MTD OAuth Setup Option"::Production:
                exit(MTDOAuth20Mgt.GetOAuthPRODSetupCode());
            "MTD OAuth Setup Option"::Sandbox:
                exit(MTDOAuth20Mgt.GetOAuthSandboxSetupCode());
            else
                exit('');
        end;
    end;
}
