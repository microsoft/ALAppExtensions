// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft;

using System.Diagnostics;
using System.Environment;
using System.Reflection;
using System.Security.AccessControl;

codeunit 31393 "Install Applications Mgt. CZL"
{
    EventSubscriberInstance = Manual;
    Permissions = tabledata "Tenant Permission Set" = i,
                  tabledata "Tenant Permission" = i,
                  tabledata "Change Log Setup (Table)" = i,
                  tabledata "Change Log Setup (Field)" = i;

    procedure InsertTableDataPermissions(AppID: Guid; OldTableID: Integer; NewTableID: Integer)
    var
#pragma warning disable AL0432
        Permission: Record Permission;
        PermissionSet: Record "Permission Set";
#pragma warning restore AL0432
        TenantPermission: Record "Tenant Permission";
        TenantPermissionSet: Record "Tenant Permission Set";
    begin
        Permission.SetRange("Object Type", Permission."Object Type"::"Table Data");
        Permission.SetRange("Object ID", OldTableID);
        if not Permission.FindSet() then
            exit;

        repeat
            if not TenantPermissionSet.Get(AppID, Permission."Role ID") then begin
                TenantPermissionSet.Init();
                TenantPermissionSet."App ID" := AppId;
                TenantPermissionSet."Role ID" := Permission."Role ID";
                if PermissionSet.Get(Permission."Role ID") then
                    TenantPermissionSet.Name := PermissionSet.Name;
                TenantPermissionSet.Insert();
            end;
            if not TenantPermission.Get(AppID, Permission."Role ID", Permission."Object Type", NewTableID) then begin
                TenantPermission.Init();
                TenantPermission."App ID" := TenantPermissionSet."App ID";
                TenantPermission."Role ID" := TenantPermissionSet."Role ID";
                TenantPermission."Object Type" := Permission."Object Type";
                TenantPermission."Object ID" := NewTableID;
                TenantPermission."Read Permission" := Permission."Read Permission";
                TenantPermission."Insert Permission" := Permission."Insert Permission";
                TenantPermission."Modify Permission" := Permission."Modify Permission";
                TenantPermission."Delete Permission" := Permission."Delete Permission";
                TenantPermission."Execute Permission" := Permission."Execute Permission";
                TenantPermission."Security Filter" := Permission."Security Filter";
                TenantPermission.Insert();
            end;
        until Permission.Next() = 0;
    end;

    procedure InsertTableDataUsage(OldTableID: Integer; NewTableID: Integer)
    var
        ChangeLogSetupTable: Record "Change Log Setup (Table)";
        NewChangeLogSetupTable: Record "Change Log Setup (Table)";
        ChangeLogSetupField: Record "Change Log Setup (Field)";
        NewChangeLogSetupField: Record "Change Log Setup (Field)";
        Field: Record Field;
    begin
        if not ChangeLogSetupTable.Get(OldTableID) then
            exit;

        if not NewChangeLogSetupTable.Get(NewTableId) then begin
            NewChangeLogSetupTable.Init();
            NewChangeLogSetupTable := ChangeLogSetupTable;
            NewChangeLogSetupTable."Table No." := NewTableID;
            NewChangeLogSetupTable.Insert();
        end;
        ChangeLogSetupField.SetRange("Table No.", OldTableId);
        if not ChangeLogSetupField.FindSet() then
            repeat
                if not NewChangeLogSetupField.Get(NewTableID, ChangeLogSetupField."Field No.") then
                    if Field.Get(NewTableID, ChangeLogSetupField."Field No.") then begin
                        NewChangeLogSetupField.Init();
                        NewChangeLogSetupField := ChangeLogSetupField;
                        NewChangeLogSetupField."Table No." := NewTableID;
                        NewChangeLogSetupField.Insert();
                    end;
            until ChangeLogSetupField.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseInsert', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseInsert(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseModify', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseModify(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseDelete', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseDelete(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::GlobalTriggerManagement, 'OnBeforeOnDatabaseRename', '', false, false)]
    local procedure DisableGlobalTriggersOnBeforeOnDatabaseRename(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}
