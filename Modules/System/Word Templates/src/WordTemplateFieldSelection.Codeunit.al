// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 9989 "Word Template Field Selection"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Word Template Field" = rimd,
                  tabledata Field = r;

    var
        CustomMergeFieldTok: Label 'CALC_%1', Locked = true;

    procedure SetExcludedFields(WordTemplateCode: Code[30]; TableId: Integer; ExcludeFieldNames: List of [Text[30]])
    var
        Field: Record Field;
        WordTemplateField: Record "Word Template Field";
        ExcludeFieldName: Text[30];
    begin
        WordTemplateField.SetRange("Word Template Code", WordTemplateCode);
        WordTemplateField.SetRange("Table ID", TableId);
        WordTemplateField.DeleteAll();

        foreach ExcludeFieldName in ExcludeFieldNames do begin
            WordTemplateField.Init();
            WordTemplateField."Word Template Code" := WordTemplateCode;
            WordTemplateField."Table ID" := TableId;
            WordTemplateField."Field Name" := ExcludeFieldName;

            Field.SetRange(TableNo, TableId);
            Field.SetRange(FieldName, ExcludeFieldName);
            if field.FindFirst() then
                WordTemplateField."Field No." := Field."No.";

            WordTemplateField.Insert();
        end;
    end;

    procedure SetIncludeFields(WordTemplateCode: Code[30]; TableId: Integer; IncludeFieldNames: List of [Text[30]]; var WordTemplateField: Record "Word Template Field")
    var
        Field: Record Field;
        IncludeFieldName: Text[30];
    begin
        foreach IncludeFieldName in IncludeFieldNames do
            if WordTemplateField.Get(WordTemplateCode, TableId, IncludeFieldName) then begin
                WordTemplateField.Exclude := false;
                WordTemplateField.Modify();
            end else begin
                WordTemplateField.Init();
                WordTemplateField."Word Template Code" := WordTemplateCode;
                WordTemplateField."Table ID" := TableId;
                WordTemplateField."Field Name" := IncludeFieldName;
                WordTemplateField.Exclude := false;

                Field.SetRange(TableNo, TableId);
                Field.SetRange(FieldName, IncludeFieldName);
                if field.FindFirst() then
                    WordTemplateField."Field No." := Field."No.";
                WordTemplateField.Insert();
            end;
    end;

    procedure GetExcludedFields(WordTemplateCode: Code[30]; TableId: Integer) ExcludedFieldNames: List of [Text[30]]
    var
        WordTemplateField: Record "Word Template Field";
    begin
        WordTemplateField.SetRange("Word Template Code", WordTemplateCode);
        WordTemplateField.SetRange("Table ID", TableId);
        if WordTemplateField.FindSet() then
            repeat
                ExcludedFieldNames.Add(WordTemplateField."Field Name");
            until WordTemplateField.Next() = 0;
    end;

    procedure GetCustomTableFields(TableId: Integer) CustomTableFieldNames: List of [Text[30]]
    var
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        WordTemplateCustomField: Codeunit "Word Template Custom Field";
        WordTemplate: Codeunit "Word Template";
    begin
        WordTemplateCustomField.SetCurrentTableId(TableId);
        WordTemplate.OnGetCustomFieldNames(WordTemplateCustomField);
        WordTemplateCustomField.GetCustomFields(TempWordTemplateCustomField);
        if TempWordTemplateCustomField.FindSet() then
            repeat
                CustomTableFieldNames.Add(StrSubstNo(CustomMergeFieldTok, TempWordTemplateCustomField.Name));
            until TempWordTemplateCustomField.Next() = 0;
    end;

    procedure GetSupportedTableFields(TableId: Integer) FieldNames: List of [Text[30]]
    var
        Field: Record Field;
    begin
        Field.SetRange(TableNo, TableId);
        if Field.FindSet() then
            repeat
                if IsFieldSupported(Field) then
                    FieldNames.Add(Field.FieldName);
            until Field.Next() = 0;
    end;

    procedure SelectDefaultFieldsForTable(WordTemplateCode: Code[30]; TableId: Integer; var WordTemplateField: Record "Word Template Field")
    var
        Field: Record Field;
    begin
        // By default exclude everything except text fields, the primary key and custom fields
        WordTemplateField.Reset();
        WordTemplateField.SetRange("Word Template Code", WordTemplateCode);
        WordTemplateField.SetRange("Table ID", TableId);
        WordTemplateField.DeleteAll();

        Field.SetRange(TableNo, TableId);
        if Field.FindSet() then
            repeat
                WordTemplateField."Word Template Code" := WordTemplateCode;
                WordTemplateField."Table ID" := TableId;
                WordTemplateField."Field Name" := Field.FieldName;
                WordTemplateField."Field No." := Field."No.";
                WordTemplateField.Exclude := true;
                if (Field.Type = Field.Type::Text) or Field.IsPartOfPrimaryKey then
                    WordTemplateField.Exclude := false;
                WordTemplateField.Insert();
            until Field.Next() = 0;
    end;

    procedure IsFieldSupported(Field: Record Field): Boolean
    begin
        exit(not (Field.Type in [Field.Type::Media, Field.Type::MediaSet]));
    end;

    procedure TableUsesDefaultFields(WordTemplateCode: Code[30]; TableId: Integer; var WordTemplateField: Record "Word Template Field"): Boolean
    begin
        WordTemplateField.Reset();
        WordTemplateField.SetRange("Word Template Code", WordTemplateCode);
        WordTemplateField.SetRange("Table ID", TableId);
        exit(WordTemplateField.IsEmpty());
    end;

    procedure IsCustomFieldSelected(WordTemplateCode: Code[30]; TableId: Integer; FieldName: Text[30]; var WordTemplateField: Record "Word Template Field"): Boolean
    begin
        WordTemplateField.Reset();
        WordTemplateField.SetRange("Word Template Code", WordTemplateCode);
        WordTemplateField.SetRange("Table ID", TableId);
        if WordTemplateField.IsEmpty() then
            exit(true); // If no fields are selected, then custom fields are selected by default
        WordTemplateField.SetRange("Field Name", FieldName);
        exit(not (WordTemplateField.FindFirst() and WordTemplateField.Exclude));
    end;

    procedure CalculateNoSelectedFields(TableId: Integer; var TempWordTemplateField: Record "Word Template Field" temporary): Integer
    var
        Field: Record Field;
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        WordTemplate: Codeunit "Word Template";
        WordTemplateCustomField: Codeunit "Word Template Custom Field";
        TableFields: Integer;
        CustomTableFields: Integer;
        ExcludedFields: Integer;
    begin
        Field.SetRange(TableNo, TableId);
        TableFields := Field.Count();

        WordTemplateCustomField.SetCurrentTableId(TableId);
        WordTemplate.OnGetCustomFieldNames(WordTemplateCustomField);
        WordTemplateCustomField.GetCustomFields(TempWordTemplateCustomField);
        CustomTableFields := TempWordTemplateCustomField.Count();

        TempWordTemplateField.Reset();
        TempWordTemplateField.SetRange("Table ID", TableId);
        TempWordTemplateField.SetRange(Exclude, true);
        ExcludedFields := TempWordTemplateField.Count();

        exit(TableFields + CustomTableFields - ExcludedFields);
    end;

    procedure GetAllTableFields(TableId: Integer; var TempWordTemplateField: Record "Word Template Field" temporary)
    var
        Field: Record Field;
        TempWordTemplateCustomField: Record "Word Template Custom Field" temporary;
        WordTemplate: Codeunit "Word Template";
        WordTemplateCustomField: Codeunit "Word Template Custom Field";
    begin
        TempWordTemplateField.Reset();
        TempWordTemplateField.SetRange("Table ID", TableId);
        TempWordTemplateField.DeleteAll();

        // Add existing table fields
        Field.SetRange(TableNo, TableId);
        if Field.FindSet() then
            repeat
                if IsFieldSupported(Field) then begin
                    TempWordTemplateField."Table ID" := TableId;
                    TempWordTemplateField."Field Name" := Field.FieldName;
                    TempWordTemplateField."Field No." := Field."No.";
                    TempWordTemplateField.Insert();
                end
            until Field.Next() = 0;

        // Add custom fields
        WordTemplateCustomField.SetCurrentTableId(TableId);
        WordTemplate.OnGetCustomFieldNames(WordTemplateCustomField);
        WordTemplateCustomField.GetCustomFields(TempWordTemplateCustomField);
        if TempWordTemplateCustomField.FindSet() then
            repeat
                TempWordTemplateField.Init();
                TempWordTemplateField."Table ID" := TableId;
                TempWordTemplateField."Field Name" := StrSubstNo(CustomMergeFieldTok, TempWordTemplateCustomField.Name);
                TempWordTemplateField.Insert();
            until TempWordTemplateCustomField.Next() = 0;
    end;

    procedure ApplyChangesTo(TableId: Integer; var FromTempWordTemplateField: Record "Word Template Field" temporary; var ToTempWordTemplateField: Record "Word Template Field" temporary)
    begin
        ToTempWordTemplateField.Reset();
        ToTempWordTemplateField.SetRange("Table ID", TableId);
        ToTempWordTemplateField.DeleteAll();

        FromTempWordTemplateField.Reset();
        FromTempWordTemplateField.SetRange("Table ID", TableId);
        if FromTempWordTemplateField.FindSet() then
            repeat
                ToTempWordTemplateField := FromTempWordTemplateField;
                ToTempWordTemplateField.Insert();
            until FromTempWordTemplateField.Next() = 0;
    end;

    procedure CopyExcludeFields(TableId: Integer; var FromTempWordTemplateField: Record "Word Template Field" temporary; var ToTempWordTemplateField: Record "Word Template Field" temporary)
    var
        FieldsSelectionIsSetup: Boolean;
    begin
        FromTempWordTemplateField.Reset();
        FromTempWordTemplateField.SetRange("Table ID", TableId);
        FieldsSelectionIsSetup := FromTempWordTemplateField.FindSet();
        if FieldsSelectionIsSetup then
            repeat
                if ToTempWordTemplateField.Get(FromTempWordTemplateField."Word Template Code", FromTempWordTemplateField."Table ID", FromTempWordTemplateField."Field Name") then begin
                    ToTempWordTemplateField.Exclude := FromTempWordTemplateField.Exclude;
                    ToTempWordTemplateField.Modify();
                end;
            until FromTempWordTemplateField.Next() = 0
        else
            SelectLegacyDefaultFieldsForTable(TableId, ToTempWordTemplateField);
    end;

    procedure ShowFieldSelection(TableId: Integer; var TempWordTemplateField: Record "Word Template Field" temporary)
    var
        WordTemplatesFieldSelection: Page "Word Templates Field Selection";
    begin
        WordTemplatesFieldSelection.SetTemporaryFieldSelection(TableId, TempWordTemplateField);
        WordTemplatesFieldSelection.LookupMode(true);
        if WordTemplatesFieldSelection.RunModal() <> Action::LookupOK then
            exit;

        WordTemplatesFieldSelection.ApplyChangesTo(TempWordTemplateField);
    end;

    local procedure SelectLegacyDefaultFieldsForTable(TableId: Integer; var TempWordTemplateField: Record "Word Template Field" temporary)
    var
        Field: Record Field;
    begin
        // For existing word templates we need to include the old default fields to avoid breaking anything
        TempWordTemplateField.Reset();
        TempWordTemplateField.SetRange("Word Template Code", '');
        TempWordTemplateField.SetRange("Table ID", TableId);
        TempWordTemplateField.DeleteAll();

        Field.SetRange(TableNo, TableId);
        if Field.FindSet() then
            repeat
                TempWordTemplateField."Word Template Code" := '';
                TempWordTemplateField."Table ID" := TableId;
                TempWordTemplateField."Field Name" := Field.FieldName;
                TempWordTemplateField."Field No." := Field."No.";
                TempWordTemplateField.Exclude := false;
                if not IsFieldSupported(Field) then
                    TempWordTemplateField.Exclude := true;
                if (Field.Class = Field.Class::FlowFilter) or (Field.Type in [Field.Type::BLOB, Field.Type::Media, Field.Type::MediaSet, Field.Type::RecordID, Field.Type::TableFilter]) then
                    TempWordTemplateField.Exclude := true;
                TempWordTemplateField.Insert();
            until Field.Next() = 0;
    end;
}