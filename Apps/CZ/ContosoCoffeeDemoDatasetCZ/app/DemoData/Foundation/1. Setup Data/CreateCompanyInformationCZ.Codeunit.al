// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.Foundation.Company;
using Microsoft.DemoData.Bank;

codeunit 31195 "Create Company Information CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Company Information" = rm;

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
        ValidateRecordFields(CompanyNameLbl, CityLbl, AddressLbl, Address2Lbl, PostCodeLbl, VATRegNoLbl, RegNoLbl);
    end;

    local procedure ValidateRecordFields(Name: Text[100]; City: Text[100]; Address: Text[100]; Address2: Text[50]; PostCode: Code[20]; VATRegistrationNo: Text[20]; RegNo: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation.Validate(Name, Name);
        CompanyInformation.Validate(City, City);
        CompanyInformation.Validate(Address, Address);
        CompanyInformation.Validate("Address 2", Address2);
        CompanyInformation.Validate("Post Code", PostCode);
        CompanyInformation.Validate("Ship-to City", City);
        CompanyInformation.Validate("Ship-to Address", Address);
        CompanyInformation.Validate("Ship-to Address 2", Address2);
        CompanyInformation.Validate("Ship-to Post Code", PostCode);
        CompanyInformation.Validate("VAT Registration No.", VATRegistrationNo);
        CompanyInformation.Validate("Registration No.", RegNo);
        CompanyInformation.Modify(true);
    end;

    var
        VATRegNoLbl: Label 'CZ00000019', MaxLength = 20, Locked = true;
        RegNoLbl: Label '00000019', MaxLength = 20, Locked = true;
        CompanyNameLbl: Label 'Cronus CZ', MaxLength = 100, Locked = true;
        CityLbl: Label 'Vracov', MaxLength = 100, Locked = true;
        AddressLbl: Label 'Okružní 5', MaxLength = 100, Locked = true;
        Address2Lbl: Label 'Vratislavice', MaxLength = 50, Locked = true;
        PostCodeLbl: Label '696 42', MaxLength = 20, Locked = true;
}
