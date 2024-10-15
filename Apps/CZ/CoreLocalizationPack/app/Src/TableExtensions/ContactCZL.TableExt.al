// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.CRM.Contact;

using Microsoft.Finance.Registration;

tableextension 11700 "Contact CZL" extends Contact
{
    fields
    {
        modify("Registration Number")
        {
            trigger OnAfterValidate()
            var
                RegistrationLogCZL: Record "Registration Log CZL";
                RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
                ResultRecordRef: RecordRef;
                LogNotVerified: Boolean;
                IsHandled: Boolean;
            begin
                OnBeforeOnValidateRegistrationNoCZL(Rec, xRec, IsHandled);
                if IsHandled then
                    exit;

                if not RegistrationNoMgtCZL.CheckRegistrationNo(GetRegistrationNoTrimmedCZL(), "No.", Database::Contact) then
                    exit;

                LogNotVerified := true;
                if "Registration Number" <> xRec."Registration Number" then
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        LogNotVerified := false;
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Contact);
                        ResultRecordRef.SetTable(Rec);
                    end;

                if LogNotVerified then
                    RegistrationLogMgtCZL.LogContact(Rec);
            end;
        }
        field(11770; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '26.0';
            ObsoleteReason = 'Replaced by standard "Registration Number" field.';
        }
        field(11771; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                RegistrationNoMgtCZL.CheckTaxRegistrationNo("Tax Registration No. CZL", "No.", Database::Contact);
            end;
        }
    }
    var
        RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
        RegistrationNoMgtCZL: Codeunit "Registration No. Mgt. CZL";

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnValidateRegistrationNoCZL(Contact: Record "Contact"; xContact: Record "Contact"; var IsHandled: Boolean)
    begin
    end;

    procedure GetRegistrationNoTrimmedCZL(): Text[20]
    begin
        exit(CopyStr("Registration Number", 1, 20));
    end;
}
