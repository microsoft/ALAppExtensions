page 20036 "APIV1 - Tax Areas"
{
    APIVersion = 'v1.0';
    Caption = 'taxAreas', Locked = true;
    DelayedInsert = true;
    EntityName = 'taxArea';
    EntitySetName = 'taxAreas';
    PageType = API;
    SourceTable = "Tax Area Buffer";
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
                field(lastModifiedDateTime; "Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                    Editable = false;
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

