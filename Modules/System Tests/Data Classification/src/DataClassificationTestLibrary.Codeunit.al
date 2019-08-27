// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 135157 "Library - Data Classification"
{
    Subtype = Normal;

    [Normal]
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