// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool.Helpers;

using Microsoft.Foundation.Company;

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
