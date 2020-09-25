page 30036 "APIV2 - Tax Areas"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Tax Area';
    EntitySetCaption = 'Tax Areas';
    DelayedInsert = true;
    EntityName = 'taxArea';
    EntitySetName = 'taxAreas';
    PageType = API;
    SourceTable = "Tax Area Buffer";
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

