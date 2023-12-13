// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Analysis;

using Microsoft.Purchases.Vendor;

codeunit 11294 "Import Company Size Codes"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        InStream: InStream;
        Line: Text;
        FileName: Text;
        TotalLines: Integer;
        MatchesFound: Integer;
    begin
        if not UploadIntoStream('', '', 'CSV Files|*.csv', FileName, InStream) then
            exit;

        repeat
            if InStream.ReadText(Line) > 0 then begin
                if ImportLine(Line) then
                    MatchesFound += 1;
                TotalLines += 1;
            end;
        until InStream.EOS();
        Message(ImportDoneMsg, MatchesFound, TotalLines);
    end;

    var
        ImportDoneMsg: Label 'Importing Company Sizes done. %1 matches found out of %2 total lines processed.', Comment = '%1,%2 - number of lines.';

    local procedure ImportLine(InputLine: Text) MatchFound: Boolean;
    var
        Vendor: Record Vendor;
        CompanySize: Record "Company Size";
        OutputList: List of [Text];
        CompanyVATREgNo: Code[20];
        CompanySizeCode: Code[20];
        CompanySizeDescription: Text[100];
    begin
        SplitLineToList(InputLine, OutputList);
        CompanyVATREgNo := CopyStr(OutputList.Get(1), 1, MaxStrLen(Vendor."VAT Registration No."));
        CompanySizeCode := CopyStr(OutputList.Get(3), 1, MaxStrLen(Vendor."Company Size Code"));
        CompanySizeDescription := CopyStr(OutputList.Get(4), 1, MaxStrLen(CompanySize.Description));
        if FindMatchingVendor(Vendor, CompanyVATREgNo) then begin
            if not CompanySize.Get(CompanySizeCode) then begin
                CompanySize.Code := CompanySizeCode;
                CompanySize.Description := CompanySizeDescription;
                CompanySize.Insert();
            end;
            Vendor."Company Size Code" := CompanySizeCode;
            Vendor.Modify();
            MatchFound := true;
        end;
    end;

    local procedure SplitLineToList(InputLine: Text; var List: List of [Text])
    var
        TabChar: Char;
        TabIndex: Integer;
    begin
        TabChar := 9;
        while StrPos(InputLine, TabChar) > 0 do begin
            TabIndex := StrPos(InputLine, TabChar);
            List.Add(CopyStr(InputLine, 1, TabIndex - 1));
            InputLine := CopyStr(InputLine, TabIndex + 1, StrLen(InputLine));
        end;
        List.Add(InputLine);
    end;

    local procedure FindMatchingVendor(var Vendor: Record Vendor; CompanyVATREgNo: Code[20]): Boolean
    begin
        Vendor.SetRange("VAT Registration No.", CompanyVATREgNo);
        if Vendor.FindFirst() then
            exit(true);
        Vendor.SetRange("VAT Registration No.", CopyStr('SE' + CompanyVATREgNo, 1, MaxStrLen(Vendor."VAT Registration No.")));
        if Vendor.FindFirst() then
            exit(true);
    end;
}
