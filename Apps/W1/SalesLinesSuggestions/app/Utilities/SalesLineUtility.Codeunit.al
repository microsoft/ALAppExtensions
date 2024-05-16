// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Document;
using System.Telemetry;
using Microsoft.Utilities;

codeunit 7280 "Sales Line Utility"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ProcessingLinesLbl: Label 'Processing lines... \#1#########################################################################################', Comment = '#1 = PreparingSalesLineLbl or InsertingSalesLineLbl ';
        PreparingSalesLineLbl: Label 'Preparing %1 of %2', Comment = '%1 = Counter, %2 = Total Lines';
        InsertingSalesLineLbl: Label 'Inserting %1 of %2', Comment = '%1 = Counter, %2 = Total Lines';
        SalesLineValidationErr: Label 'There was an error while validating the line with No. %1, Description %2.\Error: %3', Comment = '%1 = No., %2 = Description, %3 = Error Message';
        SalesLineCopyErr: Label 'There was an error while copying the line with No. %1, Description %2, Quantity %3.', Comment = '%1 = No., %2 = Description, %3 = Quantity';

    procedure CopySalesLineToDoc(SalesHeader: Record "Sales Header"; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary)
    var
        ToSalesLine: Record "Sales Line";
        TempFromSalesLine: Record "Sales Line" temporary;
        LinesNotCopied: Integer;
        NextLineNo: Integer;
    begin
        ToSalesLine.SetRange("Document Type", SalesHeader."Document Type");
        ToSalesLine.SetRange("Document No.", SalesHeader."No.");

        if ToSalesLine.FindLast() then
            NextLineNo := ToSalesLine."Line No."
        else
            NextLineNo := 0;
        LinesNotCopied := 0;

        PrepareSalesLine(SalesHeader, TempFromSalesLine, TempSalesLineAiSuggestion, NextLineNo);
        CopySalesLineToDoc(SalesHeader, TempFromSalesLine, LinesNotCopied, NextLineNo);
    end;

    local procedure CopySalesLineToDoc(var ToSalesHeader: Record "Sales Header"; var FromSalesLine: Record "Sales Line" temporary; var LinesNotCopied: Integer; NextLineNo: Integer)
    var
        ToSalesLine: Record "Sales Line";
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        CopyPostedDeferral: Boolean;
        ProgressDialog: Dialog;
        Counter: Integer;
        TotalLines: Integer;
    begin
        CopyPostedDeferral := false;
        if FromSalesLine.FindSet() then begin
            OpenProgressWindow(ProgressDialog);
            TotalLines := FromSalesLine.Count();
            CopyDocMgt.SetCopyExtendedText(true);
            repeat
                if CopyDocMgt.CopySalesDocLine(
                     ToSalesHeader, ToSalesLine, ToSalesHeader, FromSalesLine,
                     NextLineNo, LinesNotCopied, false,
                     "Sales Document Type"::Order,
                     CopyPostedDeferral, FromSalesLine."Line No.") then
                    Counter += 1
                else begin
                    FeatureTelemetry.LogError('0000MMN', SalesLineAISuggestionImpl.GetFeatureName(), 'Copy Sales Lines to Doc', StrSubstNo(SalesLineCopyErr, FromSalesLine."No.", FromSalesLine.Description, FromSalesLine.Quantity), GetLastErrorCallStack());
                    Error(SalesLineCopyErr, FromSalesLine."No.", FromSalesLine.Description, FromSalesLine.Quantity);
                end;
                ProgressDialog.Update(1, StrSubstNo(InsertingSalesLineLbl, Counter, TotalLines));
            until FromSalesLine.Next() = 0;
            CopyDocMgt.SetCopyExtendedText(false);
            ProgressDialog.Close();
        end;
    end;

    local procedure PrepareSalesLine(SalesHeader: Record "Sales Header"; var TempSalesLine: Record "Sales Line" temporary; var TempSalesLineAiSuggestion: Record "Sales Line AI Suggestions" temporary; LineNo: Integer)
    var
        TempPreparedSalesLine: Record "Sales Line" temporary;
        PrepareSalesLineForCopying: Codeunit "Prepare Sales Line For Copying";
        SalesLineAISuggestionImpl: Codeunit "Sales Lines Suggestions Impl.";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ProgressDialog: Dialog;
        TotalLines: Integer;
        Counter: Integer;
    begin
        if TempSalesLineAiSuggestion.FindSet() then begin
            OpenProgressWindow(ProgressDialog);
            TotalLines := TempSalesLineAiSuggestion.Count();
            repeat
                Counter += 1;
                ProgressDialog.Update(1, StrSubstNo(PreparingSalesLineLbl, Counter, TotalLines));

                LineNo += 10000;
                PrepareSalesLineForCopying.SetParameters(SalesHeader, LineNo, TempSalesLineAiSuggestion);
                if PrepareSalesLineForCopying.Run() then begin
                    TempPreparedSalesLine := PrepareSalesLineForCopying.GetPreparedLine();
                    TempSalesLine.Init();
                    TempSalesLine.TransferFields(TempPreparedSalesLine);
                    TempSalesLine.Insert();
                end
                else begin
                    FeatureTelemetry.LogError('0000MMM', SalesLineAISuggestionImpl.GetFeatureName(), 'Prepare Sales Lines before inserting', '', GetLastErrorCallStack());
                    Error(SalesLineValidationErr, TempSalesLineAiSuggestion."No.", TempSalesLineAiSuggestion.Description, GetLastErrorText());
                end;
            until TempSalesLineAiSuggestion.Next() = 0;
            ProgressDialog.Close();
        end;
    end;

    local procedure OpenProgressWindow(var ProgressDialog: Dialog)
    begin
        ProgressDialog.Open(ProcessingLinesLbl);
        ProgressDialog.Update(1, '');
    end;

}