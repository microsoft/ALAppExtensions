// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 139590 TestRunner
{
    trigger OnRun()
    var
        ImgAnalyzerMgtTest: Codeunit "Img. Analyzer Mgt. Test";
        ItemAttrPopulateTest: Codeunit "Item Attr Populate Test";
        ContactPicAnalyzerTest: Codeunit "Contact Pic Analyzer Test";
    begin
        ImgAnalyzerMgtTest.Run();
        ItemAttrPopulateTest.Run();
        ContactPicAnalyzerTest.Run();
    end;
}