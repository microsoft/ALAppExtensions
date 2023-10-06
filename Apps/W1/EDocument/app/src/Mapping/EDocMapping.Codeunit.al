// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.IO;

codeunit 6118 "E-Doc. Mapping"
{
    Access = Internal;
    Permissions =
        tabledata "E-Doc. Mapping" = im,
        tabledata "E-Doc. Mapping Log" = im;

    procedure SetFirstRun()
    begin
        FirstMapping := true;
    end;

    procedure SetLineNo(NewLineNo: Integer)
    begin
        LineNo := NewLineNo;
    end;

    procedure MapRecord(var EDocumentMapping: Record "E-Doc. Mapping"; RecordSource: RecordRef; var TempRecordTarget: RecordRef)
    var
        TempEDocMapping: Record "E-Doc. Mapping" temporary;
    begin
        MapRecord(EDocumentMapping, RecordSource, TempRecordTarget, TempEDocMapping);
    end;

    procedure MapRecord(var EDocumentMapping: Record "E-Doc. Mapping"; RecordSource: RecordRef; var TempRecordTarget: RecordRef; var TempEDocMapping: Record "E-Doc. Mapping" temporary)
    begin
        if not TempRecordTarget.IsTemporary() then
            Error(NonTempRecordErr);

        TempRecordTarget.Copy(RecordSource);

        // Map specific tables and fields
        EDocumentMapping.SetRange("Table ID", RecordSource.Number());
        EDocumentMapping.SetFilter("Field ID", '<>0');
        if EDocumentMapping.FindSet() then
            repeat
                MapSpecificField(EDocumentMapping, TempRecordTarget, TempEDocMapping);
            until EDocumentMapping.Next() = 0;

        // Map any field on specific table 
        EDocumentMapping.SetFilter("Field ID", '=0');
        if EDocumentMapping.FindSet() then
            repeat
                Map(EDocumentMapping, TempRecordTarget, TempEDocMapping);
            until EDocumentMapping.Next() = 0;

        // Map generics
        EDocumentMapping.SetRange("Table ID", 0);
        EDocumentMapping.SetRange("Field ID", 0);
        if EDocumentMapping.FindSet() then
            repeat
                Map(EDocumentMapping, TempRecordTarget, TempEDocMapping);
            until EDocumentMapping.Next() = 0;

        TempRecordTarget.Insert();
        SetLineNo(0);
    end;

    procedure PreviewMapping(Header: Variant; Lines: Variant; LineNoFieldId: Integer)
    var
        TempHeaderChanges, TempLineChanges : Record "E-Doc. Mapping" temporary;
        EDocService: Record "E-Document Service";
        EDocMappingRecord: Record "E-Doc. Mapping";
        EDocMapping: Codeunit "E-Doc. Mapping";
        EDocServicesPage: Page "E-Document Services";
        EDocChangesPreview: Page "E-Doc. Changes Preview";
        SourceDocumentHeader, SourceDocumentLine, SourceDocumentHeaderMapped, SourceDocumentLineMapped : RecordRef;
    begin
        EDocServicesPage.LookupMode(true);
        if EDocServicesPage.RunModal() <> Action::LookupOK then
            exit;
        EDocServicesPage.GetRecord(EDocService);

        SourceDocumentHeader.GetTable(Header);
        SourceDocumentLine.GetTable(Lines);

        SourceDocumentHeaderMapped.Open(SourceDocumentHeader.Number(), true);
        SourceDocumentLineMapped.Open(SourceDocumentLine.Number(), true);

        EDocMappingRecord.SetRange(Code, EDocService.Code);
        EDocMappingRecord.ModifyAll(Used, false);
        EDocMapping.MapRecord(EDocMappingRecord, SourceDocumentHeader, SourceDocumentHeaderMapped, TempHeaderChanges);

        if SourceDocumentLine.FindSet() then
            repeat
                EDocMapping.SetFirstRun();
                EDocMapping.SetLineNo(SourceDocumentLine.Field(LineNoFieldId).Value());
                EDocMapping.MapRecord(EDocMappingRecord, SourceDocumentLine, SourceDocumentLineMapped, TempLineChanges);
            until SourceDocumentLine.Next() = 0;

        EDocMappingRecord.Reset();
        EDocMappingRecord.SetRange(Used, true);
        EDocMappingRecord.SetRange(Code, EDocService.Code);
        EDocMappingRecord.FindSet();

        EDocChangesPreview.SetRecord(EDocMappingRecord);
        EDocChangesPreview.SetHeaderChanges(TempHeaderChanges);
        EDocChangesPreview.SetLineChanges(TempLineChanges);
        EDocChangesPreview.Run();
    end;

    local procedure MapSpecificField(DocumentMapping: Record "E-Doc. Mapping"; var RecordTarget: RecordRef; var TempEDocMapping: Record "E-Doc. Mapping" temporary)
    begin
        if ValidateFieldRef(RecordTarget.Field(DocumentMapping."Field ID")) then
            Transform(DocumentMapping, DocumentMapping."Field ID", RecordTarget, TempEDocMapping);
    end;

    local procedure Map(DocumentMapping: Record "E-Doc. Mapping"; var RecordTarget: RecordRef; var TempEDocMapping: Record "E-Doc. Mapping" temporary)
    var
        FieldRef: FieldRef;
        Index: Integer;
    begin
        for Index := 1 to RecordTarget.FieldCount() do begin
            FieldRef := RecordTarget.FieldIndex(Index);
            if ValidateFieldRef(FieldRef) then
                Transform(DocumentMapping, FieldRef.Number(), RecordTarget, TempEDocMapping);
        end;
    end;

    local procedure Transform(DocumentMapping: Record "E-Doc. Mapping"; FieldSourceID: Integer; var RecordTarget: RecordRef; var TempEDocMapping: Record "E-Doc. Mapping" temporary)
    var
        TransformationRule: Record "Transformation Rule";
        FieldRef: FieldRef;
        CurrentValue, NewValue : Text;
    begin
        FieldRef := RecordTarget.Field(FieldSourceID);
        CurrentValue := FieldRef.Value();
        if DocumentMapping."Transformation Rule" <> '' then begin
            TransformationRule.Get(DocumentMapping."Transformation Rule");
            NewValue := TransformationRule.TransformText(CurrentValue);
        end else
            if DocumentMapping."Find Value" = CurrentValue then
                NewValue := DocumentMapping."Replace Value";

        if NewValue <> '' then begin
            TempEDocMapping.Init();
            TempEDocMapping.Code := 'EDOC_TEMP_MAPPING';
            TempEDocMapping."Entry No." := EntryNo;
            TempEDocMapping."Table ID" := RecordTarget.Number();
            TempEDocMapping."Field ID" := FieldSourceID;
            TempEDocMapping."Find Value" := CopyStr(CurrentValue, 1, 250);
            TempEDocMapping."Replace Value" := CopyStr(NewValue, 1, 250);
            TempEDocMapping."Transformation Rule" := DocumentMapping."Transformation Rule";
            TempEDocMapping."Line No." := LineNo;

            if FirstMapping then
                TempEDocMapping.Indent := 0
            else
                TempEDocMapping.Indent := 1;
            FirstMapping := false;

            EntryNo := EntryNo + 1;
            TempEDocMapping.Insert();

            // Map field
            RecordTarget.Field(FieldSourceID).Value := NewValue;

            // Record rule as used
            DocumentMapping.Used := true;
            DocumentMapping.Modify();
        end
    end;

    local procedure ValidateFieldRef(FieldRef: FieldRef): Boolean
    begin
        if FieldRef.Class <> FieldRef.Class::Normal then
            exit(false);
        if (FieldRef.Type <> FieldRef.Type::Text) and (FieldRef.Type <> FieldRef.Type::Code) then
            exit(false);
        exit(true);
    end;

    var
        FirstMapping: Boolean;
        LineNo: Integer;
        EntryNo: Integer;
        NonTempRecordErr: Label 'Mapping of record can only be applied to temporary record';
}
