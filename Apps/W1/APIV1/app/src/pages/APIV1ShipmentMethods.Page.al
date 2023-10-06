namespace Microsoft.API.V1;

using Microsoft.Foundation.Shipping;
using Microsoft.Integration.Graph;

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
                    Caption = 'displayName', Locked = true;

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
        ShipmentMethod: Record "Shipment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecordRef: RecordRef;
    begin
        ShipmentMethod.SETRANGE(Code, Rec.Code);
        if not ShipmentMethod.ISEMPTY() then
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
        if TempFieldSet.GET(DATABASE::"Shipment Method", FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::"Shipment Method";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.insert(true);
    end;
}







