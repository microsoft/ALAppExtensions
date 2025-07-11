namespace Microsoft.API.V1;

using Microsoft.Finance.Currency;
using Microsoft.Integration.Graph;

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
                field(symbol; Rec.Symbol)
                {
                    Caption = 'symbol', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Symbol));
                    end;
                }
                field(amountDecimalPlaces; Rec."Amount Decimal Places")
                {
                    Caption = 'amountDecimalPlaces', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Decimal Places"));
                    end;
                }
                field(amountRoundingPrecision; Rec."Invoice Rounding Precision")
                {
                    Caption = 'amountRoundingPrecision', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Rounding Precision"));
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
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecordRef: RecordRef;
    begin
        Rec.insert(true);

        RecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecordRef, TempFieldSet, CURRENTDATETIME());
        RecordRef.SetTable(Rec);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Currency: Record "Currency";
    begin
        Currency.GetBySystemId(Rec.SystemId);

        if Rec.Code <> Currency.Code then begin
            Currency.TransferFields(Rec, false);
            Currency.Rename(Rec.Code);
            Rec.TransferFields(Currency);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Currency, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Currency;        TempFieldSet.TableNo := DATABASE::Currency;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}






