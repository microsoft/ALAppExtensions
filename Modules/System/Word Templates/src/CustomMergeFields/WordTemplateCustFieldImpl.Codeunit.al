// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Defines the implementation for adding custom fields
/// </summary>
codeunit 9982 "Word Template Cust. Field Impl"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        TableId: Integer;
        RelatedTableCode: Code[5];
        CustomFieldAlreadyExistErr: Label 'The custom field %1 already exists.', Comment = '%1 = the name of a custom field.';

    procedure SetCurrentTableId(NewTableId: Integer; NewRelatedTableCode: Code[5])
    begin
        TableId := NewTableId;
        RelatedTableCode := NewRelatedTableCode;
    end;

    procedure GetCustomFields(var CurrentTempWordTemplateCustomField: Record "Word Template Custom Field" temporary)
    begin
        CurrentTempWordTemplateCustomField.Copy(TempWordTemplateCustomField, true);
        CurrentTempWordTemplateCustomField.Reset(); // Clear any filters that may have been applied to TempWordTemplateCustomField
    end;

    procedure GetTableID(): Integer
    begin
        exit(TableId);
    end;

    procedure AddField(CustomFieldName: Text[20])
    begin
        TempWordTemplateCustomField.Reset();
        TempWordTemplateCustomField.SetRange("Related Table Code", RelatedTableCode);
        TempWordTemplateCustomField.SetRange(Name, CustomFieldName);
        if not TempWordTemplateCustomField.IsEmpty() then
            Error(CustomFieldAlreadyExistErr, CustomFieldName);

        TempWordTemplateCustomField.Init();
        TempWordTemplateCustomField.Name := CustomFieldName;
        TempWordTemplateCustomField."Related Table Code" := RelatedTableCode;
        TempWordTemplateCustomField.Insert();
    end;
}