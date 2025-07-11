// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;
using Microsoft.Finance.TaxBase;

codeunit 19007 "Create IN Assessee Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertAssesseeCode(AssociationPersons(), AssociationPersonsLbl, Enum::"Assessee Type"::Others);
        ContosoINTaxSetup.InsertAssesseeCode(BodyIndividuals(), BodyIndividualsLbl, Enum::"Assessee Type"::Others);
        ContosoINTaxSetup.InsertAssesseeCode(Company(), CompanyLbl, Enum::"Assessee Type"::Company);
        ContosoINTaxSetup.InsertAssesseeCode(HinduUndividedFamily(), HinduUndividedFamilyLbl, Enum::"Assessee Type"::Others);
        ContosoINTaxSetup.InsertAssesseeCode(Individual(), IndividualLbl, Enum::"Assessee Type"::Others);
        ContosoINTaxSetup.InsertAssesseeCode(NonResidentIndian(), NonResidentIndianLbl, Enum::"Assessee Type"::Others);
    end;

    procedure AssociationPersons(): Code[10]
    begin
        exit(AssociationPersonsTok);
    end;

    procedure BodyIndividuals(): Code[10]
    begin
        exit(BodyIndividualsTok);
    end;

    procedure Company(): Code[10]
    begin
        exit(CompanyTok);
    end;

    procedure HinduUndividedFamily(): Code[10]
    begin
        exit(HinduUndividedFamilyTok);
    end;

    procedure Individual(): Code[10]
    begin
        exit(IndividualTok);
    end;

    procedure NonResidentIndian(): Code[10]
    begin
        exit(NonResidentIndianTok);
    end;

    var
        AssociationPersonsTok: Label 'AOP', MaxLength = 10, Locked = true;
        BodyIndividualsTok: Label 'BOI', MaxLength = 10, Locked = true;
        CompanyTok: Label 'COM', MaxLength = 10, Locked = true;
        HinduUndividedFamilyTok: Label 'HUF', MaxLength = 10, Locked = true;
        IndividualTok: Label 'IND', MaxLength = 10, Locked = true;
        NonResidentIndianTok: Label 'NRI', MaxLength = 10, Locked = true;
        AssociationPersonsLbl: Label 'Association of Persons', MaxLength = 100;
        BodyIndividualsLbl: Label 'Body Of Individuals', MaxLength = 100;
        CompanyLbl: Label 'Company', MaxLength = 100;
        HinduUndividedFamilyLbl: Label 'Hindu Undivided Family', MaxLength = 100;
        IndividualLbl: Label 'Individual', MaxLength = 100;
        NonResidentIndianLbl: Label 'Non Resident Indian', MaxLength = 100;
}
