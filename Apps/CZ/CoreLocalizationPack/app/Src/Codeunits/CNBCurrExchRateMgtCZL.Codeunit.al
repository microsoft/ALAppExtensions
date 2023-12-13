// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Currency;

using Microsoft.Finance.GeneralLedger.Setup;
using System.IO;

codeunit 11762 "CNB Curr. Exch. Rate Mgt. CZL"
{
    var
        DummyDataExchColumnDef: Record "Data Exch. Column Def";
        DummyCurrencyExchangeRate: Record "Currency Exchange Rate";
        CNB_EXCH_RATESTxt: Label 'CNB-EXCHANGE-RATES', Comment = 'Czech National Bank Currency Exchange Rate Code', Locked = true;
        CNB_EXCH_RATESDescTxt: Label 'Czech National Bank Currency Exchange Rates Setup';
        CNB_URLTok: Label 'http://www.cnb.cz/cs/financni_trhy/devizovy_trh/kurzy_devizoveho_trhu/denni_kurz.xml', Locked = true;
        CNBServiceProviderTxt: Label 'Czech National Bank';

    [EventSubscriber(ObjectType::Table, Database::"Curr. Exch. Rate Update Setup", 'OnBeforeSetupCurrencyExchRateService', '', false, false)]
    local procedure SetupCurrencyExchangeRateServiceOnBeforeSetupCurrencyExchRateService(var CurrExchRateUpdateSetup: Record "Curr. Exch. Rate Update Setup")
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        CzechLocalCurrencyTok: Label 'CZK', Locked = true;
    begin
        if Currency.IsEmpty() then
            exit;
        if not CurrExchRateUpdateSetup.IsEmpty() then
            exit;
        if not CurrExchRateUpdateSetup.WritePermission() then
            exit;
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."LCY Code" = CzechLocalCurrencyTok then
            SetupCNBDataExchange(GetCNB_URI());
        Commit();
    end;

    procedure SetupCNBDataExchange(PathToCNBService: Text)
    var
        CurrExchRateUpdateSetup: Record "Curr. Exch. Rate Update Setup";
        DataExchLineDef: Record "Data Exch. Line Def";
        SuggestColDefinitionXML: Codeunit "Suggest Col. Definition - XML";
    begin
        if CurrExchRateUpdateSetup.Get(CNB_EXCH_RATESTxt) then
            exit;

        DataExchLineDef.SetRange("Data Exch. Def Code", CNB_EXCH_RATESTxt);
        if DataExchLineDef.FindFirst() then;

        CreateCurrencyExchangeSetup(
          CurrExchRateUpdateSetup, CNB_EXCH_RATESTxt, CNB_EXCH_RATESDescTxt,
          DataExchLineDef."Data Exch. Def Code", CNBServiceProviderTxt, '');

        if StrPos(PathToCNBService, 'http') = 1 then
            CurrExchRateUpdateSetup.SetWebServiceURL(PathToCNBService);

        if DataExchLineDef."Data Exch. Def Code" = '' then begin
            CreateExchLineDef(DataExchLineDef, CurrExchRateUpdateSetup."Data Exch. Def Code", GetCNBRepeaterPath());
            SuggestColDefinitionXML.GenerateDataExchColDef(PathToCNBService, DataExchLineDef);
            MapCNBDataExch(DataExchLineDef);
        end;
        Commit();
    end;

    local procedure CreateCurrencyExchangeSetup(var CurrExchRateUpdateSetup: Record "Curr. Exch. Rate Update Setup"; NewCode: Code[20]; NewDesc: Text[250]; NewDataExchCode: Code[20]; NewServiceProvider: Text[30]; NewTermOfUse: Text[250])
    begin
        CurrExchRateUpdateSetup.Init();
        CurrExchRateUpdateSetup.Validate("Data Exch. Def Code", NewDataExchCode);
        CurrExchRateUpdateSetup.Validate(Code, NewCode);
        CurrExchRateUpdateSetup.Validate(Description, NewDesc);
        CurrExchRateUpdateSetup.Validate("Service Provider", NewServiceProvider);
        CurrExchRateUpdateSetup.Validate("Terms of Service", NewTermOfUse);
        CurrExchRateUpdateSetup.Insert(true);
    end;

    local procedure CreateExchLineDef(var DataExchLineDef: Record "Data Exch. Line Def"; DataExchDefCode: Code[20]; RepeaterPath: Text[250])
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDefCode);
        DataExchLineDef.FindFirst();
        DataExchLineDef.Validate("Data Line Tag", RepeaterPath);
        DataExchLineDef.Modify(true);
    end;

    local procedure MapCNBDataExch(var DataExchLineDef: Record "Data Exch. Line Def")
    var
        DataExchMapping: Record "Data Exch. Mapping";
        TransformationRuleMgtCZL: Codeunit "Transformation Rule Mgt. CZL";
    begin
        DataExchMapping.Get(DataExchLineDef."Data Exch. Def Code", DataExchLineDef.Code, Database::"Currency Exchange Rate");

        CreateExchMappingLine(
          DataExchMapping, GetCNBCurrencyCodeXMLElement(), GetCurrencyCodeFieldNo(),
          DummyDataExchColumnDef."Data Type"::Text, 1, '', '', '');
        CreateExchMappingLine(
          DataExchMapping, GetCNBStartingDateXMLElement(), GetStartingDateFieldNo(),
          DummyDataExchColumnDef."Data Type"::Date, 1, '', TransformationRuleMgtCZL.GetCZDateFormatCode(), '');
        CreateExchMappingLine(
          DataExchMapping, GetCNBExchRateXMLElement(), GetExchRateAmtFieldNo(),
          DummyDataExchColumnDef."Data Type"::Decimal, 1, '', '', '');
        CreateExchMappingLine(
          DataExchMapping, GetCNBRelationalExchRateXMLElement(), GetRelationalExchRateFieldNo(),
          DummyDataExchColumnDef."Data Type"::Decimal, 1, '', TransformationRuleMgtCZL.GetCzechDecimalFormatCode(), '');
    end;

    local procedure CreateExchMappingLine(DataExchMapping: Record "Data Exch. Mapping"; FromColumnName: Text[250]; ToFieldNo: Integer; DataType: Option; NewMultiplier: Decimal; NewDataFormat: Text[10]; NewTransformationRule: Code[20]; NewDefaultValue: Text[250])
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchColumnDef: Record "Data Exch. Column Def";
    begin
        DataExchColumnDef.SetRange(DataExchColumnDef."Data Exch. Def Code", DataExchMapping."Data Exch. Def Code");
        DataExchColumnDef.SetRange(DataExchColumnDef."Data Exch. Line Def Code", DataExchMapping."Data Exch. Line Def Code");
        if NewDefaultValue <> '' then begin
            if DataExchColumnDef.FindLast() then begin
                DataExchColumnDef.Init();
                DataExchColumnDef."Column No." += 10000;
                DataExchColumnDef.Insert();
            end
        end else begin
            DataExchColumnDef.SetRange(DataExchColumnDef.Name, FromColumnName);
            DataExchColumnDef.FindFirst();
        end;
        DataExchColumnDef.Validate(DataExchColumnDef."Data Type", DataType);
        DataExchColumnDef.Validate(DataExchColumnDef."Data Format", NewDataFormat);
        DataExchColumnDef.Modify(true);

        DataExchFieldMapping.Init();
        DataExchFieldMapping.Validate(DataExchFieldMapping."Data Exch. Def Code", DataExchMapping."Data Exch. Def Code");
        DataExchFieldMapping.Validate(DataExchFieldMapping."Data Exch. Line Def Code", DataExchMapping."Data Exch. Line Def Code");
        DataExchFieldMapping.Validate(DataExchFieldMapping."Table ID", DataExchMapping."Table ID");
        DataExchFieldMapping.Validate(DataExchFieldMapping."Column No.", DataExchColumnDef."Column No.");
        DataExchFieldMapping.Validate(DataExchFieldMapping."Field ID", ToFieldNo);
        DataExchFieldMapping.Validate(DataExchFieldMapping.Multiplier, NewMultiplier);
        DataExchFieldMapping.Validate(DataExchFieldMapping."Transformation Rule", NewTransformationRule);
        DataExchFieldMapping.Validate(DataExchFieldMapping."Default Value", NewDefaultValue);
        DataExchFieldMapping.Insert(true);
    end;

    local procedure GetCNBRepeaterPath(): Text[250]
    var
        RateTableLineTok: Label '/kurzy/tabulka/radek', Locked = true;
    begin
        exit(RateTableLineTok);
    end;

    local procedure GetCNBCurrencyCodeXMLElement(): Text[250]
    var
        CodeTok: Label 'kod', Locked = true;
    begin
        exit(CodeTok);
    end;

    local procedure GetCNBExchRateXMLElement(): Text[250]
    var
        RateTok: Label 'mnozstvi', Locked = true;
    begin
        exit(RateTok);
    end;

    local procedure GetCNBStartingDateXMLElement(): Text[250]
    var
        DateTok: Label 'datum', Locked = true;
    begin
        exit(DateTok);
    end;

    local procedure GetCNBRelationalExchRateXMLElement(): Text[250]
    var
        RelationalExchRateTok: Label 'kurz', Locked = true;
    begin
        exit(RelationalExchRateTok);
    end;

    local procedure GetCurrencyCodeFieldNo(): Integer
    begin
        exit(DummyCurrencyExchangeRate.FieldNo("Currency Code"));
    end;

    local procedure GetRelationalExchRateFieldNo(): Integer
    begin
        exit(DummyCurrencyExchangeRate.FieldNo("Relational Exch. Rate Amount"));
    end;

    local procedure GetExchRateAmtFieldNo(): Integer
    begin
        exit(DummyCurrencyExchangeRate.FieldNo("Exchange Rate Amount"));
    end;

    local procedure GetStartingDateFieldNo(): Integer
    begin
        exit(DummyCurrencyExchangeRate.FieldNo("Starting Date"));
    end;

    procedure GetCNB_URI(): Text
    begin
        exit(CNB_URLTok);
    end;
}
