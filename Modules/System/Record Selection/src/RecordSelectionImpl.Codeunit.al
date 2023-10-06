// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Reflection;

using System;
using System.Integration;

/// <summary>
/// Implementation for looking up records.
/// </summary>
codeunit 9556 "Record Selection Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure Open(TableId: Integer; MaximumCount: Integer; var SelectedRecord: Record "Record Selection Buffer"): Boolean
    var
        RecordLookup: Page "Record Lookup";
    begin
        if RecordAutoSelected(TableId, MaximumCount, SelectedRecord) then begin
            Message(OnlyOneRecordMsg);
            exit(true);
        end;

        RecordLookup.SetTableId(TableId);
        RecordLookup.LookupMode(true);

        if RecordLookup.RunModal() = ACTION::LookupOK then begin
            RecordLookup.GetSelectedRecords(SelectedRecord);
            exit(true);
        end;

        exit(false);
    end;

    procedure ToText(TableId: Integer; SystemId: Guid): Text
    var
        FromRecordRef: RecordRef;
        FromFieldRef: FieldRef;
        FromKeyRef: KeyRef;
        PageSummaryFieldList: List of [Integer];
        RecordTextBuilder: TextBuilder;
        ValueAsText: Text;
        PageId: Integer;
        Index: Integer;
        FieldIndex: Integer;
        FieldCount: Integer;
        RelatedPageExist: Boolean;
    begin
        FromRecordRef.Open(TableId);

        if not FromRecordRef.GetBySystemId(SystemId) then
            exit('');

        PageId := GetRelatedPageId(TableId);
        RelatedPageExist := GetPageSummaryFields(PageId, FieldCount, PageSummaryFieldList);

        if not RelatedPageExist then
            GetPrimaryKeyFields(FromRecordRef, FromKeyRef, FieldCount);

        for Index := 1 to FieldCount do begin
            if RelatedPageExist then begin
                PageSummaryFieldList.Get(Index, FieldIndex);
                FromFieldRef := FromRecordRef.Field(FieldIndex);
            end else
                FromFieldRef := FromKeyRef.FieldIndex(Index);

            if FromFieldRef.Class = FieldClass::FlowField then
                FromFieldRef.CalcField();

            ValueAsText := FromFieldRef.Value();

            if ValueAsText <> '' then begin
                RecordTextBuilder.Append(ValueAsText);
                RecordTextBuilder.Append(',');
            end;
        end;

        if RecordTextBuilder.Length > 0 then
            RecordTextBuilder.Remove(RecordTextBuilder.Length, 1);

        exit(RecordTextBuilder.ToText());
    end;

    local procedure RecordAutoSelected(TableId: Integer; MaximumCount: Integer; var RecordSelectionBuffer: Record "Record Selection Buffer"): Boolean
    var
        FromRecordRef: RecordRef;
        RecordCount: Integer;
    begin
        FromRecordRef.Open(TableId);
        RecordCount := FromRecordRef.Count();

        if RecordCount = 0 then
            Error(NoRecordsErr);

        if RecordCount > MaximumCount then
            Error(TooManyRecordsErr, MaximumCount);

        if RecordCount = 1 then begin
            FromRecordRef.FindFirst();
            RecordSelectionBuffer."Record System Id" := FromRecordRef.Field(FromRecordRef.SystemIdNo()).Value;
            RecordSelectionBuffer.Insert();
            exit(true);
        end;

        exit(false);
    end;

    procedure GetRecordsFromTableId(TableId: Integer; var PrimaryKeyCaptions: array[10] of Text; var RecordSelectionBuffer: Record "Record Selection Buffer"): Integer
    var
        FieldCount: Integer;
        PageId: Integer;
    begin
        PageId := GetRelatedPageId(TableId);

        if GetFieldsFromPage(TableId, PageId, FieldCount, PrimaryKeyCaptions, RecordSelectionBuffer) then
            exit(FieldCount);

        GetFieldsFromPrimaryKey(TableId, FieldCount, PrimaryKeyCaptions, RecordSelectionBuffer);
        exit(FieldCount);
    end;

    local procedure GetRelatedPageId(TableId: Integer): Integer
    var
        TableMetadata: Record "Table Metadata";
        PageMetadata: Record "Page Metadata";
    begin
        if TableMetadata.Get(TableId) then
            if TableMetadata.LookupPageID <> 0 then
                exit(TableMetadata.LookupPageID)
            else
                if TableMetadata.DrillDownPageId <> 0 then
                    exit(TableMetadata.DrillDownPageId);

        PageMetadata.SetRange(SourceTable, TableId);
        if PageMetadata.FindFirst() then
            exit(PageMetadata.ID);

        exit(0);
    end;

    local procedure GetFieldsFromPage(TableId: Integer; PageId: Integer; var FieldCount: Integer; var PageSummaryCaptions: array[10] of Text; var RecordSelectionBuffer: Record "Record Selection Buffer"): Boolean
    var
        FromRecordRef: RecordRef;
        PageSummaryFieldList: List of [Integer];
    begin
        if not GetPageSummaryFields(PageId, FieldCount, PageSummaryFieldList) then
            exit(false);

        FromRecordRef.Open(TableId);
        if FromRecordRef.FindSet() then
            repeat
                SetRecordRefFieldsFromPageSummaryFields(PageSummaryFieldList, FromRecordRef, RecordSelectionBuffer);
            until FromRecordRef.Next() = 0;

        SetCaptionsFromPageSummary(PageSummaryFieldList, FromRecordRef, PageSummaryCaptions);

        exit(true);
    end;

    local procedure GetPageSummaryFields(PageId: Integer; var FieldCount: Integer; var PageSummaryFieldList: List of [Integer]): Boolean
    var
        GenericList: DotNet GenericList1;
        NavPageSummaryALFunctions: DotNet NavPageSummaryALFunctions;
        PageSummaryField: Integer;
    begin
        if PageId = 0 then
            exit(false);

        GenericList := NavPageSummaryALFunctions.GetSummaryFields(PageId);

        foreach PageSummaryField in GenericList do
            PageSummaryFieldList.Add(PageSummaryField);

        FieldCount := PageSummaryFieldList.Count();
        exit(FieldCount <> 0);
    end;

    local procedure SetRecordRefFieldsFromPageSummaryFields(var PageSummaryFieldList: List of [Integer]; var FromRecordRef: RecordRef; var RecordSelectionBuffer: Record "Record Selection Buffer")
    var
        RecordSelectionBufferRecordRef: RecordRef;
    begin
        RecordSelectionBufferRecordRef.GetTable(RecordSelectionBuffer);
        RecordSelectionBufferRecordRef.Init();

        CopySystemId(FromRecordRef, RecordSelectionBufferRecordRef);
        SetFieldsFromPageSummary(PageSummaryFieldList, FromRecordRef, RecordSelectionBufferRecordRef);

        RecordSelectionBufferRecordRef.SetTable(RecordSelectionBuffer);
        RecordSelectionBufferRecordRef.Reset();
        RecordSelectionBuffer.Insert();
    end;

    local procedure GetFieldsFromPrimaryKey(TableId: Integer; var FieldCount: Integer; var PrimaryKeyCaptions: array[10] of Text; var RecordSelectionBuffer: Record "Record Selection Buffer")
    var
        FromRecordRef: RecordRef;
        KeyRef: KeyRef;
    begin
        FromRecordRef.Open(TableId);
        GetPrimaryKeyFields(FromRecordRef, KeyRef, FieldCount);

        if FromRecordRef.FindSet() then
            repeat
                SetRecordRefFieldsFromPrimaryKeyFields(FieldCount, KeyRef, FromRecordRef, RecordSelectionBuffer);
            until FromRecordRef.Next() = 0;

        SetCaptionsFromKeyRef(FieldCount, KeyRef, PrimaryKeyCaptions);
    end;

    local procedure GetPrimaryKeyFields(var FromRecordRef: RecordRef; var KeyRef: KeyRef; var FieldCount: Integer)
    begin
        KeyRef := FromRecordRef.KeyIndex(FromRecordRef.CurrentKeyIndex());
        FieldCount := GetFieldCount(KeyRef);
    end;

    local procedure SetRecordRefFieldsFromPrimaryKeyFields(FieldCount: Integer; var KeyRef: KeyRef; var FromRecordRef: RecordRef; var RecordSelectionBuffer: Record "Record Selection Buffer")
    var
        RecordSelectionBufferRecordRef: RecordRef;
    begin
        RecordSelectionBufferRecordRef.GetTable(RecordSelectionBuffer);
        RecordSelectionBufferRecordRef.Init();

        CopySystemId(FromRecordRef, RecordSelectionBufferRecordRef);
        SetFieldsFromKeyRef(FieldCount, KeyRef, RecordSelectionBufferRecordRef);

        RecordSelectionBufferRecordRef.SetTable(RecordSelectionBuffer);
        RecordSelectionBufferRecordRef.Reset();
        RecordSelectionBuffer.Insert();
    end;

    local procedure GetFieldCount(KeyRef: KeyRef): Integer
    var
        FieldCount: Integer;
    begin
        FieldCount := KeyRef.FieldCount();

        if FieldCount > MaximumFieldsSupported() then
            FieldCount := MaximumFieldsSupported();

        exit(FieldCount);
    end;

    local procedure CopySystemId(var FromRecordRef: RecordRef; var RecordSelectionBufferRecordRef: RecordRef)
    var
        RecordSelectionBufferFieldRef: FieldRef;
        FromFieldRef: FieldRef;
    begin
        FromFieldRef := FromRecordRef.Field(FromRecordRef.SystemIdNo());
        RecordSelectionBufferFieldRef := RecordSelectionBufferRecordRef.Field(1); // System Id
        RecordSelectionBufferFieldRef.Value(FromFieldRef.Value());
    end;

    local procedure SetFieldsFromPageSummary(var PageSummaryFieldList: List of [Integer]; var FromRecordRef: RecordRef; var RecordSelectionBufferRecordRef: RecordRef)
    var
        RecordSelectionBufferFieldRef: FieldRef;
        FromFieldRef: FieldRef;
        FieldIndex: Integer;
        Index: Integer;
        ValueAsTxt: Text[250];
    begin
        for Index := 1 to PageSummaryFieldList.Count() do begin
            PageSummaryFieldList.Get(Index, FieldIndex);
            FromFieldRef := FromRecordRef.Field(FieldIndex);

            if FromFieldRef.Class = FieldClass::FlowField then
                FromFieldRef.CalcField();

            ValueAsTxt := FromFieldRef.Value();
            RecordSelectionBufferFieldRef := RecordSelectionBufferRecordRef.Field(Index + 1);
            RecordSelectionBufferFieldRef.Value(ValueAsTxt);
        end;
    end;

    local procedure SetCaptionsFromPageSummary(var PageSummaryFieldList: List of [Integer]; var FromRecordRef: RecordRef; var PrimaryKeyCaptions: array[10] of Text)
    var
        FromFieldRef: FieldRef;
        FieldIndex: Integer;
        Index: Integer;
    begin
        for Index := 1 to PageSummaryFieldList.Count() do begin
            PageSummaryFieldList.Get(Index, FieldIndex);
            FromFieldRef := FromRecordRef.Field(FieldIndex);
            PrimaryKeyCaptions[Index] := FromFieldRef.Caption();
        end;
    end;

    local procedure SetFieldsFromKeyRef(FieldCount: Integer; var FromKeyRef: KeyRef; var ToRecordRef: RecordRef)
    var
        ToFieldRef: FieldRef;
        FromFieldRef: FieldRef;
        Index: Integer;
        ValueAsTxt: Text[250];
    begin
        for Index := 1 to FieldCount do begin
            FromFieldRef := FromKeyRef.FieldIndex(Index);

            if FromFieldRef.Class = FieldClass::FlowField then
                FromFieldRef.CalcField();

            ValueAsTxt := FromFieldRef.Value();
            ToFieldRef := ToRecordRef.Field(Index + 1);
            ToFieldRef.Value(ValueAsTxt);
        end;
    end;

    local procedure SetCaptionsFromKeyRef(FieldCount: Integer; FromKeyRef: KeyRef; var PrimaryKeyCaptions: array[10] of Text)
    var
        FromFieldRef: FieldRef;
        Index: Integer;
    begin
        for Index := 1 to FieldCount do begin
            FromFieldRef := FromKeyRef.FieldIndex(Index);
            PrimaryKeyCaptions[Index] := FromFieldRef.Caption();
        end;
    end;

    local procedure MaximumFieldsSupported(): Integer
    begin
        exit(10);
    end;

    var
        OnlyOneRecordMsg: Label 'The table contains only one record, which has been automatically selected.';
        NoRecordsErr: Label 'The selected table does not contain any records.';
        TooManyRecordsErr: Label 'The selected table contains more than %1 records which is not supported.', Comment = '%1 - Number of records';
}

