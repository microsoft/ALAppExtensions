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
                field(displayName; Name)
                {
                    Caption = 'name', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO(Name));
                    end;
                }
                field(addressFormat; "Address Format")
                {
                    Caption = 'addressFormat', Locked = true;

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FIELDNO("Address Format"));
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
        CountryRegion: Record "Country/Region";
        GraphMgtGeneralTools: Codeunit "Graph Mgt - General Tools";
        RecRef: RecordRef;
    begin
        CountryRegion.SETRANGE(Code, Code);
        IF NOT CountryRegion.ISEMPTY() THEN
            INSERT();

        INSERT(TRUE);

        RecRef.GETTABLE(Rec);
        GraphMgtGeneralTools.ProcessNewRecordFromAPI(RecRef, TempFieldSet, CURRENTDATETIME());
        RecRef.SETTABLE(Rec);

        MODIFY(TRUE);
        EXIT(FALSE);
    end;

    trigger OnModifyRecord(): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.GetBySystemId(SystemId);

        IF Code = CountryRegion.Code THEN
            MODIFY(TRUE)
        ELSE BEGIN
            CountryRegion.TRANSFERFIELDS(Rec, FALSE);
            CountryRegion.RENAME(Code);
            TRANSFERFIELDS(CountryRegion);
        END;
    end;

    var
        TempFieldSet: Record 2000000041 temporary;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        IF TempFieldSet.GET(DATABASE::"Country/Region", FieldNo) THEN
            EXIT;

        TempFieldSet.INIT();
        TempFieldSet.TableNo := DATABASE::"Country/Region";
        TempFieldSet.VALIDATE("No.", FieldNo);
        TempFieldSet.INSERT(TRUE);
    end;
}






