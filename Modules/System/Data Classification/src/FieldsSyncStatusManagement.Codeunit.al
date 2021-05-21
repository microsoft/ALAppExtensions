// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1757 "Fields Sync Status Management"
{
    Access = Internal;
    Permissions = tabledata "Fields Sync Status" = rim;

    procedure GetLastSyncStatusDate(): DateTime
    var
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        if FieldsSyncStatus.Get() then
            exit(FieldsSyncStatus."Last Sync Date Time");
    end;

    procedure SetLastSyncDate()
    var
        FieldsSyncStatus: Record "Fields Sync Status";
    begin
        if FieldsSyncStatus.Get() then begin
            FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime();
            FieldsSyncStatus.Modify();
        end else begin
            FieldsSyncStatus.Init();
            FieldsSyncStatus."Last Sync Date Time" := CurrentDateTime();
            FieldsSyncStatus.Insert();
        end;
    end;
}