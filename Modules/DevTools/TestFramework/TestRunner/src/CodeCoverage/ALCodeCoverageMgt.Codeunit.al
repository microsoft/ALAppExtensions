// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.CodeCoverage;

using System.TestTools.TestRunner;
using System.Tooling;

codeunit 130470 "AL Code Coverage Mgt."
{
    SingleInstance = true;
    Access = Internal;

    var
        ALCodeCoverageSubscribers: Codeunit "AL Code Coverage Subscribers";
        IsRunning: Boolean;
        IsMultiSession: Boolean;
        CodeCoverageXMLPortId: Integer;


    procedure Start(MultiSession: Boolean)
    begin
        if IsRunning then
            Error('Already recording CC');

        System.CodeCoverageLog(true, MultiSession);
        IsRunning := true;
        IsMultiSession := MultiSession;
    end;

    procedure Refresh()
    begin
        System.CodeCoverageRefresh();
    end;

    procedure Stop()
    begin
        if not IsRunning then
            Error('Not recording CC');

        System.CodeCoverageLog(false, IsMultiSession);
        IsRunning := false;
    end;

    procedure Initialize(TestSuite: Code[10]): Boolean
    var
        ALTestSuite: Record "AL Test Suite";
    begin
        if not ALTestSuite.Get(TestSuite) then
            exit(false);

        if ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::Disabled then
            exit(false);

        ALCodeCoverageSubscribers.SetALTestSuite(ALTestSuite);
        SetCodeCoverageXMLPortId(ALTestSuite."CC Exporter ID");
        exit(true);
    end;

    procedure StopAndSave(TestCodeunitId: Integer; TestMethod: Text)
    begin
        System.CodeCoverageRefresh();
        Stop();
        SaveCoverageResults(TestCodeunitId, TestMethod);
    end;

    procedure CoverageFromInternals(CodeCoverage: Record "Code Coverage"): Boolean
    begin
        if CodeCoverage."Object Type" = CodeCoverage."Object Type"::Codeunit then
            if CodeCoverage."Object ID" in [
                Codeunit::"AL Code Coverage Mgt.",
                Codeunit::"AL Code Coverage Subscribers",
                Codeunit::"Test Runner - Mgt",
                Codeunit::"Test Runner - Isol. Codeunit",
                Codeunit::"Test Runner - Isol. Disabled",
                Codeunit::"Test Runner - Progress Dialog",
                Codeunit::"Test Suite Mgt."
            ] then
                exit(true);
        exit(false);
    end;

    local procedure SaveCoverageResults(TestCodeunitID: Integer; TestMethod: Text)
    var
        TestCodeCoverageResult: Record "Test Code Coverage Result";
        CodeCoverage: Record "Code Coverage";
        CSVOutStream: OutStream;
    begin
        if not TestCodeCoverageResult.Get(TestCodeunitID, TestMethod) then begin
            TestCodeCoverageResult."Test Codeunit ID" := TestCodeunitID;
            TestCodeCoverageResult."Test Method" := CopyStr(TestMethod, 1, 250);
            TestCodeCoverageResult.Insert();
        end;

        CodeCoverage.SetFilter("Code Coverage Status", '%1|%2', CodeCoverage."Code Coverage Status"::Covered, CodeCoverage."Code Coverage Status"::PartiallyCovered);
        TestCodeCoverageResult."CC Result".CreateOutStream(CSVOutStream, TextEncoding::UTF16);
        if CodeCoverageXMLPortId = 0 then
            CodeCoverageXMLPortId := GetDefaultCodeCoverageXmlPortId();

        XmlPort.Export(CodeCoverageXMLPortId, CSVOutStream, CodeCoverage);

        TestCodeCoverageResult.Modify();
    end;

    procedure SaveCodeCoverageMap(TestCodeunitID: Integer; TestMethod: Text; var ALTestSuite: Record "AL Test Suite")
    var
        CodeCoverage: Record "Code Coverage";
        ALCodeCoverageMap: Record "AL Code Coverage Map";
    begin
        if ALTestSuite."CC Coverage Map" = ALTestSuite."CC Coverage Map"::Disabled then
            exit;

        if ALTestSuite."CC Coverage Map" = ALTestSuite."CC Coverage Map"::"Per Codeunit" then
            TestMethod := '';

        CodeCoverage.SetRange("Line Type", CodeCoverage."Line Type"::"Trigger/Function");

        if not CodeCoverage.FindSet() then
            exit;

        repeat
            Clear(ALCodeCoverageMap);
            ALCodeCoverageMap."Test Codeunit ID" := TestCodeunitID;
            ALCodeCoverageMap."Test Method" := CopyStr(TestMethod, 1, MaxStrLen(ALCodeCoverageMap."Test Method"));
            ALCodeCoverageMap."Object ID" := CodeCoverage."Object ID";
            ALCodeCoverageMap."Object Type" := CodeCoverage."Object Type";
            ALCodeCoverageMap."Line No." := CodeCoverage."Line No.";
            if not ALCodeCoverageMap.Get(ALCodeCoverageMap.RecordId) then
                ALCodeCoverageMap.Insert();
        until CodeCoverage.Next() = 0;
    end;

    procedure ConsumeCoverageResult(var CSVResults: Text; var CCInfo: Text): Boolean
    var
        TestCodeCoverageResult: Record "Test Code Coverage Result";
        CSVInStream: InStream;
    begin
        TestCodeCoverageResult.SetAutoCalcFields("CC Result");
        if not TestCodeCoverageResult.FindFirst() then
            exit(false);

        TestCodeCoverageResult."CC Result".CreateInStream(CSVInStream, TextEncoding::UTF16);
        CSVInStream.Read(CSVResults);
        if TestCodeCoverageResult."Test Codeunit ID" = 0 then begin
            CCInfo := TestCodeCoverageResult."Test Method";
            TestCodeCoverageResult.Delete();
            exit(true);
        end;
        CCInfo := Format(TestCodeCoverageResult."Test Codeunit ID", 0, 9);
        if TestCodeCoverageResult."Test Method" <> '' then
            CCInfo += ',' + TestCodeCoverageResult."Test Method";
        TestCodeCoverageResult.Delete();
        exit(true);
    end;

    procedure GetCoveCoverageMap(var CSVCodeCoverageMap: Text): Boolean
    var
        ALCodeCoverageMap: Record "AL Code Coverage Map";
        TempDummyTestCodeCoverageResult: Record "Test Code Coverage Result" temporary;
        CCMapOutStream: OutStream;
        CCMapInstream: InStream;
    begin
        if ALCodeCoverageMap.IsEmpty() then
            exit(false);

        TempDummyTestCodeCoverageResult."CC Result".CreateOutStream(CCMapOutStream);
        Xmlport.Export(Xmlport::"AL Code Coverage Map", CCMapOutStream, ALCodeCoverageMap);
        TempDummyTestCodeCoverageResult.Insert();
        TempDummyTestCodeCoverageResult.CalcFields("CC Result");
        TempDummyTestCodeCoverageResult."CC Result".CreateInStream(CCMapInstream, TextEncoding::UTF16);

        CCMapInstream.Read(CSVCodeCoverageMap);
        ALCodeCoverageMap.DeleteAll();
        exit(true);
    end;

    procedure ObjectsCoverage(var CodeCoverage: Record "Code Coverage"; var NoCodeLines: Integer; var NoCodeLinesHit: Integer): Decimal
    var
        CodeCoverage2: Record "Code Coverage";
    begin
        NoCodeLines := 0;
        NoCodeLinesHit := 0;

        CodeCoverage2.CopyFilters(CodeCoverage);
        CodeCoverage2.SetFilter("Line Type", 'Code');
        repeat
            NoCodeLines += 1;
            if CodeCoverage2."No. of Hits" > 0 then
                NoCodeLinesHit += 1;
        until CodeCoverage2.Next() = 0;

        exit(CoveragePercent(NoCodeLines, NoCodeLinesHit))
    end;

    procedure ObjectCoverage(var CodeCoverage: Record "Code Coverage"; var NoCodeLines: Integer; var NoCodeLinesHit: Integer): Decimal
    var
        CodeCoverage2: Record "Code Coverage";
    begin
        NoCodeLines := 0;
        NoCodeLinesHit := 0;

        CodeCoverage2.SetPosition(CodeCoverage.GetPosition());
        CodeCoverage2.SetRange("Object Type", CodeCoverage."Object Type");
        CodeCoverage2.SetRange("Object ID", CodeCoverage."Object ID");

        repeat
            if CodeCoverage2."Line Type" = CodeCoverage2."Line Type"::Code then begin
                NoCodeLines += 1;
                if CodeCoverage2."No. of Hits" > 0 then
                    NoCodeLinesHit += 1;
            end
        until (CodeCoverage2.Next() = 0) or
                (CodeCoverage2."Line Type" = CodeCoverage2."Line Type"::Object);

        exit(CoveragePercent(NoCodeLines, NoCodeLinesHit))
    end;

    procedure FunctionCoverage(var CodeCoverage: Record "Code Coverage"; var NoCodeLines: Integer; var NoCodeLinesHit: Integer): Decimal
    var
        CodeCoverage2: Record "Code Coverage";
    begin
        NoCodeLines := 0;
        NoCodeLinesHit := 0;

        CodeCoverage2.SetPosition(CodeCoverage.GetPosition());
        CodeCoverage2.SetRange("Object Type", CodeCoverage."Object Type");
        CodeCoverage2.SetRange("Object ID", CodeCoverage."Object ID");

        repeat
            if CodeCoverage2."Line Type" = CodeCoverage2."Line Type"::Code then begin
                NoCodeLines += 1;
                if CodeCoverage2."No. of Hits" > 0 then
                    NoCodeLinesHit += 1;
            end
        until (CodeCoverage2.Next() = 0) or
                (CodeCoverage2."Line Type" = CodeCoverage2."Line Type"::Object) or
                (CodeCoverage2."Line Type" = CodeCoverage2."Line Type"::"Trigger/Function");

        exit(CoveragePercent(NoCodeLines, NoCodeLinesHit))
    end;

    procedure SetCodeCoverageXMLPortId(NewCodeCoverageXMLPortId: Integer)
    begin
        CodeCoverageXMLPortId := NewCodeCoverageXMLPortId;
    end;

    procedure GetDefaultCodeCoverageXmlPortId(): Integer
    begin
        exit(Xmlport::"Code Coverage Results");
    end;

    procedure CoveragePercent(NoCodeLines: Integer; NoCodeLinesHit: Integer): Decimal
    begin
        if NoCodeLines > 0 then
            exit(NoCodeLinesHit / NoCodeLines);

        exit(1.0)
    end;
}