page 30024 "APIV2 - Shipment Methods"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Shipment Method';
    EntitySetCaption = 'Shipment Methods';
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
        ShipmentMethod: Record "Shipment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ShipmentMethodRecordRef: RecordRef;
    begin
        ShipmentMethod.SetRange(Code, Code);
        if not ShipmentMethod.IsEmpty() then
            Insert();

        Insert(true);

        ShipmentMethodRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(ShipmentMethodRecordRef, TempFieldSet, CurrentDateTime());
        ShipmentMethodRecordRef.SetTable(Rec);

        Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.GetBySystemId(SystemId);

        if Code = ShipmentMethod.Code then
            Modify(true)
        else begin
            ShipmentMethod.TransferFields(Rec, false);
            ShipmentMethod.Rename(Code);
            TransferFields(ShipmentMethod, true);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"Shipment Method", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Shipment Method";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}






