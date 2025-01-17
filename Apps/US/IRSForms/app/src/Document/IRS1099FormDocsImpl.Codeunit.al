// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

codeunit 10036 "IRS 1099 Form Docs Impl." implements "IRS 1099 Create Form Docs"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        IRSFormsSetup: Record "IRS Forms Setup";
        NoVendorFormBoxAmountsFoundErr: Label 'No vendor form box amounts are found';

    procedure CreateFormDocs(var TempVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer" temporary; IRS1099CalcParameters: Record "IRS 1099 Calc. Params");
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary;
        TempIRS1099FormDocLine: Record "IRS 1099 Form Doc. Line" temporary;
        TempIRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail" temporary;
        CurrVendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer";
        LineNo: Integer;
        DocID: Integer;
    begin
        TempVendFormBoxBuffer.Reset();
        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::Amount);
        if not TempVendFormBoxBuffer.FindSet() then
            error(NoVendorFormBoxAmountsFoundErr);

        IRSFormsSetup.Get();
        if IRS1099FormDocHeader.FindLast() then
            DocID := IRS1099FormDocHeader.ID;
        repeat
            if not SkipFormDocumentCreation(TempVendFormBoxBuffer, IRS1099CalcParameters) then begin
                LineNo := 0;
                AddTempFormHeaderFromBuffer(TempIRS1099FormDocHeader, DocID, TempVendFormBoxBuffer);
                repeat
                    LineNo += 1000;
                    AddTempFormLineFromBuffer(TempIRS1099FormDocLine, TempIRS1099FormDocHeader, TempVendFormBoxBuffer, LineNo);
                    if IRSFormsSetup."Collect Details For Line" then begin
                        CurrVendFormBoxBuffer.Copy(TempVendFormBoxBuffer);
                        TempVendFormBoxBuffer.Reset();
                        TempVendFormBoxBuffer.SetRange("Parent Entry No.", TempVendFormBoxBuffer."Entry No.");
                        TempVendFormBoxBuffer.SetRange("Buffer Type", TempVendFormBoxBuffer."Buffer Type"::"Ledger Entry");
                        if TempVendFormBoxBuffer.FindSet() then
                            repeat
                                AddFormDocLineDetail(TempIRS1099FormDocLineDetail, TempIRS1099FormDocLine, TempVendFormBoxBuffer."Vendor Ledger Entry No.");
                            until TempVendFormBoxBuffer.Next() = 0;
                        TempVendFormBoxBuffer.Copy(CurrVendFormBoxBuffer);
                    end;
                until TempVendFormBoxBuffer.Next() = 0;
            end;
            TempVendFormBoxBuffer.SetRange("Vendor No.");
            TempVendFormBoxBuffer.SetRange("Form No.");
        until TempVendFormBoxBuffer.Next() = 0;

        InsertFormDocsFromTempBuffer(TempIRS1099FormDocHeader, TempIRS1099FormDocLine, TempIRS1099FormDocLineDetail);
    end;

    local procedure SkipFormDocumentCreation(var VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer"; IRS1099CalcParameters: Record "IRS 1099 Calc. Params"): Boolean
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocument: Codeunit "IRS 1099 Form Document";
    begin
        VendFormBoxBuffer.SetRange("Vendor No.", VendFormBoxBuffer."Vendor No.");
        VendFormBoxBuffer.SetRange("Form No.", VendFormBoxBuffer."Form No.");
        IRS1099FormDocHeader.SetRange("Period No.", VendFormBoxBuffer."Period No.");
        IRS1099FormDocHeader.SetRange("Vendor No.", VendFormBoxBuffer."Vendor No.");
        IRS1099FormDocHeader.SetRange("Form No.", VendFormBoxBuffer."Form No.");
        if not IRS1099FormDocHeader.FindFirst() then
            exit(false);

        if IRS1099FormDocHeader.Status = IRS1099FormDocHeader.Status::Submitted then
            exit(true);

        if not IRS1099CalcParameters.Replace then
            exit(true);

        if IRS1099FormDocHeader.Status = IRS1099FormDocHeader.Status::Released then
            IRS1099FormDocument.Reopen(IRS1099FormDocHeader);

        IRS1099FormDocHeader.Delete(true);
        exit(false);
    end;

    local procedure AddTempFormHeaderFromBuffer(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var DocID: Integer; VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer")
    begin
        TempIRS1099FormDocHeader.Init();
        DocID += 1;
        TempIRS1099FormDocHeader.ID := DocID;
        TempIRS1099FormDocHeader."Period No." := VendFormBoxBuffer."Period No.";
        TempIRS1099FormDocHeader."Vendor No." := VendFormBoxBuffer."Vendor No.";
        TempIRS1099FormDocHeader."Form No." := VendFormBoxBuffer."Form No.";
        TempIRS1099FormDocHeader.Insert(true);
    end;

    local procedure AddTempFormLineFromBuffer(var TempIRS1099FormDocLine: Record "IRS 1099 Form Doc. Line" temporary; IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; VendFormBoxBuffer: Record "IRS 1099 Vend. Form Box Buffer"; LineNo: Integer)
    begin
        TempIRS1099FormDocLine.Init();
        TempIRS1099FormDocLine."Document ID" := IRS1099FormDocHeader.ID;
        TempIRS1099FormDocLine."Period No." := IRS1099FormDocHeader."Period No.";
        TempIRS1099FormDocLine."Vendor No." := IRS1099FormDocHeader."Vendor No.";
        TempIRS1099FormDocLine."Form No." := IRS1099FormDocHeader."Form No.";
        TempIRS1099FormDocLine."Form Box No." := VendFormBoxBuffer."Form Box No.";
        TempIRS1099FormDocLine."Line No." := LineNo;
        VendFormBoxBuffer.CalcFields("Minimum Reportable Amount", "Adjustment Amount");
        TempIRS1099FormDocLine."Minimum Reportable Amount" := VendFormBoxBuffer."Minimum Reportable Amount";
        TempIRS1099FormDocLine."Adjustment Amount" := VendFormBoxBuffer."Adjustment Amount";
        TempIRS1099FormDocLine.Validate("Calculated Amount", VendFormBoxBuffer.Amount);
        TempIRS1099FormDocLine.Validate(Amount, VendFormBoxBuffer."Reporting Amount");
        TempIRS1099FormDocLine.Validate("Include In 1099", VendFormBoxBuffer."Include In 1099");
        TempIRS1099FormDocLine.Insert();
    end;

    local procedure AddFormDocLineDetail(var TempIRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail" temporary; IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line"; EntryNo: Integer)
    begin
        TempIRS1099FormDocLineDetail.Validate("Document ID", IRS1099FormDocLine."Document ID");
        TempIRS1099FormDocLineDetail.Validate("Line No.", IRS1099FormDocLine."Line No.");
        TempIRS1099FormDocLineDetail.Validate("Vendor Ledger Entry No.", EntryNo);
        TempIRS1099FormDocLineDetail.Insert(true);
    end;

    local procedure InsertFormDocsFromTempBuffer(var TempIRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header" temporary; var TempIRS1099FormDocLine: Record "IRS 1099 Form Doc. Line" temporary; var TempIRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail" temporary)
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocLine: Record "IRS 1099 Form Doc. Line";
        IRS1099FormDocLineDetail: Record "IRS 1099 Form Doc. Line Detail";
        DocID: Integer;
    begin
        if IRS1099FormDocHeader.FindLast() then
            DocID := IRS1099FormDocHeader.ID;
        TempIRS1099FormDocHeader.Reset();
        TempIRS1099FormDocLine.Reset();
        if TempIRS1099FormDocHeader.FindSet() then
            repeat
                DocID += 1;
                IRS1099FormDocHeader := TempIRS1099FormDocHeader;
                IRS1099FormDocHeader.ID := DocID;
                IRS1099FormDocHeader.Validate("Vendor No.");
                IRS1099FormDocHeader.Insert(true);
                TempIRS1099FormDocLine.SetRange("Document ID", TempIRS1099FormDocHeader.ID);
                if TempIRS1099FormDocLine.FindSet() then
                    repeat
                        IRS1099FormDocLine := TempIRS1099FormDocLine;
                        IRS1099FormDocLine.Validate("Document ID", IRS1099FormDocHeader.ID);
                        IRS1099FormDocLine.Validate(Amount, IRS1099FormDocLine.Amount);
                        IRS1099FormDocLine.Insert(true);
                        if IRSFormsSetup."Collect Details For Line" then begin
                            TempIRS1099FormDocLineDetail.SetRange("Document ID", TempIRS1099FormDocLine."Document ID");
                            TempIRS1099FormDocLineDetail.SetRange("Line No.", TempIRS1099FormDocLine."Line No.");
                            if TempIRS1099FormDocLineDetail.FindSet() then
                                repeat
                                    IRS1099FormDocLineDetail := TempIRS1099FormDocLineDetail;
                                    IRS1099FormDocLineDetail.Validate("Document ID", IRS1099FormDocLine."Document ID");
                                    IRS1099FormDocLineDetail.Insert(true);
                                until TempIRS1099FormDocLineDetail.Next() = 0;
                        end;
                    until TempIRS1099FormDocLine.Next() = 0;
            until TempIRS1099FormDocHeader.Next() = 0;
    end;
}
