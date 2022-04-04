page 30030 "APIV2 - Units of Measure"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Unit Of Measure';
    EntitySetCaption = 'Units Of Measure';
    DelayedInsert = true;
    EntityName = 'unitOfMeasure';
    EntitySetName = 'unitsOfMeasure';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Unit of Measure";
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
                    Caption = 'Display Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
                }
                field(internationalStandardCode; "International Standard Code")
                {
                    Caption = 'International Standard Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("International Standard Code"));
                    end;
                }
                field(symbol; Symbol)
                {
                    Caption = 'Symbol';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Symbol"));
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
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        UnitofMeasureRecordRef: RecordRef;
    begin
        Insert(true);

        UnitofMeasureRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(UnitofMeasureRecordRef, TempFieldSet, CurrentDateTime());
        UnitofMeasureRecordRef.SetTable(Rec);

        exit(false);
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(DATABASE::"Unit of Measure", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := DATABASE::"Unit of Measure";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}



