#if not CLEAN27
#pragma warning disable AL0432
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Utilities;

using Microsoft.Sales.Document;

codeunit 31150 "Sync.Dep.Fld-SalesHeader CZL"
{
    Access = Internal;
    Permissions = tabledata "Sales Header" = rimd;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure SyncOnBeforeInsertSalesHeader(var Rec: Record "Sales Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeModifyEvent', '', false, false)]
    local procedure SyncOnBeforeModifySalesHeader(var Rec: Record "Sales Header")
    begin
        SyncDeprecatedFields(Rec);
    end;

    local procedure SyncDeprecatedFields(var Rec: Record "Sales Header")
    var
        PreviousRecord: Record "Sales Header";
        SyncDepFldUtilities: Codeunit "Sync.Dep.Fld-Utilities";
        PreviousRecordRef: RecordRef;
        DepFieldTxt, NewFieldTxt : Text;
    begin
        if Rec.IsTemporary() then
            exit;
        if SyncDepFldUtilities.GetPreviousRecord(Rec, PreviousRecordRef) then
            PreviousRecordRef.SetTable(PreviousRecord);
        DepFieldTxt := Rec."Registration No. CZL";
        NewFieldTxt := Rec."Registration Number";
        SyncDepFldUtilities.SyncFields(DepFieldTxt, NewFieldTxt, PreviousRecord."Registration No. CZL", PreviousRecord."Registration Number");
        Rec."Registration No. CZL" := CopyStr(DepFieldTxt, 1, MaxStrLen(Rec."Registration No. CZL"));
        Rec."Registration Number" := CopyStr(NewFieldTxt, 1, MaxStrLen(Rec."Registration Number"));
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Registration No. CZL', false, false)]
    local procedure SyncOnAfterValidateRegistrationNoCZL(var Rec: Record "Sales Header")
    begin
        Rec."Registration Number" := Rec."Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnAfterValidateEvent', 'Registration Number', false, false)]
    local procedure SyncOnAfterValidateVatReportingDate(var Rec: Record "Sales Header")
    begin
        Rec."Registration No. CZL" := Rec.GetRegistrationNoTrimmedCZL();
    end;
}
#endif