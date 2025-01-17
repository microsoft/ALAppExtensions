// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Preview;

using Microsoft.Finance;
using System.Utilities;

codeunit 31128 "Post. Prev. Table Handler CZL"
{
    EventSubscriberInstance = Manual;
    SingleInstance = true;

    var
        TempEETEntryCZL: Record "EET Entry CZL" temporary;
        TempEETEntryStatusLogCZL: Record "EET Entry Status Log CZL" temporary;
        TempErrorMessage: Record "Error Message" temporary;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertEETEntry(var Rec: Record "EET Entry CZL"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if TempEETEntryCZL.Get(Rec."Entry No.") then
            exit;

        TempEETEntryCZL := Rec;
        TempEETEntryCZL."Document No." := '***';
        TempEETEntryCZL."Receipt Serial No." := '***';
        TempEETEntryCZL.Insert();
    end;

    // The status of EET Entry is changing after insert so we must subscribe OnAfterModifyEvent as well
    [EventSubscriber(ObjectType::Table, Database::"EET Entry CZL", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnModifyEETEntry(var Rec: Record "EET Entry CZL"; var xRec: Record "EET Entry CZL"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        if not TempEETEntryCZL.Get(Rec."Entry No.") then
            exit;

        Rec.CalcFields("Taxpayer's Signature Code");
        TempEETEntryCZL := Rec;
        TempEETEntryCZL."Document No." := '***';
        TempEETEntryCZL."Receipt Serial No." := '***';
        TempEETEntryCZL.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"EET Entry Status Log CZL", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertEETEntryStatusLog(var Rec: Record "EET Entry Status Log CZL"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempEETEntryStatusLogCZL := Rec;
        TempEETEntryStatusLogCZL.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Error Message", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnInsertErrorMessage(var Rec: Record "Error Message"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        TempErrorMessage := Rec;
        TempErrorMessage.Insert();
    end;

    procedure DeleteAll()
    begin
        TempEETEntryCZL.Reset();
        TempEETEntryCZL.DeleteAll();
        TempEETEntryStatusLogCZL.Reset();
        TempEETEntryStatusLogCZL.DeleteAll();
        TempErrorMessage.Reset();
        TempErrorMessage.DeleteAll();
    end;

    procedure GetTempEETEntryCZL(var OutTempEETEntryCZL: Record "EET Entry CZL" temporary)
    begin
        OutTempEETEntryCZL.Copy(TempEETEntryCZL, true);
    end;

    procedure GetTempEETEntryStatusLogCZL(var OutTempEETEntryStatusLogCZL: Record "EET Entry Status Log CZL" temporary)
    begin
        OutTempEETEntryStatusLogCZL.Copy(TempEETEntryStatusLogCZL, true);
    end;

    procedure GetTempErrorMessage(var OutTempErrorMessage: Record "Error Message" temporary)
    begin
        OutTempErrorMessage.Copy(TempErrorMessage, true);
    end;
}
