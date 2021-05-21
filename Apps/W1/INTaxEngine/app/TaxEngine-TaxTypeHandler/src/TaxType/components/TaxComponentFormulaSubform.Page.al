page 20262 "Tax Component Formula Subform"
{
    Caption = 'Tokens';
    PageType = ListPart;
    DataCaptionExpression = '';
    InsertAllowed = false;
    DeleteAllowed = false;
    ShowFilter = false;
    PopulateAllFields = true;
    SourceTable = "Tax Component Formula Token";
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Token; Token)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Token name.';
                }
                field(ValueVariable; ValueVariable2)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of Token.';
                    trigger OnValidate();
                    begin
                        if ConvertLookupToConstant() then
                            FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if ConvertConstantToLookup() then begin
                            CurrPage.Update(true);
                            Commit();

                            OpenComponentLookup();
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    local procedure FormatLine()
    begin
        ValueVariable2 := ConstantOrLookupText();
    end;

    local procedure ConvertLookupToConstant(): Boolean;
    var
        DataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        XmlValue: Text;
        Evaluated: Boolean;
        InvalidateContLbl: Label 'Constant value %1 is invalid for datatype %2', Comment = '%1= Constant value, %2 = datatype';
    begin
        if ("Value Type" = "Value Type"::Component) then begin
            if not Confirm('Convert to constant value ?') then
                exit(false);

            Validate("Component ID", 0);
        end;

        "Value Type" := "Value Type"::Constant;
        Evaluated := DataTypeMgmt.IsNumber(ValueVariable2);

        if not Evaluated then
            Error(InvalidateContLbl, ValueVariable2, "Symbol Data Type"::Number);

        XmlValue := DataTypeMgmt.ConvertLocalToXmlFormat(ValueVariable2, "Symbol Data Type"::Number);
        Value := CopyStr(XmlValue, 1, 250);
        Validate(Value);
        exit(true);
    end;

    local procedure ConvertConstantToLookup(): Boolean
    begin
        if ("Value Type" = "Value Type"::Constant) and (Value <> '') then begin
            if not Confirm('Convert to Lookup ?') then
                exit(false);

            Value := '';
        end;

        "Value Type" := "Value Type"::Component;
        exit(true);
    end;

    local procedure OpenComponentLookup()
    var
        TaxComponent: Record "Tax Component";
        TaxComponentFormula: Record "Tax Component Formula";
    begin
        TaxComponentFormula.SetRange(ID, "Formula Expr. ID");
        if TaxComponentFormula.FindFirst() then begin
            TaxComponent.SetRange("Tax Type", "Tax Type");
            TaxComponent.SetFilter("Component Type", '%1', TaxComponent."Component Type"::Normal);
            TaxComponent.SetFilter(ID, '<>%1', TaxComponentFormula."Component ID");
            if Page.RunModal(page::"Tax Components", TaxComponent) = Action::LookupOK then begin
                Validate("Component ID", TaxComponent.ID);
                CurrPage.Update(true);
            end;
        end;
    end;

    local procedure ConstantOrLookupText(): Text;
    var
        ScriptDataTypeMgmt: Codeunit "Script Data Type Mgmt.";
        ScriptSymbolMgmt: Codeunit "Script Symbols Mgmt.";
        ResultText: Text;
        ConstantTxt: Label '''%1''', Locked = true;
        EmptyGuid: Guid;
    begin
        if "Value Type" = "Value Type"::Constant then begin
            ValueVariable2 := ScriptDataTypeMgmt.ConvertXmlToLocalFormat(Value, "Symbol Data Type"::Number);
            ResultText := StrSubstNo(ConstantTxt, ValueVariable2)
        end else begin
            ScriptSymbolMgmt.SetContext("Tax Type", EmptyGuid, EmptyGuid);
            ResultText := ScriptSymbolMgmt.GetSymbolName("Symbol Type"::Component, "Component ID");
        end;

        exit(ResultText);
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;

    var
        ValueVariable2: Text;
}