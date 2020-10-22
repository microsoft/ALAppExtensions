// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 149107 "BCPT Detail Trial Bal. Report"
{
    trigger OnRun();
    var
        DetailTrialBal: Report "Detail Trial Balance";
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
    begin
        TempBlob.CreateOutstream(OutStr);
        DetailTrialBal.SaveAs('', ReportFormat::Pdf, OutStr);
    end;
}