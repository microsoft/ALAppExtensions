// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.UOM;
using System.Reflection;
using Microsoft.Test.Sustainability;

codeunit 139795 "Library Sustainability Copilot"
{
    var
        LibrarySustainability: Codeunit "Library - Sustainability";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IncorrectFormulaErr: Label 'Value %1 is not in the list of expected values: %2', Comment = '%1 = actual value, %2 = expected values';

    procedure CreateTestData()
    begin
        InitKilometerUnitOfMeasure();
        InitMileUnitOfMeasure();
        InitLiterUnitOfMeasure();
        InitFlightUnitOfMeasure();
        InitNighttUnitOfMeasure();
        InitKilowattPerHourUnitOfMeasure();
        InitTonUnitOfMeasure();
        InitPercentageUnitOfMeasure();
        CreateDistanceAccount('9900');
        CreateFuelElectricityAccount('9901');
        CreateHotelAccount('9902');
        CreateInstallationsAccount('9903');
        CreateAirflightAccount('9904');
        CreateWasteTonneAccount('9905');
    end;

    procedure GetUserInputFromJson(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; JsonContent: JsonObject)
    var
        SustainabilityJournalLine: Record "Sustainability Jnl. Line";
        DataTypeManagement: Codeunit "Data Type Management";
        SustEmissionSuggestion: Codeunit "Sust. Emission Suggestion";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        JsonToken: JsonToken;
        JsonKey, FieldName : text;
    begin
        RecRef.GetTable(SustainabilityJournalLine);
        foreach JsonKey in JsonContent.Keys() do begin
            JsonContent.Get(JsonKey, JsonToken);
            FieldName := JsonKey.Replace('_', ' ');
            Assert.IsTrue(DataTypeManagement.FindFieldByName(RecRef, FieldRef, FieldName), 'Cannot find by name form the Yaml file');
            FieldRef.Validate(JsonToken.AsValue().AsText());
        end;
        RecRef.Insert();
        RecRef.SetTable(SustainabilityJournalLine);
        SustainabilityJournalLine.SetRecFilter();
        SustEmissionSuggestion.BuildFromLines(SustainEmissionSuggestion, SustainabilityJournalLine);
        SustainabilityJournalLine.Delete(true);
    end;

    procedure VerifyFormulaJson(var SustainEmissionSuggestion: Record "Sustain. Emission Suggestion"; ExpectedResultsJObject: JsonObject)
    var
        ExpectedExpressionJToken, ActualExpressionJToken, ExpectedExpresionsToken, ActualExpressionsToken, ExpectedValueToken, ExpectedOptionToken, ActualValueToken, LinesToken : JsonToken;
        FormulaInStream: InStream;
        ListOfExpectedValues: List of [Text];
        ExpressionId: Integer;
        JsonKey, ExpectedValuesString : Text;
    begin
        SustainEmissionSuggestion.CalcFields("Emission Formula Json");
        Assert.IsTrue(SustainEmissionSuggestion."Emission Formula Json".HasValue(), 'Emission Formula Json is empty');
        SustainEmissionSuggestion."Emission Formula Json".CreateInStream(FormulaInStream);
        LinesToken.ReadFrom(FormulaInStream);
        Assert.IsTrue(LinesToken.AsObject().Get('expressions', ActualExpressionsToken), 'Cannot find expressions in formula');

        ExpectedResultsJObject.Get('expressions', ExpectedExpresionsToken);
        Assert.AreEqual(ExpectedExpresionsToken.AsArray().Count(), ActualExpressionsToken.AsArray().Count(), 'Number of expressions in formula text is not as expected');
        ExpressionId := 0;
        foreach ExpectedExpressionJToken in ExpectedExpresionsToken.AsArray() do begin
            ActualExpressionsToken.AsArray().Get(ExpressionId, ActualExpressionJToken);
            foreach JsonKey in ExpectedExpressionJToken.AsObject().Keys do begin
                ExpectedExpressionJToken.AsObject().Get(JsonKey, ExpectedValueToken);
                assert.IsTrue(ActualExpressionJToken.AsObject().Get(JsonKey, ActualValueToken), 'Cannot find ' + JsonKey + ' in formula text');
                Clear(ListOfExpectedValues);
                ExpectedValuesString := '';
                if JsonKey in ['left_operand_name', 'right_operand_name'] then
                    foreach ExpectedOptionToken in ExpectedValueToken.AsArray() do begin
                        ListOfExpectedValues.Add(ExpectedOptionToken.AsValue().AsText().ToUpper());
                        if ExpectedValuesString <> '' then
                            ExpectedValuesString += ', ';
                        ExpectedValuesString += ExpectedOptionToken.AsValue().AsText().ToUpper();
                    end
                else begin
                    ListOfExpectedValues.Add(ExpectedValueToken.AsValue().AsText().ToUpper());
                    ExpectedValuesString := ExpectedValueToken.AsValue().AsText().ToUpper();
                end;
                Assert.IsTrue(
                    ListOfExpectedValues.Contains(ActualValueToken.AsValue().AsText().ToUpper()),
                    StrSubstNo(IncorrectFormulaErr, JsonKey, ExpectedValuesString));
            end;
            ExpressionId += 1;
        end;
    end;

    local procedure CreateDistanceAccount(AccountCode: Code[20])
    begin
        CreateAccount(AccountCode, "Calculation Foundation"::Distance, '');
    end;

    local procedure CreateFuelElectricityAccount(AccountCode: Code[20])
    begin
        CreateAccount(AccountCode, "Calculation Foundation"::"Fuel/Electricity", '');
    end;

    local procedure CreateAirflightAccount(AccountCode: Code[20])
    begin
        CreateAccount(AccountCode, "Calculation Foundation"::Custom, "Emission Scope"::"Scope 3", 'FLIGHT');
    end;

    local procedure CreateHotelAccount(AccountCode: Code[20])
    begin
        CreateAccount(AccountCode, "Calculation Foundation"::Custom, "Emission Scope"::"Scope 3", 'NIGHT');
    end;

    local procedure CreateWasteTonneAccount(AccountCode: Code[20])
    begin
        CreateAccount(AccountCode, "Calculation Foundation"::Custom, "Emission Scope"::"Scope 3", 'WASTE TON');
    end;

    local procedure CreateInstallationsAccount(AccountCode: Code[20])
    begin
        CreateAccount(AccountCode, "Calculation Foundation"::Installations, '');
    end;

    local procedure CreateAccount(AccountCode: Code[20]; CalculationFoundation: Enum "Calculation Foundation"; CustomValue: Text[100])
    begin
        CreateAccount(AccountCode, CalculationFoundation, "Emission Scope"::"Scope 1", CustomValue);
    end;

    local procedure CreateAccount(AccountCode: Code[20]; CalculationFoundation: Enum "Calculation Foundation"; EmissionScope: Enum "Emission Scope"; CustomValue: Text[100])
    var
        SustainAccountCategory: Record "Sustain. Account Category";
        SustainAccountSubcategory: Record "Sustain. Account Subcategory";
        SustainabilityAccount: Record "Sustainability Account";
        SustainabilityJnlLine: Record "Sustainability Jnl. Line";
    begin
        if SustainabilityAccount.Get(AccountCode) then
            SustainabilityAccount.Delete();
        SustainabilityJnlLine.SetRange("Account No.", SustainabilityAccount."No.");
        SustainabilityJnlLine.DeleteAll();
        SustainAccountCategory :=
            LibrarySustainability.InsertAccountCategory(
                LibraryUtility.GenerateGUID(), '', EmissionScope, CalculationFoundation, true, false, false, CustomValue, false);
        SustainAccountSubcategory :=
            LibrarySustainability.InsertAccountSubcategory(SustainAccountCategory.Code, LibraryUtility.GenerateGUID(), '', 0, 0, 0, false);
        SustainabilityAccount :=
            LibrarySustainability.InsertSustainabilityAccount(
                AccountCode, '', SustainAccountCategory.Code, SustainAccountSubcategory.Code, "Sustainability Account Type"::Posting, '', true);
    end;

    local procedure InitKilometerUnitOfMeasure()
    begin
        InitUnitOfMeasure('KM', 'Kilometer');
    end;

    local procedure InitMileUnitOfMeasure()
    begin
        InitUnitOfMeasure('M', 'Mile');
    end;

    local procedure InitLiterUnitOfMeasure()
    begin
        InitUnitOfMeasure('L', 'Liter');
    end;

    local procedure InitKilowattPerHourUnitOfMeasure()
    begin
        InitUnitOfMeasure('KWH', 'Kilowatt per hour');
    end;

    local procedure InitTonUnitOfMeasure()
    begin
        InitUnitOfMeasure('T', 'Tonne');
    end;

    local procedure InitFlightUnitOfMeasure()
    begin
        InitUnitOfMeasure('FLIGHT', 'Flight');
    end;

    local procedure InitNighttUnitOfMeasure()
    begin
        InitUnitOfMeasure('NIGHT', 'Night');
    end;

    local procedure InitPercentageUnitOfMeasure()
    begin
        InitUnitOfMeasure('%', 'Percentage');
    end;

    local procedure InitUnitOfMeasure(UnitOfMeasureCode: Code[10]; UnitOfMeasureDescription: Text[50])
    var
        UnitOfMeasure: Record "Unit of Measure";
        UOMCode: Code[10];
    begin
        UOMCode := UnitOfMeasureCode;
        UnitOfMeasure.SetRange(Code, UOMCode);
        UnitOfMeasure.DeleteAll(true);
        UnitOfMeasure.Code := UOMCode;
        UnitOfMeasure.Description := UnitOfMeasureDescription;
        UnitOfMeasure.Insert();
    end;
}
