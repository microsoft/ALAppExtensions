codeunit 148102 "Field Mapping Date Formula CZA"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Data Exchange Mapping Field Mapping Date Formula]
        isInitialized := false;
    end;

    var
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Field Mapping Date Formula CZA");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Field Mapping Date Formula CZA");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Field Mapping Date Formula CZA");
    end;

    [Test]
    procedure FieldMappingAppendValueOfFieldTextType()
    var
        DataExchFieldMapping: Record "Data Exch. Field Mapping";
        DataExchField: Record "Data Exch. Field";
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        Currency: Record Currency;
        "Integer": Record "Integer";
        ProcessDataExch: Codeunit "Process Data Exch.";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        DateFormula: DateFormula;
        ExpectedDate: Date;
        DatesErr: Label 'Dates must be equal.';
    begin
        // [SCENARIO] When in Function "Process Data Exch.".SetField value of field with type "Date" and if field "Date Formula CZA" is Set to value "1D" then the resulting date must plus one day
        Initialize();

        // [GIVEN] Currency and Currency Exchange Rate
        LibraryERM.CreateCurrency(Currency);
        LibraryERM.CreateExchangeRate(Currency.Code, Today, LibraryRandom.RandDec(100, 2), LibraryRandom.RandDec(100, 2));
        RecordRef.GetTable(CurrencyExchangeRate);

        // [GIVEN] DateFormula and calculate Expected Date
        evaluate(DateFormula, '<1D>');
        ExpectedDate := CalcDate(DateFormula, Today);

        // [GIVEN] "Data Exch. Field" for field "Starting Date" and Value of field "Date Formula CZA = "1D"
        CreateDataExchSetupAndFieldMappingWithOverwriteValue(DataExchFieldMapping, DataExchField, CurrencyExchangeRate.FieldNo("Starting Date"), DateFormula);

        // [WHEN] Invoke "Process Data Exch.".SetField
        ProcessDataExch.SetField(RecordRef, DataExchFieldMapping, DataExchField, Integer);
        FieldRef := RecordRef.Field(CurrencyExchangeRate.FieldNo("Starting Date"));

        // [THEN] ExpectedDate = Currency Exchange Starting Date       
        Assert.AreEqual(ExpectedDate, FieldRef.Value, DatesErr);
    end;

    local procedure CreateDataExchSetupAndFieldMappingWithOverwriteValue(var DataExchFieldMapping: Record "Data Exch. Field Mapping"; var DataExchField: Record "Data Exch. Field"; FieldNo: Integer; VarDateFormula: DateFormula)
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchMapping: Record "Data Exch. Mapping";
    begin
        CreateDataExchDef(DataExchDef, DataExchDef.Type::"Generic Import");
        CreateDataExchLineDef(DataExchDef, DataExchLineDef);
        CreateDataExchColumnDefWithColumnNo(DataExchColumnDef, DataExchLineDef, FieldNo);
        CreateDataExchMapping(DataExchMapping, DataExchLineDef, Database::"Currency Exchange Rate");
        CreateDataExchFieldMappingWithFieldID(DataExchFieldMapping, DataExchMapping, FieldNo, FieldNo);
        DataExchFieldMapping.Validate("Overwrite Value", true);
        DataExchFieldMapping.Validate("Date Formula CZA", VarDateFormula);
        DataExchFieldMapping.Modify(true);
        CreateDataExchField(DataExchField, DataExchLineDef, FieldNo);
        DataExchField.Value := format(Today, 0, '<Year4>-<Month,2>-<Day,2>');
        DataExchField.Modify();
        DataExchField.Get(DataExchField."Data Exch. No.", DataExchField."Line No.", DataExchField."Column No.", DataExchField."Node ID");
    end;

    local procedure CreateDataExchDef(var DataExchDef: Record "Data Exch. Def"; ParamaterType: Enum "Data Exchange Definition Type")
    begin
        DataExchDef.Init();
        DataExchDef.Code :=
          LibraryUtility.GenerateRandomCode(DataExchDef.FieldNo(Code), Database::"Data Exch. Def");
        DataExchDef.Validate(Type, ParamaterType);
        if ParamaterType <> DataExchDef.Type::"Payment Export" then
            DataExchDef."Ext. Data Handling Codeunit" := Codeunit::"Read Data Exch. from File";
        DataExchDef.Insert(true);
    end;

    local procedure CreateDataExchLineDef(var DataExchDef: Record "Data Exch. Def"; var DataExchLineDef: Record "Data Exch. Line Def")
    begin
        DataExchLineDef.Init();
        DataExchLineDef."Data Exch. Def Code" := DataExchDef.Code;
        DataExchLineDef.Code :=
          LibraryUtility.GenerateRandomCode(DataExchLineDef.FieldNo(Code), Database::"Data Exch. Line Def");
        DataExchLineDef.Insert();
    end;

    local procedure CreateDataExchColumnDefWithColumnNo(var DataExchColumnDef: Record "Data Exch. Column Def"; DataExchLineDef: Record "Data Exch. Line Def"; ColumnNo: Integer)
    begin
        DataExchColumnDef.Init();
        DataExchColumnDef."Data Exch. Def Code" := DataExchLineDef."Data Exch. Def Code";
        DataExchColumnDef."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchColumnDef."Column No." := ColumnNo;
        DataExchColumnDef.Insert();
    end;

    local procedure CreateDataExchMapping(var DataExchMapping: Record "Data Exch. Mapping"; DataExchLineDef: Record "Data Exch. Line Def"; TableID: Integer)
    begin
        DataExchMapping.Init();
        DataExchMapping."Data Exch. Def Code" := DataExchLineDef."Data Exch. Def Code";
        DataExchMapping."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchMapping."Table ID" := TableID;
        DataExchMapping.Insert();
    end;

    local procedure CreateDataExchFieldMappingWithFieldID(var DataExchFieldMapping: Record "Data Exch. Field Mapping"; DataExchMapping: Record "Data Exch. Mapping"; ColumnNo: Integer; FieldID: Integer)
    begin
        DataExchFieldMapping.Init();
        DataExchFieldMapping."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExchFieldMapping."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExchFieldMapping."Table ID" := DataExchMapping."Table ID";
        DataExchFieldMapping."Column No." := ColumnNo;
        DataExchFieldMapping."Field ID" := FieldID;
        DataExchFieldMapping.Insert();
    end;

    local procedure CreateDataExchField(var DataExchField: Record "Data Exch. Field"; DataExchLineDef: Record "Data Exch. Line Def"; ColumnNo: Integer)
    begin
        DataExchField.Init();
        DataExchField."Data Exch. No." := LibraryRandom.RandIntInRange(1, 10);
        DataExchField."Line No." := LibraryRandom.RandIntInRange(1, 10);
        DataExchField."Data Exch. Line Def Code" := DataExchLineDef.Code;
        DataExchField."Data Exch. Def Code" := DataExchLineDef."Data Exch. Def Code";
        DataExchField."Node ID" := LibraryUtility.GenerateGUID();
        DataExchField."Column No." := ColumnNo;
        DataExchField.Insert(true);
    end;
}