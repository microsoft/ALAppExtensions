page 4814 "Intrastat Report Checklist"
{
    Caption = 'Intrastat Report Checklist';
    PageType = List;
    SourceTable = "Intrastat Report Checklist";
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the number of the table field that this entry in the checklist uses.';
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the name of the table field that this entry in the checklist uses.';

                    trigger OnAssistEdit()
                    begin
                        Rec.AssistEditFieldName();
                    end;
                }
                field("Filter Expression"; Rec."Filter Expression")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies the filter expression that must be applied to the Intrastat line. The check for fields is run only on those lines that are passes the filter expression.';
                }
                field("Reversed Filter Expression"; Rec."Reversed Filter Expression")
                {
                    ApplicationArea = BasicEU, BasicNO, BasicCH;
                    ToolTip = 'Specifies that the check for fields is run only on those lines that do not match the filter expression. If the line is not filtered, this field is ignored.';
                }
            }
        }
    }
}