namespace Microsoft.API.V2;

using Microsoft.Foundation.Address;
using Microsoft.Integration.Graph;

page 30027 "APIV2 - Countries/Regions"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Countries Region';
    EntitySetCaption = 'Countries Regions';
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
                field(displayName; Rec.Name)
                {
                    Caption = 'Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Name));
                    end;
                }
                field(addressFormat; Rec."Address Format")
                {
                    Caption = 'Address Format';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Address Format"));
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
        CountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        CountryRegionRecordRef: RecordRef;
    begin
        CountryRegion.SetRange(Code, Rec.Code);
        if not CountryRegion.IsEmpty() then
            Rec.Insert();

        Rec.Insert(true);

        CountryRegionRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(CountryRegionRecordRef, TempFieldSet, CurrentDateTime());
        CountryRegionRecordRef.SetTable(Rec);

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

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::"Country/Region";
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}






