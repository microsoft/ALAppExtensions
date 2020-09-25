page 20019 "APIV1 - Currencies"
{
    APIVersion = 'v1.0';
    Caption = 'currencies', Locked = true;
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
                    Caption = 'description', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Description));
                    end;
                }
                field(symbol; Symbol)
                {
                    Caption = 'symbol', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Symbol));
                    end;
                }
                field(amountDecimalPlaces; "Amount Decimal Places")
                {
                    Caption = 'amountDecimalPlaces', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Amount Decimal Places"));
                    end;
                }
                field(amountRoundingPrecision; "Invoice Rounding Precision")
                {
                    Caption = 'amountRoundingPrecision', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Amount Rounding Precision"));
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
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        INSERT(TRUE);

        RecRef.GETTABLE(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CURRENTDATETIME());
        RecRef.SETTABLE(Rec);

        MODIFY(TRUE);
        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Currency: Record "Currency";
    begin
        Currency.GetBySystemId(SystemId);

        IF Code <> Currency.Code THEN BEGIN
            Currency.TRANSFERFIELDS(Rec, FALSE);
            Currency.RENAME(Code);
            TRANSFERFIELDS(Currency);
        END;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::Currency, FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::Currency;
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;
}





