page 18620 "Service Entity Types"
{
    Caption = 'Service Entity Types';
    PageType = List;
    SourceTable = "Service Entity Type";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of service entity type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the service entity type.';
                }
            }
        }
    }
}