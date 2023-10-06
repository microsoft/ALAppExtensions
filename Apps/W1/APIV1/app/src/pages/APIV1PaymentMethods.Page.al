namespace Microsoft.API.V1;

using Microsoft.Bank.BankAccount;
using Microsoft.Integration.Graph;

page 20020 "APIV1 - Payment Methods"
{
    APIVersion = 'v1.0';
    Caption = 'paymentMethods', Locked = true;
    DelayedInsert = true;
    EntityName = 'paymentMethod';
    EntitySetName = 'paymentMethods';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Payment Method";
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
        PaymentMethod: Record "Payment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecordRef: RecordRef;
    begin
        PaymentMethod.SETRANGE(Code, Rec.Code);
        if not PaymentMethod.ISEMPTY() then
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
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.GetBySystemId(Rec.SystemId);

        if Rec.Code = PaymentMethod.Code then
            Rec.Modify(true)
        else begin
            PaymentMethod.TransferFields(Rec, false);
            PaymentMethod.Rename(Rec.Code);
            Rec.TransferFields(PaymentMethod);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.GET(DATABASE::"Payment Method", FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::"Payment Method";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.insert(true);
    end;
}







