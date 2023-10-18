// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestTools.CodeCoverage;

using System.TestTools.TestRunner;

codeunit 130471 "AL Code Coverage Subscribers"
{
    SingleInstance = true;
    Access = Internal;

    var
        ALTestSuite: Record "AL Test Suite";
        ALCodeCoverageMgt: Codeunit "AL Code Coverage Mgt.";
        TestSuiteMgt: Codeunit "Test Suite Mgt.";


    procedure SetALTestSuite(NewALTestSuite: Record "AL Test Suite")
    begin
        ALTestSuite := NewALTestSuite;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnRunTestSuite', '', false, false)]
    local procedure OnRunTestSuite(var TestMethodLine: Record "Test Method Line")
    begin
        if ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Run" then
            ALCodeCoverageMgt.Start(ALTestSuite."CC Track All Sessions");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterRunTestSuite', '', false, false)]
    local procedure OnAfterRunTestSuite(var TestMethodLine: Record "Test Method Line")
    begin
        if ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Run" then
            ALCodeCoverageMgt.StopAndSave(0, TestMethodLine.GetFilter("Test Suite"));
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnBeforeCodeunitRun', '', false, false)]
    local procedure OnBeforeCodeunitRun(var TestMethodLine: Record "Test Method Line")
    begin
        if ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Codeunit" then
            ALCodeCoverageMgt.Start(ALTestSuite."CC Track All Sessions");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterCodeunitRun', '', false, false)]
    local procedure OnAfterCodeunitRun(var TestMethodLine: Record "Test Method Line")
    begin
        if ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Codeunit" then
            ALCodeCoverageMgt.StopAndSave(TestMethodLine."Test Codeunit", '');

        if ALTestSuite."CC Coverage Map" = ALTestSuite."CC Coverage Map"::"Per Codeunit" then begin
            if ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Run" then
                ALCodeCoverageMgt.Refresh();

            ALCodeCoverageMgt.SaveCodeCoverageMap(TestMethodLine."Test Codeunit", '', ALTestSuite);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnBeforeTestMethodRun', '', false, false)]
    local procedure OnBeforeTestMethodRun(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; var CurrentTestMethodLine: Record "Test Method Line")
    begin
        if (
            (ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Test") and
            TestSuiteMgt.IsTestMethodLine(FunctionName)
        ) then
            ALCodeCoverageMgt.Start(ALTestSuite."CC Track All Sessions");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Test Runner - Mgt", 'OnAfterTestMethodRun', '', false, false)]
    local procedure OnAfterTestMethodRun(CodeunitID: Integer; CodeunitName: Text[30]; FunctionName: Text[128]; FunctionTestPermissions: TestPermissions; IsSuccess: Boolean; var CurrentTestMethodLine: Record "Test Method Line")
    begin
        if not (ALTestSuite."CC Tracking Type" = ALTestSuite."CC Tracking Type"::"Per Test") then
            exit;


        if not TestSuiteMgt.IsTestMethodLine(FunctionName) then
            exit;

        ALCodeCoverageMgt.StopAndSave(CodeunitID, FunctionName);

        if ALTestSuite."CC Coverage Map" = ALTestSuite."CC Coverage Map"::"Per Test" then
            ALCodeCoverageMgt.SaveCodeCoverageMap(CodeunitID, FunctionName, ALTestSuite);
    end;
}