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
                LogNotVerified: Boolean;
            begin
                if not RegistrationNoMgtCZL.CheckRegistrationNo("Registration No. CZL", "No.", Database::Contact) then
                    exit;

                LogNotVerified := true;
                if "Registration No. CZL" <> xRec."Registration No. CZL" then
                    if RegNoServiceConfigCZL.RegNoSrvIsEnabled() then begin
                        LogNotVerified := false;
                        RegistrationLogMgtCZL.ValidateRegNoWithARES(ResultRecordRef, Rec, "No.", RegistrationLogCZL."Account Type"::Contact);
                        ResultRecordRef.SetTable(Rec);
                    end;

                if LogNotVerified then
                    RegistrationLogMgtCZL.LogContact(Rec);
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
