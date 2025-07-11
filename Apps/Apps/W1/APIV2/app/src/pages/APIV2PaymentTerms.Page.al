namespace Microsoft.API.V2;

using Microsoft.Foundation.PaymentTerms;
using Microsoft.Integration.Graph;

page 30023 "APIV2 - Payment Terms"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Payment Term';
    EntitySetCaption = 'Payment Terms';
    DelayedInsert = true;
    EntityName = 'paymentTerm';
    EntitySetName = 'paymentTerms';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Payment Terms";
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
                field(dueDateCalculation; Rec."Due Date Calculation")
                {
                    Caption = 'Due Date Calculation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Due Date Calculation"));
                    end;
                }
                field(discountDateCalculation; Rec."Discount Date Calculation")
                {
                    Caption = 'Discount Date Calculation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Discount Date Calculation"));
                    end;
                }
                field(discountPercent; Rec."Discount %")
                {
                    Caption = 'Discount Percent';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Discount %"));
                    end;
                }
                field(calculateDiscountOnCreditMemos; Rec."Calc. Pmt. Disc. on Cr. Memos")
                {
                    Caption = 'Calc. Pmt. Disc. On Credit Memos';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Calc. Pmt. Disc. on Cr. Memos"));
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
        PaymentTerms: Record "Payment Terms";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        PaymentTermsRecordRef: RecordRef;
    begin
        PaymentTerms.SetRange(Code, Rec.Code);
        if not PaymentTerms.IsEmpty() then
            Rec.Insert();

        Rec.Insert(true);

        PaymentTermsRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(PaymentTermsRecordRef, TempFieldSet, CurrentDateTime());
        PaymentTermsRecordRef.SetTable(Rec);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.GetBySystemId(Rec.SystemId);

        if Rec.Code = PaymentTerms.Code then
            Rec.Modify(true)
        else begin
            PaymentTerms.TransferFields(Rec, false);
            PaymentTerms.Rename(Rec.Code);
            Rec.TransferFields(PaymentTerms, true);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"Payment Terms", FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Payment Terms";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}





