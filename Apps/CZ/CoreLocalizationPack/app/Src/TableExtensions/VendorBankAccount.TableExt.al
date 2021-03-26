tableextension 11708 "Vendor Bank Account CZL" extends "Vendor Bank Account"
{
    fields
    {
        field(11790; "Third Party Bank Account CZL"; Boolean)
        {
            Caption = 'Third Party Bank Account';
            DataClassification = CustomerContent;
        }
    }
    procedure IsPublicBankAccountCZL(): Boolean
    var
        Vendor: Record Vendor;
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        if not Vendor.Get("Vendor No.") then
            exit(false);
        exit(UnreliablePayerMgtCZL.IsPublicBankAccount("Vendor No.", Vendor."VAT Registration No.", "Bank Account No.", IBAN));
    end;

    procedure IsForeignBankAccountCZL(): Boolean
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        exit(("Country/Region Code" <> '') and ("Country/Region Code" <> CompanyInformation."Country/Region Code"));
    end;

    procedure IsStandardFormatBankAccountCZL(): Boolean
    begin
        exit(IBAN = '');
    end;
}
