namespace Microsoft.API.V2;

using Microsoft.Bank.BankAccount;
using Microsoft.Integration.Graph;

page 30020 "APIV2 - Payment Methods"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Payment Method';
    EntitySetCaption = 'Payment Methods';
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
                    Caption = 'Description';

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
        PaymentMethod: Record "Payment Method";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        PaymentMethodRecordRef: RecordRef;
    begin
        PaymentMethod.SetRange(Code, Rec.Code);
        if not PaymentMethod.IsEmpty() then
            Rec.Insert();

        Rec.Insert(true);

        PaymentMethodRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(PaymentMethodRecordRef, TempFieldSet, CurrentDateTime());
        PaymentMethodRecordRef.SetTable(Rec);

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
        if TempFieldSet.Get(Database::"Payment Method", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Payment Method";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}





