// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System;

/// <summary>
/// Codeunit used to log needed permission for a given activity.
/// </summary>
codeunit 9802 "Log Activity Permissions"
{
    Access = Public;
    SingleInstance = true;

    var
        TempTablePermissionBuffer: Record "Tenant Permission" temporary;
        [WithEvents]
        EventReceiver: DotNet NavPermissionEventReceiver;

    procedure Start()
    var
        SessionIdVar: Integer;
    begin
        SessionIdVar := SessionId();
        OnBeforeStart(SessionIdVar);
        TempTablePermissionBuffer.DeleteAll();
        if IsNull(EventReceiver) then
            EventReceiver := EventReceiver.NavPermissionEventReceiver(SessionIdVar);

        EventReceiver.RegisterForEvents();
    end;

    procedure Stop(var TempTablePermissionBufferVar: Record "Tenant Permission" temporary)
    begin
        EventReceiver.UnregisterEvents();
        TempTablePermissionBufferVar.Copy(TempTablePermissionBuffer, true)
    end;

    local procedure LogTableUsage(TypeOfObject: Option; ObjectId: Integer; Permissions: Integer; PermissionsFromCaller: Integer)
    var
        NullGuid: Guid;
    begin
        // Note: Do not start any write transactions inside this method and do not make
        // any commits. This code is invoked on permission checks - where there may be
        // no transaction.
        if (ObjectId = Database::"Tenant Permission") and
           ((TypeOfObject = TempTablePermissionBuffer."Object Type"::Table) or
            (TypeOfObject = TempTablePermissionBuffer."Object Type"::"Table Data") or
            ((TypeOfObject = TempTablePermissionBuffer."Object Type"::Codeunit) and (ObjectId = Codeunit::"Log Activity Permissions")))
        then
            exit;

        if not TempTablePermissionBuffer.Get(NullGuid, '', TypeOfObject, ObjectId) then begin
            TempTablePermissionBuffer.Init();
            TempTablePermissionBuffer."Object Type" := TypeOfObject;
            TempTablePermissionBuffer."Object ID" := ObjectId;
            TempTablePermissionBuffer."Read Permission" := TempTablePermissionBuffer."Read Permission"::" ";
            TempTablePermissionBuffer."Insert Permission" := TempTablePermissionBuffer."Insert Permission"::" ";
            TempTablePermissionBuffer."Modify Permission" := TempTablePermissionBuffer."Modify Permission"::" ";
            TempTablePermissionBuffer."Delete Permission" := TempTablePermissionBuffer."Delete Permission"::" ";
            TempTablePermissionBuffer."Execute Permission" := TempTablePermissionBuffer."Execute Permission"::" ";
            TempTablePermissionBuffer.Insert();
        end;

        TempTablePermissionBuffer."Object Type" := TypeOfObject;

        case SelectDirectOrIndirect(Permissions, PermissionsFromCaller) of
            1:
                TempTablePermissionBuffer."Read Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Read Permission", TempTablePermissionBuffer."Read Permission"::Yes);
            32:
                TempTablePermissionBuffer."Read Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Read Permission", TempTablePermissionBuffer."Read Permission"::Indirect);
            2:
                TempTablePermissionBuffer."Insert Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Insert Permission", TempTablePermissionBuffer."Insert Permission"::Yes);
            64:
                TempTablePermissionBuffer."Insert Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Insert Permission", TempTablePermissionBuffer."Insert Permission"::Indirect);
            4:
                TempTablePermissionBuffer."Modify Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Modify Permission", TempTablePermissionBuffer."Modify Permission"::Yes);
            128:
                TempTablePermissionBuffer."Modify Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Modify Permission", TempTablePermissionBuffer."Modify Permission"::Indirect);
            8:
                TempTablePermissionBuffer."Delete Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Delete Permission", TempTablePermissionBuffer."Delete Permission"::Yes);
            256:
                TempTablePermissionBuffer."Delete Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Delete Permission", TempTablePermissionBuffer."Delete Permission"::Indirect);
            16:
                TempTablePermissionBuffer."Execute Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Execute Permission", TempTablePermissionBuffer."Execute Permission"::Yes);
            512:
                TempTablePermissionBuffer."Execute Permission" :=
                  GetMaxPermission(TempTablePermissionBuffer."Execute Permission", TempTablePermissionBuffer."Execute Permission"::Indirect);
        end;
        TempTablePermissionBuffer.Modify();

        OnAfterLogTableUsage(TempTablePermissionBuffer);
    end;

    internal procedure GetMaxPermission(CurrentPermission: Option; NewPermission: Option): Integer
    begin
        if IsFirstPermissionHigherThanSecond(CurrentPermission, NewPermission) then
            exit(CurrentPermission);
        exit(NewPermission);
    end;

    local procedure IsFirstPermissionHigherThanSecond(First: Option; Second: Option): Boolean
    var
        TempExpandedPermission: Record "Expanded Permission" temporary;
    begin
        case First of
            TempExpandedPermission."Read Permission"::" ":
                exit(false);
            TempExpandedPermission."Read Permission"::Indirect:
                exit(Second = TempExpandedPermission."Read Permission"::" ");
            TempExpandedPermission."Read Permission"::Yes:
                exit(Second in [TempExpandedPermission."Read Permission"::Indirect, TempExpandedPermission."Read Permission"::" "]);
        end;
    end;

    local procedure SelectDirectOrIndirect(DirectPermission: Integer; IndirectPermission: Integer): Integer
    begin
        if IndirectPermission = 0 then
            exit(DirectPermission);
        exit(IndirectPermission);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStart(var SessionId: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterLogTableUsage(var TempTablePermissionBuffer: Record "Tenant Permission" temporary)
    begin
    end;

    trigger EventReceiver::OnPermissionCheckEvent(sender: Variant; e: DotNet PermissionCheckEventArgs)
    begin
        case e.EventId of
            801:
                case e.ValidationCategory of
                    EventReceiver.NormalValidationCategoryId,
                  EventReceiver.ReadPermissionValidationCategoryId,
                  EventReceiver.WritePermissionValidationCategoryId:
                        LogTableUsage(e.ObjectType, e.ObjectId, e.Permissions, e.IndirectPermissionsFromCaller);
                end;
        end;
    end;
}

