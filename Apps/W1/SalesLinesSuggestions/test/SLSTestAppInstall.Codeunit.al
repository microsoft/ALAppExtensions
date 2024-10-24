namespace Microsoft.Sales.Document.Test;

using System.TestTools.AITestToolkit;
using System;

codeunit 139784 "SLS Test App Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        ALSearch: DotNet ALSearch;
        DatasetPaths: List of [Text];
        TestSuitePaths: List of [Text];
        ResourcePath: Text;
    begin
        // Load Datasets
        DatasetPaths := NavApp.ListResources('Datasets/*.jsonl');
        foreach ResourcePath in DatasetPaths do
            SetupDataInput(ResourcePath);

        // Load Test Suites
        TestSuitePaths := NavApp.ListResources('TestSuites/*.xml');
        foreach ResourcePath in TestSuitePaths do
            SetupTestSuite(ResourcePath);

        // Enable Item Search
        ALSearch.EnableItemSearch();
    end;

    local procedure SetupDataInput(FilePath: Text)
    var
        AITALTestSuiteMgt: Codeunit "AIT AL Test Suite Mgt";
        FileName: Text;
        ResInStream: InStream;
    begin
        // Get the filename from the path
        FileName := FilePath.Substring(FilePath.LastIndexOf('/') + 1);

        NavApp.GetResource(FilePath, ResInStream);
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