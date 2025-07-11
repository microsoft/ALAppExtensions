// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;

table 5315 "Dimension SIE"
{
    Caption = 'Dimension SIE';

    fields
    {
        field(1; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension;

            trigger OnValidate()
            begin
                if Dimension.Get("Dimension Code") then
                    Name := Dimension.Name;

                GeneralLedgerSetup.Get();
                if GeneralLedgerSetup."Shortcut Dimension 1 Code" = "Dimension Code" then
                    ShortCutDimNo := 1;
                if GeneralLedgerSetup."Shortcut Dimension 2 Code" = "Dimension Code" then
                    ShortCutDimNo := 2;
                if GeneralLedgerSetup."Shortcut Dimension 3 Code" = "Dimension Code" then
                    ShortCutDimNo := 3;
                if GeneralLedgerSetup."Shortcut Dimension 4 Code" = "Dimension Code" then
                    ShortCutDimNo := 4;
                if GeneralLedgerSetup."Shortcut Dimension 5 Code" = "Dimension Code" then
                    ShortCutDimNo := 5;
                if GeneralLedgerSetup."Shortcut Dimension 6 Code" = "Dimension Code" then
                    ShortCutDimNo := 6;
                if GeneralLedgerSetup."Shortcut Dimension 7 Code" = "Dimension Code" then
                    ShortCutDimNo := 7;
                if GeneralLedgerSetup."Shortcut Dimension 8 Code" = "Dimension Code" then
                    ShortCutDimNo := 8;
            end;
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(3; Selected; Boolean)
        {
            Caption = 'Selected';
            InitValue = true;
        }
        field(4; "SIE Dimension"; Integer)
        {
            Caption = 'SIE Dimension';
        }
        field(5; ShortCutDimNo; Integer)
        {
            Caption = 'ShortCutDimNo';
        }
    }

    keys
    {
        key(Key1; "Dimension Code")
        {
            Clustered = true;
        }
        key(Key2; "SIE Dimension")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Dimension: Record Dimension;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DimCodesTxt: label '%1; %2', Comment = '%1 - existing string with dimensions codes, %2 - dimension code to add';
        DimCodesThreeDotsTxt: label '%1;...', Comment = '%1 - existing string with dimensions codes';

    local procedure AddDimCodeToText(DimCode: Code[20]; var Text: Text[250])
    begin
        if Text = '' then
            Text := DimCode
        else
            if (StrLen(Text) + StrLen(DimCode)) <= (MaxStrLen(Text) - 4) then
                Text := StrSubstNo(DimCodesTxt, Text, DimCode)
            else
                Text := StrSubstNo(DimCodesThreeDotsTxt, Text)
    end;

    procedure GetDimSelectionText(): Text[250]
    var
        DimensionSIE: Record "Dimension SIE";
        SelectedDimText: Text[250];
    begin
        DimensionSIE.SetRange(Selected, true);
        if DimensionSIE.FindSet() then
            repeat
                AddDimCodeToText(DimensionSIE."Dimension Code", SelectedDimText);
            until DimensionSIE.Next() = 0;
        exit(SelectedDimText);
    end;
}
