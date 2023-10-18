namespace Microsoft.API.V2;

using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;

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
        ShipmentMethod: Record "Shipment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        ShipmentMethodRecordRef: RecordRef;
    begin
        ShipmentMethod.SetRange(Code, Rec.Code);
        if not ShipmentMethod.IsEmpty() then
            Rec.Insert();

        Rec.Insert(true);

        ShipmentMethodRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(ShipmentMethodRecordRef, TempFieldSet, CurrentDateTime());
        ShipmentMethodRecordRef.SetTable(Rec);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.GetBySystemId(Rec.SystemId);

        if Rec.Code = ShipmentMethod.Code then
            Rec.Modify(true)
        else begin
            ShipmentMethod.TransferFields(Rec, false);
            ShipmentMethod.Rename(Rec.Code);
            Rec.TransferFields(ShipmentMethod, true);
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





