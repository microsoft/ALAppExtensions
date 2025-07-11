// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

using Microsoft.DemoData.Foundation;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;

codeunit 19051 "Create IN GST Rates"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        CreateINGSTGroup: Codeunit "Create IN GST Group";
        CreateINHSNSAC: Codeunit "Create IN HSN/SAC";
        CreateINState: Codeunit "Create IN State";
        TaxTypeCode: Code[20];
    begin
        TaxTypeCode := 'GST';

        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode0988001(), CreateINGSTGroup.GSTGroup0988(), '', CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode0988001(), CreateINGSTGroup.GSTGroup0988(), CreateINState.Haryana(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode0988001(), CreateINGSTGroup.GSTGroup0988(), CreateINState.Delhi(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '9', '9', '0', '0', 'false', 'false');

        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode0989001(), CreateINGSTGroup.GSTGroup0989(), '', CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode0989001(), CreateINGSTGroup.GSTGroup0989(), CreateINState.Haryana(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode0989001(), CreateINGSTGroup.GSTGroup0989(), CreateINState.Delhi(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '9', '9', '0', '0', 'false', 'false');

        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode2089001(), CreateINGSTGroup.GSTGroup2089(), '', CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode2089001(), CreateINGSTGroup.GSTGroup2089(), CreateINState.Haryana(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode2089001(), CreateINGSTGroup.GSTGroup2089(), CreateINState.Delhi(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '9', '9', '0', '0', 'false', 'false');

        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode2090001(), CreateINGSTGroup.GSTGroup2090(), '', CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode2090001(), CreateINGSTGroup.GSTGroup2090(), CreateINState.Haryana(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '0', '0', '18', '0', 'false', 'false');
        InsertGSTRates(TaxTypeCode, CreateINHSNSAC.HSNSACCode2090001(), CreateINGSTGroup.GSTGroup2090(), CreateINState.Delhi(), CreateINState.Delhi(), '2010-01-01', '2025-01-01', '9', '9', '0', '0', 'false', 'false');

        EnableTaxType(TaxTypeCode, true);
    end;

    local procedure InsertTaxRateValue(TaxTypeCode: Code[20]; ID: Guid; ColID: Integer; ColType: Enum "Column Type"; ColValue: Text[250]; DateValue: Date; DateValueTo: Date; DecimalValue: Decimal)
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
        TaxRateValue."Value To" := Format(DateValueTo, 0, 9);
        TaxRateValue."Date Value To" := DateValueTo;
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

    local procedure InsertGSTRates(TaxTypeCode: Code[20]; HSNSAC: Text[250]; GSTGroupCode: Text[250]; FromState: Text[250]; LocationStateCode: Text[250]; DateFrom: Text[250]; DateTo: Text[250]; SGST: Text[250]; CGST: Text[250]; IGST: Text[250]; KFC: Text[250]; POSOutOfIndia: Text[250]; POSasVendorState: Text[250])
    var
        SGSTValue: Decimal;
        CGSTValue: Decimal;
        IGSTValue: Decimal;
        KFCValue: Decimal;
        ToDate: Date;
        FromDate: Date;
    begin
        Evaluate(SGSTValue, SGST);
        Evaluate(CGSTValue, CGST);
        Evaluate(IGSTValue, IGST);
        Evaluate(KFCValue, KFC);
        Evaluate(FromDate, DateFrom, 9);
        Evaluate(ToDate, DateTo, 9);

        CreateConfigID(TaxTypeCode);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'GST Group Code'), "Column Type"::"Tax Attributes", GSTGroupCode, 0D, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'HSN/SAC'), "Column Type"::"Tax Attributes", HSNSAC, 0D, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'From State'), "Column Type"::Value, FromState, 0D, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Location State Code'), "Column Type"::Value, LocationStateCode, 0D, 0D, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'Date'), "Column Type"::"Range From and Range To", DateFrom, FromDate, ToDate, 0);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'SGST'), "Column Type"::Component, SGST, 0D, 0D, SGSTValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'CGST'), "Column Type"::Component, CGST, 0D, 0D, CGSTValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'IGST'), "Column Type"::Component, IGST, 0D, 0D, IGSTValue);
        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'KFloodCess'), "Column Type"::Component, KFC, 0D, 0D, KFCValue);

        if POSOutOfIndia = 'false' then
            POSOutOfIndia := 'No'
        else
            POSOutOfIndia := 'Yes';

        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'POS Out Of India'), "Column Type"::"Tax Attributes", POSOutOfIndia, 0D, 0D, 0);

        if POSasVendorState = 'false' then
            POSasVendorState := 'No'
        else
            POSasVendorState := 'Yes';

        InsertTaxRateValue(TaxTypeCode, TaxRate.ID, GetTaxColumnID(TaxTypeCode, 'POS as Vendor State'), "Column Type"::"Tax Attributes", POSasVendorState, 0D, 0D, 0);
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
