page 30025 "APIV2 - Item Categories"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Item Category';
    EntitySetCaption = 'Item Categories';
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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Code)
                {
                    Caption = 'Code';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Code));
                    end;
                }
                field(displayName; Description)
                {
                    Caption = 'Description';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        ItemCategory: Record "Item Category";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ItemCategoryRecordRef: RecordRef;
    begin
        ItemCategory.SetRange(Code, Code);
        if not ItemCategory.IsEmpty() then
            Insert();

        Insert(true);

        ItemCategoryRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(ItemCategoryRecordRef, TempFieldSet, CurrentDateTime());
        ItemCategoryRecordRef.SetTable(Rec);

        Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ItemCategory: Record "Item Category";
    begin
        ItemCategory.GetBySystemId(SystemId);

        if Code = ItemCategory.Code then
            Modify(true)
        else begin
            ItemCategory.TransferFields(Rec, false);
            ItemCategory.Rename(Code);
            TransferFields(ItemCategory);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"Item Category", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Item Category";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}






