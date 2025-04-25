// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Company;
using Microsoft.DemoTool;

codeunit 27018 "Create CA Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();

        CompanyInformation.Validate(Address, YoungStreetLbl);
        CompanyInformation.Validate("Address 2", '');
        CompanyInformation.Validate("Post Code", 'M5E 1G5');
        CompanyInformation.Validate(City, TorontoLbl);
        CompanyInformation.Validate(County, OntarioLbl);
        CompanyInformation.Validate("Phone No.", '+1 425 555 0100');
        CompanyInformation.Validate("Fax No.", '+1 425 555 0101');
        CompanyInformation.Validate("Ship-to Address", YoungStreetLbl);
        CompanyInformation.Validate("Ship-to Address 2", '');
        CompanyInformation.Validate("Ship-to Post Code", 'M5E 1G5');
        CompanyInformation.Validate("Ship-to City", TorontoLbl);
        CompanyInformation.Validate("Ship-to County", OntarioLbl);
        CompanyInformation.Validate("VAT Registration No.", '');
        CompanyInformation.Modify(true);
    end;

    internal procedure UpdateCACompanyInformationSetupData()
    var
        CompanyInformation: Record "Company Information";
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();
        CompanyInformation.Get();

        CompanyInformation.Validate("Country/Region Code", ContosoCoffeeDemoDataSetup."Country/Region Code");
        CompanyInformation.Modify(true);
    end;

    var
        YoungStreetLbl: Label '220 Yonge St', MaxLength = 100, Locked = true;
        TorontoLbl: Label 'Toronto', MaxLength = 30, Locked = true;
        OntarioLbl: Label 'Ontario', MaxLength = 30, Locked = true;
}
