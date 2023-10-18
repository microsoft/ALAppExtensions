namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;

page 30053 "APIV2 - Pictures"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Picture';
    EntitySetCaption = 'Pictures';
    EntityName = 'picture';
    EntitySetName = 'pictures';
    DelayedInsert = true;
    InsertAllowed = false;
    PageType = API;
    SourceTable = "Picture Entity";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = Id;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(parentType; Rec."Parent Type")
                {
                    Caption = 'Parent Type';
                    Editable = false;
                }
                field(width; Rec.Width)
                {
                    Caption = 'Width';
                    Editable = false;
                }
                field(height; Rec.Height)
                {
                    Caption = 'Height';
                    Editable = false;
                }
                field(contentType; Rec."Mime Type")
                {
                    Caption = 'Content Type';
                    Editable = false;
                }
                field(pictureContent; Rec.Content)
                {
                    Caption = 'Picture Content';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.DeletePictureWithParentType();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        PictureEntityParentType: Enum "Picture Entity Parent Type";
        ParentIdFilter: Text;
        ParentTypeFilter: Text;
    begin
        if not DataLoaded then begin
            ParentIdFilter := Rec.GetFilter(Id);
            ParentTypeFilter := Rec.GetFilter("Parent Type");
            if (ParentTypeFilter = '') or (ParentIdFilter = '') then begin
                Rec.FilterGroup(4);
                ParentIdFilter := Rec.GetFilter(Id);
                ParentTypeFilter := Rec.GetFilter("Parent Type");
                Rec.FilterGroup(0);
                if (ParentTypeFilter = '') or (ParentIdFilter = '') then
                    Error(ParentNotSpecifiedErr)
            end;
            Evaluate(PictureEntityParentType, ParentTypeFilter);
            Rec.LoadDataWithParentType(ParentIdFilter, PictureEntityParentType);
            Rec.Insert(true);
        end;

        DataLoaded := true;
        exit(true);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SavePictureWithParentType();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.SavePictureWithParentType();
    end;

    var
        ParentNotSpecifiedErr: Label 'You must get to the parent first to get to the picture.';
        DataLoaded: Boolean;
}
