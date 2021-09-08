// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135157 "Library - Data Classification"
{
    Subtype = Normal;
    Permissions = tabledata "Fields Sync Status" = rid;

    /// <summary>
    /// Modifies the Last Sync Date Time field of the Field Sync Status table to LastFieldsSyncStatusDate.
    /// </summary>
    /// <param name="LastFieldsSyncStatusDate">The value that the Last Sync Date Time will take.</param>
    procedure ModifyLastFieldsSyncStatusDate(LastFieldsSyncStatusDate: DateTime)
    var
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        FieldsSyncStatus.DeleteAll();

        FieldsSyncStatus.Init();
        FieldsSyncStatus."Last Sync Date Time" := LastFieldsSyncStatusDate;
        FieldsSyncStatus.Insert();
    end;
}