codeunit 31225 "Contoso Human Resources CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata "Company Official CZL" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertCompanyOfficial(No: Code[20]; EmployeeNo: Code[20])
    var
        CompanyOfficialCZL: Record "Company Official CZL";
        Exists: Boolean;
    begin
        if CompanyOfficialCZL.Get(No) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        CompanyOfficialCZL.Validate("No.", No);
        CompanyOfficialCZL.Validate("Employee No.", EmployeeNo);

        if Exists then
            CompanyOfficialCZL.Modify(true)
        else
            CompanyOfficialCZL.Insert(true);
    end;
}