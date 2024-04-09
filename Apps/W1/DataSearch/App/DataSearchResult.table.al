namespace Microsoft.Foundation.DataSearch;

using Microsoft.Utilities;
using System.Reflection;

table 2680 "Data Search Result"
{
    DataClassification = CustomerContent;
    TableType = Temporary;
    Permissions = tabledata "Data Search Setup (Table)" = rm;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Table No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(2; "Table Subtype"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(3; "Entry No."; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Parent ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Parent ID';
        }
        field(5; Description; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Line Type"; Option)
        {
            OptionMembers = Header,Data,MoreHeader,MoreData;
            DataClassification = SystemMetadata;
        }
        field(7; "No. of Hits"; Integer)
        {
            Caption = 'No. of Hits';
            DataClassification = CustomerContent;
        }
        field(8; "Table/Type ID"; Integer)
        {
            Caption = 'Table/Type ID';
            DataClassification = SystemMetadata;
        }
        field(10; "Table Caption"; Text[250])
        {
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Caption = 'Table Caption';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Table Subtype", "Entry No.")
        {
        }
        key(Key2; "No. of Hits")
        {
        }
    }

    var
        linesLbl: Label 'lines';

    internal procedure GetStyleExpr(): Text
    begin
        case "Line Type" of
            "Line Type"::Header:
                exit('Strong');
            "Line Type"::Data:
                exit('Standard');
            "Line Type"::MoreHeader:
                exit('AttentionAccent');
            "Line Type"::MoreData:
                exit('');
        end;
        exit('');
    end;

    internal procedure GetTableCaption(): Text
    var
        PageMetadata: Record "Page Metadata";
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        PageNo: Integer;
        PageCaption: Text;
    begin
        PageNo := DataSearchObjectMapping.GetListPageNo(Rec."Table No.", Rec."Table Subtype");
        if PageNo <> 0 then
            if PageMetadata.Get(PageNo) then
                PageCaption := PageMetadata.Caption;
        if PageCaption = '' then begin
            Rec.CalcFields("Table Caption");
            PageCaption := Rec."Table Caption";
        end;
        if PageCaption = '' then
            PageCaption := Format(Rec."Table No.");
        if DataSearchObjectMapping.IsSubTable(Rec."Table No.") then
            PageCaption += ' - ' + linesLbl;
        exit(PageCaption);
    end;

    internal procedure LogUserHit(RoleCenterID: Integer; TableNo: Integer; TableSubtype: Integer)
    var
        DataSearchSetupTable: Record "Data Search Setup (Table)";
    begin
        DataSearchSetupTable.LockTable();
        if DataSearchSetupTable.Get(RoleCenterID, TableNo, TableSubtype) then begin
            DataSearchSetupTable."No. of Hits" += 1;
            if DataSearchSetupTable.Modify() then;
        end;
        Commit();
    end;

    internal procedure ShowRecord(RoleCenterID: Integer; SearchString: Text)
    var
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        DataSearchResultRecords: page "Data Search Result Records";
        RecRef: RecordRef;
        PageNo: Integer;
    begin
        case Rec."Line Type" of
            Rec."Line Type"::Header:
                begin
                    PageNo := DataSearchObjectMapping.GetListPageNo(Rec."Table No.", Rec."Table Subtype");
                    if PageNo > 0 then
                        Page.Run(PageNo);
                end;
            Rec."Line Type"::MoreHeader:
                begin
                    RecRef.Open(Rec."Table No.");
                    DataSearchResultRecords.SetSourceRecRef(RecRef, Rec."Table Subtype", SearchString, GetTableCaption());
                    DataSearchResultRecords.Run();
                end;
            Rec."Line Type"::Data:
                begin
                    RecRef.Open(Rec."Table No.");
                    if not RecRef.GetBySystemId(Rec."Parent ID") then
                        exit;
                    ShowPage(RecRef, Rec."Table Subtype");
                end;
        end;
        LogUserHit(RoleCenterID, Rec."Table No.", rec."Table Subtype");
    end;

    internal procedure ShowPage(var RecRef: RecordRef)
    begin
        ShowPage(RecRef, Rec."Table Subtype");
    end;

    internal procedure ShowPage(RecRef: RecordRef; TableType: Integer)
    var
        TableMetadata: Record "Table Metadata";
        PageMetaData: Record "Page Metadata";
        DataSearchObjectMapping: Codeunit "Data Search Object Mapping";
        PageManagement: Codeunit "Page Management";
        DataSearchEvents: Codeunit "Data Search Events";
        RecRefNoFilter: RecordRef;
        RecVariant: Variant;
        PageNo: Integer;
    begin
        RecRefNoFilter := RecRef;
        RecRefNoFilter.Reset();
        DataSearchObjectMapping.MapLinesRecToHeaderRec(RecRefNoFilter);
        RecVariant := RecRefNoFilter;
        if not PageManagement.PageRun(RecVariant) then begin
            DataSearchEvents.OnGetCardPageNo(RecRef.Number, TableType, PageNo);
            if PageNo = 0 then begin
                if not TableMetadata.Get(RecRef.Number) then
                    exit;
                PageNo := TableMetadata.LookupPageID;
                if not PageMetaData.Get(PageNo) then
                    exit;
                if PageMetaData.CardPageID <> 0 then
                    PageNo := PageMetaData.CardPageID;
            end;
            Page.Run(PageNo, RecVariant);
        end;
    end;
}