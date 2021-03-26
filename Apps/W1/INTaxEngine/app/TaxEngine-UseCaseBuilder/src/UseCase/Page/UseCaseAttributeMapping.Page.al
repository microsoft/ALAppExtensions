page 20307 "Use Case Attribute Mapping"
{
    PageType = ListPart;
    SourceTable = "Use Case Attribute Mapping";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Attribtue Name"; AttributeNameTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attribute Name';
                    ToolTip = 'Specifies the name of attribute that is mapped in the use case for tax computation.';
                    trigger OnValidate();
                    begin
                        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);
                        ScriptSymbolsMgmt.SearchSymbol("Symbol Type"::"Tax Attributes", "Attribtue ID", AttributeNameTxt);
                        Validate("Attribtue ID");
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);
                        ScriptSymbolsMgmt.OpenSymbolsLookup("Symbol Type"::"Tax Attributes", Text, "Attribtue ID", AttributeNameTxt);
                        Validate("Attribtue ID");
                    end;
                }
                field(TableRelation; TableRelationTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Table Relation';
                    ToolTip = 'Specifies the mapping of attribute name to get its value.';
                    Editable = false;
                    StyleExpr = true;
                    Style = Subordinate;
                    trigger OnAssistEdit()
                    begin
                        if IsNullGuid("Switch Statement ID") then
                            "Switch Statement ID" := SwitchStatementHelper.CreateSwitchStatement("Case ID");

                        SwitchStatementHelper.OpenSwitchStatements("Case ID", "Switch Statement ID", "Switch Case Action Type"::Relation);
                    end;
                }
            }
        }

    }
    local procedure FormatLine()
    var
        SwitchCase: Record "Switch Case";
    begin
        clear(ScriptSymbolsMgmt);
        ScriptSymbolsMgmt.SetContext("Case ID", EmptyGuid);
        TableRelationTxt := '';
        Clear(TableRelationTxt);

        SwitchCase.SetRange("Case ID", "Case ID");
        SwitchCase.SetRange("Switch Statement ID", "Switch Statement ID");
        if SwitchCase.FindSet() then
            repeat
                if TableRelationTxt <> '' then
                    TableRelationTxt += ', ';

                if not IsNullGuid(SwitchCase."Condition ID") then
                    TableRelationTxt += 'If ' + ScriptSerialization.ConditionToString("Case ID", EmptyGuid, SwitchCase."Condition ID") + ' Then ';

                TableRelationTxt += UseCaseSerialization.TableRelationToString(
                    "Case ID",
                    SwitchCase."Action ID");
            until SwitchCase.Next() = 0
        else
            TableRelationTxt := '< Table Relation >';

        if "Attribtue ID" <> 0 then
            AttributeNameTxt := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Tax Attributes", "Attribtue ID")
        else
            AttributeNameTxt := '';

    end;

    trigger OnAfterGetRecord()
    var

    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord()
    var

    begin
        FormatLine();
    end;

    var
        ScriptSerialization: Codeunit "Script Serialization";
        SwitchStatementHelper: Codeunit "Switch Statement Helper";
        UseCaseSerialization: Codeunit "Use Case Serialization";
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        EmptyGuid: Guid;
        TableRelationTxt: Text;
        AttributeNameTxt: Text[30];
}