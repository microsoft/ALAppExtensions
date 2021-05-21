tableextension 11700 "Contact CZL" extends Contact
{
    fields
    {
        field(11770; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                RegistrationLogCZL: Record "Registration Log CZL";
                RegNoServiceConfigCZL: Record "Reg. No. Service Config CZL";
                ResultRecordRef: RecordRef;
            begin
                if not RegistrationNoMgtCZL.CheckRegistrationNo("Registration No. CZL", "No.", Database::Contact) then
                    exit;
                if "Registration No. CZL" <> xRec."Registration No. CZL" then begin
                    RegistrationLogMgtCZL.LogContact(Rec);
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Contact);
                        ResultRecordRef.SetTable(Rec);
                    end;
                end;
            end;
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
}
