namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;

page 20015 "APIV1 - Tax Groups"
{
    APIVersion = 'v1.0';
    Caption = 'taxGroups', Locked = true;
    DelayedInsert = true;
    EntityName = 'taxGroup';
    EntitySetName = 'taxGroups';
    PageType = API;
    SourceTable = "Tax Group Buffer";
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
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(taxType; Rec.Type)
                {
                    Caption = 'taxType', Locked = true;
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec."Last Modified DateTime")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.PropagateDelete();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.PropagateInsert();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec.PropagateModify();
    end;

    trigger OnOpenPage()
    begin
        Rec.LoadRecords();
    end;
}


