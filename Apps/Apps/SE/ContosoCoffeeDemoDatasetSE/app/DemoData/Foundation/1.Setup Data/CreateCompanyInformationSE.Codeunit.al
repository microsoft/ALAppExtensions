// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Company;

codeunit 11204 "Create Company Information SE"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    begin
        ValidateRecordSEelds(CityLbl, PostCodeLbl, 'SE777777777701', GiroNoLbl);
    end;

    local procedure ValidateRecordSEelds(City: Text[30]; PostCode: Code[20]; VatRegNo: Text[20]; GiroNo: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate("Post Code", PostCodeLbl);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        CompanyInformation."VAT Registration No." := VatRegNo;
        CompanyInformation.Validate("Giro No.", GiroNo);
        CompanyInformation.Modify(true);
    end;

    procedure UpdateCompanyRegistrationInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate("Phone No.", '031-00000');
        CompanyInformation.Validate("Registration No.", '5562334804');
        CompanyInformation."VAT Registration No." := 'SE556233480401';
        CompanyInformation.Modify(true);
    end;

    var
        CityLbl: Label 'GÖTEBORG', Maxlength = 30, Locked = true;
        PostCodeLbl: Label '415 06', MaxLength = 20;
        GiroNoLbl: Label '991-2346', MaxLength = 20;
}
