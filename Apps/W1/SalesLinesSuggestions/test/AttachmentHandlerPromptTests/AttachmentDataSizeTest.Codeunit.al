namespace Microsoft.Sales.Document.Test;

using Microsoft.Sales.Document.Attachment;
using System.Utilities;

codeunit 133517 "Attachment Data Size Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Sales with AI]:[Attachment]
    end;

    var
        Assert: Codeunit Assert;
        LibtraryUtility: Codeunit "Library - Utility";
        TestUtility: Codeunit "SLS Test Utility";
        IsInitialized: Boolean;

    [Test]
    procedure ThrowErrorIfFirstRowIsMoreThanMaxAllowedHeaderLength()
    var
        CsvHandler: Codeunit "CSV Handler";
        TempBlob: Codeunit "Temp Blob";
        Instream: InStream;
        OutStream: OutStream;
        InputData: Text;
        InvalidCsvDataErr: Label 'Cannot process input data. Either the data is not in a valid CSV format or data exceeds the maximum length supported.';
    begin
        // [FEATURE] [Sales Line From Attachment with AI] 
        // [SCENARIO] Error is thrown if the first row is more than the maximum allowed header length
        Initialize();

        // [GIVEN] Create input data that is more than the allowed header length of 10000
        InputData := LibtraryUtility.GenerateRandomAlphabeticText(10001, 1);
        TempBlob.CreateOutStream(OutStream);
        TempBlob.CreateInStream(Instream);
        OutStream.WriteText(InputData);

        // [WHEN] Process the input data
        asserterror CsvHandler.Process(Instream);

        // [THEN] Error is thrown
        Assert.ExpectedError(InvalidCsvDataErr);
    end;

    [Test]
    procedure ReadLinesOnlyReadsCompleteLinesInsideTheAllowedSize()
    var
        CsvHandler: Codeunit "CSV Handler";
        TempBlob: Codeunit "Temp Blob";
        Instream: InStream;
        OutStream: OutStream;
        InputData: Text;
        LoopIndex: Integer;
        ReadLines: Text;
    begin
        // [FEATURE] [Sales Line From Attachment with AI] 
        // [SCENARIO] Complete lines are read inside the allowed size
        Initialize();

        // [GIVEN] Create input data that is more than the allowed header length of 10000
        TempBlob.CreateOutStream(OutStream);
        TempBlob.CreateInStream(Instream);

        for LoopIndex := 1 to 7 do begin // 1500 * 7 = 10500 characters
            InputData := LibtraryUtility.GenerateRandomAlphabeticText(1499, 1); // 1499 characters + 1 carriage return
            OutStream.WriteText(InputData);
            OutStream.WriteText();
        end;

        // [WHEN] Process the input data
        ReadLines := CsvHandler.ReadLines(Instream, 10, 10000);

        // [THEN] Error is thrown
        Assert.AreEqual(9004, StrLen(ReadLines), ''); // (1499 * 6) + (5 * 2(\n))
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        TestUtility.RegisterCopilotCapability();

        IsInitialized := true;
    end;
}