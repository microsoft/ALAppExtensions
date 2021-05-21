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
                field(id; Id)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Description)
                {
                    Caption = 'Display Name';
                }
                field(taxType; Type)
                {
                    Caption = 'Tax Type';
                    Editable = false;
                }
                field(lastModifiedDateTime; SystemModifiedAt)
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
        PropagateDelete();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        PropagateInsert();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        PropagateModify();
    end;

    trigger OnOpenPage()
    begin
        LoadRecords();
    end;
}

