// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 3906 "Reten. Pol. Allowed Tbl. Impl."
{
    Access = Internal;
    Permissions = tabledata AllObj = r,
                  tabledata AllObjWithCaption = r,
                  tabledata Field = r,
                  tabledata "Published Application" = r,
                  tabledata "Retention Policy Allowed Table" = rimd;
    EventSubscriberInstance = Manual;

    var
        TableDoesNotExistLbl: Label 'Cannot add Table %1 to the list of allowed tables because it does not exist.', Comment = '%1 = table number';
        ModuleDoesNotExistLbl: Label 'Cannot add table %1 %2 to list of allowed tables because module %3 cannot be found.', Comment = '%1 = table number, %2 = table name, %3 = a guid';
        WrongModuleOwnerLbl: Label 'Cannot add table %1 %2 to the list of allowed tables because the table is not owned by module %3.', Comment = '%1 = table number, %2 = table name, %3 = a guid';
        AllowedTablesModifiedLbl: Label 'The list of allowed tables was updated for Table %1 %2: Default Date Field No.: %3', Comment = '%1 = table number, %2 = table name, %3 = a field number';
        AddTableToAllowedTablesLbl: Label 'Table %1 %2 was added to the list of allowed tables. Default Date Field No.: %3', Comment = '%1 = table number, %2 = table name, %3 = a field number';
        DeleteFromAllowedTablesErrLbl: Label 'Could not remove Table Id %1 from the list of allowed tables as it was not present.', Comment = '%1 = table number';
        DeletedFromAllowedTableLbl: Label 'Removed Table Id %1 from the list of allowed tables', Comment = '%1 = table number';
        AllowedAddingTableLbl: Label 'Allowed adding table %1 to the list of allowed tables.', Comment = '%1 = table number';
        RefusedAddingTableLbl: Label 'Did not allow adding table %1 to the list of allowed tables', Comment = '%1 = table number';
        FailedAddingTableLbl: Label 'Failed to add table %1 %2 to the list of allowed tables', Comment = '%1 = table number, %2 = table name';
        AllowedModifyingTableLbl: Label 'Allowed modifying table %1 in the list of allowed tables.', Comment = '%1 = table number';
        RefusedModifyingTableLbl: Label 'Did not allow modifying of table %1 in the list of allowed tables', Comment = '%1 = table number';
        FailedModifyingTableLbl: Label 'Failed to modify table %1 %2 in the list of allowed tables', Comment = '%1 = table number, %2 = table name';
        DefaultDateFieldDoesNotExistLbl: Label 'The retention policy allowed tables list has a default date field number %1 which does not exist in table %2.', Comment = '%1 = Field number, %2 = table number';
        MinExpirationDateFormulaLbl: Label '<-%1D>', Locked = true;
        MaxDateDateFormulaTxt: Label '<+CY+%1Y>', Locked = true;

    procedure AddToAllowedTables(TableId: Integer; DefaultDateFieldNo: Integer; CallerModuleInfo: ModuleInfo; MandatoryMinRetenDays: Integer; TableFilters: JsonArray): Boolean
    var
        RetenPolFiltering: Enum "Reten. Pol. Filtering";
        RetenPolDeleting: Enum "Reten. Pol. Deleting";
    begin
        exit(AddToAllowedTables(TableId, DefaultDateFieldNo, CallerModuleInfo, MandatoryMinRetenDays, RetenPolFiltering::Default, RetenPolDeleting::Default, TableFilters));
    end;

    procedure AddToAllowedTables(TableId: Integer; DefaultDateFieldNo: Integer; CallerModuleInfo: ModuleInfo; MandatoryMinRetenDays: Integer; RetenPolFiltering: Enum "Reten. Pol. Filtering"; RetenPolDeleting: Enum "Reten. Pol. Deleting"; TableFilters: JsonArray): Boolean
    var
        AllObj: Record AllObj;
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        RetenPolAllowedTblImpl: Codeunit "Reten. Pol. Allowed Tbl. Impl.";
        OutStream: OutStream;
        UpdateAllowedTables: Boolean;
        TableAllowed: Boolean;
    begin
        // check table(s) belongs to module
        if not ModuleOwnsTable(CallerModuleInfo, TableId) then
            exit(false);

        if RetentionPolicyAllowedTable.Get(TableId) then
            UpdateAllowedTables := true;

        RetentionPolicyAllowedTable."Table Id" := TableId;
        RetentionPolicyAllowedTable."Reten. Pol. Filtering " := RetenPolFiltering;
        RetentionPolicyAllowedTable."Reten. Pol. Deleting" := RetenPolDeleting;
        RetentionPolicyAllowedTable."Default Date Field No." := DefaultDateFieldNo;
        RetentionPolicyAllowedTable."Mandatory Min. Reten. Days" := MandatoryMinRetenDays;
        Clear(RetentionPolicyAllowedTable."Table Filters");
        if TableFilters.Count() > 0 then begin
            RetentionPolicyAllowedTable."Table Filters".CreateOutStream(OutStream, TextEncoding::UTF8);
            TableFilters.WriteTo(OutStream);
        end;

        AllObj.Get(AllObj."Object Type"::Table, TableId);
        if UpdateAllowedTables then begin
            BindSubscription(RetenPolAllowedTblImpl);
            TableAllowed := RetentionPolicyAllowedTable.Modify(true);
            UnBindSubscription(RetenPolAllowedTblImpl);

            if TableAllowed then
                RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(AllowedTablesModifiedLbl, RetentionPolicyAllowedTable."Table Id", AllObj."Object Name", RetentionPolicyAllowedTable."Default Date Field No."))
            else
                RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(FailedModifyingTableLbl, RetentionPolicyAllowedTable."Table Id", AllObj."Object Name"), false);

            exit(TableAllowed);
        end;

        BindSubscription(RetenPolAllowedTblImpl);
        TableAllowed := RetentionPolicyAllowedTable.Insert();
        UnBindSubscription(RetenPolAllowedTblImpl);

        if TableAllowed then
            RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(AddTableToAllowedTablesLbl, RetentionPolicyAllowedTable."Table Id", AllObj."Object Name", RetentionPolicyAllowedTable."Default Date Field No."))
        else
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(FailedAddingTableLbl, RetentionPolicyAllowedTable."Table Id", AllObj."Object Name"), false);

        exit(TableAllowed)
    end;

    local procedure ModuleOwnsTable(CallerModuleInfo: ModuleInfo; TableId: Integer): Boolean
    var
        AllObj: Record AllObj;
        PublishedApplication: Record "Published Application";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        TenantInformation: Codeunit "Tenant Information";
    begin
        if not AllObj.Get(AllObj."Object Type"::Table, TableId) then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(TableDoesNotExistLbl, TableId));
            exit(false);
        end;

        PublishedApplication.SetRange("ID", CallerModuleInfo.Id);
        PublishedApplication.SetRange("Version Major", CallerModuleInfo.AppVersion.Major);
        PublishedApplication.SetRange("Version Minor", CallerModuleInfo.AppVersion.Minor);
        PublishedApplication.SetRange("Version Build", CallerModuleInfo.AppVersion.Build);
        PublishedApplication.SetRange("Version Revision", CallerModuleInfo.AppVersion.Revision);
        PublishedApplication.SetFilter("Tenant ID", '%1|%2', '', TenantInformation.GetTenantId());
        if not PublishedApplication.FindFirst() then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(ModuleDoesNotExistLbl, TableId, AllObj."Object Name", CallerModuleInfo.Id));
            exit(false);
        end;

        if AllObj."App Runtime Package ID" <> PublishedApplication."Runtime Package ID" then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(WrongModuleOwnerLbl, TableId, AllObj."Object Name", CallerModuleInfo.Id));
            exit(false);
        end;

        exit(true);
    end;

    procedure RemoveFromAllowedTables(TableId: Integer): Boolean
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if not RetentionPolicyAllowedTable.Get(TableId) then begin
            RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(DeleteFromAllowedTablesErrLbl, RetentionPolicyAllowedTable."Table Id"));
            exit(true);
        end;
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(DeletedFromAllowedTableLbl, RetentionPolicyAllowedTable."Table Id"));
        exit(RetentionPolicyAllowedTable.Delete());
    end;

    procedure IsAllowedTable(TableId: Integer): boolean
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, TableId) then
            exit(RetentionPolicyAllowedTable.Get(TableId));
        exit(false);
    end;

    procedure GetAllowedTables(var AllowedList: List of [Integer])
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
        AllObjWithCaption: Record AllObjWithCaption;
    begin
        if RetentionPolicyAllowedTable.findset(false, false) then
            repeat
                if AllObjWithCaption.Get(AllObjWithCaption."Object Type"::Table, RetentionPolicyAllowedTable."Table Id") then
                    AllowedList.Add(RetentionPolicyAllowedTable."Table Id");
            until RetentionPolicyAllowedTable.Next() = 0;
    end;

    procedure GetRetenPolFiltering(TableId: Integer): Enum "Reten. Pol. Filtering"
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
    begin
        RetentionPolicyAllowedTable.Get(TableId);
        exit(RetentionPolicyAllowedTable."Reten. Pol. Filtering ");
    end;

    procedure GetRetenPolDeleting(TableId: Integer): Enum "Reten. Pol. Deleting"
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
    begin
        RetentionPolicyAllowedTable.Get(TableId);
        exit(RetentionPolicyAllowedTable."Reten. Pol. Deleting");
    end;

    procedure GetDefaultDateFieldNo(TableId: Integer): Integer
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
        Field: Record Field;
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        if not IsAllowedTable(TableId) then
            exit(0);
        RetentionPolicyAllowedTable.Get(TableId);
        // check field exists
        if not Field.Get(TableId, RetentionPolicyAllowedTable."Default Date Field No.") then begin
            RetentionPolicyLog.LogWarning(LogCategory(), StrSubstNo(DefaultDateFieldDoesNotExistLbl, RetentionPolicyAllowedTable."Default Date Field No.", TableId));
            exit(0);
        end;
        exit(RetentionPolicyAllowedTable."Default Date Field No.");
    end;

    procedure GetMandatoryMinimumRetentionDays(TableId: Integer): Integer
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
    begin
        if not IsAllowedTable(TableId) then
            exit(0);
        RetentionPolicyAllowedTable.Get(TableId);
        exit(RetentionPolicyAllowedTable."Mandatory Min. Reten. Days");
    end;

    procedure CalcMinimumExpirationDate(TableId: Integer): Date
    var
        MaxExpirationDateFormula: DateFormula;
        MinRetentionDays: Integer;
    begin
        MinRetentionDays := GetMandatoryMinimumRetentionDays(TableId);
        if MinRetentionDays > 0 then
            exit(CalcDate(StrSubstNo(MinExpirationDateFormulaLbl, GetMandatoryMinimumRetentionDays(TableId)), Today()));

        Evaluate(MaxExpirationDateFormula, StrSubstNo(MaxDateDateFormulaTxt, 9999 - Date2DMY(Today(), 3)));
        exit(CalcDate(MaxExpirationDateFormula, Today()))
    end;

    procedure GetAllowedTables() FilterText: Text
    var
        AllowedList: List of [Integer];
        Count: Integer;
        TableId: Integer;
    begin
        GetAllowedTables(AllowedList);

        Count := AllowedList.Count();
        if Count = 0 then
            exit('');

        AllowedList.Get(1, TableId);
        FilterText := Format(TableId);

        if Count >= 2 then
            foreach TableId in AllowedList.GetRange(2, Count - 1) do
                FilterText += '|' + Format(TableId);
    end;

    procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetentionPeriodEnum: Enum "Retention Period Enum"; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecordRef: RecordRef)
    var
        RetPeriodCalc: DateFormula;
    begin
        Evaluate(RetPeriodCalc, '');
        AddTableFilterToJsonArray(TableFilters, RetentionPeriodEnum, RetPeriodCalc, DateFieldNo, Enabled, Locked, RecordRef);
    end;

    procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetPeriodCalc: DateFormula; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecordRef: RecordRef)
    var
        RetentionPeriodEnum: Enum "Retention Period Enum";
    begin
        AddTableFilterToJsonArray(TableFilters, RetentionPeriodEnum::Custom, RetPeriodCalc, DateFieldNo, Enabled, Locked, RecordRef);
    end;

    procedure AddTableFilterToJsonArray(var TableFilters: JsonArray; RetentionPeriodEnum: Enum "Retention Period Enum"; RetPeriodCalc: DateFormula; DateFieldNo: Integer; Enabled: Boolean; Locked: Boolean; RecordRef: RecordRef)
    var
        JsonObject: JsonObject;
    begin
        // this code must match the parsing code in codeunit 3903 "Retention Policy Setup Impl."
        JsonObject.Add('Table Id', RecordRef.Number);
        JsonObject.Add('Retention Period', Format(RetentionPeriodEnum, 0, 9));
        JsonObject.Add('Ret. Period Calculation', Format(RetPeriodCalc, 0, 2));
        JsonObject.Add('Date Field No.', DateFieldNo);
        JsonObject.Add('Enabled', Enabled);
        JsonObject.Add('Locked', Locked);
        JsonObject.Add('Table Filter', RecordRef.GetView(false));

        TableFilters.add(JsonObject.AsToken())
    end;

    procedure GetTableFilters(TableId: Integer) TableFilters: JsonArray
    var
        RetentionPolicyAllowedTable: Record "Retention Policy Allowed Table";
        InStream: InStream;
    begin
        if not IsAllowedTable(TableId) then
            exit(TableFilters);
        RetentionPolicyAllowedTable.Get(TableId);
        RetentionPolicyAllowedTable.CalcFields("Table Filters");
        if RetentionPolicyAllowedTable."Table Filters".HasValue then begin
            RetentionPolicyAllowedTable."Table Filters".CreateInStream(InStream, TextEncoding::UTF8);
            TableFilters.ReadFrom(InStream);
        end;
        exit(TableFilters);
    end;

    procedure ParseTableFilter(JsonObject: JsonObject; var TableId: Integer; var RetentionPeriodEnum: enum "Retention Period Enum"; var RetPeriodCalc: DateFormula; var DateFieldNo: Integer; var Enabled: Boolean; var Locked: Boolean; var TableFilter: Text)
    var
    begin
        TableId := GetTableId(JsonObject);
        RetentionPeriodEnum := GetRetentionPeriodEnum(JsonObject);
        Evaluate(RetPeriodCalc, GetRetPeriodCalc(JsonObject), 2);
        DateFieldNo := GetDateFieldNo(JsonObject);
        Enabled := GetEnabled(JsonObject);
        Locked := GetLocked(JsonObject);
        TableFilter := GetTableFilter(JsonObject);
    end;

    local procedure GetTableId(JsonObject: JsonObject): Integer
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Table Id', JsonToken);
        exit(jsonToken.AsValue().AsInteger())
    end;

    local procedure GetRetentionPeriodEnum(JsonObject: JsonObject) RetentionPeriodEnum: Enum "Retention Period Enum"
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Retention Period', JsonToken);
        Evaluate(RetentionPeriodEnum, jsonToken.AsValue().AsText(), 9);
    end;

    local procedure GetRetPeriodCalc(JsonObject: JsonObject): Text
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Ret. Period Calculation', JsonToken);
        exit(JsonToken.AsValue().AsText())
    end;

    local procedure GetDateFieldNo(JsonObject: JsonObject): Integer
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Date Field No.', JsonToken);
        exit(jsonToken.AsValue().AsInteger())
    end;

    local procedure GetEnabled(JsonObject: JsonObject): Boolean
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Enabled', JsonToken);
        exit(jsonToken.AsValue().AsBoolean())
    end;

    local procedure GetLocked(JsonObject: JsonObject): Boolean
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Locked', JsonToken);
        exit(jsonToken.AsValue().AsBoolean())
    end;

    local procedure GetTableFilter(JsonObject: JsonObject): Text
    var
        JsonToken: JsonToken;
    begin
        JsonObject.Get('Table Filter', JsonToken);
        exit(jsonToken.AsValue().AsText())
    end;

    local procedure LogCategory(): Enum "Retention Policy Log Category"
    var
        RetentionPolicyLogCategory: Enum "Retention Policy Log Category";
    begin
        exit(RetentionPolicyLogCategory::"Retention Policy - Allowed Tables");
    end;

    /// <Summary>
    /// This is an internal event that only this module is allowed to subscribe to. It is raised by a subscriber to the OnBeforeInsertEvent of the Reten. Pol. Allowed Table table.
    /// The manual subscriber AllowAddtoAllowedList is bound just before the Insert() in procedure AddToAllowedTables.
    /// These elements combined are to ensure that only procedure AddToAllowedTables can insert into the table.
    /// </Summary>
    [InternalEvent(false)]
    internal procedure OnVerifyAddtoAllowedList(TableId: Integer; var InsertAllowed: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reten. Pol. Allowed Tbl. Impl.", 'OnVerifyAddtoAllowedList', '', false, false)]
    local procedure AllowAddtoAllowedList(TableId: Integer; var InsertAllowed: Boolean)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(AllowedAddingTableLbl, TableId));
        InsertAllowed := true;
    end;

    procedure VerifyInsertAllowed(TableId: Integer)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        InsertAllowed: Boolean;
    begin
        OnVerifyAddtoAllowedList(TableId, InsertAllowed);
        if not InsertAllowed then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(RefusedAddingTableLbl, TableId));
    end;

    /// <Summary>
    /// This is an internal event that only this module is allowed to subscribe to. It is raised by a subscriber to the OnBeforeModifyEvent of the Reten. Pol. Allowed Table table.
    /// The manual subscriber AllowModifyAllowedList is bound just before the Modify() in procedure AddToAllowedTables.
    /// These elements combined are to ensure that only procedure AddToAllowedTables can modify the table.
    /// </Summary>
    [InternalEvent(false)]
    internal procedure OnVerifyModifyAllowedList(TableId: Integer; var ModifyAllowed: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Reten. Pol. Allowed Tbl. Impl.", 'OnVerifyModifyAllowedList', '', false, false)]
    local procedure AllowModifyAllowedList(TableId: Integer; var ModifyAllowed: Boolean)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
    begin
        RetentionPolicyLog.LogInfo(LogCategory(), StrSubstNo(AllowedModifyingTableLbl, TableId));
        ModifyAllowed := true;
    end;

    procedure VerifyModifyAllowed(TableId: Integer)
    var
        RetentionPolicyLog: Codeunit "Retention Policy Log";
        ModifyAllowed: Boolean;
    begin
        OnVerifyModifyAllowedList(TableId, ModifyAllowed);
        if not ModifyAllowed then
            RetentionPolicyLog.LogError(LogCategory(), StrSubstNo(RefusedModifyingTableLbl, TableId));
    end;

}