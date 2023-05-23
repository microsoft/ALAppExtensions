// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Used to provide indirect permission to retention policies
/// </summary>
codeunit 8903 "Email Record Reference Impl." implements "Record Reference"
{
    Access = Internal;
    InherentPermissions = X;
    InherentEntitlements = X;
    Permissions = tabledata "Sent Email" = r,
                  tabledata "Email Outbox" = r;

    var
        InitializedCallerModuleId: Guid;
        IncorrectCallerAppIdErr: Label 'The interface was initialized by a different app. Initializer app id: %1, caller app id :%2', Comment = '%1 and %2 are guid''s';
        SystemApplicationAppIdTxt: Label '63ca2fa4-4f03-4f2b-a480-172fef340d3f', Locked = true;
        RetentionPolicyAppIdTxt: Label 'a8177fd4-0adb-4482-889c-2e123a13b50a', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Record Reference", OnInitialize, '', false, false)]
    local procedure OnSetRecordRefIndirectPermissionInterface(RecordRef: RecordRef; var RecordReference: Interface "Record Reference"; CallerModuleInfo: ModuleInfo; var IsInitialized: Boolean);
    var
        EmailRecordReferenceImpl: Codeunit "Email Record Reference Impl.";
    begin
        if IsInitialized then
            exit;

        if not IsAllowedCallerModuleId(CallerModuleInfo.Id) then
            exit;

        if RecordRef.Number in [Database::"Sent Email", Database::"Email Outbox"] then begin
            RecordReference := EmailRecordReferenceImpl;
            EmailRecordReferenceImpl.SetInitializedCalledModuleId(CallerModuleInfo.Id);
            IsInitialized := true;
        end;
    end;

    local procedure IsAllowedCallerModuleId(CallerModuleId: Guid): Boolean
    begin
        exit(CallerModuleId in [SystemApplicationAppIdTxt, RetentionPolicyAppIdTxt]);
    end;

    procedure SetInitializedCalledModuleId(CallerModuleId: Guid)
    begin
        if IsAllowedCallerModuleId(CallerModuleId) then
            InitializedCallerModuleId := CallerModuleId
    end;

    local procedure VerifyCallerModuleId(CallerModuleId: Guid)
    begin
        if not (CallerModuleId = InitializedCallerModuleId) then
            error(IncorrectCallerAppIdErr, InitializedCallerModuleId, CallerModuleId);
    end;

    procedure ReadPermission(RecordRef: RecordRef): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.ReadPermission())
    end;

    procedure WritePermission(RecordRef: RecordRef): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.WritePermission())
    end;

    procedure Count(RecordRef: RecordRef): Integer
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.Count())
    end;

    procedure CountApprox(RecordRef: RecordRef): Integer
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.Count())
    end;

    procedure IsEmpty(RecordRef: RecordRef): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.IsEmpty())
    end;

    procedure Find(RecordRef: RecordRef; Which: Text)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
#pragma warning disable AA0181
        RecordRef.Find(Which)
#pragma warning restore AA0181
    end;

    procedure Find(RecordRef: RecordRef; Which: Text; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
#pragma warning disable AA0181
        if not UseReturnValue then
            RecordRef.Find(Which)
        else
            exit(RecordRef.Find(Which))
#pragma warning restore AA0181
    end;

    procedure FindFirst(RecordRef: RecordRef)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.FindFirst()
    end;

    procedure FindFirst(RecordRef: RecordRef; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.FindFirst()
        else
            exit(RecordRef.FindFirst())
    end;

    procedure FindLast(RecordRef: RecordRef)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.FindLast()
    end;

    procedure FindLast(RecordRef: RecordRef; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.FindLast()
        else
            exit(RecordRef.FindLast())
    end;

    procedure FindSet(RecordRef: RecordRef)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
#pragma warning disable AA0181
        RecordRef.FindSet()
#pragma warning restore AA0181
    end;

    procedure FindSet(RecordRef: RecordRef; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
#pragma warning disable AA0181
        if not UseReturnValue then
            RecordRef.FindSet()
        else
            exit(RecordRef.FindSet())
#pragma warning restore AA0181
    end;

    procedure FindSet(RecordRef: RecordRef; ForUpdate: Boolean; UpdateKey: Boolean; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
#pragma warning disable AA0181
        if not UseReturnValue then
            RecordRef.FindSet(ForUpdate, UpdateKey)
        else
            exit(RecordRef.FindSet(ForUpdate, UpdateKey))
#pragma warning restore AA0181
    end;

    procedure Next(RecordRef: RecordRef; RecordRefSteps: Integer): Integer
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.Next(RecordRefSteps));
    end;

    procedure Next(RecordRef: RecordRef): Integer
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        exit(RecordRef.Next());
    end;

    procedure Get(RecordRef: RecordRef; RecordId: RecordId)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.Get(RecordId)
    end;

    procedure Get(RecordRef: RecordRef; RecordId: RecordId; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.Get(RecordId)
        else
            exit(RecordRef.Get(RecordId))
    end;

    procedure GetBySystemId(RecordRef: RecordRef; SystemId: Guid)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.GetBySystemId(SystemId)
    end;

    procedure GetBySystemId(RecordRef: RecordRef; SystemId: Guid; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.GetBySystemId(SystemId)
        else
            exit(RecordRef.GetBySystemId(SystemId))
    end;

    procedure Insert(RecordRef: RecordRef; RunTrigger: Boolean)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.Insert(RunTrigger)
    end;

    procedure Insert(RecordRef: RecordRef; RunTrigger: Boolean; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.Insert(RunTrigger)
        else
            exit(RecordRef.Insert(RunTrigger))
    end;

    procedure Insert(RecordRef: RecordRef; RunTrigger: Boolean; InsertWithSystemId: Boolean; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.Insert(RunTrigger, InsertWithSystemId)
        else
            exit(RecordRef.Insert(RunTrigger, InsertWithSystemId))
    end;

    procedure Modify(RecordRef: RecordRef; RunTrigger: Boolean)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.Modify(RunTrigger)
    end;

    procedure Modify(RecordRef: RecordRef; RunTrigger: Boolean; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.Modify(RunTrigger)
        else
            exit(RecordRef.Modify(RunTrigger))
    end;

    procedure Delete(RecordRef: RecordRef; RunTrigger: Boolean)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.Delete(RunTrigger)
    end;

    procedure Delete(RecordRef: RecordRef; RunTrigger: Boolean; UseReturnValue: Boolean): Boolean
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        if not UseReturnValue then
            RecordRef.Delete(RunTrigger)
        else
            exit(RecordRef.Delete(RunTrigger))
    end;

    procedure DeleteAll(RecordRef: RecordRef; RunTrigger: Boolean)
    var
        CallerModuleInfo: ModuleInfo;
    begin
        NavApp.GetCallerModuleInfo(CallerModuleInfo);
        VerifyCallerModuleId(CallerModuleInfo.Id);
        RecordRef.DeleteAll(RunTrigger)
    end;
}