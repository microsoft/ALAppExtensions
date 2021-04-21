page 20335 "Tax Insert Record Subform"
{
    Caption = 'Insert Record Field Mapping';
    PageType = ListPart;
    DataCaptionExpression = '';
    DeleteAllowed = true;
    ShowFilter = false;
    PopulateAllFields = true;
    SourceTable = "Tax Insert Record Field";
    SourceTableView = SORTING("Sequence No.", "Field ID");
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sequence of Insert record.';
                }
                field(TableFieldName; TableFieldName2)
                {
                    Caption = 'Field';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field name of Insert record.';
                    LookupPageID = "Field Lookup";
                    Lookup = true;
                    trigger OnValidate();
                    begin
                        AppObjectHelper.SearchTableField(Rec."Table ID", Rec."Field ID", TableFieldName2);
                        Rec.Validate("Field ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        AppObjectHelper.OpenFieldLookup(Rec."Table ID", Rec."Field ID", TableFieldName2, Text);
                        Rec.Validate("Field ID");
                    end;
                }
                field(FieldValue; FieldValue2)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of field mapping.';
                    trigger OnValidate();
                    var
                        FieldDatatype: Enum "Symbol Data Type";
                    begin
                        FieldDatatype := ScriptDataTypeMgmt.GetFieldDatatype(Rec."Table ID", Rec."Field ID");
                        if LookupMgmt.ConvertLookupToConstant(Rec."Case ID", Rec."Script ID", Rec."Value Type", Rec.Value, Rec."Lookup ID", FieldValue2, FieldDatatype) then
                            Rec.Validate(Value);

                        FormatLine();
                    end;

                    trigger OnAssistEdit();

                    var
                        FieldDatatype: Enum "Symbol Data Type";
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            Rec."Case ID",
                            Rec."Script ID",
                            Rec."Value Type",
                            Rec.Value,
                            Rec."Lookup ID")
                        then begin
                            Commit();

                            FieldDatatype := ScriptDataTypeMgmt.GetFieldDatatype(Rec."Table ID", Rec."Field ID");
                            LookupMgmt.OpenLookupDialogOfType(Rec."Case ID", Rec."Script ID", Rec."Lookup ID", FieldDatatype);
                            Rec.Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
                field("Run Validate"; Rec."Run Validate")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to trigger the OnValidate trigger of the field.';
                }
                field("Reverse Sign"; Rec."Reverse Sign")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether to reverse the sign of the numeric value.';
                    trigger OnValidate()
                    var
                        FieldDatatype: Enum "Symbol Data Type";
                    begin
                        FieldDatatype := ScriptDataTypeMgmt.GetFieldDatatype(Rec."Table ID", Rec."Field ID");
                        if FieldDatatype <> "Symbol Data Type"::NUMBER then
                            Error(InvalidReverseSignErr);
                    end;
                }
            }
        }
    }

    local procedure FormatLine();
    var
        FieldDatatype: Enum "Symbol Data Type";
    begin
        if (Rec."Table ID" <> 0) and (Rec."Field ID" <> 0) then begin
            FieldDatatype := ScriptDataTypeMgmt.GetFieldDatatype(Rec."Table ID", Rec."Field ID");
            FieldValue2 := LookupSerialization.ConstantOrLookupText(
                Rec."Case ID",
                Rec."Script ID",
                Rec."Value Type",
                Rec.Value,
                Rec."Lookup ID",
                FieldDatatype);
            TableFieldName2 := AppObjectHelper.GetFieldName(Rec."Table ID", Rec."Field ID");
        end else begin
            FieldValue2 := '';
            TableFieldName2 := '';
        end;
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        FieldValue2 := '';
        TableFieldName2 := '';
    end;

    var
        AppObjectHelper: Codeunit "App Object Helper";
        LookupSerialization: Codeunit "Lookup Serialization";
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        TableFieldName2: Text[30];
        FieldValue2: Text;
        InvalidReverseSignErr: Label 'Reverse Sign can be only used with Number datatype';
}