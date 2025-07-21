// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 19053 "Create IN TCS Rates"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateINTCSNatureofColl: Codeunit "Create IN TCS Nature of Coll.";
        CreateINAssesseeCode: Codeunit "Create IN Assessee Code";
        TaxTypeCode: Code[20];
    begin
        TaxTypeCode := 'TCS';

        InsertTCSRates(TaxTypeCode, CreateINTCSNatureofColl.NatureofCollectionA(), CreateINAssesseeCode.Company(), '', '2010-01-01', '1', '0', '5', '0', '0', '0', '0', '0', 'No');
        InsertTCSRates(TaxTypeCode, CreateINTCSNatureofColl.NatureofCollectionA(), CreateINAssesseeCode.Individual(), '', '2010-01-01', '1', '0', '5', '0', '0', '0', '0', '0', 'No');
        InsertTCSRates(TaxTypeCode, CreateINTCSNatureofColl.NatureofCollectionA(), CreateINAssesseeCode.NonResidentIndian(), '', '2010-01-01', '1', '10', '5', '4', '0', '5000000', '0', '0', 'No');
        InsertTCSRates(TaxTypeCode, CreateINTCSNatureofColl.NatureofCollection1H(), CreateINAssesseeCode.Company(), '', '2020-10-01', '0.075', '0', '1', '0', '0', '5000000', '0', '0', 'Yes');

        EnableTaxType(TaxTypeCode, true);
    end;

    local procedure InsertTaxRateValue(TaxTypeCode: Code[20]; ID: Guid; ColID: Integer; ColType: Enum "Column Type"; ColValue: Text[100]; DateValue: Date; DecimalValue: Decimal)
    var
        TaxRateValue: Record "Tax Rate Value";
        TaxSetupMatrixMgmt: Codeunit "Tax Setup Matrix Mgmt.";
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
        TaxRateValue."Tax Rate ID" := TaxSetupMatrixMgmt.GenerateTaxRateID(ID, TaxTypeCode);
        TaxRateValue.Modify();
    end;

    local procedure CreateConfigID(TaxTypeCode: Code[20])
    begin
        TaxRate.Init();
        TaxRate."Tax Type" := TaxTypeCode;
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

    local procedure InsertTCSRates(TaxTypeCode: Code[20]; TCSNOC: Text[100]; AssesseCode: Text[100]; ConcessionalCode: Text[100]; EffectiveDate: Text[100]; TCS: Text[100]; Surcharge: Text[100]; NonPANTCS: Text[100]; eCess: Text[100]; SHECess: Text[100]; TCSThresholdAmount: Text[100]; SurchargeThresholdAmount: Text[100]; ContractAmount: Text[100]; CalcOverThreshold: Text[100])
    var
        TCSValue: Decimal;
        SurchargeValue: Decimal;
        NonPANTCSValue: Decimal;
        eCessValue: Decimal;
        SHECessValue: Decimal;
        TCSThresholdAmountValue: Decimal;
        SurchargeThresholdAmountValue: Decimal;
        ContractAmountValue: Decimal;
    begin
        Evaluate(TCSValue, TCS);
        Evaluate(SurchargeValue, Surcharge);
        Evaluate(NonPANTCSValue, NonPANTCS);
        Evaluate(eCessValue, eCess);
        Evaluate(SHECessValue, SHECess);
        Evaluate(TCSThresholdAmountValue, TCSThresholdAmount);
        Evaluate(SurchargeThresholdAmountValue, SurchargeThresholdAmount);
        Evaluate(ContractAmountValue, ContractAmount);

        CreateConfigID(TaxTypeCode);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'TCS Nature of Collection'), "Column Type"::"Tax Attributes", TCSNOC, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Assessee Code'), "Column Type"::"Tax Attributes", AssesseCode, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Concessional Code'), "Column Type"::"Range From", ConcessionalCode, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Effective Date'), "Column Type"::"Range From", EffectiveDate, DMY2Date(1, 1, 2010), 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'TCS'), "Column Type"::Component, TCS, 0D, TCSValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Surcharge'), "Column Type"::Component, Surcharge, 0D, SurchargeValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Non PAN TCS'), "Column Type"::Component, NonPANTCS, 0D, NonPANTCSValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'e Cess'), "Column Type"::Component, eCess, 0D, eCessValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'SHE Cess'), "Column Type"::Component, SHECess, 0D, SHECessValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'TCS Threshold Amount'), "Column Type"::"Output Information", TCSThresholdAmount, 0D, TCSThresholdAmountValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Surcharge Threshold Amount'), "Column Type"::"Output Information", SurchargeThresholdAmount, 0D, SurchargeThresholdAmountValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Contract Amount'), "Column Type"::"Output Information", ContractAmount, 0D, ContractAmountValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Calc. Over & Above Threshold'), "Column Type"::"Output Information", CalcOverThreshold, 0D, 0);

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
