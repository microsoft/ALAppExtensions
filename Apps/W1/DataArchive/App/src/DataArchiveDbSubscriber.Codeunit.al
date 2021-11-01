// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This codeunit manually bound to the Global database delete trigger
/// </summary>
codeunit 603 "Data Archive Db Subscriber"
{
    Access = Internal;
    EventSubscriberInstance = Manual;
    Permissions = tabledata "Data Archive" = rimd,
                  tabledata "Data Archive Table" = rimd,
                  tabledata "Data Archive Media Field" = rimd;

    var
        DataArchiveProvider: interface "Data Archive Provider";
        DataArchiveProviderIsSet: Boolean;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'GetDatabaseTableTriggerSetup', '', false, false)]
    local procedure GetDatabaseTableTriggerSetup(TableId: Integer; var OnDatabaseInsert: Boolean; var OnDatabaseModify: Boolean; var OnDatabaseDelete: Boolean; var OnDatabaseRename: Boolean)
    begin
        if not (TableId in [Database::"Data Archive", Database::"Data Archive Table", Database::"Data Archive Media Field"]) then
            OnDatabaseDelete := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Global Triggers", 'OnDatabaseDelete', '', false, false)]
    local procedure OnDatabaseDelete(RecRef: RecordRef)
    begin
        if DataArchiveProviderIsSet then
            if not RecRef.IsTemporary() then
                DataArchiveProvider.SaveRecord(RecRef);
    end;

    procedure SetDataArchiveProvider(var IDataArchiveProvider: Interface "Data Archive Provider")
    begin
        DataArchiveProvider := IDataArchiveProvider;
        DataArchiveProviderIsSet := true;
    end;
}