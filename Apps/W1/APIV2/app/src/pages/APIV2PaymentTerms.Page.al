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
                field(dueDateCalculation; "Due Date Calculation")
                {
                    Caption = 'Due Date Calculation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Due Date Calculation"));
                    end;
                }
                field(discountDateCalculation; "Discount Date Calculation")
                {
                    Caption = 'Discount Date Calculation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Discount Date Calculation"));
                    end;
                }
                field(discountPercent; "Discount %")
                {
                    Caption = 'Discount Percent';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Discount %"));
                    end;
                }
                field(calculateDiscountOnCreditMemos; "Calc. Pmt. Disc. on Cr. Memos")
                {
                    Caption = 'Calc. Pmt. Disc. On Credit Memos';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Calc. Pmt. Disc. on Cr. Memos"));
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
        PaymentTerms: Record "Payment Terms";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        PaymentTermsRecordRef: RecordRef;
    begin
        PaymentTerms.SetRange(Code, Code);
        if not PaymentTerms.IsEmpty() then
            Insert();

        Insert(true);

        PaymentTermsRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(PaymentTermsRecordRef, TempFieldSet, CurrentDateTime());
        PaymentTermsRecordRef.SetTable(Rec);

        Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.GetBySystemId(SystemId);

        if Code = PaymentTerms.Code then
            Modify(true)
        else begin
            PaymentTerms.TransferFields(Rec, false);
            PaymentTerms.Rename(Code);
            TransferFields(PaymentTerms, true);
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






