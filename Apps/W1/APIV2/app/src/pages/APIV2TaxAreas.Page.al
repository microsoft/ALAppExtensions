namespace Microsoft.API.V2;

using Microsoft.Integration.Entity;

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
    AboutText = 'Manages tax area definitions including code, description, tax type (Sales Tax or VAT), and last modified date, supporting full CRUD operations for synchronizing tax area data with external tax engines, e-commerce platforms, and compliance automation systems to ensure accurate tax calculation for sales and purchasing transactions.';

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
