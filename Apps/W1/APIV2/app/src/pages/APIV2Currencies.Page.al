namespace Microsoft.API.V2;

using Microsoft.Finance.Currency;
using Microsoft.Integration.Graph;

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
    AboutText = 'Manages currency master data including codes, symbols, ISO codes, rounding settings, and related financial accounts. Supports full CRUD operations for synchronizing currency lists, automating exchange rate updates, and enabling multi-currency processing between Business Central and external financial or ERP platforms. Ideal for integrations requiring accurate and up-to-date currency information for global business operations.';

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
                field(symbol; Rec.Symbol)
                {
                    Caption = 'Symbol';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Symbol));
                    end;
                }
                field(amountDecimalPlaces; Rec."Amount Decimal Places")
                {
                    Caption = 'Amount Decimal Places';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Decimal Places"));
                    end;
                }
                field(amountRoundingPrecision; Rec."Invoice Rounding Precision")
                {
                    Caption = 'Amount Rounding Precision';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Amount Rounding Precision"));
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
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        CurrencyRecordRef: RecordRef;
    begin
        Rec.Insert(true);

        CurrencyRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(CurrencyRecordRef, TempFieldSet, CurrentDateTime());
        CurrencyRecordRef.SetTable(Rec);

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
        TempFieldSet.TableNo := Database::Currency;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}





