// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoTool.Helpers;

codeunit 19038 "Create IN TDS Section"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINTaxSetup: Codeunit "Contoso IN Tax Setup";
    begin
        ContosoINTaxSetup.InsertTDSSection(Section194C(), ContractorLbl, '94C', '');
        ContosoINTaxSetup.InsertTDSSection(SectionS(), ContractorSingletransactionLbl, '94C', '194C');
        ContosoINTaxSetup.InsertTDSSection(SectionC(), ContractorConsolidatedPaymentDuringtheFYLbl, '94C', '194C');
        ContosoINTaxSetup.InsertTDSSection(Section194J(), ProfessionalFeesLbl, '94J', '');
        ContosoINTaxSetup.InsertTDSSection(Section194JPF(), ProfessionalFeesLbl, '94J', '194J');
        ContosoINTaxSetup.InsertTDSSection(Section194JTF(), TechnicalFeesLbl, '94J', '194J');
        ContosoINTaxSetup.InsertTDSSection(Section194JCC(), PaymenttoCallCentreOperatorLbl, '94J', '194J');
        ContosoINTaxSetup.InsertTDSSection(Section194JDF(), DirectorsFeesLbl, '94J', '194J');
        ContosoINTaxSetup.InsertTDSSection(Section194I(), RentLbl, '94I', '');
        ContosoINTaxSetup.InsertTDSSection(Section194IPM(), RentPlantMachineryLbl, '94I', '194I');
        ContosoINTaxSetup.InsertTDSSection(Section194ILB(), RentLandorBuildingFurnitureFittingLbl, '94I', '194I');
        ContosoINTaxSetup.InsertTDSSection(Section195(), PayabletoNonResidentsLbl, '195', '');
        ContosoINTaxSetup.InsertTDSSection(Section194A(), InterestLbl, '94A', '');
        ContosoINTaxSetup.InsertTDSSection(Section194ABP(), InterestonBankPostOfficeDepositsLbl, '94A', '194A');
        ContosoINTaxSetup.InsertTDSSection(Section194AOT(), InterestAnyOtherLbl, '94A', '194A');
    end;

    procedure Section194C(): Code[10]
    begin
        exit(Section194CTok);
    end;

    procedure SectionS(): Code[10]
    begin
        exit(SectionSTok);
    end;

    procedure SectionC(): Code[10]
    begin
        exit(SectionCTok);
    end;

    procedure Section194J(): Code[10]
    begin
        exit(Section194JTok);
    end;

    procedure Section194JPF(): Code[10]
    begin
        exit(Section194JPFTok);
    end;

    procedure Section194JTF(): Code[10]
    begin
        exit(Section194JTFTok);
    end;

    procedure Section194JCC(): Code[10]
    begin
        exit(Section194JCCTok);
    end;

    procedure Section194JDF(): Code[10]
    begin
        exit(Section194JDFTok);
    end;

    procedure Section194I(): Code[10]
    begin
        exit(Section194ITok);
    end;

    procedure Section194IPM(): Code[10]
    begin
        exit(Section194IPMTok);
    end;

    procedure Section194ILB(): Code[10]
    begin
        exit(Section194ILBTok);
    end;

    procedure Section195(): Code[10]
    begin
        exit(Section195Tok);
    end;

    procedure Section194A(): Code[10]
    begin
        exit(Section194ATok);
    end;

    procedure Section194ABP(): Code[10]
    begin
        exit(Section194ABPTok);
    end;

    procedure Section194AOT(): Code[10]
    begin
        exit(Section194AOTTok);
    end;

    var
        Section194CTok: Label '194C', MaxLength = 10;
        SectionSTok: Label 'S', MaxLength = 10;
        SectionCTok: Label 'C', MaxLength = 10;
        Section194JTok: Label '194J', MaxLength = 10;
        Section194JPFTok: Label '194J-PF', MaxLength = 10;
        Section194JTFTok: Label '194J-TF', MaxLength = 10;
        Section194JCCTok: Label '194J-CC', MaxLength = 10;
        Section194JDFTok: Label '194J-DF', MaxLength = 10;
        Section194ITok: Label '194I', MaxLength = 10;
        Section194IPMTok: Label '194I-PM', MaxLength = 10;
        Section194ILBTok: Label '194I-LB', MaxLength = 10;
        Section195Tok: Label '195', MaxLength = 10;
        Section194ATok: Label '194A', MaxLength = 10;
        Section194ABPTok: Label '194A-BP', MaxLength = 10;
        Section194AOTTok: Label '194A-OT', MaxLength = 10;
        ContractorLbl: Label 'Contractor', MaxLength = 100;
        ContractorSingletransactionLbl: Label 'Contractor-Single transaction', MaxLength = 100;
        ContractorConsolidatedPaymentDuringtheFYLbl: Label 'Contractor - Consolidated Payment During the F.Y.', MaxLength = 100;
        ProfessionalFeesLbl: Label 'Professional Fees', MaxLength = 100;
        TechnicalFeesLbl: Label 'Technical Fees (w.e.f. 01.04.2020)', MaxLength = 100;
        PaymenttoCallCentreOperatorLbl: Label 'Payment to call centre operator (w.e.f. 01.06.2017)', MaxLength = 100;
        DirectorsFeesLbl: Label 'Director''s fees', MaxLength = 100;
        RentLbl: Label 'Rent', MaxLength = 100;
        RentPlantMachineryLbl: Label 'Rent  Plant & Machinery', MaxLength = 100;
        RentLandorBuildingFurnitureFittingLbl: Label 'Rent  Land or building or furniture or fitting', MaxLength = 100;
        PayabletoNonResidentsLbl: Label 'Payable to Non Residents', MaxLength = 100;
        InterestLbl: Label 'Interest', MaxLength = 100;
        InterestonBankPostOfficeDepositsLbl: Label 'Interest on Bank and Post Office deposits', MaxLength = 100;
        InterestAnyOtherLbl: Label 'Interest any other', MaxLength = 100;
}
