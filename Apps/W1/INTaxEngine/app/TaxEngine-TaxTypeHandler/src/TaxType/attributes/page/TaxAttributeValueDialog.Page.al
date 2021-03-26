page 20259 "Tax Attribute Value Dialog"
{
    Caption = 'Attribute Value';
    Editable = false;
    PageType = StandardDialog;
    DataCaptionExpression = '';
    SourceTable = "Tax Attribute Value";

    layout
    {
        area(Content)
        {
            repeater(Group2)
            {
                field(Value; Value)
                {
                    ToolTip = 'Specifies the value of the option.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    var
        DummySelectedGenericAttributeValue: Record "Tax Attribute Value";

    procedure GetSelectedValue(var GenericAttributeValue: Record "Tax Attribute Value");
    begin
        GenericAttributeValue.COPY(DummySelectedGenericAttributeValue);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean;
    begin
        Clear(DummySelectedGenericAttributeValue);
        CurrPage.SETSELECTIONFILTER(DummySelectedGenericAttributeValue);
    end;
}