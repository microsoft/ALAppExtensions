// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using System.Automation;
using System.Reflection;

codeunit 18548 "Posting No. Series Mgmt."
{
    var
        GlobalPostingNoSeries: Record "Posting No. Series";
        RecordConditionTxt: Label 'Record Conditions - %1', Comment = '%1 = Table Caption';

    procedure OpenDynamicRequestPage(var PostingNoSeries: Record "Posting No. Series")
    var
        RecordRef: RecordRef;
        RequestFilters: Text;
        ReturnFilters: Text;
        UserClickedOK: Boolean;
    begin
        GlobalPostingNoSeries := PostingNoSeries;
        RecordRef.GetTable(PostingNoSeries);
        RequestFilters := GetRqeuestFilters(RecordRef);
        UserClickedOK := RunDynamicRequestPage(ReturnFilters, RequestFilters, RecordRef);

        if UserClickedOK then
            SetTablesCondition(PostingNoSeries, ReturnFilters);
    end;

    procedure SetTablesCondition(var PostingNoSeries: Record "Posting No. Series"; Filters: Text)
    var
        FiltersOutStream: OutStream;
    begin
        PostingNoSeries.Condition.CreateOutStream(FiltersOutStream);
        FiltersOutStream.Write(Filters);
        PostingNoSeries.Modify(true);
    end;

    procedure GetRqeuestFilters(Recordref: RecordRef) Filters: Text
    var
        ConditionInStream: InStream;
    begin
        GlobalPostingNoSeries.CalcFields(Condition);
        GlobalPostingNoSeries.Condition.CreateInStream(ConditionInStream);
        ConditionInStream.Read(Filters);
    end;

    procedure RunDynamicRequestPage(var ReturnFilters: Text; Filters: Text; var RecordRef: RecordRef): Boolean
    var
        FilterPageBuilder: FilterPageBuilder;
    begin
        if not BuildDynamicRequestPage(FilterPageBuilder, '', GlobalPostingNoSeries."Table ID") then
            exit(false);

        if (Filters <> '') and not (SetViewOnDynamicRequestPage(FilterPageBuilder, Filters, '', GlobalPostingNoSeries."Table ID")) then
            exit(false);

        FilterPageBuilder.PageCaption := StrSubstNo(RecordConditionTxt, GetTableCaption(GlobalPostingNoSeries."Table Id"));

        Commit();
        if not FilterPageBuilder.RunModal() then
            exit(false);

        ReturnFilters := FilterPageBuilder.GetView(GetTableCaption(GlobalPostingNoSeries."Table Id"), false);
        exit(true);
    end;

    procedure BuildDynamicRequestPage(var FilterPageBuilder: FilterPageBuilder; EntityName: Code[20]; TableID: Integer): Boolean
    var
        Name: Text;
    begin
        Name := FilterPageBuilder.AddTable(GetTableCaption(TableID), TableID);
        AddFields(FilterPageBuilder, Name, TableID);
        exit(true);
    end;

    procedure AddFields(var FilterPageBuilder: FilterPageBuilder; Name: Text; TableID: Integer)
    var
        DynamicRequestPageField: Record "Dynamic Request Page Field";
        Field: Record Field;
    begin
        DynamicRequestPageField.SetRange("Table ID", TableID);
        if DynamicRequestPageField.FindSet() then
            repeat
                FilterPageBuilder.AddFieldNo(Name, DynamicRequestPageField."Field ID");
            until DynamicRequestPageField.Next() = 0
        else begin
            Field.SetRange(TableNo, TableID);
            Field.FindFirst();
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

    procedure SetViewOnDynamicRequestPage(
        var FilterPageBuilder: FilterPageBuilder;
        Filters: Text;
        EntityName: Code[20];
        TableID: Integer): Boolean
    var
        Recref: RecordRef;
    begin
        Recref.Open(TableID);
        GetFiltersForTable(Recref, Filters);
        FilterPageBuilder.SetView(GetTableCaption(TableID), Recref.GetView(false));
        Recref.Close();
        Clear(Recref);
        exit(true);
    end;

    procedure GetFiltersForTable(var RecRef: RecordRef; var FilterText: Text): Boolean
    begin
        RecRef.SetView(FilterText);
    end;
}
