page 20233 "Entity Value Factbox"
{
    PageType = ListPart;
    SourceTable = "Record Attribute Mapping";
    InsertAllowed = false;
    Editable = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Tax Type"; "Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Tax Type of Attribute.';
                }
                field("Attribute Name"; AttributeNameTxt)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Attribute Name';
                    ToolTip = 'Specifies the attribute name.';
                }
                field(ValueTxt; ValueTxt2)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of attribute.';
                }
            }
        }

    }

    actions
    {
        area(Processing)
        {
            action(EditAttributes)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Show Tax Attributes';
                ToolTip = 'Open the list attached attributes with the record.';
                Image = SetupColumns;
                Promoted = true;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    RecordAttributeMapping: Record "Record Attribute Mapping";
                    EntityValues: Page "Entity Values";
                begin
                    RecordAttributeMapping.Reset();
                    RecordAttributeMapping.SetRange("Attribute Record ID", GlobalTaxRecID);
                    EntityValues.SetTableView(RecordAttributeMapping);
                    EntityValues.Run();
                end;
            }
        }
    }

    var
        ScriptSymbolsMgmt: Codeunit "Script Symbols Mgmt.";
        GlobalTaxRecID: RecordId;
        ValueTxt2: Text;
        AttributeNameTxt: Text[30];
        EmptyGuid: Guid;

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
        GlobalTaxRecID := TaxRecordID;
        exit(FindSet());
    end;
}
