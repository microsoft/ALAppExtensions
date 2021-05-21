page 20157 "Action Concatenate Subform"
{
    Caption = 'String Concatenate Lines';
    PageType = ListPart;
    DataCaptionExpression = '';
    ShowFilter = false;
    AutoSplitKey = true;
    PopulateAllFields = true;
    SourceTable = "Action Concatenate Line";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(ValueVariable; ValueVariable2)
                {
                    Caption = 'Value';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value which will be concatenated';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            ValueVariable2,
                            "Symbol Data Type"::STRING)
                        then
                            Validate(Value);

                        FormatLine();
                    end;

                    trigger OnAssistEdit();
                    begin
                        if LookupMgmt.ConvertConstantToLookup(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID")
                        then begin
                            CurrPage.Update(true);
                            Commit();

                            LookupMgmt.OpenLookupDialog("Case ID", "Script ID", "Lookup ID");
                            Validate("Lookup ID");
                        end;

                        FormatLine();
                    end;
                }
            }
        }
    }

    var
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        ValueVariable2: Text;

    local procedure FormatLine();
    begin
        ValueVariable2 := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            "Symbol Data Type"::STRING);
    end;

    trigger OnAfterGetRecord();
    begin
        FormatLine();
    end;

    trigger OnAfterGetCurrRecord();
    begin
        FormatLine();
    end;
}