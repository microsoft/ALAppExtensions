// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148041 "VAT Report Ext Test Runner"
{
    trigger OnRun();
    var
        MSECSLExportTest: Codeunit "MS - ECSL Export Test";
    begin
        MSECSLExportTest.Run();
    end;
}