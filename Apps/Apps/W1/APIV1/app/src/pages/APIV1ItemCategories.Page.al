namespace Microsoft.API.V1;

using Microsoft.Inventory.Item;
using Microsoft.Integration.Graph;

page 20025 "APIV1 - Item Categories"
{
    APIVersion = 'v1.0';
    Caption = 'itemCategories', Locked = true;
    DelayedInsert = true;
    EntityName = 'itemCategory';
    EntitySetName = 'itemCategories';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Item Category";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Code));
                    end;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'description', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecordRef: RecordRef;
    begin
        ItemCategory.SETRANGE(Code, Rec.Code);
        if not ItemCategory.ISEMPTY() then
            Rec.insert();

        Rec.insert(true);

        RecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecordRef, TempFieldSet, CURRENTDATETIME());
        RecordRef.SetTable(Rec);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.GetBySystemId(Rec.SystemId);

        if Rec.Code = ItemCategory.Code then
            Rec.Modify(true)
        else begin
            ItemCategory.TransferFields(Rec, false);
            ItemCategory.Rename(Rec.Code);
            Rec.TransferFields(ItemCategory);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.GET(DATABASE::"Item Category", FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::"Item Category";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.insert(true);
    end;
}







