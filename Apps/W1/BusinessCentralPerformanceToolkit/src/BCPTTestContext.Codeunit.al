// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functions that can be used by the BCPT tests.
/// </summary>
codeunit 149003 "BCPT Test Context"
{
    SingleInstance = true;
    Access = Public;

    var
        BCPTLineCU: Codeunit "BCPT Line";

    /// <summary>
    /// This method starts the scope of a test session where the performance numbers are collected.
    /// </summary>
    /// <param name="ScenarioOperation">Label of the scenario.</param>
    procedure StartScenario(ScenarioOperation: Text)
    begin
        BCPTLineCU.StartScenario(ScenarioOperation);
    end;

    /// <summary>
    /// This method ends the scope of a test session where the performance numbers are collected.
    /// </summary>
    /// <param name="ScenarioOperation">Label of the scenario.</param>
    procedure EndScenario(ScenarioOperation: Text)
    var
        BCPTLine: Record "BCPT Line";
    begin
        GetBCPTLine(BCPTLine);
        BCPTLineCU.EndScenario(BCPTLine, ScenarioOperation, true);
    end;

    /// <summary>
    /// This method ends the scope of a test session where the performance numbers are collected.
    /// </summary>
    /// <param name="ScenarioOperation">Label of the scenario.</param>
    /// <param name="ExecutionSuccess">Result of the test execution.</param>
    procedure EndScenario(ScenarioOperation: Text; ExecutionSuccess: Boolean)
    var
        BCPTLine: Record "BCPT Line";
    begin
        GetBCPTLine(BCPTLine);
        BCPTLineCU.EndScenario(BCPTLine, ScenarioOperation, ExecutionSuccess);
    end;

    /// <summary>
    /// This method simulates a users delay between operations. This method is called by the BCPT test to represent a realistic scenario.
    /// The calculation of the length of the wait is done usign the parameters defined on the BCPT suite.
    /// </summary>
    /// <param name="ScenarioOperation">Label of the scenario.</param>
    /// <param name="ExecutionSuccess">Result of the test execution.</param>
    procedure UserWait()
    var
        BCPTHeader: Record "BCPT Header";
        BCPTLine: Record "BCPT Line";

    begin
        GetBCPTHeader(BCPTHeader);
        if BCPTHeader.CurrentRunType = BCPTHeader.CurrentRunType::PRT then
            exit;

        GetBCPTLine(BCPTLine);
        BCPTLineCU.UserWait(BCPTLine);
    end;

    /// <summary>
    /// Returns the BCPTLine associated with the sessions.
    /// </summary>
    /// <param name="BCPTLine">BCPTLine associated with the session.</param>
    local procedure GetBCPTLine(var BCPTLine: Record "BCPT Line")
    var
        BCPTRoleWrapperImpl: Codeunit "BCPT Role Wrapper";
    begin
        BCPTRoleWrapperImpl.GetBCPTLine(BCPTLine);
    end;

    /// <summary>
    /// Returns the BCPTHeader associated with the sessions.
    /// </summary>
    /// <param name="BCPTLine">BCPTLine associated with the session.</param>
    local procedure GetBCPTHeader(var BCPTHeader: Record "BCPT header")
    var
        BCPTRoleWrapperImpl: Codeunit "BCPT Role Wrapper";
    begin
        BCPTRoleWrapperImpl.GetBCPTHeader(BCPTHeader);
    end;

    /// <summary>
    /// Returns the paramater list associated with the sessions.
    /// </summary>
    procedure GetParameters(): Text
    var
        BCPTLine: Record "BCPT Line";
    begin
        GetBCPTLine(BCPTLine);
        Exit(BCPTLine.Parameters);
    end;

    /// <summary>
    /// Returns the requested paramater value associated with the session.
    /// </summary>
    /// <param name="ParameterName">Name of the parameter.</param>
    Procedure GetParameter(ParameterName: Text): Text
    var
        BCPTLine: Record "BCPT Line";
        dict: Dictionary of [Text, Text];
    begin
        GetBCPTLine(BCPTLine);
        if ParameterName = '' then
            exit('');
        if BCPTLine.Parameters = '' then
            exit('');
        BCPTLineCU.ParameterStringToDictionary(BCPTLine.Parameters, dict);
        if dict.Count = 0 then
            exit('');
        if not dict.ContainsKey(ParameterName) then
            exit('');
        exit(dict.Get(ParameterName));
    end;

}