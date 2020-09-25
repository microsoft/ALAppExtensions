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
                field(id; Id)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(displayName; Description)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(taxType; Type)
                {
                    Caption = 'taxType', Locked = true;
                    Editable = false;
                }
                field(lastModifiedDateTime; "Last Modified DateTime")
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

