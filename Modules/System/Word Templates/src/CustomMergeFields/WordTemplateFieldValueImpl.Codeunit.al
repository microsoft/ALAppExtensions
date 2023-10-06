// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration.Word;

/// <summary>
/// Defines the implementation for adding custom field values
/// </summary>
codeunit 9984 "Word Template Field Value Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        CurrentRecord: RecordRef;
        CurrentRelatedTableCode: Code[5];
        CannotAddCustomFieldValueErr: Label 'Trying to add custom field %1, however it was not prepared for merge!', Comment = '%1 is the name of a custom field';

    internal procedure Initialize(var NewTempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    begin
        TempWordTemplateCustomField.Copy(NewTempWordTemplateCustomField, true);
    end;

    internal procedure SetCurrentRecord(RecordRef: RecordRef; RelatedTableCode: Code[5])
    begin
        CurrentRecord := RecordRef;
        CurrentRelatedTableCode := RelatedTableCode;
        TempWordTemplateCustomField.SetRange("Related Table Code", RelatedTableCode);
        TempWordTemplateCustomField.ModifyAll(Value, '');
    end;

    internal procedure GetCurrentCustomValues(var CurrentTempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    begin
        CurrentTempWordTemplateCustomField.Copy(TempWordTemplateCustomField, true);
    end;

    procedure GetRecord(): RecordRef
    begin
        exit(CurrentRecord);
    end;

    procedure AddField(CustomFieldName: Text; CustomFieldValue: Text[2048])
    begin
        if not TempWordTemplateCustomField.Get(CurrentRelatedTableCode, CustomFieldName) then
            Error(CannotAddCustomFieldValueErr, CustomFieldName);

        TempWordTemplateCustomField.Value := CustomFieldValue;
        TempWordTemplateCustomField.Modify();
    end;
}