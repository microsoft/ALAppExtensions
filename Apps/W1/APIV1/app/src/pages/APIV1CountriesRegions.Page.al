namespace Microsoft.API.V1;

using Microsoft.Foundation.Address;
using Microsoft.Integration.Graph;

page 20027 "APIV1 - Countries/Regions"
{
    APIVersion = 'v1.0';
    Caption = 'countriesRegions', Locked = true;
    DelayedInsert = true;
    EntityName = 'countryRegion';
    EntitySetName = 'countriesRegions';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Country/Region";
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
                field(displayName; Rec.Name)
                {
                    Caption = 'name', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Name));
                    end;
                }
                field(addressFormat; Rec."Address Format")
                {
                    Caption = 'addressFormat', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address Format"));
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
        CountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecordRef: RecordRef;
    begin
        CountryRegion.SetRange(Code, Rec.Code);
        if not CountryRegion.IsEmpty() then
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
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.GetBySystemId(Rec.SystemId);

        if Rec.Code = CountryRegion.Code then
            Rec.Modify(true)
        else begin
            CountryRegion.TransferFields(Rec, false);
            CountryRegion.Rename(Rec.Code);
            Rec.TransferFields(CountryRegion);
        end;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::"Country/Region", FieldNo) then
            exit;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::"Country/Region";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}







