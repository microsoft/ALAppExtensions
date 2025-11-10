namespace Microsoft.API.V2;

using Microsoft.Foundation.UOM;
using Microsoft.Integration.Graph;

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
    AboutText = 'Manages unit of measure definitions including code, description, international standard code, and symbol, supporting full CRUD operations for synchronizing measurement units across product catalogs and inventory systems. Enables external integrations to maintain consistent units for accurate inventory tracking, sales processing, and cross-system data alignment.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Rec.Code)
                {
                    Caption = 'Code';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Code));
                    end;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'Display Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Description));
                    end;
                }
                field(internationalStandardCode; Rec."International Standard Code")
                {
                    Caption = 'International Standard Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("International Standard Code"));
                    end;
                }
                field(symbol; Rec.Symbol)
                {
                    Caption = 'Symbol';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Symbol"));
                    end;
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

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        UnitofMeasureRecordRef: RecordRef;
    begin
        Rec.Insert(true);

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



