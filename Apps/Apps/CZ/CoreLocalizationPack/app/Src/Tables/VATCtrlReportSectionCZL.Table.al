// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

table 31108 "VAT Ctrl. Report Section CZL"
{
    Caption = 'VAT Control Report Section';
    DrillDownPageId = "VAT Ctrl. Report Sections CZL";
    LookupPageId = "VAT Ctrl. Report Sections CZL";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Group By"; Option)
        {
            Caption = 'Group By';
            OptionCaption = 'Document No.,External Document No.,Section Code';
            OptionMembers = "Document No.","External Document No.","Section Code";
            DataClassification = CustomerContent;
        }
        field(10; "Simplified Tax Doc. Sect. Code"; Code[20])
        {
            Caption = 'Simplified Tax Document Section Code';
            TableRelation = "VAT Ctrl. Report Section CZL".Code;
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    var
        A1Tok: Label 'A1', Locked = true;
        A2Tok: Label 'A2', Locked = true;
        A3Tok: Label 'A3', Locked = true;
        A4Tok: Label 'A4', Locked = true;
        A5Tok: Label 'A5', Locked = true;
        B1Tok: Label 'B1', Locked = true;
        B2Tok: Label 'B2', Locked = true;
        B3Tok: Label 'B3', Locked = true;

    procedure ReverseChargeSalesSection(): Code[20]
    begin
        exit(A1Tok);
    end;

    procedure EUPurchaseSection(): Code[20]
    begin
        exit(A2Tok);
    end;

    procedure SalesOfInvestmentGoldSection(): Code[20]
    begin
        exit(A3Tok);
    end;

    procedure DomesticSalesAbove10ThousandSection(): Code[20]
    begin
        exit(A4Tok);
    end;

    procedure DomesticSalesBelow10ThousandSection(): Code[20]
    begin
        exit(A5Tok);
    end;

    procedure ReverseChargePurchaseSection(): Code[20]
    begin
        exit(B1Tok);
    end;

    procedure DomesticPurchaseAbove10ThousandSection(): Code[20]
    begin
        exit(B2Tok);
    end;

    procedure DomesticPurchaseBelow10ThousandSection(): Code[20]
    begin
        exit(B3Tok);
    end;
}
