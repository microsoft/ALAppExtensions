// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using System.Utilities;

codeunit 31178 "Copy Document Mgt. CZZ"
{
    var
        ErrorMessageManagement: Codeunit "Error Message Management";
        ConfirmManagement: Codeunit "Confirm Management";
        IncludeHeader: Boolean;
        RecalculateLines: Boolean;
        DeleteLinesQst: Label 'The existing lines for %1 will be deleted.\\Do you want to continue?', Comment = '%1=Advance Letter No., e.g. 001';
        ErrorContextMsg: Label 'Copy advance letter %1', Comment = '%1 - Advance Letter No.';
        CopyDocumentItselfErr: Label 'Advance Letter %1 cannot be copied onto itself.', Comment = '%1=Advance Letter No., e.g. 001';
        EnterDocumentNoErr: Label 'Please enter a Document No.';

    #region Sales Advance Letter
    procedure CopyDocument(FromDocNo: Code[20]; var ToSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    var
        FromSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        FormSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        OldSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        ToSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        NextLineNo: Integer;
    begin
        ToSalesAdvLetterHeaderCZZ.TestField(Status, ToSalesAdvLetterHeaderCZZ.Status::New);
        if FromDocNo = '' then
            Error(EnterDocumentNoErr);
        ToSalesAdvLetterHeaderCZZ.Find();

        FromSalesAdvLetterHeaderCZZ.Get(FromDocNo);
        CheckDocumentItselfCopy(ToSalesAdvLetterHeaderCZZ, FromSalesAdvLetterHeaderCZZ);

        if not IncludeHeader and not RecalculateLines then
            CheckFromDocumentHeader(FromSalesAdvLetterHeaderCZZ, ToSalesAdvLetterHeaderCZZ);

        ToSalesAdvLetterLineCZZ.LockTable();
        ToSalesAdvLetterLineCZZ.SetRange("Document No.", ToSalesAdvLetterHeaderCZZ."No.");
        if IncludeHeader then
            if not ToSalesAdvLetterLineCZZ.IsEmpty() then begin
                Commit();
                if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteLinesQst, ToSalesAdvLetterHeaderCZZ."No."), true) then
                    exit;
                ToSalesAdvLetterLineCZZ.DeleteAll(true);
            end;

        if ToSalesAdvLetterLineCZZ.FindLast() then
            NextLineNo := ToSalesAdvLetterLineCZZ."Line No."
        else
            NextLineNo := 0;

        if IncludeHeader then begin
            OldSalesAdvLetterHeaderCZZ := ToSalesAdvLetterHeaderCZZ;
            ToSalesAdvLetterHeaderCZZ.TransferFields(FromSalesAdvLetterHeaderCZZ, false);
            ToSalesAdvLetterHeaderCZZ.Status := ToSalesAdvLetterHeaderCZZ.Status::New;
            CopyFieldsFromOldSalesAdvLetterHeader(ToSalesAdvLetterHeaderCZZ, OldSalesAdvLetterHeaderCZZ);
            if RecalculateLines then
                ToSalesAdvLetterHeaderCZZ.CreateDimFromDefaultDim(0);
            ToSalesAdvLetterHeaderCZZ."No. Printed" := 0;
            ToSalesAdvLetterHeaderCZZ.Modify();
        end;

        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, ToSalesAdvLetterHeaderCZZ.RecordId, 0, StrSubstNo(ErrorContextMsg, FromDocNo));

        FormSalesAdvLetterLineCZZ.Reset();
        FormSalesAdvLetterLineCZZ.SetRange("Document No.", FromSalesAdvLetterHeaderCZZ."No.");
        if FormSalesAdvLetterLineCZZ.FindSet() then
            repeat
                CopyDocumentLine(ToSalesAdvLetterHeaderCZZ, ToSalesAdvLetterLineCZZ, FormSalesAdvLetterLineCZZ, NextLineNo);
            until FormSalesAdvLetterLineCZZ.Next() = 0;

        if ErrorMessageManagement.GetLastErrorID() > 0 then
            ErrorMessageHandler.NotifyAboutErrors();
    end;

    local procedure CheckDocumentItselfCopy(FromSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ToSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        CheckDocumentItselfCopy(FromSalesAdvLetterHeaderCZZ."No.", ToSalesAdvLetterHeaderCZZ."No.");
    end;

    local procedure CheckFromDocumentHeader(FromSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; ToSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        FromSalesAdvLetterHeaderCZZ.TestField("Currency Code", ToSalesAdvLetterHeaderCZZ."Currency Code");
    end;

    local procedure CopyFieldsFromOldSalesAdvLetterHeader(var ToSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; OldSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        ToSalesAdvLetterHeaderCZZ."No. Series" := OldSalesAdvLetterHeaderCZZ."No. Series";
        ToSalesAdvLetterHeaderCZZ."Job No." := OldSalesAdvLetterHeaderCZZ."Job No.";
        ToSalesAdvLetterHeaderCZZ."Job Task No." := OldSalesAdvLetterHeaderCZZ."Job Task No.";
    end;

    local procedure CopyDocumentLine(var ToSalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ"; var ToSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var FromSalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ"; var NextLineNo: Integer): Boolean
    begin
        if RecalculateLines then
            ToSalesAdvLetterLineCZZ.Init()
        else
            ToSalesAdvLetterLineCZZ := FromSalesAdvLetterLineCZZ;

        NextLineNo += 10000;
        ToSalesAdvLetterLineCZZ."Document No." := ToSalesAdvLetterHeaderCZZ."No.";
        ToSalesAdvLetterLineCZZ."Line No." := NextLineNo;

        if RecalculateLines then begin
            ToSalesAdvLetterLineCZZ."VAT Bus. Posting Group" := FromSalesAdvLetterLineCZZ."VAT Bus. Posting Group";
            ToSalesAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", FromSalesAdvLetterLineCZZ."VAT Prod. Posting Group");
            ToSalesAdvLetterLineCZZ.Validate("Amount Including VAT", FromSalesAdvLetterLineCZZ."Amount Including VAT");
            ToSalesAdvLetterLineCZZ.Description := FromSalesAdvLetterLineCZZ.Description;
        end;

        ToSalesAdvLetterLineCZZ.Insert();
        exit(true);
    end;
    #endregion

    #region Purchase Advance Letter
    procedure CopyDocument(FromDocNo: Code[20]; var ToPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    var
        FromPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        FormPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        OldPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        ToPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
        ErrorContextElement: Codeunit "Error Context Element";
        ErrorMessageHandler: Codeunit "Error Message Handler";
        NextLineNo: Integer;
    begin
        ToPurchAdvLetterHeaderCZZ.TestField(Status, ToPurchAdvLetterHeaderCZZ.Status::New);
        if FromDocNo = '' then
            Error(EnterDocumentNoErr);
        ToPurchAdvLetterHeaderCZZ.Find();

        FromPurchAdvLetterHeaderCZZ.Get(FromDocNo);
        CheckDocumentItselfCopy(ToPurchAdvLetterHeaderCZZ, FromPurchAdvLetterHeaderCZZ);

        if not IncludeHeader and not RecalculateLines then
            CheckFromDocumentHeader(FromPurchAdvLetterHeaderCZZ, ToPurchAdvLetterHeaderCZZ);

        ToPurchAdvLetterLineCZZ.LockTable();
        ToPurchAdvLetterLineCZZ.SetRange("Document No.", ToPurchAdvLetterHeaderCZZ."No.");
        if IncludeHeader then
            if not ToPurchAdvLetterLineCZZ.IsEmpty() then begin
                Commit();
                if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(DeleteLinesQst, ToPurchAdvLetterHeaderCZZ."No."), true) then
                    exit;
                ToPurchAdvLetterLineCZZ.DeleteAll(true);
            end;

        if ToPurchAdvLetterLineCZZ.FindLast() then
            NextLineNo := ToPurchAdvLetterLineCZZ."Line No."
        else
            NextLineNo := 0;

        if IncludeHeader then begin
            OldPurchAdvLetterHeaderCZZ := ToPurchAdvLetterHeaderCZZ;
            ToPurchAdvLetterHeaderCZZ.TransferFields(FromPurchAdvLetterHeaderCZZ, false);
            ToPurchAdvLetterHeaderCZZ.Status := ToPurchAdvLetterHeaderCZZ.Status::New;
            CopyFieldsFromOldPurchAdvLetterHeader(ToPurchAdvLetterHeaderCZZ, OldPurchAdvLetterHeaderCZZ);
            if RecalculateLines then
                ToPurchAdvLetterHeaderCZZ.CreateDimFromDefaultDim(0);
            ToPurchAdvLetterHeaderCZZ."No. Printed" := 0;
            ToPurchAdvLetterHeaderCZZ.Modify();
        end;

        ErrorMessageManagement.Activate(ErrorMessageHandler);
        ErrorMessageManagement.PushContext(ErrorContextElement, ToPurchAdvLetterHeaderCZZ.RecordId, 0, StrSubstNo(ErrorContextMsg, FromDocNo));

        FormPurchAdvLetterLineCZZ.Reset();
        FormPurchAdvLetterLineCZZ.SetRange("Document No.", FromPurchAdvLetterHeaderCZZ."No.");
        if FormPurchAdvLetterLineCZZ.FindSet() then
            repeat
                CopyDocumentLine(ToPurchAdvLetterHeaderCZZ, ToPurchAdvLetterLineCZZ, FormPurchAdvLetterLineCZZ, NextLineNo);
            until FormPurchAdvLetterLineCZZ.Next() = 0;

        if ErrorMessageManagement.GetLastErrorID() > 0 then
            ErrorMessageHandler.NotifyAboutErrors();
    end;

    local procedure CheckDocumentItselfCopy(FromPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; ToPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        CheckDocumentItselfCopy(FromPurchAdvLetterHeaderCZZ."No.", ToPurchAdvLetterHeaderCZZ."No.");
    end;

    local procedure CheckFromDocumentHeader(FromPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; ToPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        FromPurchAdvLetterHeaderCZZ.TestField("Currency Code", ToPurchAdvLetterHeaderCZZ."Currency Code");
    end;

    local procedure CopyFieldsFromOldPurchAdvLetterHeader(var ToPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; OldPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        ToPurchAdvLetterHeaderCZZ."No. Series" := OldPurchAdvLetterHeaderCZZ."No. Series";
    end;

    local procedure CopyDocumentLine(var ToPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ"; var ToPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var FromPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ"; var NextLineNo: Integer): Boolean
    begin
        if RecalculateLines then
            ToPurchAdvLetterLineCZZ.Init()
        else
            ToPurchAdvLetterLineCZZ := FromPurchAdvLetterLineCZZ;

        NextLineNo += 10000;
        ToPurchAdvLetterLineCZZ."Document No." := ToPurchAdvLetterHeaderCZZ."No.";
        ToPurchAdvLetterLineCZZ."Line No." := NextLineNo;

        if RecalculateLines then begin
            ToPurchAdvLetterLineCZZ."VAT Bus. Posting Group" := FromPurchAdvLetterLineCZZ."VAT Bus. Posting Group";
            ToPurchAdvLetterLineCZZ.Validate("VAT Prod. Posting Group", FromPurchAdvLetterLineCZZ."VAT Prod. Posting Group");
            ToPurchAdvLetterLineCZZ.Validate("Amount Including VAT", FromPurchAdvLetterLineCZZ."Amount Including VAT");
            ToPurchAdvLetterLineCZZ.Description := FromPurchAdvLetterLineCZZ.Description;
        end;

        ToPurchAdvLetterLineCZZ.Insert();
        exit(true);
    end;
    #endregion

    #region General
    procedure SetProperties(NewIncludeHeader: Boolean; NewRecalculateLines: Boolean)
    begin
        IncludeHeader := NewIncludeHeader;
        RecalculateLines := NewRecalculateLines;
    end;

    local procedure CheckDocumentItselfCopy(FromDocumentNo: Code[20]; ToDocumentNo: Code[20])
    begin
        if FromDocumentNo = ToDocumentNo then
            Error(CopyDocumentItselfErr, ToDocumentNo);
    end;
    #endregion
}
