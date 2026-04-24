// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Agents.SalesOrderAgent;

using System.TestTools.AITestToolkit;

codeunit 133701 "PA Tests Install"
{
    Subtype = Install;
    Access = Internal;

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

        NavApp.GetResource(FilePath, ResInStream, TextEncoding::UTF8);
        AITALTestSuiteMgt.ImportTestInputs(FileName, ResInStream);
    end;

    local procedure SetupTestSuite(Filepath: Text)
    var
        AITALTestSuiteMgt: Codeunit "AIT AL Test Suite Mgt";
        XMLSetupInStream: InStream;
    begin
        NavApp.GetResource(Filepath, XMLSetupInStream);
        AITALTestSuiteMgt.ImportAITestSuite(XMLSetupInStream);
    end;
}