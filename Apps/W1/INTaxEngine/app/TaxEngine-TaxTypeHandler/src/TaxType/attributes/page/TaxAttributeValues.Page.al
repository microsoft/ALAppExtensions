page 20260 "Tax Attribute Values"
{
    Caption = 'Values';
    PageType = List;
    DataCaptionFields = "Attribute ID";
    SourceTable = "Tax Attribute Value";
    AutoSplitKey = true;
    layout
    {
        area(Content)
        {
            repeater(Group1)
            {
                field(Value; Value)
                {
                    ToolTip = 'Specifies the value of the attribute.';
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Description)
                {
                    ToolTip = 'Specifies the Description of the attribute value.';
                    ApplicationArea = Basic, Suite;
                }
            }
        }
    }

    trigger OnOpenPage();
    var
        AttributeID: Integer;
    begin
        if GETFILTER("Attribute ID") <> '' then
            AttributeID := GETRANGEMIN("Attribute ID");
        if AttributeID <> 0 then begin
            FilterGroup(2);
            SetRange("Attribute ID", AttributeID);
            FilterGroup(0);
        end;
    end;
}