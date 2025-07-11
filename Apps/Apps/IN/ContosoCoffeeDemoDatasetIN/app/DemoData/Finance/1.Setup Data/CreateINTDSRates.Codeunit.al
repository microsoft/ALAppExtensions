// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoData.Foundation;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 19052 "Create IN TDS Rates"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateINTDSSection: Codeunit "Create IN TDS Section";
        CreateINAssesseeCode: Codeunit "Create IN Assessee Code";
        CreateINTDSNatureofRem: Codeunit "Create IN TDS Nature of Rem.";
        CreateINActApplicable: Codeunit "Create IN Act Applicable";
        CreateCountryRegion: Codeunit "Create Country/Region";
        TaxTypeCode: Code[20];
    begin
        TaxTypeCode := 'TDS';

        InsertTDSRates(TaxTypeCode, CreateINTDSSection.SectionS(), CreateINAssesseeCode.Individual(), '2010-01-01', '', '', '', '', '0.75', '20', '0', '0', '0', '0', '30000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.SectionS(), CreateINAssesseeCode.HinduUndividedFamily(), '2010-01-01', '', '', '', '', '0.75', '20', '0', '0', '0', '0', '30000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.SectionS(), CreateINAssesseeCode.Company(), '2010-01-01', '', '', '', '', '1.5', '20', '0', '0', '0', '0', '30000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.Section194JPF(), CreateINAssesseeCode.Individual(), '2010-01-01', '', '', '', '', '7.5', '20', '0', '0', '0', '0', '30000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.Section194JPF(), CreateINAssesseeCode.Company(), '2010-01-01', '', '', '', '', '7.5', '20', '0', '0', '0', '0', '30000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.Section194ILB(), CreateINAssesseeCode.Individual(), '2010-01-01', '', '', '', '', '7.6', '20', '0', '0', '0', '0', '240000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.Section194ILB(), CreateINAssesseeCode.Company(), '2010-01-01', '', '', '', '', '7.6', '20', '0', '0', '0', '0', '240000', '0');
        InsertTDSRates(TaxTypeCode, CreateINTDSSection.Section195(), CreateINAssesseeCode.NonResidentIndian(), '2010-01-01', '', CreateINTDSNatureofRem.NatureofRemittance16(), CreateINActApplicable.IncomeTaxAct(), CreateCountryRegion.US(), '10.4', '20', '0', '0', '0', '0', '0', '0');

        EnableTaxType(TaxTypeCode, true);
    end;


    local procedure InsertTaxRateValue(TaxTypeCode: Code[20]; ID: Guid; ColID: Integer; ColType: Enum "Column Type"; ColValue: Text[100]; DateValue: Date; DecimalValue: Decimal)
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        if ColID = 0 then
            exit;

        TaxRateValue.Init();
        TaxRateValue."Tax Type" := TaxTypeCode;
        TaxRateValue."Config ID" := ID;
        TaxRateValue.ID := CreateGuid();
        TaxRateValue."Column ID" := ColID;
        TaxRateValue."Column Type" := ColType;
        TaxRateValue.Value := ColValue;
        TaxRateValue."Decimal Value" := DecimalValue;
        TaxRateValue."Date Value" := DateValue;
        TaxRateValue.Insert();
    end;

    local procedure CreateConfigID(TaxType: Code[20])
    begin
        TaxRate.Init();
        TaxRate."Tax Type" := TaxType;
        TaxRate.Insert(true);
    end;

    local procedure GetTaxColumnID(TaxTypeCode: Code[20]; ColumnName: Text[30]): Integer
    var
        TaxRateColSetup: Record "Tax Rate Column Setup";
    begin
        TaxRateColSetup.SetRange("Tax Type", TaxTypeCode);
        TaxRateColSetup.SetRange("Column Name", ColumnName);
        TaxRateColSetup.FindFirst();

        exit(TaxRateColSetup."Column ID");
    end;

    local procedure InsertTDSRates(TaxTypeCode: Code[20]; SectionCode: Text[100]; AssesseeCode: Text[100]; EffectiveDate: Text[100]; ConcessionalCode: Text[100]; NatureofRemittance: Text[100]; ActApplicable: Text[100]; CountryCode: Text[100]; TDS: Text[100]; NonPANTDS: Text[100]; Surcharge: Text[100]; eCESS: Text[100]; SHECess: Text[100]; SurchargeThresholdAmount: Text[100]; TDSThresholdAmount: Text[100]; PerContractValue: Text[100])
    var
        TDSValue: Decimal;
        NonPANTDSValue: Decimal;
        SurchargeValue: Decimal;
        eCESSValue: Decimal;
        SHECessValue: Decimal;
        SurchargeThresholdAmountValue: Decimal;
        TDSThresholdAmountValue: Decimal;
        PerContractValueValue: Decimal;
    begin
        Evaluate(TDSValue, TDS);
        Evaluate(NonPANTDSValue, NonPANTDS);
        Evaluate(SurchargeValue, Surcharge);
        Evaluate(eCESSValue, eCESS);
        Evaluate(SHECessValue, SHECess);
        Evaluate(SurchargeThresholdAmountValue, SurchargeThresholdAmount);
        Evaluate(TDSThresholdAmountValue, TDSThresholdAmount);
        Evaluate(PerContractValueValue, PerContractValue);

        CreateConfigID(TaxTypeCode);

        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Section Code'), "Column Type"::"Tax Attributes", SectionCode, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Assessee Code'), "Column Type"::"Tax Attributes", AssesseeCode, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Effective Date'), "Column Type"::"Range From", EffectiveDate, DMY2Date(1, 1, 2010), 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Concessional Code'), "Column Type"::"Tax Attributes", ConcessionalCode, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Nature of Remittance'), "Column Type"::"Tax Attributes", NatureofRemittance, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Act Applicable'), "Column Type"::"Tax Attributes", ActApplicable, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Country Code'), "Column Type"::"Tax Attributes", CountryCode, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'TDS'), "Column Type"::Component, TDS, 0D, TDSValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Non PAN TDS'), "Column Type"::Component, NonPANTDS, 0D, NonPANTDSValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Surcharge'), "Column Type"::Component, Surcharge, 0D, SurchargeValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'eCESS'), "Column Type"::Component, eCESS, 0D, eCESSValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'SHE Cess'), "Column Type"::Component, SHECess, 0D, SHECessValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Surcharge Threshold Amount'), "Column Type"::"Output Information", SurchargeThresholdAmount, 0D, SurchargeThresholdAmountValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'TDS Threshold Amount'), "Column Type"::"Output Information", TDSThresholdAmount, 0D, TDSThresholdAmountValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Per Contract Value'), "Column Type"::"Output Information", PerContractValue, 0D, PerContractValueValue);

        UpdateTaxRateId(TaxTypeCode, TaxRate.ID);
    end;

    local procedure UpdateRateIDOnRateValue(ConfigId: Guid; KeyValue: Text[2000])
    var
        TaxRateValue: Record "Tax Rate Value";
    begin
        //This will be used to find exact line of Tax Rate on calculation.
        TaxRateValue.SetRange("Config ID", ConfigId);
        if not TaxRateValue.IsEmpty() then
            TaxRateValue.ModifyAll("Tax Rate ID", KeyValue);
    end;

    local procedure UpdateTaxRateId(TaxType: Code[20]; ConfigId: Guid)
    var
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
    begin
        TaxRate.Get(TaxType, ConfigId);
        TaxRate."Tax Setup ID" := TaxSetupMatrixMgmt.GenerateTaxSetupID(ConfigId, TaxType);
        TaxRate."Tax Rate ID" := TaxSetupMatrixMgmt.GenerateTaxRateID(ConfigId, TaxType);
        TaxRate.Modify();

        UpdateRateIDOnRateValue(ConfigId, TaxRate."Tax Rate ID");
    end;

    local procedure EnableTaxType(TaxTypeCode: Code[20]; Enable: Boolean)
    var
        TaxType: Record "Tax Type";
    begin
        if TaxType.Get(TaxTypeCode) then begin
            TaxType.Enabled := Enable;
            TaxType.Modify();
        end;
    end;

    var
        TaxRate: Record "Tax Rate";

}
