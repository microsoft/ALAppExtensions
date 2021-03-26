codeunit 18079 "GST Tests Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Library - Dimension", 'OnGetLocalTablesWithDimSetIDValidationIgnored', '', false, false)]
    local procedure IgoneDimensionCount(var CountOfTablesIgnored: Integer)
    var
        TempAllObj: Record AllObj temporary;
        "Field": Record "Field";
    begin
        Field.SetRange(Class, Field.Class::Normal);
        Field.SetRange(Enabled, true);
        Field.SetRange(RelationTableNo, DATABASE::"Dimension Set Entry");
        Field.SetFilter(TableNo, '%1..%2', 18000, 18999); //Excluding IN tables
        if Field.FindSet() then begin
            TempAllObj."Object Type" := TempAllObj."Object Type"::Table;
            repeat
                TempAllObj."Object ID" := Field.TableNo;
                if TempAllObj.Insert() then;
            until Field.Next() = 0;
            CountOfTablesIgnored += TempAllObj.Count();
        end;
    end;
}