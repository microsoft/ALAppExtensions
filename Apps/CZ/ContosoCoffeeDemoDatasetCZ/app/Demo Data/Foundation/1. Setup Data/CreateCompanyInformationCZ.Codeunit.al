codeunit 31195 "Create Company Information CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    procedure UpdateDefaultBankAccountCode()
    var
        CompanyInformation: Record "Company Information";
        CreateBankAccountCZ: Codeunit "Create Bank Account CZ";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("Default Bank Account Code CZL", CreateBankAccountCZ.NBL());
        CompanyInformation.Modify(true);
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordFields(VATRegNoLbl, RegNoLbl);
    end;

    local procedure ValidateRecordFields(VATRegistrationNo: Text[20]; RegNo: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("VAT Registration No.", VATRegistrationNo);
        CompanyInformation.Validate("Registration No.", RegNo);
        CompanyInformation.Modify(true);
    end;

    var
        VATRegNoLbl: Label 'CZ00000019', MaxLength = 20, Locked = true;
        RegNoLbl: Label '00000019', MaxLength = 20, Locked = true;
}
