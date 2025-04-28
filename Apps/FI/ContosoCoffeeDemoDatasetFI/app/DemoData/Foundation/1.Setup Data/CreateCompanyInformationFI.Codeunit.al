// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Company;

codeunit 13443 "Create Company Information FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordFields(CityLbl, PostcodeLbl, BankAccNoLbl, BusinessIdentityLbl);
    end;

    local procedure ValidateRecordFields(City: Text[30]; PostCode: Code[20]; BankAccountNo: Text[30]; BusinessIdentityCode: Code[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostcodeLbl);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        CompanyInformation.Validate("Bank Account No.", BankAccountNo);
        CompanyInformation.Validate("Business Identity Code", BusinessIdentityCode);
        CompanyInformation.Validate("Registered Home City", City);
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'Helsinki', Maxlength = 30;
        PostcodeLbl: Label '01201', MaxLength = 20;
        BankAccNoLbl: Label '2229018-7205', MaxLength = 30;
        BusinessIdentityLbl: Label '1234567-8', MaxLength = 20;
}
