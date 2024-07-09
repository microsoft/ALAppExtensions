namespace Microsoft.Foundation.DataSearch;

using System.Reflection;

codeunit 2680 "Data Search in Table"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        SetViewLbl: Label 'SORTING(%1) ORDER(Descending)', Comment = 'Do not translate! It will break the feature. %1 is a field name', Locked = true;

    trigger OnRun()
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
        RecRef: RecordRef;
        SearchString: Text;
        Results: Dictionary of [Text, Text];
        Params: Dictionary of [Text, Text];
        TableNo: Integer;
        TableSubtype: Integer;
        TableTypeID: Integer;
        CancelSearch: Boolean;
    begin
        Params := Page.GetBackgroundParameters();
        if Params.Count = 0 then
            exit;
        if not Evaluate(TableTypeID, Params.Get('TableTypeID')) then
            exit;
        if not Params.Get('SearchString', SearchString) then
            exit;
        DataSearchSetupTable.SetRange("Table/Type ID", TableTypeID);
        if not DataSearchSetupTable.FindFirst() then
            exit;
        TableNo := DataSearchSetupTable."Table No.";
        TableSubtype := DataSearchSetupTable."Table Subtype";

        RecRef.Open(TableNo);
        CancelSearch := not RecRef.ReadPermission();
        if not CancelSearch then
            CancelSearch := RecRef.IsEmpty();
        RecRef.Close();
        if CancelSearch then
            exit;

        FindInTable(TableNo, TableSubtype, SearchString, Results);
        Page.SetBackgroundTaskResult(Results);
    end;

    procedure FindInTable(TableNo: Integer; TableType: Integer; SearchString: Text; var Results: Dictionary of [Text, Text])
    var
        TableMetadata: Record "Table Metadata";
        DataSearchSetupField: Record "Data Search Setup (Field)";
        FieldList: List of [Integer];
        SearchStrings: List of [Text];
    begin
        if SearchString = '' then
            exit;
        if TableNo = 0 then
            exit;
        if not TableMetadata.Get(TableNo) then
            exit;
        if TableMetadata.DataIsExternal then
            exit;
        if TableMetadata.TableType <> TableMetadata.TableType::Normal then
            exit;
        if TableMetadata.ObsoleteState = TableMetadata.ObsoleteState::Removed then
            exit;

        SplitSearchString(SearchString, SearchStrings);

        Clear(FieldList);
        DataSearchSetupField.SetRange("Table No.", TableNo);
        DataSearchSetupField.SetLoadFields("Field No.");
        if not DataSearchSetupField.FindSet() then
            exit;
        repeat
            FieldList.Add(DataSearchSetupField."Field No.");
        until DataSearchSetupField.Next() = 0;

        SearchTable(TableNo, TableType, FieldList, SearchStrings, Results);
    end;

    internal procedure SplitSearchString(SearchString: Text; var SearchStrings: List of [Text])
    var
        i: Integer;
    begin
        i := StrPos(SearchString, ' ');
        while i > 0 do begin
            SearchStrings.Add(CopyStr(SearchString, 1, i - 1));
            SearchString := Delchr(CopyStr(SearchString, i + 1), '<>', ' ');
            i := StrPos(SearchString, ' ');
        end;
        SearchStrings.Add(SearchString);
    end;

    local procedure IsTextSearch(SearchString: Text): Boolean
    var
        i: integer;
    begin
        for i := 1 to StrLen(SearchString) do
            if SearchString[i] <> UpperCase(SearchString[i]) then
                exit(true);
    end;

    internal procedure SetFiltersOnRecRef(var RecRef: RecordRef; TableType: Integer; SearchString: Text)
    var
        FieldList: List of [Integer];
    begin
        if RecRef.Number = 0 then
            exit;
        GetFieldList(RecRef, FieldList);
        SetListedFieldFiltersOnRecRef(RecRef, TableType, SearchString, IsTextSearch(SearchString), FieldList);
    end;

    internal procedure GetFieldList(var RecRef: RecordRef; FieldList: List of [Integer])
    var
        DataSearchSetupField: Record "Data Search Setup (Field)";
    begin
        DataSearchSetupField.SetRange("Table No.", RecRef.Number);
        if DataSearchSetupField.FindSet() then
            repeat
                FieldList.Add(dataSearchSetupField."Field No.")
            until DataSearchSetupField.Next() = 0;
    end;

    local procedure SetListedFieldFiltersOnRecRef(var RecRef: RecordRef; TableType: Integer; SearchString: Text; UseTextSearch: Boolean; var FieldList: List of [Integer])
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        FldRef: FieldRef;
        FieldNo: Integer;
        LoadFieldsSet: Boolean;
        UseWildCharSearch: Boolean;
    begin
        if RecRef.Number = 0 then
            exit;

        FieldNo := DataSearchObjectMapping.GetTypeNoField(RecRef.Number);

        if FieldNo > 0 then
            DataSearchObjectMapping.SetTypeFilterOnRecRef(RecRef, TableType, FieldNo);

        if SearchString[1] = '*' then begin
            UseWildCharSearch := true;
            SearchString := DelChr(SearchString, '<', '*');
        end;
        RecRef.FilterGroup(-1); // 'OR' group
        foreach FieldNo in FieldList do
            if RecRef.FieldExist(FieldNo) then begin
                FldRef := RecRef.Field(FieldNo); 
                if FldRef.Length >= strlen(SearchString) then begin
                    if not UseWildCharSearch and FldRef.IsOptimizedForTextSearch then
                        FldRef.SetFilter('&&' + SearchString + '*')
                    else
                        if UseTextSearch then
                            if FldRef.Type = FieldType::Code then
                                FldRef.SetFilter('*' + UpperCase(SearchString) + '*')
                            else
                                FldRef.SetFilter('@*' + SearchString + '*')
                        else
                            FldRef.SetFilter('*' + SearchString + '*');
                    if LoadFieldsSet then
                        RecRef.AddLoadFields(FieldNo)
                    else
                        RecRef.SetLoadFields(FieldNo);
                    LoadFieldsSet := true;
                end;
            end;
        RecRef.FilterGroup(0);
    end;

    local procedure SearchTable(TableNo: Integer; TableType: Integer; var FieldList: List of [Integer]; var SearchStrings: List of [Text]; var Results: Dictionary of [Text, Text])
    var
        DataSearchEvents: Codeunit "Data Search Events";
        [SecurityFiltering(SecurityFilter::Filtered)]
        RecRef: RecordRef;
        FldRef: FieldRef;
        Description: TextBuilder;
        i: Integer;
        more: Boolean;
        first: Boolean;
        UseTextSearch: Boolean;
        SearchString: Text;
        SearchString1: Text;
        FieldMatchString: Text;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        DataSearchEvents.OnBeforeSearchTableProcedure(TableNo, TableType, FieldList, SearchStrings, Results, IsHandled);
        if IsHandled then
            exit;

        SearchStrings.Get(1, SearchString1);
        UseTextSearch := IsTextSearch(SearchString1);

        RecRef.Open(TableNo);
        FldRef := RecRef.Field(RecRef.SystemModifiedAtNo);
        RecRef.SetView(StrSubstNo(SetViewLbl, FldRef.Name));
        SetListedFieldFiltersOnRecRef(RecRef, TableType, SearchString1, UseTextSearch, FieldList);
        DataSearchEvents.OnBeforeSearchTable(RecRef);
        if RecRef.FindSet() then
            repeat
                FldRef := RecRef.Field(RecRef.SystemIdNo);
                if not Results.ContainsKey(Format(FldRef.Value)) then
                    if IsFullMatch(RecRef, SearchStrings, FieldList) then begin
                        Description.Clear();
                        Description.Append(GetKeyText(RecRef));
                        Description.Append(': ');
                        first := true;
                        foreach SearchString in SearchStrings do begin
                            if first then
                                first := false
                            else
                                Description.Append(', ');
                            FieldMatchString := GetFirstFieldMatch(RecRef, SearchString, FieldList);
                            if not first then begin
                                if StrPos(Description.ToText(), CopyStr(FieldMatchString, 1, StrPos(FieldMatchString, ':'))) < 1 then
                                    Description.Append(FieldMatchString);
                            end else
                                Description.Append(FieldMatchString);
                        end;
                        Results.Add(Format(FldRef.Value), Description.ToText());
                        i += 1;
                    end;
                if i < 4 then
                    more := RecRef.Next() > 0;
            until not more or (i >= 4);
    end;

    procedure IsFullMatch(var RecRef: RecordRef; var SearchStrings: List of [Text]; var FieldList: List of [Integer]): Boolean
    var
        SearchString: Text;
        IsMatch: Boolean;
    begin
        IsMatch := true;
        foreach SearchString in SearchStrings do
            if IsMatch then
                IsMatch := DoesAnyFieldMatch(RecRef, SearchString, FieldList)
            else
                exit(false);
        exit(IsMatch);
    end;

    local procedure DoesAnyFieldMatch(var RecRef: RecordRef; SearchString: Text; var FieldList: List of [Integer]): Boolean
    var
        FldRef: FieldRef;
        FieldNo: Integer;
    begin
        foreach FieldNo in FieldList do
            if RecRef.FieldExist(FieldNo) then begin
                FldRef := RecRef.Field(FieldNo);
                if StrPos(UpperCase(Format(FldRef.Value)), UpperCase(DelChr(SearchString, '=', '@*'))) > 0 then
                    exit(true);
            end;
        exit(false);
    end;

    local procedure GetKeyText(var RecRef: RecordRef): Text
    var
        TableMetadata: Record "Table Metadata";
        FldRef: FieldRef;
        KeyRef: KeyRef;
        FieldList: List of [Integer];
        KeyText: TextBuilder;
        FieldNo: Integer;
    begin
        if TableMetadata.Get(RecRef.Number) then;
        if TableMetadata.DataCaptionFields <> '' then begin // comma-separated list of fields
            SplitStringToIntegerList(TableMetadata.DataCaptionFields, FieldList);
            foreach FieldNo in FieldList do begin
                FldRef := RecRef.Field(FieldNo);
                if KeyText.Length() > 0 then
                    KeyText.Append(' ');
                KeyText.Append(Format(FldRef.Value));
            end;
        end else begin
            KeyRef := RecRef.KeyIndex(1);
            for FieldNo := 1 to KeyRef.FieldCount do begin
                FldRef := KeyRef.FieldIndex(FieldNo);
                if KeyText.Length() > 0 then
                    KeyText.Append(' ');
                KeyText.Append(Format(FldRef.Value));
            end;
        end;
        exit(KeyText.ToText());
    end;

    local procedure SplitStringToIntegerList(String: Text; FieldList: List of [Integer])
    var
        Remainder: Text;
        i, j : Integer;
    begin
        Remainder := String;
        j := StrPos(Remainder, ',');
        while j > 1 do begin
            if Evaluate(i, CopyStr(Remainder, 1, j - 1)) then
                FieldList.Add(i);
            Remainder := CopyStr(Remainder, j + 1);
            j := StrPos(Remainder, ',');
        end;
        if Remainder <> '' then
            if Evaluate(i, Remainder) then
                FieldList.Add(i);
    end;

    local procedure GetFirstFieldMatch(var RecRef: RecordRef; SearchString: Text; var FieldList: List of [Integer]): Text
    var
        Field: Record Field;
        FldRef: FieldRef;
        FieldNo: Integer;
    begin
        foreach FieldNo in FieldList do
            if RecRef.FieldExist(FieldNo) then begin
                FldRef := RecRef.Field(FieldNo);
                if StrPos(UpperCase(Format(FldRef.Value)), UpperCase(DelChr(SearchString, '=', '@*'))) > 0 then begin
                    Field.Get(RecRef.Number, FieldNo);
                    exit(Field."Field Caption" + ': ' + Format(FldRef.Value));
                end;
            end;
        exit('');
    end;
}