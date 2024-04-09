// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Address;

report 31077 "Suggest VIES Declaration CZL"
{
    Caption = 'Suggest VIES Declaration Lines';
    ProcessingOnly = true;

    dataset
    {
        dataitem(VIESDeclarationHeaderCZL; "VIES Declaration Header CZL")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            dataitem(VATEntrySale; "VAT Entry")
            {
                DataItemTableView = sorting(Type, "Country/Region Code", "VAT Registration No.", "VAT Bus. Posting Group", "VAT Prod. Posting Group") where(Type = const(Sale));

                trigger OnPreDataItem()
                begin
                    if VIESDeclarationHeaderCZL."Trade Type" = VIESDeclarationHeaderCZL."Trade Type"::Purchase then
                        CurrReport.Break();

                    SetFilters(VATEntrySale);

                    RecordNo := 0;
                    NoOfRecords := Count;
                    OldTime := Time;
                end;

                trigger OnAfterGetRecord()
                begin
                    UpdateProgressBar();
                    if not IncludingAdvancePayments then
                        if VATEntrySale.IsAdvanceEntryCZL() then
                            CurrReport.Skip();
                    AddVIESDeclarationLine(VATEntrySale);
                end;
            }
            dataitem(VATEntryPurchase; "VAT Entry")
            {
                DataItemTableView = sorting(Type, "Country/Region Code", "VAT Registration No.", "VAT Bus. Posting Group", "VAT Prod. Posting Group") where(Type = const(Purchase));

                trigger OnPreDataItem()
                begin
                    if VIESDeclarationHeaderCZL."Trade Type" = VIESDeclarationHeaderCZL."Trade Type"::Sales then
                        CurrReport.Break();

                    SetFilters(VATEntryPurchase);

                    RecordNo := 0;
                    NoOfRecords := Count;
                    OldTime := Time;
                end;

                trigger OnAfterGetRecord()
                begin
                    UpdateProgressBar();
                    if not IncludingAdvancePayments then
                        if VATEntryPurchase.IsAdvanceEntryCZL() then
                            CurrReport.Skip();
                    AddVIESDeclarationLine(VATEntryPurchase);
                end;
            }

            trigger OnPreDataItem()
            var
                VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
            begin
                if GetRangeMin("No.") <> GetRangeMax("No.") then
                    Error(OnlyOneErr);

                if DeleteLines then begin
                    VIESDeclarationLineCZL.SetRange("VIES Declaration No.", GetRangeMin("No."));
                    VIESDeclarationLineCZL.DeleteAll();
                    Commit();
                end;

                WindowDialog.Open(ProcessTxt);
            end;

            trigger OnAfterGetRecord()
            begin
                WindowDialog.Update(1, "Period No.");
                WindowDialog.Update(2, Year);
            end;

            trigger OnPostDataItem()
            begin
                SaveBuffer();
                WindowDialog.Close();
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DeleteLinesCZL; DeleteLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Delete Existing Lines';
                        ToolTip = 'Specifies if existing lines have to be deleted.';
                    }
                    field(IncludingAdvancePaymentsCZL; IncludingAdvancePayments)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Including Advance Payments';
                        ToolTip = 'Specifies if advance letters will be included.';
                    }
                }
            }
        }
    }
    var
        TempVIESDeclarationLineCZL: Record "VIES Declaration Line CZL" temporary;
        VIESTransactionBuffer: List of [Integer];
        WindowDialog: Dialog;
        NoOfRecords: Integer;
        RecordNo: Integer;
        NewProgress: Integer;
        OldProgress: Integer;
        NewTime: Time;
        OldTime: Time;
        LastLineNo: Integer;
        DeleteLines: Boolean;
        IncludingAdvancePayments: Boolean;
        ProcessTxt: Label 'Quarter/Month #1## Year #2#### Suggesting lines @3@@@@@@@@@@@@@', Comment = '%1 = Period no., %2 = Year, %3 = Progress';
        OnlyOneErr: Label 'You can process one declaration only.';

    procedure AddBuffer(var VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; TransactionNo: Integer)
    begin
        TempVIESDeclarationLineCZL.SetCurrentKey("Trade Type");
        TempVIESDeclarationLineCZL.SetRange("Trade Type", VIESDeclarationLineCZL."Trade Type");
        TempVIESDeclarationLineCZL.SetRange("Country/Region Code", VIESDeclarationLineCZL."Country/Region Code");
        TempVIESDeclarationLineCZL.SetRange("VAT Registration No.", VIESDeclarationLineCZL."VAT Registration No.");
        TempVIESDeclarationLineCZL.SetRange("Trade Role Type", VIESDeclarationLineCZL."Trade Role Type");
        TempVIESDeclarationLineCZL.SetRange("EU 3-Party Trade", VIESDeclarationLineCZL."EU 3-Party Trade");
        TempVIESDeclarationLineCZL.SetRange("EU 3-Party Intermediate Role", VIESDeclarationLineCZL."EU 3-Party Intermediate Role");
        TempVIESDeclarationLineCZL.SetRange("EU Service", VIESDeclarationLineCZL."EU Service");
        if TempVIESDeclarationLineCZL.FindFirst() then begin
            TempVIESDeclarationLineCZL."Amount (LCY)" += VIESDeclarationLineCZL."Amount (LCY)";
            UpdateNumberOfSupplies(TempVIESDeclarationLineCZL, TransactionNo);
            TempVIESDeclarationLineCZL.Modify();
        end else begin
            LastLineNo += 10000;
            TempVIESDeclarationLineCZL := VIESDeclarationLineCZL;
            TempVIESDeclarationLineCZL."Line No." := LastLineNo;
            UpdateNumberOfSupplies(TempVIESDeclarationLineCZL, TransactionNo);
            TempVIESDeclarationLineCZL.Insert();
        end;
    end;

    procedure SaveBuffer()
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        LineNo: Integer;
    begin
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if VIESDeclarationLineCZL.FindLast() then
            LineNo := VIESDeclarationLineCZL."Line No.";

        TempVIESDeclarationLineCZL.Reset();
        TempVIESDeclarationLineCZL.SetFilter("Amount (LCY)", '<>%1', 0);
        if TempVIESDeclarationLineCZL.FindSet() then
            repeat
                LineNo += 10000;
                VIESDeclarationLineCZL := TempVIESDeclarationLineCZL;
                VIESDeclarationLineCZL."Amount (LCY)" := Round(TempVIESDeclarationLineCZL."Amount (LCY)", 1, '>');
                VIESDeclarationLineCZL."Line No." := LineNo;
                VIESDeclarationLineCZL.Insert();
            until TempVIESDeclarationLineCZL.Next() = 0;
    end;

    procedure UpdateNumberOfSupplies(var VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; TransactionNo: Integer)
    begin
        if VIESDeclarationLineCZL."EU Service" then
            TransactionNo := -TransactionNo;
        if VIESTransactionBuffer.Contains(TransactionNo) then
            exit;

        VIESTransactionBuffer.Add(TransactionNo);
        VIESDeclarationLineCZL."Number of Supplies" += 1;
    end;

    procedure IsEUCountry(VATEntry: Record "VAT Entry"): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if VATEntry."Country/Region Code" <> '' then begin
            CountryRegion.Get(VATEntry."Country/Region Code");
            exit(CountryRegion."EU Country/Region Code" <> '');
        end;
        exit(false);
    end;

    procedure AddVIESDeclarationLine(VATEntry: Record "VAT Entry")
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if not IsEUCountry(VATEntry) then
            exit;

        VATPostingSetup.Get(VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");
        if ((VATEntry.Type = VATEntry.Type::Sale) and VATPostingSetup."VIES Sales CZL" or
            (VATEntry.Type = VATEntry.Type::Purchase) and VATPostingSetup."VIES Purchase CZL")
        then begin
            VIESDeclarationLineCZL.Init();
            VIESDeclarationLineCZL."VIES Declaration No." := VIESDeclarationHeaderCZL."No.";
            case VATEntry.Type of
                VATEntry.Type::Sale:
                    VIESDeclarationLineCZL."Trade Type" := VIESDeclarationLineCZL."Trade Type"::Sales;
                VATEntry.Type::Purchase:
                    VIESDeclarationLineCZL."Trade Type" := VIESDeclarationLineCZL."Trade Type"::Purchase;
            end;
            VIESDeclarationLineCZL."Country/Region Code" := VATEntry."Country/Region Code";
            VIESDeclarationLineCZL."VAT Registration No." := VATEntry."VAT Registration No.";
            VIESDeclarationLineCZL."Registration No." := VATEntry."Registration No. CZL";
            VIESDeclarationLineCZL."Amount (LCY)" := -VATEntry.Base;
            VIESDeclarationLineCZL."EU 3-Party Trade" := VATEntry."EU 3-Party Trade";
            VIESDeclarationLineCZL."EU 3-Party Intermediate Role" := VATEntry."EU 3-Party Intermed. Role CZL";
            if VIESDeclarationLineCZL."EU 3-Party Trade" and VIESDeclarationLineCZL."EU 3-Party Intermediate Role" then
                VIESDeclarationLineCZL."Trade Role Type" := VIESDeclarationLineCZL."Trade Role Type"::"Intermediate Trade"
            else
                VIESDeclarationLineCZL."Trade Role Type" := VIESDeclarationLineCZL."Trade Role Type"::"Direct Trade";
            VIESDeclarationLineCZL."EU Service" := VATEntry."EU Service";
            VIESDeclarationLineCZL."System-Created" := true;
            AddBuffer(VIESDeclarationLineCZL, VATEntry."Transaction No.");
        end;
    end;

    procedure UpdateProgressBar()
    begin
        RecordNo += 1;
        NewTime := Time;
        if (NewTime - OldTime > 500) or (NewTime < OldTime) then begin
            NewProgress := Round(RecordNo / NoOfRecords * 100, 1);
            if NewProgress <> OldProgress then begin
                OldProgress := NewProgress;
                WindowDialog.Update(3, NewProgress)
            end;
            OldTime := Time;
        end;
    end;

    procedure SetFilters(var VATEntry: Record "VAT Entry")
    begin
        case VIESDeclarationHeaderCZL."EU Goods/Services" of
            VIESDeclarationHeaderCZL."EU Goods/Services"::Goods:
                VATEntry.SetRange("EU Service", false);
            VIESDeclarationHeaderCZL."EU Goods/Services"::Services:
                VATEntry.SetRange("EU Service", true);
        end;
#if not CLEAN22
#pragma warning disable AL0432
        if not VATEntry.IsReplaceVATDateEnabled() then
            VATEntry.SetRange("VAT Date CZL", VIESDeclarationHeaderCZL."Start Date", VIESDeclarationHeaderCZL."End Date")
        else
#pragma warning restore AL0432
#endif
        VATEntry.SetRange("VAT Reporting Date", VIESDeclarationHeaderCZL."Start Date", VIESDeclarationHeaderCZL."End Date");
        VATEntry.SetFilter(Base, '<>%1', 0);
    end;
}
