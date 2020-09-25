page 20024 "APIV1 - Shipment Methods"
{
    APIVersion = 'v1.0';
    Caption = 'shipmentMethods', Locked = true;
    DelayedInsert = true;
    EntityName = 'shipmentMethod';
    EntitySetName = 'shipmentMethods';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Shipment Method";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field("code"; Code)
                {
                    Caption = 'code', Locked = true;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Code));
                    end;
                }
                field(displayName; Description)
                {
                    Caption = 'displayName', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Description));
                    end;
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
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
        ShipmentMethod: Record "Shipment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        ShipmentMethod.SETRANGE(Code, Code);
        IF NOT ShipmentMethod.ISEMPTY() THEN
            INSERT();

        INSERT(TRUE);

        RecRef.GETTABLE(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CURRENTDATETIME());
        RecRef.SETTABLE(Rec);

        MODIFY(TRUE);
        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.GetBySystemId(SystemId);

        IF Code = ShipmentMethod.Code THEN
            MODIFY(TRUE)
        ELSE BEGIN
            ShipmentMethod.TRANSFERFIELDS(Rec, FALSE);
            ShipmentMethod.RENAME(Code);
            TRANSFERFIELDS(ShipmentMethod, TRUE);
        END;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::"Shipment Method", FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::"Shipment Method";
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;
}






