page 4765 "Manufacturing Module Setup"
{
    PageType = Card;
    ApplicationArea = Manufacturing;
    Caption = 'Manufacturing Module Setup';
    SourceTable = "Manufacturing Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Manufacturing Location"; Rec."Manufacturing Location")
                {
                    ToolTip = 'Specifies a new or an existing location that you want to use for production operations.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}