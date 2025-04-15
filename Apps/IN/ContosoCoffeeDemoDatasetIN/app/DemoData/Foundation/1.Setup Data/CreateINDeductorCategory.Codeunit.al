// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 19070 "Create IN Deductor Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertDeductorCategory(CentralGovernment(), CentralGovernmentLbl, false, false, false, false, false);
        ContosoINTaxSetup.InsertDeductorCategory(BodyIndividuals(), BodyIndividualsLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(StatutoryBodyCentralGovt(), StatutoryBodyCentralGovtLbl, true, true, false, true, true);
        ContosoINTaxSetup.InsertDeductorCategory(StatutoryBodyStateGovt(), StatutoryBodyStateGovtLbl, true, true, true, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(Firm(), FirmLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(AutonomousBodyCentralGovt(), AutonomousBodyCentralGovtLbl, true, true, false, true, true);
        ContosoINTaxSetup.InsertDeductorCategory(AutonomousBodyStateGovt(), AutonomousBodyStateGovtLbl, true, true, true, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(ArtificialJuridicalPerson(), ArtificialJuridicalPersonLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(Company(), CompanyLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(LocalAuthorityCentralGovt(), LocalAuthorityCentralGovtLbl, true, true, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(BranchDivisionCompany(), BranchDivisionCompanyLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(LocalAuthorityStateGovt(), LocalAuthorityStateGovtLbl, true, true, true, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(AssociationPersonAOP(), AssociationPersonAOPLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(IndividualHUF(), IndividualHUFLbl, false, false, false, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(StateGovernment(), StateGovernmentLbl, true, true, true, false, true);
        ContosoINTaxSetup.InsertDeductorCategory(AssociationPersonTrust(), AssociationPersonTrustLbl, false, false, false, false, true);
    end;

    procedure CentralGovernment(): Code[1]
    begin
        exit(CentralGovernmentTok);
    end;

    procedure BodyIndividuals(): Code[1]
    begin
        exit(BodyIndividualsTok);
    end;

    procedure StatutoryBodyCentralGovt(): Code[1]
    begin
        exit(StatutoryBodyCentralGovtTok);
    end;

    procedure StatutoryBodyStateGovt(): Code[1]
    begin
        exit(StatutoryBodyStateGovtTok);
    end;

    procedure Firm(): Code[1]
    begin
        exit(FirmTok);
    end;

    procedure AutonomousBodyCentralGovt(): Code[1]
    begin
        exit(AutonomousBodyCentralGovtTok);
    end;

    procedure AutonomousBodyStateGovt(): Code[1]
    begin
        exit(AutonomousBodyStateGovtTok);
    end;

    procedure ArtificialJuridicalPerson(): Code[1]
    begin
        exit(ArtificialJuridicalPersonTok);
    end;

    procedure Company(): Code[1]
    begin
        exit(CompanyTok);
    end;

    procedure LocalAuthorityCentralGovt(): Code[1]
    begin
        exit(LocalAuthorityCentralGovtTok);
    end;

    procedure BranchDivisionCompany(): Code[1]
    begin
        exit(BranchDivisionCompanyTok);
    end;

    procedure LocalAuthorityStateGovt(): Code[1]
    begin
        exit(LocalAuthorityStateGovtTok);
    end;

    procedure AssociationPersonAOP(): Code[1]
    begin
        exit(AssociationPersonAOPTok);
    end;

    procedure IndividualHUF(): Code[1]
    begin
        exit(IndividualHUFTok);
    end;

    procedure StateGovernment(): Code[1]
    begin
        exit(StateGovernmentTok);
    end;

    procedure AssociationPersonTrust(): Code[1]
    begin
        exit(AssociationPersonTrustTok);
    end;

    var
        CentralGovernmentTok: Label 'A', MaxLength = 1;
        BodyIndividualsTok: Label 'B', MaxLength = 1;
        StatutoryBodyCentralGovtTok: Label 'D', MaxLength = 1;
        StatutoryBodyStateGovtTok: Label 'E', MaxLength = 1;
        FirmTok: Label 'F', MaxLength = 1;
        AutonomousBodyCentralGovtTok: Label 'G', MaxLength = 1;
        AutonomousBodyStateGovtTok: Label 'H', MaxLength = 1;
        ArtificialJuridicalPersonTok: Label 'J', MaxLength = 1;
        CompanyTok: Label 'K', MaxLength = 1;
        LocalAuthorityCentralGovtTok: Label 'L', MaxLength = 1;
        BranchDivisionCompanyTok: Label 'M', MaxLength = 1;
        LocalAuthorityStateGovtTok: Label 'N', MaxLength = 1;
        AssociationPersonAOPTok: Label 'P', MaxLength = 1;
        IndividualHUFTok: Label 'Q', MaxLength = 1;
        StateGovernmentTok: Label 'S', MaxLength = 1;
        AssociationPersonTrustTok: Label 'T', MaxLength = 1;
        CentralGovernmentLbl: Label 'Central Government', MaxLength = 50;
        BodyIndividualsLbl: Label 'Body of Individuals', MaxLength = 50;
        StatutoryBodyCentralGovtLbl: Label 'Statutory body (Central Govt.)', MaxLength = 50;
        StatutoryBodyStateGovtLbl: Label 'Statutory body (State Govt.)', MaxLength = 50;
        FirmLbl: Label 'Firm', MaxLength = 50;
        AutonomousBodyCentralGovtLbl: Label 'Autonomous body (Central Govt.)', MaxLength = 50;
        AutonomousBodyStateGovtLbl: Label 'Autonomous body (State Govt.)', MaxLength = 50;
        ArtificialJuridicalPersonLbl: Label 'Artificial Juridical Person', MaxLength = 50;
        CompanyLbl: Label 'Company', MaxLength = 50;
        LocalAuthorityCentralGovtLbl: Label 'Local Authority (Central Govt.)', MaxLength = 50;
        BranchDivisionCompanyLbl: Label 'Branch / Division of Company', MaxLength = 50;
        LocalAuthorityStateGovtLbl: Label 'Local Authority (State Govt.)', MaxLength = 50;
        AssociationPersonAOPLbl: Label 'Association of Person (AOP)', MaxLength = 50;
        IndividualHUFLbl: Label 'Individual/HUF', MaxLength = 50;
        StateGovernmentLbl: Label 'State Government', MaxLength = 50;
        AssociationPersonTrustLbl: Label 'Association of Person (Trust)', MaxLength = 50;
}
