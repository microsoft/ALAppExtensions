// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Processing.Import;
using System.Reflection;
using Microsoft.Purchases.History;

page 6107 "E-Doc. Field Value Edit"
{
    Caption = 'Edit value';
    PageType = Card;
    Extensible = false;

    layout
    {
        area(Content)
        {
            field("Previous value"; PreviousValue)
            {
                ApplicationArea = All;
                Caption = 'Previous value';
                ToolTip = 'Specifies the previous value of the field.';
                Editable = false;
            }
            field("New value (Text)"; TextValue)
            {
                ApplicationArea = All;
                Caption = 'New value';
                ToolTip = 'Specifies the new value of the field.';
                Visible = (FieldType = Field.Type::Text) or (FieldType = Field.Type::Option);
                Editable = FieldType <> Field.Type::Option;

                trigger OnValidate()
                begin
                    Edited := true;
                    if FieldType = Field.Type::Text then
                        EDocPurchLineField."Text Value" := TextValue;
                end;

                trigger OnAssistEdit()
                var
                    EDocOptionValueSelector: Page "E-Doc. Option Value Selector";
                begin
                    if FieldType <> Field.Type::Option then
                        exit;
                    EDocOptionValueSelector.SetFieldToSelect(Field);
                    EDocOptionValueSelector.LookupMode(true);
                    if EDocOptionValueSelector.RunModal() = Action::LookupOK then begin
                        Edited := true;
                        TextValue := EDocOptionValueSelector.GetSelectedValueAsText();
                        EDocPurchLineField."Integer Value" := EDocOptionValueSelector.GetSelectedValue();
                    end;
                end;
            }
            field("New value (Decimal)"; EDocPurchLineField."Decimal Value")
            {
                ApplicationArea = All;
                Caption = 'New value';
                ToolTip = 'Specifies the new value of the field.';
                Visible = FieldType = Field.Type::Decimal;

                trigger OnValidate()
                begin
                    Edited := true;
                end;
            }
            field("New value (Date)"; EDocPurchLineField."Date Value")
            {
                ApplicationArea = All;
                Caption = 'New value';
                ToolTip = 'Specifies the new value of the field.';
                Visible = FieldType = Field.Type::Date;

                trigger OnValidate()
                begin
                    Edited := true;
                end;
            }
            field("New value (Boolean)"; EDocPurchLineField."Boolean Value")
            {
                ApplicationArea = All;
                Caption = 'New value';
                ToolTip = 'Specifies the new value of the field.';
                Visible = FieldType = Field.Type::Boolean;

                trigger OnValidate()
                begin
                    Edited := true;
                end;
            }
            field("New value (Code)"; EDocPurchLineField."Code Value")
            {
                ApplicationArea = All;
                Caption = 'New value';
                ToolTip = 'Specifies the new value of the field.';
                Visible = FieldType = Field.Type::Code;
                Editable = not FieldWithRelation;

                trigger OnValidate()
                begin
                    Edited := true;
                end;

                trigger OnAssistEdit()
                var
                    EDocOptionValueSelector: Page "E-Doc. Option Value Selector";
                begin
                    if not FieldWithRelation then
                        exit;
                    EDocOptionValueSelector.SetFieldToSelect(Field);
                    EDocOptionValueSelector.LookupMode(true);
                    if EDocOptionValueSelector.RunModal() = Action::LookupOK then begin
                        Edited := true;
                        EDocPurchLineField."Code Value" := EDocOptionValueSelector.GetSelectedValue();
                    end;
                    CurrPage.Update();
                end;
            }
            field("New value (Integer)"; EDocPurchLineField."Integer Value")
            {
                ApplicationArea = All;
                Caption = 'New value';
                ToolTip = 'Specifies the new value of the field.';
                Visible = FieldType = Field.Type::Integer;
                Editable = not FieldWithRelation;

                trigger OnValidate()
                begin
                    Edited := true;
                end;

                trigger OnAssistEdit()
                var
                    EDocOptionValueSelector: Page "E-Doc. Option Value Selector";
                begin
                    if not FieldWithRelation then
                        exit;
                    EDocOptionValueSelector.SetFieldToSelect(Field);
                    EDocOptionValueSelector.LookupMode(true);
                    if EDocOptionValueSelector.RunModal() = Action::LookupOK then begin
                        Edited := true;
                        EDocPurchLineField."Integer Value" := EDocOptionValueSelector.GetSelectedValue();
                    end;
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Field.Get(Database::"Purch. Inv. Line", EDocPurchLineField."Field No.") then
            Error('');
        PreviousValue := EDocPurchLineField.GetValueAsText();
        FieldType := Field.Type;
        FieldWithRelation := Field.RelationTableNo <> 0;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if (not Edited) or (CloseAction <> Action::LookupOK) then
            exit(true);
        EDocPurchLineField.InsertOrModify();
        exit(true);
    end;

    var
        EDocPurchLineField: Record "E-Document Line - Field";
        Field: Record Field;
        TextValue: Text[2048];
        PreviousValue: Text;
        FieldType: Option;
        Edited, FieldWithRelation : Boolean;

    internal procedure SetValueToEdit(NewEDocPurchLineField: Record "E-Document Line - Field")
    begin
        EDocPurchLineField := NewEDocPurchLineField;
    end;
}