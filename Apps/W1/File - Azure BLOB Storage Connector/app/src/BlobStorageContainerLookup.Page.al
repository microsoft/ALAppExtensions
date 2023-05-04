page 80102 "Blob Storage Container Lookup"
{
    Caption = 'Container Lookup';
    PageType = List;
    SourceTable = "ABS Container";
    Editable = false;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Name of the container.';
                }
            }
        }
    }
}
