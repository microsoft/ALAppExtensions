// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This module provides functions for easy verification of expected values and error handling in test code.
/// </summary>
codeunit 130002 "Library Assert"
{

    trigger OnRun()
    begin
    end;

    var
        IsTrueFailedErr: Label 'Assert.IsTrue failed. %1';
        IsFalseFailedErr: Label 'Assert.IsFalse failed. %1';
        AreEqualFailedErr: Label 'Assert.AreEqual failed. Expected:<%1> (%2). Actual:<%3> (%4). %5.', Locked = true;
        AreNotEqualFailedErr: Label 'Assert.AreNotEqual failed. Expected any value except:<%1> (%2). Actual:<%3> (%4). %5.', Locked = true;
        AreNearlyEqualFailedErr: Label 'Assert.AreNearlyEqual failed. Expected a difference no greater than <%1> between expected value <%2> and actual value <%3>. %4';
        AreNotNearlyEqualFailedErr: Label 'Assert.AreNotNearlyEqual failed. Expected a difference greater than <%1> between expected value <%2> and actual value <%3>. %4';
        FailFailedErr: Label 'Assert.Fail failed. %1';
        TableIsEmptyErr: Label 'Assert.TableIsEmpty failed. Table <%1> with filter <%2> must not contain records.', Locked = true;
        TableIsNotEmptyErr: Label 'Assert.TableIsNotEmpty failed. Table <%1> with filter <%2> must contain records.', Locked = true;
        KnownFailureErr: Label 'Known failure: see VSTF Bug #%1.';
        ExpectedErrorFailedErr: Label 'Assert.ExpectedError failed. Expected: %1. Actual: %2.';
        ExpectedErrorCodeFailedErr: Label 'Assert.ExpectedErrorCode failed. Expected: %1. Actual: %2. Actual error message: %3.';
        ExpectedMessageFailedErr: Label 'Assert.ExpectedMessage failed. Expected: %1. Actual: %2.';
        RecordCountErr: Label 'Assert.RecordCount failed. Expected number of %1 entries: %2. Actual: %3.', Locked = true;
        UnsupportedTypeErr: Label 'Equality assertions only support Boolean, Option, Integer, BigInteger, Decimal, Code, Text, Date, DateFormula, Time, Duration, and DateTime values. Current value:%1.';
        RecordNotFoundTok: Label 'DB:RecordNotFound';
        RecordAlreadyExistsTok: Label 'DB:RecordExists';
        RecordNothingInsideFilterTok: Label 'DB:NothingInsideFilter';
        AssertErr: Label 'Expected error %1 actual %2';
        PrimRecordNotFoundTok: Label 'DB:PrimRecordNotFound';
        NoFilterTok: Label 'DB:NoFilter';
        ErrorHasNotBeenThrownErr: Label 'The error has not been thrown.';

    /// <summary>
    /// Tests whether the specified condition is true and throws an exception if the condition is false.
    /// </summary>
    /// <param name="Condition">The condition the test expects to be true.</param>
    /// <param name="Msg">The message to include in the exception when condition is false. The message is shown in test results.</param>
    procedure IsTrue(Condition: Boolean; Msg: Text)
    begin
        if not Condition then
            Error(IsTrueFailedErr, Msg)
    end;

    /// <summary>
    /// Tests whether the specified condition is false and throws an exception if the condition is true.
    /// </summary>
    /// <param name="Condition">The condition the test expects to be false.</param>
    /// <param name="Msg">The message to include in the exception when condition is true. The message is shown in test results.</param>
    procedure IsFalse(Condition: Boolean; Msg: Text)
    begin
        if Condition then
            Error(IsFalseFailedErr, Msg)
    end;

    /// <summary>
    /// Tests whether the specified values are equal and throws an exception if the two values are not equal.
    /// </summary>
    /// <param name="Expected">The first value to compare. This is the value the tests expects.</param>
    /// <param name="Actual">The second value to compare. This is the value produced by the code under test.</param>
    /// <param name="Msg">The message to include in the exception when actual is not equal to expected. The message is shown in test results.</param>
    procedure AreEqual(Expected: Variant; Actual: Variant; Msg: Text)
    begin
        if not Equal(Expected, Actual) then
            Error(AreEqualFailedErr, Expected, TypeNameOf(Expected), Actual, TypeNameOf(Actual), Msg)
    end;

    /// <summary>
    /// Tests whether the specified DateTime values are equal and throws an exception if the two DateTime values are not equal.
    /// This function uses the high precision format type 1
    /// </summary>
    /// <param name="Expected">The first DateTime value to compare. This is the DateTime value the tests expects.</param>
    /// <param name="Actual">The second DateTime value to compare. This is the DateTime value produced by the code under test.</param>
    /// <param name="Msg">The message to include in the exception when actual is not equal to expected. The message is shown in test results.</param>
    procedure AreEqualDateTime(Expected: DateTime; Actual: DateTime; Msg: Text)
    begin
        if (Format(Expected, 0, 1) <> Format(Actual, 0, 1)) then // need format 1 to include decimal time precision on datetime
            Error(AreEqualFailedErr, Format(Expected, 0, 1), TypeNameOf(Expected), Format(Actual, 0, 1), TypeNameOf(Actual), Msg)
    end;

    /// <summary>
    /// Tests whether the specified values are unequal and throws an exception if they are equal.
    /// </summary>
    /// <param name="Expected">The first value to compare. This is the value the test expects not to match actual.</param>
    /// <param name="Actual">The second value to compare. This is the value produced by the code under test.</param>
    /// <param name="Msg">The message to include in the exception when actual is not equal to expected. The message is shown in test results.</param>
    procedure AreNotEqual(Expected: Variant; Actual: Variant; Msg: Text)
    begin
        if Equal(Expected, Actual) then
            Error(AreNotEqualFailedErr, Expected, TypeNameOf(Expected), Actual, TypeNameOf(Actual), Msg)
    end;

    /// <summary>
    /// Tests whether the specified decimals are equal and throws an exception if the they are not equal.
    /// </summary>
    /// <param name="Expected">The first value to compare. This is the value the tests expects.</param>
    /// <param name="Actual">The second value to compare. This is the value produced by the code under test.</param>
    /// <param name="Delta">The required accuracy. An exception will be thrown only if actual is different than expected by more than delta.</param>
    /// <param name="Msg">The message to include in the exception when actual is different than expected by more than delta. The message is shown in test results.</param>
    procedure AreNearlyEqual(Expected: Decimal; Actual: Decimal; Delta: Decimal; Msg: Text)
    begin
        if Abs(Expected - Actual) > Abs(Delta) then
            Error(AreNearlyEqualFailedErr, Delta, Expected, Actual, Msg)
    end;

    /// <summary>
    /// Tests whether the specified decimals are unequal and throws an exception if the they are equal.
    /// </summary>
    /// <param name="Expected">The first value to compare. This is the value the tests expects not to match actual.</param>
    /// <param name="Actual">The second value to compare. This is the value produced by the code under test.</param>
    /// <param name="Delta">The required accuracy. An exception will be thrown only if actual is different than Expected by at most delta.</param>
    /// <param name="Msg">The message to include in the exception when actual is equal to Expected or different by less than delta. The message is shown in test results.</param>
    procedure AreNotNearlyEqual(Expected: Decimal; Actual: Decimal; Delta: Decimal; Msg: Text)
    begin
        if Abs(Expected - Actual) <= Abs(Delta) then
            Error(AreNotNearlyEqualFailedErr, Delta, Expected, Actual, Msg)
    end;

    /// <summary>
    /// Throws an exception.
    /// </summary>
    /// <param name="Msg">The message to include in the exception. The message is shown in test results.</param>
    procedure Fail(Msg: Text)
    begin
        Error(FailFailedErr, Msg)
    end;

    /// <summary>
    /// Tests whether the specified record is non-empty and throws an exception if it is.
    /// </summary>
    /// <param name="RecVariant">The record to be checked</param>
    procedure RecordIsEmpty(RecVariant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVariant);
        RecRefIsEmpty(RecRef);
    end;

    /// <summary>
    /// Tests whether the specified record is empty and throws an exception if it is.
    /// </summary>
    /// <param name="RecVariant">The record to be checked</param>
    procedure RecordIsNotEmpty(RecVariant: Variant)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVariant);
        RecRefIsNotEmpty(RecRef);
    end;

    /// <summary>
    /// Tests whether the specified table is non-empty and throws an exception if it is.
    /// </summary>
    /// <param name="TableNo">The id of table the test expects to be empty</param>
    procedure TableIsEmpty(TableNo: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableNo);
        RecRefIsEmpty(RecRef);
        RecRef.Close();
    end;

    /// <summary>
    /// Tests whether the specified table is empty and throws an exception if it is.
    /// </summary>
    /// <param name="TableNo">The id of table the test expects not to be empty</param>
    procedure TableIsNotEmpty(TableNo: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.Open(TableNo);
        RecRefIsNotEmpty(RecRef);
        RecRef.Close();
    end;

    local procedure RecRefIsEmpty(var RecRef: RecordRef)
    begin
        if not RecRef.IsEmpty() then
            Error(TableIsEmptyErr, RecRef.Caption(), RecRef.GetFilters());
    end;

    local procedure RecRefIsNotEmpty(var RecRef: RecordRef)
    begin
        if RecRef.IsEmpty() then
            Error(TableIsNotEmptyErr, RecRef.Caption(), RecRef.GetFilters());
    end;

    /// <summary>
    /// Tests whether the Table holds the expected number of Records and throws an exception when the count is different.
    /// </summary>
    /// <param name="RecVariant">The table whos records will be counter</param>
    /// <param name="ExpectedCount">The expected number of records in the table</param>
    procedure RecordCount(RecVariant: Variant; ExpectedCount: Integer)
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(RecVariant);
        if ExpectedCount <> RecRef.Count() then
            Error(RecordCountErr, RecRef.Caption(), ExpectedCount, RecRef.Count());
        RecRef.Close();
    end;

    /// <summary>
    /// This function is used to indicate the test is known to fail with a certain error. If the last error thrown is the expected one, a known failure error is thrown. If the last error was a different error than an exception is thrown.
    /// </summary>
    /// <param name="Expected">The expected error</param>
    /// <param name="WorkItemNo">The Id of the workitem to fix the know test defect</param>
    procedure KnownFailure(Expected: Text; WorkItemNo: Integer)
    begin
        ExpectedError(Expected);
        Error(KnownFailureErr, WorkItemNo)
    end;

    /// <summary>
    /// Verifies that the last error thrown is the expected error. If a different error was thrown, an exception is thrown.
    /// </summary>
    /// <param name="Expected">The expected error</param>
    procedure ExpectedError(Expected: Text)
    begin
        if (GetLastErrorText() = '') and (Expected = '') then begin
            if GetLastErrorCallstack() = '' then
                Error(ErrorHasNotBeenThrownErr);
        end else
            if StrPos(GetLastErrorText(), Expected) = 0 then
                Error(ExpectedErrorFailedErr, Expected, GetLastErrorText());
    end;

    /// <summary>
    /// Verifies that the last error code thrown is the expected error code. If a different error code was thrown, an exception is thrown.
    /// </summary>
    /// <param name="Expected">The expected error code</param>
    procedure ExpectedErrorCode(Expected: Text)
    begin
        if StrPos(GetLastErrorCode(), Expected) = 0 then
            Error(ExpectedErrorCodeFailedErr, Expected, GetLastErrorCode(), GetLastErrorText());
    end;

    /// <summary>
    /// Tests that the Expected message matches the Actual message
    /// </summary>
    /// <param name="Expected">The first value to compare. This is the value the tests expects not to match actual.</param>
    /// <param name="Actual">The second value to compare. This is the value produced by the code under test.</param>
    procedure ExpectedMessage(Expected: Text; Actual: Text)
    begin
        if StrPos(Actual, Expected) = 0 then
            Error(ExpectedMessageFailedErr, Expected, Actual);
    end;

    /// <summary>
    /// Verifies that the last error code thrown was the Record Not Found error code.
    /// </summary>
    procedure AssertRecordNotFound()
    begin
        VerifyFailure(RecordNotFoundTok, StrSubstNo(AssertErr, RecordNotFoundTok, GetLastErrorCode()));
    end;

    /// <summary>
    /// Verifies that the last error code thrown was the Record Already Exists error code.
    /// </summary>
    procedure AssertRecordAlreadyExists()
    begin
        VerifyFailure(RecordAlreadyExistsTok, StrSubstNo(AssertErr, RecordAlreadyExistsTok, GetLastErrorCode()));
    end;

    /// <summary>
    /// Verifies that the last error code thrown was the Nothing Inside Filter error code.
    /// </summary>
    procedure AssertNothingInsideFilter()
    begin
        VerifyFailure(RecordNothingInsideFilterTok, StrSubstNo(AssertErr, RecordNothingInsideFilterTok, GetLastErrorCode()));
    end;

    /// <summary>
    /// Verifies that the last error code thrown was the No Filter error code.
    /// </summary>
    procedure AssertNoFilter()
    begin
        VerifyFailure(NoFilterTok, StrSubstNo(AssertErr, NoFilterTok, GetLastErrorCode()));
    end;

    /// <summary>
    /// Verifies that the last error code thrown was the Primary Record Not Found error code.
    /// </summary>
    procedure AssertPrimRecordNotFound()
    begin
        VerifyFailure(PrimRecordNotFoundTok, StrSubstNo(AssertErr, PrimRecordNotFoundTok, GetLastErrorCode()));
    end;

    local procedure TypeOf(Value: Variant): Integer
    var
        "Field": Record "Field";
    begin
        case true of
            Value.IsBoolean():
                exit(Field.Type::Boolean);
            Value.IsOption() or Value.IsInteger() or Value.IsByte():
                exit(Field.Type::Integer);
            Value.IsBigInteger():
                exit(Field.Type::BigInteger);
            Value.IsDecimal():
                exit(Field.Type::Decimal);
            Value.IsText() or Value.IsCode() or Value.IsChar() or Value.IsTextConstant():
                exit(Field.Type::Text);
            Value.IsDate():
                exit(Field.Type::Date);
            Value.IsTime():
                exit(Field.Type::Time);
            Value.IsDuration():
                exit(Field.Type::Duration);
            Value.IsDateTime():
                exit(Field.Type::DateTime);
            Value.IsDateFormula():
                exit(Field.Type::DateFormula);
            Value.IsGuid():
                exit(Field.Type::GUID);
            Value.IsRecordId():
                exit(Field.Type::RecordID);
            else
                Error(UnsupportedTypeErr, UnsupportedTypeName(Value))
        end
    end;

    local procedure TypeNameOf(Value: Variant): Text
    var
        "Field": Record "Field";
    begin
        Field.Type := TypeOf(Value);
        exit(Format(Field.Type));
    end;

    local procedure UnsupportedTypeName(Value: Variant): Text
    begin
        case true of
            Value.IsRecord():
                exit('Record');
            Value.IsRecordRef():
                exit('RecordRef');
            Value.IsFieldRef():
                exit('FieldRef');
            Value.IsCodeunit():
                exit('Codeunit');
            Value.IsFile():
                exit('File');
        end;
        exit('Unsupported Type');
    end;

    local procedure Equal(Left: Variant; Right: Variant): Boolean
    begin
        if IsNumber(Left) and IsNumber(Right) then
            exit(EqualNumbers(Left, Right));

        exit((TypeOf(Left) = TypeOf(Right)) and (Format(Left, 0, 2) = Format(Right, 0, 2)))
    end;

    local procedure IsNumber(Value: Variant): Boolean
    begin
        exit(Value.IsDecimal() or Value.IsInteger() or Value.IsChar())
    end;

    local procedure EqualNumbers(Left: Decimal; Right: Decimal): Boolean
    begin
        exit(Left = Right)
    end;

    local procedure VerifyFailure(expectedErrorCode: Text; failureText: Text)
    var
        errorCode: Text;
    begin
        errorCode := GetLastErrorCode();

        IsTrue(errorCode = expectedErrorCode, failureText);
        ClearLastError();
    end;
}

