page 30019 "APIV2 - Currencies"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Currency';
    EntitySetCaption = 'Currencies';
    DelayedInsert = true;
    EntityName = 'currency';
    EntitySetName = 'currencies';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Currency;
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
                    Caption = 'Description';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
                }
                field(symbol; Symbol)
                {
                    Caption = 'Symbol';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Symbol));
                    end;
                }
                field(amountDecimalPlaces; "Amount Decimal Places")
                {
                    Caption = 'Amount Decimal Places';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Amount Decimal Places"));
                    end;
                }
                field(amountRoundingPrecision; "Invoice Rounding Precision")
                {
                    Caption = 'Amount Rounding Precision';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Amount Rounding Precision"));
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
        CurrencyRecordRef: RecordRef;
    begin
        Insert(true);

        CurrencyRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(CurrencyRecordRef, TempFieldSet, CurrentDateTime());
        CurrencyRecordRef.SetTable(Rec);

        Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Currency: Record "Currency";
    begin
        Currency.GetBySystemId(SystemId);

        if Code <> Currency.Code then begin
            Currency.TransferFields(Rec, false);
            Currency.Rename(Code);
            TransferFields(Currency);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Currency, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Currency;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}





