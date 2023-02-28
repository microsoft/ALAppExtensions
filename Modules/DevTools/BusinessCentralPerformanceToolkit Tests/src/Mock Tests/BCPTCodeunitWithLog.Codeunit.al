// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 144757 "BCPT Codeunit With Log"
{
    trigger OnRun()
    var
        ObjectMetadata: Record "Object Metadata";
        BCPTTestContext: Codeunit "BCPT Test Context";
    begin
        BCPTTestContext.StartScenario(Format(Codeunit::"BCPT Codeunit With Log"));
        if ObjectMetadata.IsEmpty() then;
        BCPTTestContext.EndScenario(Format(Codeunit::"BCPT Codeunit With Log"));
    end;
}