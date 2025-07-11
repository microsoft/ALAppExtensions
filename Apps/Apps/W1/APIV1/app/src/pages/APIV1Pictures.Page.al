namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;

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
                field(id; Rec.Id)
                {
                    ApplicationArea = All;
                    Caption = 'id', Locked = true;
                    ToolTip = 'Specifies the id.';
                    Editable = false;
                }
                field(width; Rec.Width)
                {
                    ApplicationArea = All;
                    Caption = 'width', Locked = true;
                    ToolTip = 'Specifies the width.';
                    Editable = false;
                }
                field(height; Rec.Height)
                {
                    ApplicationArea = All;
                    Caption = 'height', Locked = true;
                    ToolTip = 'Specifies the height.';
                    Editable = false;
                }
                field(contentType; Rec."Mime Type")
                {
                    ApplicationArea = All;
                    Caption = 'contentType';
                    ToolTip = 'Specifies the content type.';
                    Editable = false;
                }
#pragma warning disable AL0273
#pragma warning disable AW0004
                field(content; Rec.Content)
#pragma warning restore
                {
                    ApplicationArea = All;
                    Caption = 'content';
                    ToolTip = 'Specifies the content.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.DeletePicture();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        if not DataLoaded then begin
            Rec.LoadData(Rec.GetFilter(Id));
            Rec.Insert(true);
        end;

        DataLoaded := true;
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SavePicture();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.SavePicture();
    end;

    var
        DataLoaded: Boolean;
}


