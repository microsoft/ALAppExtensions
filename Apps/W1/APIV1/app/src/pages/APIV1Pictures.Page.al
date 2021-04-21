page 20055 "APIV1 - Pictures"
{
    Caption = 'picture', Locked = true;
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = "Picture Entity";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Id)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(width; Width)
                {
                    ApplicationArea = All;
                    Caption = 'width', Locked = true;
                    Editable = false;
                }
                field(height; Height)
                {
                    ApplicationArea = All;
                    Caption = 'height', Locked = true;
                    Editable = false;
                }
                field(contentType; "Mime Type")
                {
                    ApplicationArea = All;
                    Caption = 'contentType';
                    Editable = false;
                }
                field(content; Content)
                {
                    ApplicationArea = All;
                    Caption = 'content';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        DeletePicture();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not DataLoaded then begin
            LoadData(GetFilter(Id));
            Insert(true);
        end;

        DataLoaded := true;
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        SavePicture();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        SavePicture();
    end;

    var
        DataLoaded: Boolean;
}

