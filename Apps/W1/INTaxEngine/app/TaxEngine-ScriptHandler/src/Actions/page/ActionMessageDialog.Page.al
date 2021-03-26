page 20173 "Action Message Dialog"
{
    Caption = 'Alert Message';
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Action Message";
    layout
    {
        area(Content)
        {
            group(General)
            {

                field(Message; MessageValue)
                {
                    Caption = 'Message';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of alert message.';
                    trigger OnValidate();
                    begin
                        if LookupMgmt.ConvertLookupToConstant(
                            "Case ID",
                            "Script ID",
                            "Value Type",
                            Value,
                            "Lookup ID",
                            MessageValue,
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
                field("Throw Error"; "Throw Error")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether alert message will be an error.';
                }
            }
        }
    }

    var
        ActionMessage: Record "Action Message";
        LookupSerialization: Codeunit "Lookup Serialization";
        LookupMgmt: Codeunit "Lookup Mgmt.";
        MessageValue: Text;

    procedure SetCurrentRecord(var ActionMessage2: Record "Action Message");
    begin
        ActionMessage := ActionMessage2;

        TestRecord();

        FilterGroup := 2;
        SetRange("Case ID", ActionMessage."Case ID");
        SetRange("Script ID", ActionMessage."Script ID");
        SetRange(ID, ActionMessage.ID);
        FilterGroup := 0;
    end;

    local procedure TestRecord();
    begin
        ActionMessage.TestField("Case ID");
        ActionMessage.TestField("Script ID");
        ActionMessage.TestField(ID);
    end;

    local procedure FormatLine();
    begin
        MessageValue := LookupSerialization.ConstantOrLookupText(
            "Case ID",
            "Script ID",
            "Value Type",
            Value,
            "Lookup ID",
            "Symbol Data Type"::STRING);
    end;

    trigger OnOpenPage();
    begin
        TestRecord();
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