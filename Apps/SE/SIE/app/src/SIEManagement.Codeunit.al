// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.GeneralLedger.Setup;

codeunit 5316 "SIE Management"
{
    var
        AuditFileNameSIETxt: label 'SIE.se', Locked = true;

    procedure GetStandardAccountsCSVDocSIE(StandardAccountType: enum "Standard Account Type") CSVDocContent: Text
    var
        StandardAccountSIE: Codeunit "Standard Account SIE";
    begin
        if StandardAccountType = Enum::"Standard Account Type"::"Four Digit Standard Account (SRU)" then
            CSVDocContent := StandardAccountSIE.GetStandardAccountsCSV();
    end;

    procedure GetAuditFileName(): Text[1024]
    begin
        exit(AuditFileNameSIETxt);
    end;

    local procedure UpdateDimensionSIE(ShortCutDimNo: Integer; OldDimensionCode: Code[20]; NewDimensionCode: Code[20])
    var
        DimensionSIE: Record "Dimension SIE";
    begin
        if OldDimensionCode = NewDimensionCode then
            exit;

        if OldDimensionCode <> '' then begin
            DimensionSIE.SetRange("Dimension Code", OldDimensionCode);
            if DimensionSIE.FindFirst() then begin
                DimensionSIE.ShortCutDimNo := 0;
                DimensionSIE.Modify();
            end;
        end;
        if NewDimensionCode <> '' then begin
            DimensionSIE.SetRange("Dimension Code", NewDimensionCode);
            if DimensionSIE.FindFirst() then begin
                DimensionSIE.ShortCutDimNo := ShortCutDimNo;
                DimensionSIE.Modify();
            end;
        end;
    end;

    procedure SIEFormatSetupExists(): Boolean
    var
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
    begin
        exit(AuditFileExportFormatSetup.Get(Enum::"Audit File Export Format"::SIE));
    end;

    [EventSubscriber(ObjectType::Table, Database::"General Ledger Setup", 'OnAfterUpdateDimValueGlobalDimNo', '', true, true)]
    local procedure UpdateSIEDimensionOnAfterUpdateDimValueGlobalDimNo(ShortCutDimNo: Integer; OldDimensionCode: Code[20]; NewDimensionCode: Code[20])
    begin
        UpdateDimensionSIE(ShortcutDimNo, OldDimensionCode, NewDimensionCode);
    end;
}
