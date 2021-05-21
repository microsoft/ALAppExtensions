page 20234 "Entity Values"
{
    PageType = List;
    SourceTable = "Record Attribute Mapping";
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Tax Type"; "Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax type of the attribute.';
                    Editable = false;
                }
                field("Attribute Name"; AttributeNameTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attribute Name';
                    ToolTip = 'Specifies the name of attribute.';
                    Editable = false;
                }
                field(ValueTxt; ValueTxt2)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of attribute.';
                    trigger onValidate()
                    begin
                        ValidateAttributeValue(ValueTxt2);
                        ValueTxt2 := GetAttributeValue("Attribute Value");
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AttributeManagement: Codeunit "Tax Attribute Management";
                    begin
                        AttributeManagement.GetAttributeOptionValue("Tax Type", "Attribute ID", ValueTxt2);
                        ValidateAttributeValue(ValueTxt2);
                        ValueTxt2 := GetAttributeValue("Attribute Value");
                    end;
                }
            }
        }

    }


    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    trigger OnAfterGetRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    begin
        ScriptSymbolsMgmt.SetContext("Tax Type", EmptyGuid, EmptyGuid);
        ValueTxt2 := '';
        ValueTxt2 := GetAttributeValue("Attribute Value");
        if "Attribute ID" <> 0 then
            AttributeNameTxt := ScriptSymbolsMgmt.GetSymbolName("Symbol Type"::"Tax Attributes", "Attribute ID")
        else
            AttributeNameTxt := '';
    end;

    procedure SetRecordFilter(TaxRecordID: RecordId): Boolean
    begin
        Reset();
        SetRange("Attribute Record ID", TaxRecordID);
        CurrPage.Update(false);
        exit(FindSet());
    end;

    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        ValueTxt2: Text[250];
        AttributeNameTxt: Text[30];
        EmptyGuid: Guid;

}
