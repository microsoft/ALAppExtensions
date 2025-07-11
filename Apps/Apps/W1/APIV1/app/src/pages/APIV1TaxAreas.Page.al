namespace Microsoft.API.V1;

using Microsoft.Integration.Entity;

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
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
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


