// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Test.Agents.Designer.AgentSamples.SalesValidation;

using System.AI;
using System.TestLibraries.AI;
using System.TestTools.AITestToolkit;

codeunit 133742 "Sample Agents Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase()
    var
        LibraryCopilotCapability: Codeunit "Library - Copilot Capability";
    begin
        LibraryCopilotCapability.ActivateCopilotCapability(Enum::"Copilot Capability"::"Custom Agent", '00155c68-8cdd-4d60-a451-2034ad094223');
    end;

    trigger OnInstallAppPerCompany()
    var
        DatasetPaths: List of [Text];
        TestSuitePaths: List of [Text];
        ResourcePath: Text;
    begin
        // Load Datasets
        DatasetPaths := NavApp.ListResources('*.yaml');
        foreach ResourcePath in DatasetPaths do
            SetupDataInput(ResourcePath);
        // Load Test Suites
        TestSuitePaths := NavApp.ListResources('*.xml');
        foreach ResourcePath in TestSuitePaths do
            SetupTestSuite(ResourcePath);
    end;

    local procedure SetupDataInput(FilePath: Text)
    var
        AITALTestSuiteMgt: Codeunit "AIT AL Test Suite Mgt";
        FileName: Text;
        ResInStream: InStream;
    begin
        // Get the filename from the path
        FileName := FilePath.Substring(FilePath.LastIndexOf('/') + 1);

        NavApp.GetResource(FilePath, ResInStream, SampleAgentUtilities.GetTextEncoding());
        AITALTestSuiteMgt.ImportTestInputs(FileName, ResInStream);
    end;

    local procedure SetupTestSuite(Filepath: Text)
    var
        AITALTestSuiteMgt: Codeunit "AIT AL Test Suite Mgt";
        XMLSetupInStream: InStream;
    begin
        NavApp.GetResource(Filepath, XMLSetupInStream, SampleAgentUtilities.GetTextEncoding());
        AITALTestSuiteMgt.ImportAITestSuite(XMLSetupInStream);
    end;

    var
        SampleAgentUtilities: Codeunit "Sample Agents Utilities";
}