// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.Company;

codeunit 19069 "Create IN Company Information"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    begin
        UpdateCompanyInformation();
    end;

    local procedure UpdateCompanyInformation()
    var
        CreateINState: Codeunit "Create IN State";
        CreateINDeductorCategory: Codeunit "Create IN Deductor Category";
        CreateINTCANNos: Codeunit "Create IN TCAN Nos.";
        CreateINTANNos: Codeunit "Create IN TAN Nos.";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        ValidateRecordsFields(AddressLbl, Address2Lbl, CityLbl, PostCodeLbl, ShiptoCityLbl, ShiptoPostCodeLbl, CreateCountryRegion.IND(), RegistrationNoLbl, Enum::"Company Status"::Government, 'COMPA0007I', CreateINDeductorCategory.CentralGovernment(), Enum::"Ministry Type"::Regular, '10', AssessingOfficerLbl, '70B', CreateINTANNos.BlueTANNo(), CreateINState.Delhi(), '07COMPA0007I1Z1', CreateINTCANNos.BlueTCANNo());
    end;

    local procedure ValidateRecordsFields(Address: Text[100]; Address2: Text[50]; City: Text[30]; PostCode: Code[20]; ShiptoCity: Text[30]; ShiptoPostCode: Code[20]; ShiptoCountryRegionCode: Code[10]; RegistrationNo: Text[20]; CompanyStatus: Enum "Company Status"; PANNo: Code[20]; DeductorCategory: Code[1]; MinistryType: Enum "Ministry Type"; CircleNo: Text[30]; AssessingOfficer: Text[30]; WardNo: Text[30]; TANNo: Code[10]; StateCode: Code[10]; GSTRegistrationNo: Code[20]; TCANNo: Code[10])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate(Address, Address);
        CompanyInformation.Validate("Address 2", Address2);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.City := City;
        CompanyInformation.Validate("Ship-to City", ShiptoCity);
        CompanyInformation.Validate("Ship-to Post Code", ShiptoPostCode);
        CompanyInformation."Ship-to Country/Region Code" := ShiptoCountryRegionCode;
        CompanyInformation.Validate("Registration No.", RegistrationNo);
        CompanyInformation.Validate("Company Status", CompanyStatus);
        CompanyInformation.Validate("P.A.N. No.", PANNo);
        CompanyInformation.Validate("Deductor Category", DeductorCategory);
        CompanyInformation.Validate("Ministry Type", MinistryType);
        CompanyInformation.Validate("Circle No.", CircleNo);
        CompanyInformation.Validate("Assessing Officer", AssessingOfficer);
        CompanyInformation.Validate("Ward No.", WardNo);
        CompanyInformation.Validate("T.A.N. No.", TANNo);
        CompanyInformation.Validate("State Code", StateCode);
        CompanyInformation."GST Registration No." := GSTRegistrationNo;
        CompanyInformation.Validate("T.C.A.N. No.", TCANNo);
        CompanyInformation.Modify(true);
    end;

    var
        AddressLbl: Label 'The Ring 5', MaxLength = 100, Locked = true;
        Address2Lbl: Label 'Patel Nagar', MaxLength = 50, Locked = true;
        CityLbl: Label 'New Delhi', Maxlength = 30, Locked = true;
        PostCodeLbl: Label 'IN-110001', MaxLength = 20, Locked = true;
        ShiptoCityLbl: Label 'London', Maxlength = 30, Locked = true;
        ShiptoPostCodeLbl: Label 'GB-W2 8HG', MaxLength = 20, Locked = true;
        RegistrationNoLbl: Label 'U12345ND6789PLC09898', MaxLength = 20;
        AssessingOfficerLbl: Label 'James', MaxLength = 30;
}
