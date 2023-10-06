// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.NoSeries;
using Microsoft.Inventory.Location;
using System.Reflection;

codeunit 18201 "GST Distribution Subcsribers"
{
    var
        IntrastateInterstateErr: Label '%1 is already true for GST Component Code: %2 Distribution Component Code: %3.', Comment = '%1 = Intrastate Distribution , %2 = GST Component Code , %3 = Distribution Component Code';
        UpdateDimQst: Label 'You may have changed a dimension.Do you want to update the lines?';
        SamePriorityErr: Label 'Priority cannot be duplicate.';
        ZeroPriorityErr: Label 'Priority cannot be Zero.';
        PostingNoSeriesNotDefinedErr: Label 'Posting no. series not defined, in posting no. series setup.';

    local procedure GetLastPriority(GSTComponentCode: Code[30]): Integer
    var
        GSTClaimSetoff: Record "GST Claim Setoff";
    begin
        GSTClaimSetoff.SetCurrentKey(Priority);
        GSTClaimSetoff.SetRange("GST Component Code", GSTComponentCode);
        if GSTClaimSetoff.FindLast() then
            exit(GSTClaimSetoff.Priority + 1);

        exit(1);
    end;

    local procedure IsZeroPriority(GSTComponentCode: Code[30]): Boolean
    var
        GSTClaimSetoff: Record "GST Claim Setoff";
    begin
        GSTClaimSetoff.SetRange("GST Component Code", GSTComponentCode);
        GSTClaimSetoff.SetRange(Priority, 0);
        exit(not GSTClaimSetoff.IsEmpty());
    end;

    local procedure IsSamePriority(GSTComponentCode: Code[30]; GSTPriority: Integer): Boolean
    var
        GSTClaimSetoff: Record "GST Claim Setoff";
    begin
        GSTClaimSetoff.SetCurrentKey(Priority);
        GSTClaimSetoff.SetRange("GST Component Code", GSTComponentCode);
        GSTClaimSetoff.SetRange(Priority, GSTPriority);
        exit(not GSTClaimSetoff.IsEmpty());
    end;

    //GST Component Distribution Validation - Definition
    local procedure IntrastateDistribution(var GSTComponentDistribution: Record "GST Component Distribution")
    var
        GSTComponentDistribution2: Record "GST Component Distribution";
    begin
        GSTComponentDistribution2.Reset();
        GSTComponentDistribution2.SetRange("GST Component Code", GSTComponentDistribution."GST Component Code");
        GSTComponentDistribution2.SetFilter("Distribution Component Code", '<>%1', GSTComponentDistribution."Distribution Component Code");
        GSTComponentDistribution2.SetRange("Intrastate Distribution", true);
        if GSTComponentDistribution2.FindFirst() then
            Error(
                IntrastateInterstateErr,
                GSTComponentDistribution.FieldCaption(GSTComponentDistribution."Intrastate Distribution"),
                GSTComponentDistribution."GST Component Code",
                GSTComponentDistribution2."Distribution Component Code");
    end;

    local procedure InterstateDistribution(var GSTComponentDistribution: Record "GST Component Distribution")
    var
        GSTCompDistribution2: Record "GST Component Distribution";
    begin
        GSTCompDistribution2.Reset();
        GSTCompDistribution2.SetRange("GST Component Code", GSTComponentDistribution."GST Component Code");
        GSTCompDistribution2.SetFilter("Distribution Component Code", '<>%1', GSTComponentDistribution."Distribution Component Code");
        GSTCompDistribution2.SetRange("Interstate Distribution", true);
        if GSTCompDistribution2.FindFirst() then
            Error(
                  IntrastateInterstateErr,
                  GSTComponentDistribution.FieldCaption(GSTComponentDistribution."Interstate Distribution"),
                  GSTComponentDistribution."GST Component Code",
                  GSTCompDistribution2."Distribution Component Code");
    end;

    //GST Distribution Header Validation - Definition
    local procedure OnGSTDistHeaderInsert(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeries: Record "No. Series";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if GSTDistributionHeader."No." = '' then begin
            GeneralLedgerSetup.Get();
            if GeneralLedgerSetup."GST Distribution Nos." <> '' then begin
                GeneralLedgerSetup.TestField("GST Distribution Nos.");
                NoSeries.Get(GeneralLedgerSetup."GST Distribution Nos.");
                GSTDistributionHeader."No." := NoSeriesManagement.GetNextNo(NoSeries.Code, WorkDate(), true);
                GSTDistributionHeader."No. Series" := GeneralLedgerSetup."GST Distribution Nos.";
            end;
        end;

        GSTDistributionHeader."Creation Date" := WorkDate();
        GSTDistributionHeader."User ID" := CopyStr(UserId(), 1, MaxStrLen(GSTDistributionHeader."User ID"));
        GSTDistributionHeader."Posting Date" := WorkDate();
    end;

    local procedure PostingDate(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        GSTDistributionLine: Record "GST Distribution Line";
    begin
        if not GSTDistributionHeader.Reversal then
            GSTDistributionHeader.TestField("Total Amout Applied for Dist.", 0)
        else
            if GSTDistributionLinesExist(GSTDistributionHeader."No.") then begin
                GSTDistributionLine.Reset();
                GSTDistributionLine.SetRange("Distribution No.", GSTDistributionHeader."No.");
                if GSTDistributionLine.FindSet() then
                    GSTDistributionLine.ModifyAll("Posting Date", GSTDistributionHeader."Posting Date");
            end;
    end;

    local procedure GSTDistributionLinesExist(No: Code[20]): Boolean
    var
        GSTDistributionLine: Record "GST Distribution Line";
    begin
        GSTDistributionLine.SetRange("Distribution No.", No);
        exit(GSTDistributionLine.IsEmpty());
    end;

    local procedure DistDocumentType(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        Location: Record location;
        Record: Variant;
    begin
        GSTDistributionHeader.TestField("Total Amout Applied for Dist.", 0);
        GSTDistributionHeader.TestField("From Location Code");
        Location.Get(GSTDistributionHeader."From Location Code");

        case GSTDistributionHeader."Dist. Document Type" of
            GSTDistributionHeader."Dist. Document Type"::Invoice:
                begin
                    Record := GSTDistributionHeader;
                    GetDistributionNoSeriesCode(Record);
                    GSTDistributionHeader := Record;
                    if GSTDistributionHeader."Posting No. Series" = '' then
                        Error(PostingNoSeriesNotDefinedErr);

                    GSTDistributionHeader."ISD Document Type" := GSTDistributionHeader."ISD Document Type"::Invoice;
                end;
            GSTDistributionHeader."Dist. Document Type"::"Credit Memo":
                begin
                    Record := GSTDistributionHeader;
                    GetDistributionNoSeriesCode(Record);
                    GSTDistributionHeader := Record;
                    if GSTDistributionHeader."Posting No. Series" = '' then
                        Error(PostingNoSeriesNotDefinedErr);

                    GSTDistributionHeader."ISD Document Type" := GSTDistributionHeader."ISD Document Type"::"Credit Memo";
                end;
        end;
    end;

    local procedure ReversalInvoiceNo(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetRange("Dist. Reverse Document No.", GSTDistributionHeader."No.");
        DetailedGSTLedgerEntry.SetRange("Distributed Reversed", false);
        DetailedGSTLedgerEntry.SetFilter("Dist. Document No.", '<>%1', GSTDistributionHeader."Reversal Invoice No.");
        DetailedGSTLedgerEntry.ModifyAll("Dist. Reverse Document No.", '');
        InsertDistHeaderReversal(GSTDistributionHeader);
        InsertDistLineReversal(GSTDistributionHeader);
    end;

    local procedure ValidateShortcutDimCode(FieldNumber: Integer; var ShortcutDimCode: Code[20]; var GSTDistributionHeader: Record "GST Distribution Header")
    var
        DimensionManagement: Codeunit DimensionManagement;
        OldDimSetID: Integer;
    begin
        OldDimSetID := GSTDistributionHeader."Dimension Set ID";
        DimensionManagement.ValidateShortcutDimValues(FieldNumber, ShortcutDimCode, GSTDistributionHeader."Dimension Set ID");
        if GSTDistributionHeader."No." <> '' then
            GSTDistributionHeader.Modify();

        if OldDimSetID <> GSTDistributionHeader."Dimension Set ID" then begin
            GSTDistributionHeader.Modify();
            if GSTDistributionLinesExist(GSTDistributionHeader."No.") then
                UpdateAllLineDim(GSTDistributionHeader."Dimension Set ID", OldDimSetID, GSTDistributionHeader."No.");
        end;
    end;

    local procedure UpdateAllLineDim(NewParentDimSetID: Integer; OldParentDimSetID: Integer; DisTributionNo: Code[20])
    var
        GSTDistributionLine: Record "GST Distribution Line";
        DimensionManagement: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        if NewParentDimSetID = OldParentDimSetID then
            exit;

        if not Confirm(UpdateDimQst) then
            exit;

        GSTDistributionLine.SetRange("Distribution No.", "DisTributionNo");
        GSTDistributionLine.LockTable();
        if GSTDistributionLine.FindSet() then
            repeat
                NewDimSetID := DimensionManagement.GetDeltaDimSetID(GSTDistributionLine."Dimension Set ID", NewParentDimSetID, OldParentDimSetID);
                if GSTDistributionLine."Dimension Set ID" <> NewDimSetID then begin
                    GSTDistributionLine."Dimension Set ID" := NewDimSetID;
                    DimensionManagement.UpdateGlobalDimFromDimSetID(
                        GSTDistributionLine."Dimension Set ID",
                        GSTDistributionLine."Shortcut Dimension 1 Code",
                        GSTDistributionLine."Shortcut Dimension 2 Code");
                    GSTDistributionLine.Modify();
                end;

            until GSTDistributionLine.Next() = 0;
    end;

    local procedure FromLocationCode(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        Location: Record Location;
    begin
        GSTDistributionHeader.TestField("Total Amout Applied for Dist.", 0);
        if Location.Get(GSTDistributionHeader."From Location Code") then begin
            GSTDistributionHeader."From GSTIN No." := Location."GST Registration No.";
            case GSTDistributionHeader."Dist. Document Type" of
                GSTDistributionHeader."Dist. Document Type"::Invoice:
                    GSTDistributionHeader."ISD Document Type" := GSTDistributionHeader."ISD Document Type"::Invoice;
                GSTDistributionHeader."Dist. Document Type"::"Credit Memo":
                    GSTDistributionHeader."ISD Document Type" := GSTDistributionHeader."ISD Document Type"::"Credit Memo";
            end;

        end else begin
            GSTDistributionHeader."From GSTIN No." := '';
            GSTDistributionHeader."Posting No. Series" := '';
        end;
    end;

    local procedure InsertDistHeaderReversal(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        PostedGSTDistributionHeader: Record "Posted GST Distribution Header";
        Location: Record Location;
        GSTDistribution: Codeunit "GST Distribution";
    begin
        GSTDistributionHeader.TestField("Posting Date");
        if GSTDistributionHeader."Reversal Invoice No." <> '' then begin
            GSTDistribution.DeleteGSTDistributionLine(GSTDistributionHeader."No.");
            PostedGSTDistributionHeader.Get(GSTDistributionHeader."Reversal Invoice No.");

            GSTDistributionHeader."From GSTIN No." := PostedGSTDistributionHeader."From GSTIN No.";
            GSTDistributionHeader."Creation Date" := WorkDate();
            GSTDistributionHeader."User ID" := CopyStr(UserId(), 1, MaxStrLen(GSTDistributionHeader."User ID"));
            GSTDistributionHeader."From Location Code" := PostedGSTDistributionHeader."From Location Code";
            GSTDistributionHeader."Dist. Document Type" := PostedGSTDistributionHeader."Dist. Document Type";
            Location.Get(GSTDistributionHeader."From Location Code");
            if PostedGSTDistributionHeader."Dist. Document Type" = PostedGSTDistributionHeader."Dist. Document Type"::Invoice then begin
                GSTDistributionHeader."ISD Document Type" := GSTDistributionHeader."ISD Document Type"::"Credit Memo";
                GSTDistributionHeader."Posting No. Series" := Location."Posted Dist. Cr. Memo Nos.";
            end else begin
                GSTDistributionHeader."ISD Document Type" := GSTDistributionHeader."ISD Document Type"::Invoice;
                GSTDistributionHeader."Posting No. Series" := Location."Posted Dist. Invoice Nos.";
            end;

            GSTDistributionHeader."Dist. Credit Type" := PostedGSTDistributionHeader."Dist. Credit Type";
            GSTDistributionHeader."Total Amout Applied for Dist." := 0;
        end else begin
            GSTDistributionHeader."From GSTIN No." := '';
            GSTDistributionHeader."Posting Date" := 0D;
            GSTDistributionHeader."Dist. Document Type" := GSTDistributionHeader."Dist. Document Type"::" ";
            GSTDistributionHeader."From Location Code" := '';
            GSTDistributionHeader."Total Amout Applied for Dist." := 0;
            GSTDistribution.DeleteGSTDistributionLine(GSTDistributionHeader."No.");
        end;
    end;

    local procedure InsertDistLineReversal(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        PostedGSTDistributionLine: Record "Posted GST Distribution Line";
        GSTDistributionHeader2: Record "GST Distribution Header";
        GSTDistributionLine: Record "GST Distribution Line";
    begin
        GSTDistributionHeader2.Get(GSTDistributionHeader."No.");
        PostedGSTDistributionLine.SetRange("Distribution No.", GSTDistributionHeader."Reversal Invoice No.");
        if PostedGSTDistributionLine.FindSet() then
            repeat
                GSTDistributionLine.Init();
                GSTDistributionLine.TransferFields(PostedGSTDistributionLine);
                GSTDistributionLine."Distribution No." := GSTDistributionHeader."No.";
                GSTDistributionLine."Posting Date" := GSTDistributionHeader2."Posting Date";
                GSTDistributionLine."Distribution Amount" := 0;
                GSTDistributionLine.Insert(true);
            until PostedGSTDistributionLine.Next() = 0;
    end;

    local procedure GetDistributionPostingNoSeries(var GSTDistributionHeader: Record "GST Distribution Header")
    var
        PostingNoSeries: Record "Posting No. Series";
        NoSeriesCode: Code[20];
    begin
        PostingNoSeries.SetRange("Table Id", Database::"GST Distribution Header");
        NoSeriesCode := LoopPostingNoSeries(PostingNoSeries, GSTDistributionHeader, PostingNoSeries."Document Type"::"GST Distribution");
        if NoSeriesCode <> '' then
            GSTDistributionHeader."Posting No. Series" := NoSeriesCode;
    end;

    local procedure LoopPostingNoSeries(Var PostingNoSeries: Record "Posting No. Series"; Record: Variant; PostingDocumentType: Enum "Posting Document Type"): Code[20]
    var
        Filters: Text;
    begin
        PostingNoSeries.SetRange("Document Type", PostingDocumentType);
        if PostingNoSeries.FindSet() then
            repeat
                Filters := GetRecordView(PostingNoSeries);
                if RecordViewFound(Record, Filters) then begin
                    PostingNoSeries.TestField("Posting No. Series");
                    exit(PostingNoSeries."Posting No. Series");
                end;
            until PostingNoSeries.Next() = 0;
    end;

    local procedure RecordViewFound(Record: Variant; Filters: Text) Found: Boolean;
    var
        Field: Record Field;
        DuplicateRecRef: RecordRef;
        TempRecRef: RecordRef;
        FieldRef: FieldRef;
        TempFieldRef: FieldRef;
    begin
        DuplicateRecRef.GetTable(Record);
        Clear(TempRecRef);
        TempRecRef.Open(DuplicateRecRef.Number(), true);
        Field.SetRange(TableNo, DuplicateRecRef.Number());
        if Field.FindSet() then
            repeat
                FieldRef := DuplicateRecRef.Field(Field."No.");
                TempFieldRef := TempRecRef.Field(Field."No.");
                TempFieldRef.Value := FieldRef.Value();
            until Field.Next() = 0;

        TempRecRef.Insert();
        Found := true;
        if Filters = '' then
            exit;

        TempRecRef.SetView(Filters);
        Found := TempRecRef.Find();
    end;

    procedure GetDistributionNoSeriesCode(var Record: Variant)
    var
        RecRef: RecordRef;
    begin
        if not Record.IsRecord() then
            exit;

        RecRef.GetTable(Record);
        case RecRef.Number() of
            Database::"GST Distribution Header":
                GetDistributionPostingNoSeries(Record);
        end;
    end;

    local procedure GetRecordView(var PostingNoSeries: Record "Posting No. Series") Filters: Text;
    var
        ConditionInStream: InStream;
    begin
        PostingNoSeries.CalcFields(Condition);
        PostingNoSeries.Condition.CREATEINSTREAM(ConditionInStream);
        ConditionInStream.Read(Filters);
    end;

    //GST Posting No. Series Table
    [EventSubscriber(ObjectType::Table, Database::"Posting No. Series", 'OnBeforeRun', '', false, false)]
    local procedure ValidatePostingSeriesDocumentType(var PostingNoSeries: Record "Posting No. Series"; var IsHandled: Boolean)
    begin
        case PostingNoSeries."Document Type" of
            PostingNoSeries."Document Type"::"GST Distribution":
                begin
                    PostingNoSeries."Table Id" := Database::"GST Distribution Header";
                    IsHandled := true;
                end;
        end;
    end;

    //GST Component Distribution Validation - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"GST Component Distribution", 'OnAfterValidateEvent', 'Intrastate Distribution', false, false)]
    local procedure ValidateIntrastateDistribution(var Rec: Record "GST Component Distribution")
    begin
        IntrastateDistribution(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Component Distribution", 'OnAfterValidateEvent', 'Interstate Distribution', false, false)]
    local procedure ValidateInterstateDistribution(var Rec: Record "GST Component Distribution")
    begin
        InterstateDistribution(Rec);
    end;

    //GST Distribution Header Validation - Subcsribers
    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnBeforeInsertEvent', '', false, false)]
    local procedure GSTDistHeaderOnInsertTrigger(var Rec: Record "GST Distribution Header")
    begin
        OnGSTDistHeaderInsert(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure ValidateNoField(var Rec: Record "GST Distribution Header"; var xRec: Record "GST Distribution Header")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        GeneralLedgerSetup.Get();
        if Rec."No." <> xRec."No." then begin
            GeneralLedgerSetup.Get();
            NoSeriesManagement.TestManual(GeneralLedgerSetup."GST Distribution Nos.");
            Rec."No. Series" := '';
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'Posting Date', false, false)]
    local procedure ValidatePostingDate(var Rec: Record "GST Distribution Header")
    begin
        PostingDate(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'Dist. Document Type', false, false)]
    local procedure ValidateDistDocumentType(var Rec: Record "GST Distribution Header")
    begin
        DistDocumentType(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'Reversal Invoice No.', false, false)]
    local procedure ValidateReversalInvoiceNo(var Rec: Record "GST Distribution Header")
    begin
        ReversalInvoiceNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'From Location Code', false, false)]
    local procedure ValidateFromLocationCode(var Rec: Record "GST Distribution Header")
    begin
        FromLocationCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'Dist. Credit Type', false, false)]
    local procedure ValidateDistCreditType(var Rec: Record "GST Distribution Header")
    begin
        Rec.TestField("Total Amout Applied for Dist.", 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'Shortcut Dimension 1 Code', false, false)]
    local procedure ValidateShortcutDimension1Code(var Rec: Record "GST Distribution Header")
    begin
        ValidateShortcutDimCode(1, Rec."Shortcut Dimension 1 Code", Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Distribution Header", 'OnAfterValidateEvent', 'Shortcut Dimension 2 Code', false, false)]
    local procedure ValidateShortcutDimension2Code(var Rec: Record "GST Distribution Header")
    begin
        ValidateShortcutDimCode(2, Rec."Shortcut Dimension 2 Code", Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Claim Setoff", 'OnAfterValidateEvent', 'Priority', False, False)]
    local procedure ValidatePriority(var Rec: Record "GST Claim Setoff"; var xRec: Record "GST Claim Setoff")
    begin
        if (xRec.Priority <> Rec.Priority) and IsSamePriority(Rec."GST Component Code", Rec.Priority) then
            Error(SamePriorityErr);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Claim Setoff", 'OnBeforeInsertEvent', '', False, False)]
    local procedure ValidateInsertRecord(var Rec: Record "GST Claim Setoff")
    begin
        Rec.Priority := GetLastPriority(Rec."GST Component Code");
        if IsZeroPriority(Rec."GST Component Code") then
            Error(ZeroPriorityErr);
    end;
}
