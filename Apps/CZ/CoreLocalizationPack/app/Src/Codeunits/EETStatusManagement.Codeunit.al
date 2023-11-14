// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Utilities;

codeunit 31098 "EET Status Management CZL"
{
    Permissions = tabledata "EET Entry Status Log CZL" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnAfterChangeStatus', '', false, false)]
    local procedure LogStatusChangeOnAfterChangeStatus(var EETEntryCZL: Record "EET Entry CZL"; NewStatus: Enum "EET Status CZL"; NewDescription: Text; var TempErrorMessage: Record "Error Message")
    begin
        if EETEntryCZL.IsTemporary() then
            exit;

        EETEntryCZL.TestField("Entry No.");
        CreateEETEntryStatusLog(EETEntryCZL, NewDescription, TempErrorMessage);
    end;

    local procedure CreateEETEntryStatusLog(EETEntryCZL: Record "EET Entry CZL"; Description: Text; var TempErrorMessage: Record "Error Message")
    var
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        EETEntryStatusLogCZL.Init();
        EETEntryStatusLogCZL."EET Entry No." := EETEntryCZL."Entry No.";
        EETEntryStatusLogCZL.Status := EETEntryCZL."Status";
        EETEntryStatusLogCZL."Changed At" := EETEntryCZL."Status Last Changed At";
        EETEntryStatusLogCZL.Description := CopyStr(Description, 1, MaxStrLen(EETEntryStatusLogCZL.Description));
        EETEntryStatusLogCZL.Insert(true);

        EETEntryStatusLogCZL.SetErrorMessage(TempErrorMessage);
    end;
}
