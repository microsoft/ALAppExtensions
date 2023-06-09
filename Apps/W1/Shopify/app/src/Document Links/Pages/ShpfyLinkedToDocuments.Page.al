page 30148 "Shpfy Linked To Documents"
{
    ApplicationArea = All;
    Caption = 'Linked Documents';
    PageType = ListPart;
    SourceTable = "Shpfy Doc. Link To Doc.";
    SourceTableView = sorting("Document Type", "Document No.");

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the value of the Document Type field.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the value of the Document No. field.';

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