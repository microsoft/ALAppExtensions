// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

report 132610 "Checklist Test Report"
{
    ProcessingOnly = true;
    
    trigger OnPostReport()
    begin
        OnChecklistTestReportPostRun();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnChecklistTestReportPostRun()
    begin
    end;
}