page 30148 "Shpfy Linked BC Documents"
{
    ApplicationArea = All;
    Caption = 'Linked BC Documents';
    PageType = ListPart;
    SourceTable = "Shpfy Doc. Link To BC Doc.";
    SourceTableView = sorting("BC Document Type", "BC Document No.");

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("BC Document Type"; Rec."BC Document Type")
                {
                    ToolTip = 'Specifies the value of the BC Document Type field.';
                }
                field("BC Document No."; Rec."BC Document No.")
                {
                    ToolTip = 'Specifies the value of the BC Document No. field.';

                    trigger OnDrillDown()
                    begin
                        Rec.OpenBCDocument();
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenDocument)
            {
                Caption = 'Open Document';
                ToolTip = 'Open linked document';
                Image = Document;

                trigger OnAction()
                begin
                    Rec.OpenBCDocument();
                end;
            }
        }
    }
}
