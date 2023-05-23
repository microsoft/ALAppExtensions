// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// A list page to view and edit fields included in the Word Template for a specific Word Template
/// </summary>
page 9992 "Word Templates Field Selection"
{
    Caption = 'Field Selection';
    PageType = List;
    SourceTable = "Word Template Field";
    SourceTableTemporary = true;
    Extensible = false;
    SourceTableView = sorting("Field No.") order(ascending);
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Tables)
            {
                field(FieldNo; Rec."Field No.")
                {
                    ApplicationArea = All;
                    Caption = 'Field Number';
                    ToolTip = 'Number of the field that will be included in the Word Template.';
                    Editable = false;
                    BlankZero = true;
                }
                field(FieldName; Rec."Field Name")
                {
                    ApplicationArea = All;
                    Caption = 'Field Name';
                    ToolTip = 'Name of the field that will be included in the Word Template.';
                    Editable = false;
                }
                field(FieldTypeField; FieldType)
                {
                    ApplicationArea = All;
                    Caption = 'Field Type';
                    ToolTip = 'Type of the field that will be included in the Word Template.';
                    Editable = false;
                }
                field(Included; Included)
                {
                    ApplicationArea = All;
                    Caption = 'Include';
                    ToolTip = 'Specifies if this field is included in the Word Template.';

                    trigger OnValidate()
                    begin
                        Rec.Exclude := not Included;
                        Rec.Modify();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(IncludeSelection)
            {
                ApplicationArea = All;
                Caption = 'Mark as included';
                ToolTip = 'Includes the selected fields in the template.';
                Image = Add;

                trigger OnAction()
                var
                    TempWordTemplateFieldCopy: Record "Word Template Field" temporary;
                begin
                    TempWordTemplateFieldCopy.Copy(Rec, true);
                    CurrPage.SetSelectionFilter(TempWordTemplateFieldCopy);
                    TempWordTemplateFieldCopy.ModifyAll(Exclude, false);
                end;
            }
            action(ExcludeSelection)
            {
                ApplicationArea = All;
                Caption = 'Mark as excluded';
                ToolTip = 'Excludes the selected fields in the template.';
                Image = Reject;

                trigger OnAction()
                var
                    TempWordTemplateFieldCopy: Record "Word Template Field" temporary;
                begin
                    TempWordTemplateFieldCopy.Copy(Rec, true);
                    CurrPage.SetSelectionFilter(TempWordTemplateFieldCopy);
                    TempWordTemplateFieldCopy.ModifyAll(Exclude, true);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(IncludeSelection_Promoted; IncludeSelection)
                {
                }
                actionref(ExcludeSelection_Promoted; ExcludeSelection)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        Field: Record Field;
    begin
        Included := not Rec.Exclude;

        if Field.Get(Rec."Table ID", Rec."Field No.") then
            FieldType := format(Field.Type)
        else
            FieldType := CustomFieldTypeTxt;
    end;

    internal procedure ApplyChangesTo(var TempWordTemplateField: Record "Word Template Field" temporary)
    begin
        WordTemplateFieldSelection.ApplyChangesTo(Rec."Table ID", Rec, TempWordTemplateField);
    end;

    internal procedure SetTemporaryFieldSelection(TableId: Integer; var TempWordTemplateField: Record "Word Template Field" temporary)
    begin
        WordTemplateFieldSelection.GetAllTableFields(TableId, Rec);
        WordTemplateFieldSelection.CopyExcludeFields(TableId, TempWordTemplateField, Rec);
        Rec.SetCurrentKey("Field No.");
        if Rec.FindFirst() then;
    end;

    var
        WordTemplateFieldSelection: Codeunit "Word Template Field Selection";
        [InDataSet]
        Included: Boolean;
        [InDataSet]
        FieldType: Text;
        CustomFieldTypeTxt: Label 'Calculated';
}