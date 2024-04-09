// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;

table 31076 "VIES Declaration Line CZL"
{
    Caption = 'VIES Declaration Line';
    LookupPageId = "VIES Declaration Lines CZL";
    DrillDownPageId = "VIES Declaration Lines CZL";

    fields
    {
        field(1; "VIES Declaration No."; Code[20])
        {
            Caption = 'VIES Declaration No.';
            TableRelation = "VIES Declaration Header CZL";
            DataClassification = CustomerContent;
        }
        field(2; "Trade Type"; Option)
        {
            Caption = 'Trade Type';
            OptionCaption = 'Purchase,Sales, ';
            OptionMembers = Purchase,Sales," ";
            InitValue = " ";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();

                if "Trade Type" = "Trade Type"::" " then begin
                    "Trade Role Type" := "Trade Role Type"::" ";
                    "Number of Supplies" := 0;
                    "Amount (LCY)" := 0;
                end;

                "Record Code" := "Record Code"::" ";
                "VAT Reg. No. of Original Cust." := '';
            end;
        }
        field(6; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(7; "Line Type"; Option)
        {
            Caption = 'Line Type';
            OptionCaption = 'New,Cancellation,Correction';
            OptionMembers = New,Cancellation,Correction;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
            end;
        }
        field(8; "Related Line No."; Integer)
        {
            Caption = 'Related Line No.';
            DataClassification = CustomerContent;
        }
        field(9; "EU Service"; Boolean)
        {
            Caption = 'EU Service';
            DataClassification = CustomerContent;
        }
        field(10; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
            end;
        }
        field(11; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
                if "VAT Registration No." <> xRec."VAT Registration No." then
                    "Corrected Reg. No." := true;
            end;
        }
        field(12; "Amount (LCY)"; Decimal)
        {
            Caption = 'Amount (LCY)';
            DecimalPlaces = 0 : 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
                CheckTradeType();
                if "Amount (LCY)" <> xRec."Amount (LCY)" then
                    "Corrected Amount" := true;
            end;
        }
        field(13; "EU 3-Party Trade"; Boolean)
        {
            Caption = 'EU 3-Party Trade';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
            end;
        }
        field(14; "Registration No."; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
            end;
        }
        field(15; "EU 3-Party Intermediate Role"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
            end;
        }
        field(17; "Number of Supplies"; Decimal)
        {
            BlankNumbers = DontBlank;
            Caption = 'Number of Supplies';
            DecimalPlaces = 0 : 0;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
                CheckTradeType();
            end;
        }
        field(20; "Corrected Reg. No."; Boolean)
        {
            Caption = 'Corrected Reg. No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(21; "Corrected Amount"; Boolean)
        {
            Caption = 'Corrected Amount';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(25; "Trade Role Type"; Option)
        {
            Caption = 'Trade Role Type';
            OptionCaption = 'Direct Trade,Intermediate Trade,Property Movement, ';
            OptionMembers = "Direct Trade","Intermediate Trade","Property Movement"," ";
            InitValue = " ";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestStatusOpen();
                CheckLineType();
                CheckTradeType();
            end;
        }
        field(29; "System-Created"; Boolean)
        {
            Caption = 'System-Created';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(30; "Report Page Number"; Integer)
        {
            Caption = 'Report Page Number';
            DataClassification = CustomerContent;
        }
        field(31; "Report Line Number"; Integer)
        {
            Caption = 'Report Line Number';
            DataClassification = CustomerContent;
        }
        field(35; "Record Code"; Option)
        {
            Caption = 'Record Code';
            OptionCaption = ' ,1,2,3';
            OptionMembers = " ","1","2","3";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Record Code" = xRec."Record Code" then
                    exit;

                TestField("Trade Type", "Trade Type"::" ");
                TestField("Trade Role Type", "Trade Role Type"::" ");
                TestField("Number of Supplies", 0);
                TestField("Amount (LCY)", 0);
                "VAT Reg. No. of Original Cust." := '';
            end;
        }
        field(36; "VAT Reg. No. of Original Cust."; Text[20])
        {
            Caption = 'VAT Reg. No. of Original Cust.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Record Code", "Record Code"::"3");
            end;
        }
    }
    keys
    {
        key(Key1; "VIES Declaration No.", "Line No.")
        {
            Clustered = true;
            SumIndexFields = "Amount (LCY)", "Number of Supplies";
        }
        key(Key2; "Trade Type", "Country/Region Code", "VAT Registration No.", "Trade Role Type", "EU Service")
        {
            SumIndexFields = "Amount (LCY)";
        }
        key(Key3; "VAT Registration No.")
        {
            SumIndexFields = "Amount (LCY)";
        }
    }
    trigger OnDelete()
    begin
        TestStatusOpen();
    end;

    trigger OnInsert()
    begin
        TestStatusOpen();
    end;

    trigger OnModify()
    begin
        TestStatusOpen();
        CheckLineType();
    end;

    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        CancelModifyErr: Label 'You cannot change Cancellation line.';
        CancelYesTxt: Label 'A', Comment = 'A';
        CancelNoTxt: Label 'N', Comment = 'N';

    local procedure TestStatusOpen()
    begin
        GetHeader();
        VIESDeclarationHeaderCZL.TestField(Status, VIESDeclarationHeaderCZL.Status::Open);
    end;

    procedure GetTradeRole(): Code[10]
    begin
        case "Trade Role Type" of
            "Trade Role Type"::"Direct Trade":
                if (not "EU Service") and (not "EU 3-Party Intermediate Role") then
                    exit('0');
            "Trade Role Type"::"Property Movement":
                exit('1');
            "Trade Role Type"::"Intermediate Trade":
                if (not "EU Service") then
                    exit('2');
        end;
        if "EU Service" then
            exit('3');
    end;

    procedure GetCancelCode(): Code[10]
    begin
        if "Line Type" = "Line Type"::Cancellation then
            exit(CancelYesTxt);
        exit(CancelNoTxt);
    end;

    procedure GetVATRegNo(): Code[20]
    begin
        exit(FormatVATRegNo("VAT Registration No."));
    end;

    procedure GetOrigCustVATRegNo(): Code[20]
    begin
        exit(FormatVATRegNo("VAT Reg. No. of Original Cust."));
    end;

    local procedure FormatVATRegNo(VATRegNo: Code[20]): Code[20]
    var
        CountryRegion: Record "Country/Region";
        IsHandled: Boolean;
    begin
        OnBeforeFormatVATRegNo(Rec, VATRegNo, IsHandled);
        if IsHandled then
            exit(VATRegNo);
        if "Country/Region Code" = '' then
            exit(VATRegNo);

        CountryRegion.Get("Country/Region Code");
        if CopyStr(VATRegNo, 1, StrLen(CountryRegion."EU Country/Region Code")) = CountryRegion."EU Country/Region Code" then
            exit(CopyStr(VATRegNo, StrLen(CountryRegion."EU Country/Region Code") + 1, 20));
        exit(VATRegNo);
    end;

    procedure DrillDownAmountLCY()
    var
        VATEntry: Record "VAT Entry";
        TempVATEntry: Record "VAT Entry" temporary;
    begin
        GetHeader();

        VATEntry.SetCurrentKey(Type, "Country/Region Code");
        VATEntry.SetRange(Type, "Trade Type" + 1);
        VATEntry.SetRange("Country/Region Code", "Country/Region Code");
        VATEntry.SetRange("VAT Registration No.", "VAT Registration No.");
        case "Trade Role Type" of
            "Trade Role Type"::"Direct Trade":
                VATEntry.SetRange("EU 3-Party Trade", false);
            "Trade Role Type"::"Intermediate Trade":
                VATEntry.SetRange("EU 3-Party Trade", true);
            "Trade Role Type"::"Property Movement":
                exit;
        end;
#if not CLEAN22
#pragma warning disable AL0432
        if not VATEntry.IsReplaceVATDateEnabled() then
            VATEntry.SetRange("VAT Date CZL", VIESDeclarationHeaderCZL."Start Date", VIESDeclarationHeaderCZL."End Date")
        else
#pragma warning restore AL0432
#endif
        VATEntry.SetRange("VAT Reporting Date", VIESDeclarationHeaderCZL."Start Date", VIESDeclarationHeaderCZL."End Date");
        VATEntry.SetRange("EU Service", "EU Service");
        OnDrillDownAmountLCYOnBeforeVATEntryFind(Rec, VIESDeclarationHeaderCZL, VATEntry);
        if VATEntry.FindSet() then
            repeat
                if IsVATEntryIncludedToDrillDown(VATEntry) then begin
                    TempVATEntry := VATEntry;
                    TempVATEntry.Insert();
                end
            until VATEntry.Next() = 0;

        Page.Run(0, TempVATEntry);
    end;

    local procedure IsVATEntryIncludedToDrillDown(VATEntry: Record "VAT Entry") IsIncluded: Boolean
    var
        VATPostingSetup: Record "VAT Posting Setup";
        IsHandled: Boolean;
    begin
        GetHeader();
        OnBeforeIsVATEntryIncludedToDrillDown(VATEntry, Rec, VIESDeclarationHeaderCZL, IsIncluded, IsHandled);
        if IsHandled then
            exit(IsIncluded);

        if not VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group") then
            exit(false);

        case "Trade Type" of
            "Trade Type"::Sales:
                exit(VATPostingSetup."VIES Sales CZL");
            "Trade Type"::Purchase:
                exit(VATPostingSetup."VIES Purchase CZL");
        end;

        exit(false);
    end;

    procedure CheckLineType()
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckLineType(Rec, IsHandled);
        if IsHandled then
            exit;
        if CurrFieldNo = FieldNo("Line Type") then
            exit;
        if "Line Type" = "Line Type"::Cancellation then
            Error(CancelModifyErr);
    end;

    local procedure CheckTradeType()
    begin
        if "Trade Type" = "Trade Type"::" " then
            FieldError("Trade Type");
    end;

    local procedure GetHeader()
    begin
        if "VIES Declaration No." <> VIESDeclarationHeaderCZL."No." then
            VIESDeclarationHeaderCZL.Get("VIES Declaration No.");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnDrillDownAmountLCYOnBeforeVATEntryFind(VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; var VATEntry: Record "VAT Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsVATEntryIncludedToDrillDown(VATEntry: Record "VAT Entry"; VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; var IsIncluded: Boolean; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLineType(VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeFormatVATRegNo(VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var VATRegNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
