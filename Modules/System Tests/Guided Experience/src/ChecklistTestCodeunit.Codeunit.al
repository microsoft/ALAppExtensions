// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132610 "Checklist Test Codeunit"
{
    trigger OnRun()
    begin
        OnChecklistTestCodeunitRun();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnChecklistTestCodeunitRun()
    begin
    end;
}