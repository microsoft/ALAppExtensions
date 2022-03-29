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
                field(displayName; Name)
                {
                    Caption = 'Name';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Name));
                    end;
                }
                field(addressFormat; "Address Format")
                {
                    Caption = 'Address Format';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Address Format"));
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
        CountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        CountryRegionRecordRef: RecordRef;
    begin
        CountryRegion.SetRange(Code, Code);
        if not CountryRegion.IsEmpty() then
            Insert();

        Insert(true);

        CountryRegionRecordRef.GetTable(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(CountryRegionRecordRef, TempFieldSet, CurrentDateTime());
        CountryRegionRecordRef.SetTable(Rec);

        Modify(true);
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.GetBySystemId(SystemId);

        if Code = CountryRegion.Code then
            Modify(true)
        else begin
            CountryRegion.TransferFields(Rec, false);
            CountryRegion.Rename(Code);
            TransferFields(CountryRegion);
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






