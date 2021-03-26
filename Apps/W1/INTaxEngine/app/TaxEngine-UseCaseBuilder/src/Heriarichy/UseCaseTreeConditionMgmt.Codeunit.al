codeunit 20300 "Use Case Tree Condition Mgmt."
{
    procedure OpenDynamicRequestPage(var UseCaseTreeNode: Record "Use Case Tree Node")
    var
        RequestFilters: Text;
        ReturnFilters: Text;
        UserClickedOK: Boolean;
    begin
        RequestFilters := GetRqeuestFilters(UseCaseTreeNode);
        UserClickedOK := RunDynamicRequestPage(ReturnFilters, RequestFilters, UseCaseTreeNode."Table ID");

        if UserClickedOK then
            SetTablesCondition(UseCaseTreeNode, ReturnFilters);
    end;

    procedure SetTablesCondition(var UseCaseTreeNode: Record "Use Case Tree Node"; Filters: Text)
    var
        FiltersOutStream: OutStream;
    begin
        UseCaseTreeNode.Condition.CreateOutStream(FiltersOutStream);
        FiltersOutStream.Write(Filters);
        UseCaseTreeNode.Modify(true);
    end;

    procedure GetRqeuestFilters(var UseCaseTreeNode: Record "Use Case Tree Node") Filters: Text
    var
        ConditionInStream: InStream;
        Txt: Text;
    begin
        UseCaseTreeNode.CalcFields(Condition);
        UseCaseTreeNode.Condition.CreateInStream(ConditionInStream);
        while not ConditionInStream.EOS do begin
            ConditionInStream.ReadText(Txt);
            Filters += Txt;
        end;
    end;

    procedure RunDynamicRequestPage(var ReturnFilters: Text; Filters: Text; TableID: Integer): Boolean
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not BuildDynamicRequestPage(FilterPageBuilder, '', TableID) then
            exit(false);

        if Filters <> '' then
            if not SetViewOnDynamicRequestPage(FilterPageBuilder, Filters, '', TableID) then
                exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(RecordConditionTxt, GetTableCaption(TableID));

        Commit();
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := FilterPageBuilder.GetView(GetTableCaption(TableID), false);
        exit(true);
    end;

    procedure BuildDynamicRequestPage(var FilterPageBuilder: FilterPageBuilder; EntityName: Code[20]; TableID: Integer): Boolean
    var
        Name: Text;
    begin
        name := FilterPageBuilder.AddTable(GetTableCaption(TableID), TableID);
        AddFields(FilterPageBuilder, Name, TableID);
        exit(true);
    end;

    procedure AddFields(var FilterPageBuilder: FilterPageBuilder; Name: Text; TableID: Integer)
    var
        DynamicRequestPageField: Record "Dynamic Request Page Field";
        Field: Record Field;
    begin
        DynamicRequestPageField.setrange("Table ID", TableID);
        if DynamicRequestPageField.findset() then
            repeat
                FilterPageBuilder.AddFieldNo(Name, DynamicRequestPageField."Field ID");
            until DynamicRequestPageField.next() = 0
        else begin
            Field.setrange(TableNo, TableID);
            Field.findfirst();
            DynamicRequestPageField.Init();
            DynamicRequestPageField.Validate("Table ID", TableID);
            DynamicRequestPageField.Validate("Field ID", Field."No.");
            DynamicRequestPageField.Insert(true);
        end;
    end;

    procedure GetTableCaption(TableID: Integer): Text
    var
        TableMetadata: Record "Table Metadata";
    begin
        TableMetadata.Get(TableID);
        exit(TableMetadata.Caption);
    end;

    procedure SetViewOnDynamicRequestPage(var FilterPageBuilder: FilterPageBuilder; Filters: Text; EntityName: Code[20]; TableID: Integer): Boolean
    var
        Recref: RecordRef;
    begin
        Recref.Open(TableID);
        GetFiltersForTable(Recref, Filters);
        FilterPageBuilder.SetView(GetTableCaption(TableID), Recref.GETVIEW(false));
        Recref.Close();
        clear(Recref);
        exit(true);
    end;

    procedure GetFiltersForTable(var RecRef: RecordRef; FilterText: Text): Boolean
    begin
        RecRef.SetView(FilterText);
    end;

    var
        RecordConditionTxt: Label 'Record Conditions - %1', Comment = '%1 = Table Caption';
}