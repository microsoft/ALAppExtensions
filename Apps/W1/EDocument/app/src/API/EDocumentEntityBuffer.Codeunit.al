// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.API;

using Microsoft.eServices.EDocument;
using Microsoft.Integration.Graph;

codeunit 6122 "E-Document Entity Buffer"
{
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";

    [EventSubscriber(ObjectType::Table, Database::"E-Document", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertEDocument(var Rec: Record "E-Document"; RunTrigger: Boolean)
    begin
        if not this.GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        this.InsertOrModifyFromEDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyEDocument(var Rec: Record "E-Document"; RunTrigger: Boolean)
    begin
        if not this.GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        this.InsertOrModifyFromEDocument(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"E-Document", 'OnAfterDeleteEvent', '', false, false)]
    local procedure OnAfterDeleteEDocument(var Rec: Record "E-Document"; RunTrigger: Boolean)
    var
        EDocumentEntityBuffer: Record "E-Document Entity Buffer";
    begin
        if not this.GraphMgtGeneralTools.IsApiEnabled() then
            exit;

        if EDocumentEntityBuffer.Get(Rec."Entry No") then
            EDocumentEntityBuffer.Delete(true);
    end;

    local procedure InsertOrModifyFromEDocument(var EDocument: Record "E-Document")
    var
        EDocumentEntityBuffer: Record "E-Document Entity Buffer";
        RecordExists: Boolean;
    begin
        EDocumentEntityBuffer.LockTable();
        RecordExists := EDocumentEntityBuffer.Get(EDocument."Entry No");

        EDocumentEntityBuffer.TransferFields(EDocument, true);
        EDocumentEntityBuffer.Id := EDocument.SystemId;
        EDocumentEntityBuffer.UpdateRelatedRecordsIds();

        if RecordExists then
            EDocumentEntityBuffer.Modify(true)
        else
            EDocumentEntityBuffer.Insert(true);
    end;

}
