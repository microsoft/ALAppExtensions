// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132609 "Checklist Setup Test Library"
{
    Permissions = tabledata "Checklist Setup" = d;

    /// <summary>
    /// Deletes all the entries from the Checklist Setup table.
    /// </summary>
    procedure DeleteAll()
    var
        ChecklistSetup: Record "Checklist Setup";
    begin
        ChecklistSetup.DeleteAll();
    end;

    /// <summary>
    /// Checks whether the checklist setup is done.
    /// </summary>
    /// <returns>True if the checklist setup is done and false otherwise.</returns>
    procedure IsChecklistSetupDone(): Boolean
    var
        ChecklistSetup: Record "Checklist Setup";
    begin
        if ChecklistSetup.Get(true) then
            exit(true);

        exit(false);
    end;
}