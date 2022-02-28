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

    procedure VendorVATRegistrationNoCZL(): Text[20]
    var
        Vendor: Record Vendor;
    begin
        if Rec."Vendor No." = '' then
            exit('');

        Vendor.Get(Rec."Vendor No.");
        exit(Vendor."VAT Registration No.");
    end;

    procedure IsPublicBankAccountCZL(): Boolean
    var
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        if Rec."Vendor No." = '' then
            exit(false);

        exit(UnreliablePayerMgtCZL.IsPublicBankAccount(Rec."Vendor No.", Rec.VendorVATRegistrationNoCZL(), Rec."Bank Account No.", Rec.IBAN));
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
