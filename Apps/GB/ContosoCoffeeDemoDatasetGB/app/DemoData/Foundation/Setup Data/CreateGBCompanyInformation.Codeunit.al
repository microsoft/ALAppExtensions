codeunit 11510 "Create GB Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CompanyInformation.Validate(Address, AddressLbl);
        CompanyInformation.Validate("Ship-to Address", AddressLbl);
        CompanyInformation.Modify(true);
    end;

    var
        AddressLbl: Label '7122 South Ashford Street', MaxLength = 100, Locked = true;
}