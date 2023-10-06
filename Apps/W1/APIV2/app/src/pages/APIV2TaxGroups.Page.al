namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;

page 30015 "APIV2 - Tax Groups"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Tax Group';
    EntitySetCaption = 'Tax Groups';
    DelayedInsert = true;
    EntityName = 'taxGroup';
    EntitySetName = 'taxGroups';
    PageType = API;
    SourceTable = "Tax Group Buffer";
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
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Display Name';
                }
                field(taxType; Rec.Type)
                {
                    Caption = 'Tax Type';
                    Editable = false;
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
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

