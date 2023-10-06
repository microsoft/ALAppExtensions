// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Tooling;

using System.Environment.Configuration;

codeunit 132553 "Block Changes to System Tables"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        if UnbindSubscription(BlockChangesToSystemTables) then;
        if BindSubscription(BlockChangesToSystemTables) then;
        ClearLastError();
    end;

    procedure VerifyAndAllowChangesToSystemTable(TableID: Integer)
    var
        Allowed: Boolean;
    begin
        OnAllowChangesToSystemTable(Allowed, TableID);
        if Allowed then
            exit;

        Error(ChangesToSystemTableWouldCauseTestInstabilitiesErr)
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyProfileTable(RunTrigger: Boolean; var Rec: Record "Tenant Profile"; var xRec: Record "Tenant Profile")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile");
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Setting", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyTenantProfileSetting(RunTrigger: Boolean; var Rec: Record "Tenant Profile Setting"; var xRec: Record "Tenant Profile Setting")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Setting");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Extension", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyTenantProfileExtension(RunTrigger: Boolean; var Rec: Record "Tenant Profile Extension"; var xRec: Record "Tenant Profile Extension")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Extension");
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Page Metadata", 'OnBeforeModifyEvent', '', false, false)]
    local procedure OnBeforeModifyTenantProfilePageMetadata(RunTrigger: Boolean; var Rec: Record "Tenant Profile Page Metadata"; var xRec: Record "Tenant Profile Page Metadata")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Page Metadata");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameProfileTable(RunTrigger: Boolean; var Rec: Record "Tenant Profile"; var xRec: Record "Tenant Profile")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile");
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Setting", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameTenantProfileSetting(RunTrigger: Boolean; var Rec: Record "Tenant Profile Setting"; var xRec: Record "Tenant Profile Setting")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Setting");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Extension", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameTenantProfileExtension(RunTrigger: Boolean; var Rec: Record "Tenant Profile Extension"; var xRec: Record "Tenant Profile Extension")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Extension");
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Page Metadata", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameTenantProfilePageMetadata(RunTrigger: Boolean; var Rec: Record "Tenant Profile Page Metadata"; var xRec: Record "Tenant Profile Page Metadata")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Page Metadata");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertProfileTable(RunTrigger: Boolean; var Rec: Record "Tenant Profile")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile");
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Setting", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertTenantProfileSetting(RunTrigger: Boolean; var Rec: Record "Tenant Profile Setting")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Setting");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Extension", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertTenantProfileExtension(RunTrigger: Boolean; var Rec: Record "Tenant Profile Extension")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Extension");
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Page Metadata", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertTenantProfilePageMetadata(RunTrigger: Boolean; var Rec: Record "Tenant Profile Page Metadata")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Page Metadata");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteProfileTable(RunTrigger: Boolean; var Rec: Record "Tenant Profile")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile");
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Setting", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteTenantProfileSetting(RunTrigger: Boolean; var Rec: Record "Tenant Profile Setting")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Setting");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Extension", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteTenantProfileExtension(RunTrigger: Boolean; var Rec: Record "Tenant Profile Extension")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Extension");
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Tenant Profile Page Metadata", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteTenantProfilePageMetadata(RunTrigger: Boolean; var Rec: Record "Tenant Profile Page Metadata")
    begin
        if Rec.IsTemporary() then
            exit;

        VerifyAndAllowChangesToSystemTable(Database::"Tenant Profile Page Metadata");
    end;
#pragma warning restore AL0432

    [IntegrationEvent(false, false)]
    local procedure OnAllowChangesToSystemTable(var Allowed: Boolean; TableID: Integer)
    begin
    end;

    var
        BlockChangesToSystemTables: Codeunit "Block Changes to System Tables";
        ChangesToSystemTableWouldCauseTestInstabilitiesErr: Label 'Changes to a system table would cause test instabililties. The change would invalidate the metadata and fail tests that are running after the test.';
}