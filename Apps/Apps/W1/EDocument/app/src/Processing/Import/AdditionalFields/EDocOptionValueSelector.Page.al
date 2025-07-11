// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;
using Microsoft.Utilities;
using System.Reflection;

page 6109 "E-Doc. Option Value Selector"
{
    Caption = 'Select value';
    SourceTable = "Name/Value Buffer";
    SourceTableTemporary = true;
    PageType = List;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Values)
            {
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                    Caption = 'Value';
                    ToolTip = 'Specifies the value of the field.';
                    Editable = false;
                }
            }
        }
    }

    var
        Selected: Record "Name/Value Buffer";
        FieldToEdit: Record Field;
        OrdinalValuesSystemIds: Dictionary of [Text, Guid];
        FieldOptionTypes: Option TableRelation,Option;
        NoAvailableValuesErr: Label 'No available values to select from.';

    trigger OnOpenPage()
    begin
        case FieldOptionType() of
            FieldOptionTypes::TableRelation:
                AddFieldsFromRelatedTable();
            FieldOptionTypes::Option:
                AddFieldsFromOption();
        end;

        if not Rec.FindFirst() then
            Error(NoAvailableValuesErr);
    end;

    local procedure FieldOptionType(): Option
    begin
        if FieldToEdit.RelationTableNo <> 0 then
            exit(FieldOptionTypes::TableRelation);
        if FieldToEdit.Type = FieldToEdit.Type::Option then
            exit(FieldOptionTypes::Option);
    end;

    local procedure AddFieldsFromRelatedTable()
    var
        RecordRef: RecordRef;
        KeyRef: KeyRef;
        RecordDescription: Text;
        i, j : Integer;
    begin
        RecordRef.Open(FieldToEdit.RelationTableNo);
        if not RecordRef.FindSet() then
            exit;
        i := 1;
        repeat
            RecordDescription := '';
            KeyRef := RecordRef.KeyIndex(RecordRef.CurrentKeyIndex);
            for j := 1 to KeyRef.FieldCount() do begin
                if RecordDescription <> '' then
                    RecordDescription += ' - ';
                RecordDescription += Format(KeyRef.FieldIndex(j).Value());
            end;
            Rec.AddNewEntry(Format(i), RecordDescription);
            OrdinalValuesSystemIds.Add(Format(i), RecordRef.Field(RecordRef.SystemIdNo).Value());
            i += 1;
        until RecordRef.Next() = 0;
    end;

    local procedure AddFieldsFromOption()
    var
        OptionValue: Text;
        i: Integer;
    begin
        i := 1;
        foreach OptionValue in FieldToEdit.OptionString.Split(',') do begin
            Rec.AddNewEntry(Format(i), OptionValue);
            i += 1;
        end;
    end;

    internal procedure SetFieldToSelect(Field: Record Field)
    begin
        FieldToEdit := Field;
    end;

    internal procedure GetSelectedValue(): Variant
    var
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        OrdinalValue: Integer;
    begin
        case FieldOptionType() of
            FieldOptionTypes::TableRelation:
                begin
                    RecordRef.Open(FieldToEdit.RelationTableNo);
                    if OrdinalValuesSystemIds.ContainsKey(Selected.Name) then
                        if RecordRef.GetBySystemId(OrdinalValuesSystemIds.Get(Selected.Name)) then
                            if FieldToEdit.RelationFieldNo <> 0 then
                                exit(RecordRef.Field(FieldToEdit.RelationFieldNo).Value())
                            else
                                exit(RecordRef.KeyIndex(RecordRef.CurrentKeyIndex).FieldIndex(1).Value());
                end;
            FieldOptionTypes::Option:
                begin
                    RecordRef.Open(FieldToEdit.TableNo);
                    FieldRef := RecordRef.Field(FieldToEdit."No.");
                    Evaluate(OrdinalValue, Selected.Name);
                    exit(FieldRef.GetEnumValueOrdinal(OrdinalValue));
                end;
        end;
    end;

    internal procedure GetSelectedValueAsText(): Text[2048]
    begin
        case FieldOptionType() of
            FieldOptionTypes::TableRelation:
                exit(Format(GetSelectedValue()));
            FieldOptionTypes::Option:
                exit(Selected.Value);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction <> action::LookupOK then
            exit(true);
        CurrPage.SetSelectionFilter(Rec);
        if Rec.FindFirst() then
            Selected := Rec;
    end;

}