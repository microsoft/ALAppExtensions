// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using System.Reflection;
using Microsoft.Purchases.Vendor;
using Microsoft.Utilities;
using System.Utilities;
using System.Telemetry;
using System.IO;

report 10039 "IRS 1099 FIRE"
{
    ApplicationArea = BasicUS;
    Caption = 'IRS 1099 FIRE';
    ProcessingOnly = true;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("T Record"; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            begin
                WriteTRec();
            end;
        }
        dataitem(InitialData; Integer)
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;

            trigger OnPreDataItem()
            var
                VendorFiltered: Record Vendor;
                FormTypeIndex: Integer;
                IsDirectSales: Boolean;
            begin
                ProgressDialog.Open(ExportingTxt + ProcessTransactionsARecTxt);
                VendorsProcessed := 0;
                Helper.ClearTotals();

                VendorFiltered.CopyFilters(VendorData);
                VendorTotalCount := VendorFiltered.Count();
                if VendorFiltered.FindSet() then
                    repeat
                        VendorsProcessed += 1;
                        UpdateProgressDialog(1, Format(Round(VendorsProcessed / VendorTotalCount * 100, 1)));

                        Calc1099AmountForVendorInvoices(VendorFiltered."No.", PeriodDateGlobal);
                    until VendorFiltered.Next() = 0;
                ProgressDialog.Close();

                for FormTypeIndex := 1 to FormTypeCount do begin
                    AnyRecs[FormTypeIndex] := Helper.AnyAmount(FormTypeIndex, FormTypeLastNo[FormTypeIndex]);
                    Helper.AmtCodes(CodeNos[FormTypeIndex], FormTypeIndex, FormTypeLastNo[FormTypeIndex]);
                    // special case for 1099-MISC only
                    if FormTypeIndex = MiscTypeIndex then begin
                        InvoiceEntry.Reset();
                        InvoiceEntry.SetFilter("IRS 1099 Form Box No.", IRS1099CodeFilter[MiscTypeIndex]);
                        IsDirectSales :=
                            Helper.DirectSalesCheck(
                                Helper.UpdateLines(InvoiceEntry, MiscTypeIndex, FormTypeLastNo[MiscTypeIndex], GetFullMiscCode(7), 0.0));
                        if IsDirectSales then begin
                            CodeNos[FormTypeIndex] := '1';
                            DirectSales := '1'
                        end else
                            DirectSales := ' ';
                    end;
                end;
            end;
        }
        dataitem(VendorData; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.";
            RequestFilterHeading = 'Vendor Filter';

            trigger OnAfterGetRecord()
            var
                FormTypeIndex: Integer;
            begin
                // write IRS text lines to array for each vendor for each 1099 type
                VendorsProcessed += 1;
                UpdateProgressDialog(1, Format(Round(VendorsProcessed / VendorTotalCount * 100, 1)));

                Helper.ClearAmts();
                "Post Code" := CopyStr(Helper.StripNonNumerics("Post Code"), 1, MaxStrLen("Post Code"));

                Calc1099AmountForVendorInvoices("No.", PeriodDateGlobal);

                for FormTypeIndex := 1 to FormTypeCount do begin
                    WriteThis := Helper.AnyAmount(FormTypeIndex, FormTypeLastNo[FormTypeIndex]);
                    if WriteThis then begin
                        PayeeCount[FormTypeIndex] := PayeeCount[FormTypeIndex] + 1;
                        PayeeCountTotal := PayeeCountTotal + 1;
                        case FormTypeIndex of
                            MiscTypeIndex:
                                AddMiscBRecLine();
                            DivTypeIndex:
                                AddDivBRecLine();
                            IntTypeIndex:
                                AddIntBRecLine();
                            NecTypeIndex:
                                AddNecBRecLine();
                        end;
                    end;
                end;
            end;

            trigger OnPreDataItem()
            var
                EmptyList: List of [Text];
                FormTypeIndex: Integer;
            begin
                ProgressDialog.Open(ExportingTxt + ProcessTransactionsBRecTxt);
                VendorTotalCount := VendorData.Count();
                VendorsProcessed := 0;

                Helper.ClearTotals();
                for FormTypeIndex := 1 to FormTypeCount do begin
                    Clear(EmptyList);
                    IRSVendorLines.Insert(FormTypeIndex, EmptyList);
                end;
            end;

            trigger OnPostDataItem()
            begin
                ProgressDialog.Close();
            end;
        }
        dataitem("A Record"; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 4;
            dataitem(Vendor; Vendor)
            {
                DataItemTableView = sorting("No.");
            }
            dataitem("B Record"; Integer)
            {
                DataItemTableView = sorting(Number);
                MaxIteration = 1;

                trigger OnAfterGetRecord()
                var
                    VendorLinesGroup: List of [Text];
                    Line: Text;
                begin
                    if not AnyRecs[FormType] then
                        CurrReport.Skip();

                    VendorLinesGroup := IRSVendorLines.Get(FormType);
                    foreach Line in VendorLinesGroup do begin
                        IncrementSequenceNo();
                        UpdateSequenceNoInRecLine(Line);
                        IRSData.Add(Line);
                    end;
                end;
            }
            dataitem("C Record"; "Integer")
            {
                DataItemTableView = sorting(Number);
                MaxIteration = 1;

                trigger OnAfterGetRecord()
                begin
                    if not AnyRecs[FormType] then
                        CurrReport.Skip();

                    case FormType of
                        MiscTypeIndex:
                            WriteMISCCRec();
                        DivTypeIndex:
                            WriteDIVCRec();
                        IntTypeIndex:
                            WriteINTCRec();
                        NecTypeIndex:
                            WriteNECCRec();
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                // 1 iteration per 1099 type
                FormType := FormType + 1;
                EndLine := FormTypeLastNo[FormType];

                if AnyRecs[FormType] then begin
                    WriteARec();
                    ARecNum := ARecNum + 1;
                end else
                    CurrReport.Skip();
            end;
        }
        dataitem("F Record"; "Integer")
        {
            DataItemTableView = sorting(Number);
            MaxIteration = 1;

            trigger OnAfterGetRecord()
            begin
                WriteFRec();
            end;

            trigger OnPostDataItem()
            var
                FirstLineStart: Text;
                FirstLineEnd: Text;
                PayeeTotalStr: Text[8];
            begin
                // insert payee totals
                FirstLineStart := IRSData.Get(1).Substring(1, 295);
                FirstLineEnd := IRSData.Get(1).Substring(304);      // skip 8 chars for the total
                PayeeTotalStr := CopyStr(Helper.FormatAmount(PayeeCountTotal, MaxStrLen(PayeeTotalStr)), 1, MaxStrLen(PayeeTotalStr));
                IRSData.Set(1, FirstLineStart + PayeeTotalStr + FirstLineEnd);
            end;

            trigger OnPreDataItem()
            begin
                if not AnyRecs[FormType] then
                    CurrReport.Skip();
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
                    field(YearField; Year)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Calendar Year';
                        ToolTip = 'Specifies the tax year for the 1099 forms that you want to print. The default is the work date year. The taxes may apply to the previous calendar year so you may want to change this date if nothing prints.';

                        trigger OnValidate()
                        begin
                            if (Year < 1980) or (Year > 2060) then
                                Error(IncorrectYearErr);
                        end;
                    }
                    field(TCCField; TCC)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Transmitter Control Code';
                        ToolTip = 'Specifies the control code of the transmitter that is used to electronically file 1099 forms.';

                        trigger OnValidate()
                        begin
                            if TCC = '' then
                                Error(EmptyTCCErr);
                        end;
                    }
                    group(TransmitterInformation)
                    {
                        Caption = 'Transmitter Information';
                        field(TransmitterInfoName; TransmitterInfo.Name)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Transmitter Name';
                            ToolTip = 'Specifies the name of the transmitter that is used to electronically file 1099 forms.';
                        }
                        field(TransmitterInfoAddress; TransmitterInfo.Address)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Street Address';
                            ToolTip = 'Specifies the address of the vendor.';
                        }
                        field(TransmitterInfoCity; TransmitterInfo.City)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'City';
                            ToolTip = 'Specifies the city in the vendor''s address.';
                        }
                        field(TransmitterInfoCounty; TransmitterInfo.County)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'State';
                            ToolTip = 'Specifies the state as a part of the address.';
                        }
                        field(TransmitterInfoPostCode; TransmitterInfo."Post Code")
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'ZIP Code';
                            ToolTip = 'Specifies the vendor''s ZIP code as a part of the address.';
                        }
                        field(TransmitterInfoFederalIDNo; TransmitterInfo."Federal ID No.")
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Employer ID';
                            ToolTip = 'Specifies the employer at the vendor.';
                        }
                        field(ContactNameField; ContactName)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Contact Name';
                            ToolTip = 'Specifies the name of the contact at the vendor.';

                            trigger OnValidate()
                            begin
                                if ContactName = '' then
                                    Error(EmptyContactNameErr);
                            end;
                        }
                        field(ContactPhoneNoField; ContactPhoneNo)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Contact Phone No.';
                            ToolTip = 'Specifies the phone number of the contact at the vendor.';

                            trigger OnValidate()
                            begin
                                if ContactPhoneNo = '' then
                                    Error(EmptyContactPhoneNoErr);
                            end;
                        }
                        field(ContactEmailField; ContactEmail)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Contact E-Mail';
                            ToolTip = 'Specifies the email address of the contact at the vendor.';
                        }
                    }
                    field(bTestFileField; bTestFile)
                    {
                        ApplicationArea = BasicUS;
                        Caption = 'Test File';
                        ToolTip = 'Specifies you want to print a test file of the information that will be filed electronically.';

                        trigger OnValidate()
                        begin
                            bTestFileOnAfterValidate();
                        end;
                    }
                    group(VendorInformation)
                    {
                        Caption = 'Vendor Information';
                        field(VendIndicatorField; VendIndicator)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor Indicator';
                            OptionCaption = 'Vendor Software,In-House Software';
                            ToolTip = 'Specifies the type of vendor indicator that you want to use, including Vendor Software and In-House Software.';
                        }
                        field(VendorInfoName; TempVendorInfo.Name)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor Name';
                            ToolTip = 'Specifies the vendor''s name.';

                            trigger OnValidate()
                            begin
                                if TempVendorInfo.Name = '' then
                                    Error(EmptyVendorInfoErr);
                            end;
                        }
                        field(VendorInfoAddress; TempVendorInfo.Address)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor Street Address';
                            ToolTip = 'Specifies the vendor''s address.';

                            trigger OnValidate()
                            begin
                                if TempVendorInfo.Address = '' then
                                    Error(EmptyVendorInfoErr);
                            end;
                        }
                        field(VendorInfoCity; TempVendorInfo.City)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor City';
                            ToolTip = 'Specifies the vendors city as a part of the address.';

                            trigger OnValidate()
                            begin
                                if TempVendorInfo.City = '' then
                                    Error(EmptyVendorInfoErr);
                            end;
                        }
                        field(VendorInfoCounty; TempVendorInfo.County)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor State';
                            ToolTip = 'Specifies the vendor''s state as a part of the address.';

                            trigger OnValidate()
                            begin
                                if TempVendorInfo.County = '' then
                                    Error(EmptyVendorInfoErr);
                            end;
                        }
                        field(VendorInfoPostCode; TempVendorInfo."Post Code")
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor ZIP Code';
                            ToolTip = 'Specifies the vendor''s ZIP code as a part of the address.';

                            trigger OnValidate()
                            begin
                                if TempVendorInfo."Post Code" = '' then
                                    Error(EmptyVendorInfoErr);
                            end;
                        }
                        field(VendContactNameField; VendContactName)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor Contact Name';
                            ToolTip = 'Specifies the name of the contact at the vendor.';

                            trigger OnValidate()
                            begin
                                if VendContactName = '' then
                                    Error(EmptyVendContNameErr);
                            end;
                        }
                        field(VendContactPhoneNoField; VendContactPhoneNo)
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor Contact Phone No.';
                            ToolTip = 'Specifies the phone number of the contact at the vendor.';

                            trigger OnValidate()
                            begin
                                if VendContactPhoneNo = '' then
                                    Error(EmptyVendContPhoneNoErr);
                            end;
                        }
                        field(VendorInfoEmail; TempVendorInfo."E-Mail")
                        {
                            ApplicationArea = BasicUS;
                            Caption = 'Vendor E-Mail';
                            ToolTip = 'Specifies the vendor''s email address.';

                            trigger OnValidate()
                            begin
                                if TempVendorInfo."E-Mail" = '' then
                                    Error(EmptyVendorInfoErr);
                            end;
                        }
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            Year := Date2DMY(WorkDate(), 3);   /*default to current working year*/
            CompanyInfo.Get();
            Helper.EditCompanyInfo(CompanyInfo);
            TransmitterInfo := CompanyInfo;
            Helper.EditCompanyInfo(CompanyInfo);

        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        FeatureTelemetry.LogUsage('0000ODO', FIRE1099FeatureNameTxt, RunMagMediaReportMsg);
        TestFile := ' ';
        PriorYear := ' ';
        SequenceNo := 0;
    end;

    trigger OnPostReport()
    var
        TempBlob: Codeunit "Temp Blob";
        TypeHelper: Codeunit "Type Helper";
        FileManagement: Codeunit "File Management";
        InStream: InStream;
        BlobOutStream: OutStream;
        IRSDataLine: Text;
        CRLF: Text[2];
    begin
        CRLF := TypeHelper.CRLFSeparator();
        TempBlob.CreateOutStream(BlobOutStream);
        foreach IRSDataLine in IRSData do
            BlobOutStream.WriteText(IRSDataLine + CRLF);
        OnBeforeDownloadFile(TempBlob);

        TempBlob.CreateInStream(InStream);
        if FileName = '' then
            FileName := ClientFileNameTxt;
        FileManagement.DownloadFromStreamHandler(InStream, '', '', '*.txt', FileName);
    end;

    trigger OnPreReport()
    begin
        if TCC = '' then
            Error(EmptyTCCErr);
        if ContactPhoneNo = '' then
            Error(EmptyContactPhoneNoErr);
        if ContactName = '' then
            Error(EmptyContactNameErr);
        if VendContactName = '' then
            Error(EmptyVendContNameErr);
        if VendContactPhoneNo = '' then
            Error(EmptyVendContPhoneNoErr);
        if TempVendorInfo.Name = '' then
            Error(EmptyVendorInfoErr);
        if TempVendorInfo.Address = '' then
            Error(EmptyVendorInfoErr);
        if TempVendorInfo.City = '' then
            Error(EmptyVendorInfoErr);
        if TempVendorInfo.County = '' then
            Error(EmptyVendorInfoErr);
        if TempVendorInfo."Post Code" = '' then
            Error(EmptyVendorInfoErr);
        if TempVendorInfo."E-Mail" = '' then
            Error(EmptyVendorInfoErr);

        FormType := 0;

        // Create date range which covers the entire calendar year
        PeriodDateGlobal[1] := DMY2Date(1, 1, Year);
        PeriodDateGlobal[2] := DMY2Date(31, 12, Year);

        Clear(PayeeCount);
        Clear(ARecNum);

        FormTypeCount := 4;
        MiscTypeIndex := 1;
        DivTypeIndex := 2;
        IntTypeIndex := 3;
        NecTypeIndex := 4;
        FormTypeLastNo[MiscTypeIndex] := 17;
        FormTypeLastNo[DivTypeIndex] := 18;
        FormTypeLastNo[IntTypeIndex] := 13;
        FormTypeLastNo[NecTypeIndex] := 4;
        IRS1099CodeFilter[MiscTypeIndex] := 'MISC-..MISC-99';
        IRS1099CodeFilter[DivTypeIndex] := 'DIV-..DIV-99';
        IRS1099CodeFilter[IntTypeIndex] := 'INT-..INT-99';
        IRS1099CodeFilter[NecTypeIndex] := 'NEC-..NEC-99';
        ReturnType[MiscTypeIndex] := 'A ';
        ReturnType[DivTypeIndex] := '1 ';
        ReturnType[IntTypeIndex] := '6 ';
        ReturnType[NecTypeIndex] := 'NE';
        Helper.FillFormBoxNoArray(Format(Year));
    end;

    var
        CompanyInfo: Record "Company Information";
        TransmitterInfo: Record "Company Information";
        TempVendorInfo: Record "Company Information" temporary;
        TempAppliedEntry: Record "Vendor Ledger Entry" temporary;
        InvoiceEntry: Record "Vendor Ledger Entry";
        EntryAppMgt: Codeunit "Entry Application Management";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        Helper: Codeunit "Helper FIRE";
        IRSData: List of [Text];
        PeriodDateGlobal: array[2] of Date;
        Year: Integer;
        DirectSales: Text[1];
        ReturnType: array[4] of Text[2];
        CodeNos: array[4] of Text[12];
        WriteThis: Boolean;
        AnyRecs: array[4] of Boolean;
        MiscTypeIndex: Integer;
        DivTypeIndex: Integer;
        IntTypeIndex: Integer;
        NecTypeIndex: Integer;
        FormTypeCount: Integer;
        VendorTotalCount: Integer;
        VendorsProcessed: Integer;
        FormTypeLastNo: array[4] of Integer;
        IRS1099CodeFilter: array[4] of Text;
        IRSVendorLines: List of [List of [Text]];
        EndLine: Integer;
        Invoice1099Amount: Decimal;
        FormType: Integer;
        TestFile: Text[1];
        PriorYear: Text[1];
        TCC: Code[5];
        ContactName: Text[40];
        ContactPhoneNo: Text[30];
        ContactEmail: Text[35];
        VendContactName: Text[40];
        VendContactPhoneNo: Text[30];
        PayeeCount: array[4] of Integer;
        PayeeCountTotal: Integer;
        ARecNum: Integer;
        bTestFile: Boolean;
        ProgressDialog: Dialog;
        VendIndicator: Option "Vendor Software","In-House Software";
        SequenceNo: Integer;
        EmptyContactPhoneNoErr: Label 'You must enter the phone number of the person to be contacted if IRS/MCC encounters problems with the file or transmission.';
        EmptyContactNameErr: Label 'You must enter the name of the person to be contacted if IRS/MCC encounters problems with the file or transmission.';
        EmptyVendContPhoneNoErr: Label 'You must enter the phone number of the person to be contacted if IRS/MCC has any software questions.';
        EmptyVendContNameErr: Label 'You must enter the name of the person to be contacted if IRS/MCC has any software questions.';
        EmptyTCCErr: Label 'You must enter the Transmitter Control Code assigned to you by the IRS.';
        EmptyVendorInfoErr: Label 'You must enter all software vendor address information.';
        IncorrectYearErr: Label 'You must enter a valid year, eg 1993.';
        ClientFileNameTxt: Label 'IRSTAX.txt';
        ExportingTxt: Label 'Exporting...\';
        ProcessTransactionsARecTxt: label 'Processing transactions for A records: #1###', Comment = '#1 - percent of processed vendors';
        ProcessTransactionsBRecTxt: label 'Processing transactions for B records: #1###', Comment = '#1 - percent of processed vendors';
        FIRE1099FeatureNameTxt: Label 'IRS Forms FIRE', Locked = true;
        RunMagMediaReportMsg: Label 'Run IRS 1099 FIRE report', Locked = true;
        MiscCodeTok: Label 'MISC-', Locked = true;
        NecCodeTok: Label 'NEC-', Locked = true;
        HashTagTok: Label '#', Locked = true;
        BlankTagTok: Label ' ', Locked = true;
        FileName: Text;

    procedure ProcessVendorInvoices(VendorNo: Code[20]; PeriodDate: array[2] of Date)
    var
        IRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj.";
        TempIRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj." temporary;
    begin
        // search for invoices paid off by this payment
        EntryAppMgt.GetAppliedVendorEntries(TempAppliedEntry, VendorNo, PeriodDate, true);
        // search for invoices with 1099 amounts
        TempAppliedEntry.SetFilter("Document Type", '%1|%2', TempAppliedEntry."Document Type"::Invoice, TempAppliedEntry."Document Type"::"Credit Memo");
        TempAppliedEntry.SetFilter("IRS 1099 Reporting Amount", '<>0');
        case FormType of
            1:
                TempAppliedEntry.SetRange("IRS 1099 Form Box No.", 'MISC-', 'MISC-99');
            2:
                TempAppliedEntry.SetRange("IRS 1099 Form Box No.", 'DIV-', 'DIV-99');
            3:
                TempAppliedEntry.SetRange("IRS 1099 Form Box No.", 'INT-', 'INT-99');
            4:
                TempAppliedEntry.SetRange("IRS 1099 Form Box No.", 'NEC-', 'NEC-99');
        end;
        if TempAppliedEntry.FindSet() then
            repeat
                Calculate1099Amount(TempAppliedEntry, TempAppliedEntry."Amount to Apply");
                if GetAdjustmentRec(IRS1099Adjustment, TempAppliedEntry) then begin
                    TempIRS1099Adjustment := IRS1099Adjustment;
                    if not TempIRS1099Adjustment.Find() then begin
                        Helper.UpdateLines(
                          TempAppliedEntry, FormType, EndLine, TempAppliedEntry."IRS 1099 Form Box No.", IRS1099Adjustment.Amount);
                        TempIRS1099Adjustment.Insert();
                    end;
                end;
            until TempAppliedEntry.Next() = 0;
    end;

    procedure Calculate1099Amount(VendorLedgerEntry: Record "Vendor Ledger Entry"; AppliedAmount: Decimal)
    begin
        VendorLedgerEntry.CalcFields(Amount);
        Invoice1099Amount := -AppliedAmount * VendorLedgerEntry."IRS 1099 Reporting Amount" / VendorLedgerEntry.Amount;
        Helper.UpdateLines(VendorLedgerEntry, FormType, EndLine, VendorLedgerEntry."IRS 1099 Form Box No.", Invoice1099Amount);
    end;

    local procedure Calc1099AmountForVendorInvoices(VendorNo: Code[20]; StartEndDate: array[2] of Date)
    var
        TempApplVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        TempIRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj." temporary;
        IRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj.";
        IRSReportingPeriod: Codeunit "IRS Reporting Period";
        FormTypeIndex: Integer;
        PeriodNo: Code[20];
    begin
        PeriodNo := IRSReportingPeriod.GetReportingPeriod(StartEndDate[1], StartEndDate[2]);
        EntryAppMgt.GetAppliedVendorEntries(TempApplVendorLedgerEntry, VendorNo, StartEndDate, true);
        for FormTypeIndex := 1 to FormTypeCount do begin
            TempApplVendorLedgerEntry.SetFilter("Document Type", '%1|%2', Enum::"Gen. Journal Document Type"::Invoice, Enum::"Gen. Journal Document Type"::"Credit Memo");
            TempApplVendorLedgerEntry.SetFilter("IRS 1099 Reporting Amount", '<>0');
            TempApplVendorLedgerEntry.SetFilter("IRS 1099 Form Box No.", IRS1099CodeFilter[FormTypeIndex]);
            if TempApplVendorLedgerEntry.FindSet() then
                repeat
                    Calculate1099Amount(TempApplVendorLedgerEntry, FormTypeIndex);
                    if GetAdjustmentRec(IRS1099Adjustment, TempApplVendorLedgerEntry) then begin
                        TempIRS1099Adjustment := IRS1099Adjustment;
                        if not TempIRS1099Adjustment.Find() then begin
                            Helper.UpdateLines(
                                TempApplVendorLedgerEntry, FormTypeIndex, FormTypeLastNo[FormTypeIndex], TempApplVendorLedgerEntry."IRS 1099 Form Box No.", IRS1099Adjustment.Amount);
                            TempIRS1099Adjustment.Insert();
                        end;
                    end;
                until TempApplVendorLedgerEntry.Next() = 0;
            AddAdjustments(TempIRS1099Adjustment, VendorNo, PeriodNo, FormTypeIndex, IRS1099CodeFilter[FormTypeIndex]);
        end;
    end;

    local procedure AddAdjustments(var TempIRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj." temporary; VendorNo: Code[20]; PeriodNo: Code[20]; FormTypeIndex: Integer; IRSCodeFilter: Text)
    var
        DummyVendorLedgerEntry: Record "Vendor Ledger Entry";
        IRS1099FormBox: Record "IRS 1099 Form Box";
        IRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj.";
    begin
        if VendorNo = '' then
            exit;
        if PeriodNo = '' then
            exit;
        if IRSCodeFilter = '' then
            exit;
        IRS1099FormBox.SetFilter("No.", IRSCodeFilter);
        if not IRS1099FormBox.FindSet() then
            exit;
        repeat
            if not TempIRS1099Adjustment.Get(PeriodNo, VendorNo, IRS1099FormBox."Form No.", IRS1099FormBox."No.") then
                if IRS1099Adjustment.Get(PeriodNo, VendorNo, IRS1099FormBox."Form No.", IRS1099FormBox."No.") then begin
                    Helper.UpdateLines(
                        DummyVendorLedgerEntry, FormTypeIndex, FormTypeLastNo[FormTypeIndex], IRS1099Adjustment."Form Box No.", IRS1099Adjustment.Amount);
                    TempIRS1099Adjustment := IRS1099Adjustment;
                    TempIRS1099Adjustment.Insert();
                end;
        until IRS1099FormBox.Next() = 0;
    end;

    local procedure Calculate1099Amount(AppliedVendorLedgerEntry: Record "Vendor Ledger Entry"; FormTypeIndex: Integer)
    begin
        AppliedVendorLedgerEntry.CalcFields(Amount);
        Invoice1099Amount := -AppliedVendorLedgerEntry."Amount to Apply" * AppliedVendorLedgerEntry."IRS 1099 Reporting Amount" / AppliedVendorLedgerEntry.Amount;
        Helper.UpdateLines(AppliedVendorLedgerEntry, FormTypeIndex, FormTypeLastNo[FormTypeIndex], AppliedVendorLedgerEntry."IRS 1099 Form Box No.", Invoice1099Amount);
    end;

    local procedure GetForeignEntityIndicator(TempVendorInformation: Record "Company Information" temporary): Text[1]
    var
        PostCode: Record "Post Code";
    begin
        PostCode.SetRange(Code, TempVendorInformation."Post Code");
        PostCode.SetRange(City, TempVendorInformation.City);
        if PostCode.FindFirst() then
            if PostCode."Country/Region Code" in ['US', 'USA'] then
                exit(' ')
            else
                exit('1');
        exit(' ');
    end;

    procedure WriteTRec()
    begin
        // T Record - 1 per transmission, 750 length
        IncrementSequenceNo();
        IRSData.Add('T' +
          StrSubstNo('#1##', CopyStr(Format(Year), 1, 4)) +
          StrSubstNo(PriorYear) + // Prior Year Indicator
          StrSubstNo('#1#######', Helper.StripNonNumerics(TransmitterInfo."Federal ID No.")) +
          StrSubstNo('#1###', TCC) + // Transmitter Control Code
          StrSubstNo('  ') + // replacement character
          StrSubstNo('     ') + // blank 5
          StrSubstNo(TestFile) +
          StrSubstNo(' ') + // Foreign Entity Code
          StrSubstNo('#1##############################################################################',
            TransmitterInfo.Name) +
          StrSubstNo('#1################################################', CompanyInfo.Name) +
          StrSubstNo('                              ') + // 2nd Payer Name
          StrSubstNo('#1######################################', CompanyInfo.Address) +
          StrSubstNo('#1######################################', CompanyInfo.City) +
          StrSubstNo('#1', CopyStr(CompanyInfo.County, 1, 2)) +
          StrSubstNo('#1#######', Helper.StripNonNumerics(CompanyInfo."Post Code")) +
          StrSubstNo('               ') + // blank 15
          StrSubstNo('#1######', Helper.FormatAmount(PayeeCountTotal, 8)) + // Payee total
          StrSubstNo('#1######################################', ContactName) +
          StrSubstNo('#1#############', ContactPhoneNo) +
          StrSubstNo('#1################################################', ContactEmail) + // 359-408
          StrSubstNo('  ') + // Tape file indicator
          StrSubstNo('#1####', '      ') + // place for media number (not required)
          StrSubstNo('                                                  ') +
          StrSubstNo('                                 ') +
          StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
          StrSubstNo('          ') +
          StrSubstNo('%1', CopyStr(Format(VendIndicator), 1, 1)) +
          StrSubstNo('#1######################################', TempVendorInfo.Name) +
          StrSubstNo('#1######################################', TempVendorInfo.Address) +
          StrSubstNo('#1######################################', TempVendorInfo.City) +
          StrSubstNo('#1', CopyStr(TempVendorInfo.County, 1, 2)) +
          StrSubstNo('#1#######', Helper.StripNonNumerics(TempVendorInfo."Post Code")) +
          StrSubstNo('#1######################################', VendContactName) +
          StrSubstNo('#1#############', VendContactPhoneNo) +
          StrSubstNo('#1##################', TempVendorInfo."E-Mail") + // 20 chars
          StrSubstNo('               ') +
          StrSubstNo('%1', GetForeignEntityIndicator(TempVendorInfo)) + // position 740
          StrSubstNo('          '));
    end;

    procedure WriteARec()
    begin
        // A Record - 1 per Payer per 1099 type, 750 length
        IncrementSequenceNo();
        IRSData.Add('A' +
          StrSubstNo('#1##', CopyStr(Format(Year), 1, 4)) +
          StrSubstNo('      ') + // 6 blanks
          StrSubstNo('#1#######', Helper.StripNonNumerics(CompanyInfo."Federal ID No.")) + // TIN
          StrSubstNo('#1##', '    ') + // Payer Name Control
          StrSubstNo(' ') +
          StrSubstNo(ReturnType[FormType]) +
          StrSubstNo('#1##############', CodeNos[FormType]) + // Amount Codes  16
          StrSubstNo('        ') + // 8 blanks
          StrSubstNo(' ') + // Foreign Entity Code
          StrSubstNo('#1######################################', CompanyInfo.Name) +
          StrSubstNo('                                        ') + // 2nd Payer Name
          StrSubstNo(' ') + // Transfer Agent Indicator
          StrSubstNo('#1######################################', CompanyInfo.Address) +
          StrSubstNo('#1######################################', CompanyInfo.City) +
          StrSubstNo('#1', CompanyInfo.County) +
          StrSubstNo('#1#######', Helper.StripNonNumerics(CompanyInfo."Post Code")) +
          StrSubstNo('#1#############', CompanyInfo."Phone No.") +
          StrSubstNo('                                                  ') + // blank 50
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('          ') +
          StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                           '));
    end;

    procedure WriteMiscBRec()
    begin
        IncrementSequenceNo();
        IRSData.Add(GetMiscBRec());
    end;

    local procedure AddMiscBRecLine()
    begin
        IRSVendorLines.Get(MiscTypeIndex).Add(GetMiscBRec());
    end;

    local procedure GetMiscBRec(): Text
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := MiscTypeIndex;
        LastNo := FormTypeLastNo[MiscTypeIndex];

        exit('B' +
            StrSubstNo('#1##', CopyStr(Format(Year), 1, 4)) +
            StrSubstNo(' ') + // correction indicator
            StrSubstNo('    ') + // name control
            StrSubstNo(' ') + // Type of TIN
            StrSubstNo('#1#######', Helper.StripNonNumerics(VendorData."Federal ID No.")) + // TIN
            StrSubstNo('#1##################', VendorData."No.") + // Payer's Payee Account #
            StrSubstNo('              ') + // Blank 14
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(1), FormTypeIndex, LastNo), 12)) + // Payment 1
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(2), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(3), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(4), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(5), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(6), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(8), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(9), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(14), FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(10), FormTypeIndex, LastNo), 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(12), FormTypeIndex, LastNo), 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(11), FormTypeIndex, LastNo), 12)) + // Fish purchased for resale
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('                ') + // blank 16
            StrSubstNo(' ') + // Foreign Country Indicator
            StrSubstNo('#1######################################', VendorData.Name) +
            StrSubstNo('#1######################################', VendorData."Name 2") +
            StrSubstNo('#1######################################', VendorData.Address) +
            StrSubstNo('                                        ') + // blank 40
            StrSubstNo('#1######################################', VendorData.City) +
            StrSubstNo('#1', VendorData.County) +
            StrSubstNo('#1#######', VendorData."Post Code") +
            StrSubstNo(' ') +
            StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
            StrSubstNo('                                    ') +
            StrSubstNo(' ') + // Second TIN Notice (Optional) (544)
            StrSubstNo('  ') + // Blank (545-546)
            StrSubstNo(DirectSales) + // Direct Sales Indicator (547)
            StrSubstNo(Format(VendorData."FATCA Requirement", 0, 2)) + // FATCA Filing Requirement Indicator (548)
            StrSubstNo('                                                  ') +
            StrSubstNo('                                                  ') +
            StrSubstNo('              ') + // Blank (549-662)
            StrSubstNo('                                                  ') +
            StrSubstNo('          ') + // Special Data Entries (663-722)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullMiscCode(15), FormTypeIndex, LastNo), 12)) + // State Income Tax Withheld (723-734)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) + // Local Income Tax Withheld (735-746)
            StrSubstNo('  ') + // Combined Federal/State Code (747-748)
            StrSubstNo('  ')   // Blank (749-750)
        );
    end;

    procedure WriteDivBRec()
    begin
        IncrementSequenceNo();
        IRSData.Add(GetDivBRec());
    end;

    local procedure AddDivBRecLine()
    begin
        IRSVendorLines.Get(DivTypeIndex).Add(GetDivBRec());
    end;

    local procedure GetDivBRec(): Text
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := DivTypeIndex;
        LastNo := FormTypeLastNo[DivTypeIndex];

        exit('B' + // Type (1)
            StrSubstNo('#1##', CopyStr(Format(Year), 1, 4)) + // Payment Year (2-5)
            StrSubstNo(' ') + // Corrected Return Indicator (6)
            StrSubstNo('    ') + // Name Control (7-10)
            StrSubstNo(' ') + // Type of TIN (11)
            StrSubstNo('#1#######', Helper.StripNonNumerics(VendorData."Federal ID No.")) + // Payee's TIN (12-20)
            StrSubstNo('#1##################', VendorData."No.") + // Payer's Account Number for Payee (21-40)
            StrSubstNo('              ') + // Payer's Office Code (41-44) and Blank (45-54)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-01-A', FormTypeIndex, LastNo) +
                Helper.GetAmt('DIV-01-B', FormTypeIndex, LastNo) +
                Helper.GetAmt('DIV-05', FormTypeIndex, LastNo) +
                Helper.GetAmt('DIV-06', FormTypeIndex, LastNo), 12)) + // ordinary dividends 1 (55-66)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-01-B', FormTypeIndex, LastNo), 12)) + // 2 (67-78)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-02-A', FormTypeIndex, LastNo) +
                Helper.GetAmt('DIV-02-B', FormTypeIndex, LastNo) +
                Helper.GetAmt('DIV-02-C', FormTypeIndex, LastNo) +
                Helper.GetAmt('DIV-02-D', FormTypeIndex, LastNo), 12)) + // total capital gains 3 (79-90)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) + // 4 (91-102)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-05', FormTypeIndex, LastNo), 12)) + // 5-Section 199A Dividends (103-114)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-02-B', FormTypeIndex, LastNo), 12)) + // 6-Unrecaptured Section 1250 gain (115-126)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-02-C', FormTypeIndex, LastNo), 12)) + // 7-Section 1202 gain (127-138)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-02-D', FormTypeIndex, LastNo), 12)) + // 8-Collectibles (28%) gain (139-150)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-03', FormTypeIndex, LastNo), 12)) + // 9-Nondividend distributions (151-162)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-04', FormTypeIndex, LastNo), 12)) + // fed W/H A (163-174)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-06', FormTypeIndex, LastNo), 12)) + // investment. expenses B (175-186)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-07', FormTypeIndex, LastNo), 12)) + // Foreign Taxc Paid C (187-198)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-09', FormTypeIndex, LastNo), 12)) + // cash liquidation D (199-210)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-10', FormTypeIndex, LastNo), 12)) + // non-cash liquidation E (211-222)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-12', FormTypeIndex, LastNo), 12)) + // Exempt-interest dividends F (223-234)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-13', FormTypeIndex, LastNo), 12)) + // Specified private activity bond... G (235-246)
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-02-E', FormTypeIndex, LastNo), 12)) + // Section 897 Ordinary Dividens (247-258)
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt('DIV-02-F', FormTypeIndex, LastNo), 12)) + // Section 897 Capital Gains (259-270)
            GetBlankedStringWithLength(16) + // blank 16 (271-286)
            GetBlankedStringWithLength(1) + // Foreign Country Indicator (287)
            StrSubstNo(GetHashTagStringWithLength(40), GetFullVendorName(VendorData)) +
            GetBlankedStringWithLength(40) + // blank 40
            StrSubstNo(GetHashTagStringWithLength(40), VendorData.Address) +
            GetBlankedStringWithLength(40) + // blank 40
            StrSubstNo(GetHashTagStringWithLength(40), VendorData.City) +
            StrSubstNo('#1', VendorData.County) +
            StrSubstNo('#1#######', VendorData."Post Code") +
            StrSubstNo(' ') +
            StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence (500-507) number for all rec types
            StrSubstNo('                                    ') +
            StrSubstNo(' ') + // Second TIN Notice (Optional) (544)
            StrSubstNo('  ') + // Blank (545-546)
            StrSubstNo('                                        ') + // Foreign Country or U.S. Possession (547-586)
            StrSubstNo(Format(VendorData."FATCA Requirement", 0, 2)) + // FATCA Filing Requirement Indicator (587)
            StrSubstNo('                                                  ') +
            StrSubstNo('                         ') + // Blank (588-662)
            StrSubstNo('                                                  ') +
            StrSubstNo('          ') + // Special Data Entries (663-722)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) + // State Income Tax Withheld (723-734)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) + // Local Income Tax Withheld (735-746)
            StrSubstNo('  ') + // Combined Federal/State Code (747-748)
            StrSubstNo('  ') // Blank (749-750)
        );
    end;

    procedure WriteIntBRec()
    begin
        IncrementSequenceNo();
        IRSData.Add(GetIntBRec());
    end;

    local procedure AddIntBRecLine()
    begin
        IRSVendorLines.Get(IntTypeIndex).Add(GetIntBRec());
    end;

    local procedure GetIntBRec(): Text
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := IntTypeIndex;
        LastNo := FormTypeLastNo[IntTypeIndex];

        exit('B' +
            StrSubstNo('#1##', CopyStr(Format(Year), 1, 4)) +
            StrSubstNo(' ') + // correction indicator
            StrSubstNo('    ') + // name control
            StrSubstNo(' ') + // Type of TIN
            StrSubstNo('#1#######', Helper.StripNonNumerics(VendorData."Federal ID No.")) + // TIN
            StrSubstNo('#1##################', VendorData."No.") + // Payer's Payee Account #
            StrSubstNo('              ') + // Blank 14
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-01', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-02', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-03', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-04', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-05', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-06', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-08', FormTypeIndex, LastNo) +
                Helper.GetAmt('INT-09', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-09', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-10', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-11', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-13', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(
                Helper.GetAmt('INT-12', FormTypeIndex, LastNo), 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo('                ') + // blank 16
            StrSubstNo(' ') + // Foreign Country Indicator
            StrSubstNo('#1######################################', VendorData.Name) +
            StrSubstNo('#1######################################', VendorData."Name 2") +
            StrSubstNo('#1######################################', VendorData.Address) +
            StrSubstNo('                                        ') + // blank 40
            StrSubstNo('#1######################################', VendorData.City) +
            StrSubstNo('#1', VendorData.County) +
            StrSubstNo('#1#######', VendorData."Post Code") +
            StrSubstNo(' ') +
            StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
            StrSubstNo('                                    ') +
            StrSubstNo(' ') + // Second TIN Notice (Optional) (544)
            StrSubstNo('  ') + // Blank (545-546)
            StrSubstNo('                                        ') + // Foreign Country or U.S. Possession (547-586)
            StrSubstNo('             ') + // CUSIP Number (587-599)
            StrSubstNo(Format(VendorData."FATCA Requirement", 0, 2)) + // FATCA Filing Requirement Indicator (600)
            StrSubstNo('                                                  ') +
            StrSubstNo('            ') + // Blank (601-662)
            StrSubstNo('                                                  ') +
            StrSubstNo('          ') + // Special Data Entries (663-722)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) + // State Income Tax Withheld (723-734)
            StrSubstNo('#1##########', Helper.FormatMoneyAmount(0, 12)) + // Local Income Tax Withheld (735-746)
            StrSubstNo('  ') + // Combined Federal/State Code (747-748)
            StrSubstNo('  ') // Blank (749-750)
          );
    end;

    procedure WriteNecBRec()
    begin
        IncrementSequenceNo();
        IRSData.Add(GetNecBRec());
    end;

    local procedure AddNecBRecLine()
    begin
        IRSVendorLines.Get(NecTypeIndex).Add(GetNecBRec());
    end;

    local procedure GetNecBRec(): Text
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := NecTypeIndex;
        LastNo := FormTypeLastNo[NecTypeIndex];

        exit('B' +
            StrSubstNo('#1##', CopyStr(Format(Year), 1, 4)) +
            ' ' +
            '    ' +
            ' ' +
            StrSubstNo(GetHashTagStringWithLength(9), Helper.StripNonNumerics(VendorData."Federal ID No.")) +
            StrSubstNo(GetHashTagStringWithLength(20), VendorData."No.") +
            '              ' +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullNecCode(1), FormTypeIndex, LastNo), 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(
                Helper.GetAmt(GetFullNecCode(4), FormTypeIndex, LastNo), 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            '                ' + // blank 16
            ' ' +
            StrSubstNo(GetHashTagStringWithLength(40), VendorData.Name) +
            StrSubstNo(GetHashTagStringWithLength(40), VendorData."Name 2") +
            StrSubstNo(GetHashTagStringWithLength(40), VendorData.Address) +
            '                                        ' +
            StrSubstNo(GetHashTagStringWithLength(40), VendorData.City) +
            StrSubstNo(GetHashTagStringWithLength(0), VendorData.County) +
            StrSubstNo(GetHashTagStringWithLength(9), VendorData."Post Code") +
            ' ' +
            StrSubstNo(GetHashTagStringWithLength(8), Helper.FormatAmount(SequenceNo, 8)) +
            '                                    ' +
            ' ' +
            '   ' +
            StrSubstNo(Format(VendorData."FATCA Requirement", 0, 2)) +
            '                                                  ' +
            '                                                  ' +
            '              ' +
            '                                                  ' +
            '          ' +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            StrSubstNo(GetHashTagStringWithLength(12), Helper.FormatMoneyAmount(0, 12)) +
            '  ' +
            '  '
        );
    end;

    procedure WriteMISCCRec()
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := MiscTypeIndex;
        LastNo := FormTypeLastNo[MiscTypeIndex];

        // C Record - 1 per Payer per 1099 type
        IncrementSequenceNo();
        IRSData.Add('C' +
          StrSubstNo('#1######', Helper.FormatAmount(PayeeCount[MiscTypeIndex], 8)) +
          StrSubstNo('      ') + // Blank 6
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(1), FormTypeIndex, LastNo), 18)) + // Payment 1
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(2), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(3), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(4), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(5), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(6), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(8), FormTypeIndex, LastNo), 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(9), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(14), FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(10), FormTypeIndex, LastNo), 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(12), FormTypeIndex, LastNo), 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullMiscCode(11), FormTypeIndex, LastNo), 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('          ') +
          StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                           '));
    end;

    procedure WriteDIVCRec()
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := DivTypeIndex;
        LastNo := FormTypeLastNo[DivTypeIndex];

        // C Record - 1 per Payer per 1099 type
        IncrementSequenceNo();
        IRSData.Add('C' +
          StrSubstNo('#1######', Helper.FormatAmount(PayeeCount[DivTypeIndex], 8)) +
          StrSubstNo('      ') + // Blank 6
          StrSubstNo('#1################', Helper.FormatMoneyAmount(// ordinary dividends
              Helper.GetTotal('DIV-01-A', FormTypeIndex, LastNo) +
              Helper.GetTotal('DIV-01-B', FormTypeIndex, LastNo) +
              Helper.GetTotal('DIV-05', FormTypeIndex, LastNo) +
              Helper.GetTotal('DIV-06', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-01-B', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(// total capital gains
              Helper.GetTotal('DIV-02-A', FormTypeIndex, LastNo) +
              Helper.GetTotal('DIV-02-B', FormTypeIndex, LastNo) +
              Helper.GetTotal('DIV-02-C', FormTypeIndex, LastNo) +
              Helper.GetTotal('DIV-02-D', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-05', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-02-B', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-02-C', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-02-D', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(// Nondividend dist. 9
              Helper.GetTotal('DIV-03', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(// fed income tax W/H A
              Helper.GetTotal('DIV-04', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(// investment. expenses B
              Helper.GetTotal('DIV-06', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-07', FormTypeIndex, LastNo), 18)) + // Foreign Taxc Paid C
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-09', FormTypeIndex, LastNo), 18)) + // cash liquidation D
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-10', FormTypeIndex, LastNo), 18)) + // non-cash liquidation E
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-12', FormTypeIndex, LastNo), 18)) + // Exempt-interest dividends F
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-13', FormTypeIndex, LastNo), 18)) + // Specified private activity bond interest dividends G
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-02-E', FormTypeIndex, LastNo), 18)) + // Specified 897 Ordinary Dividends
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal('DIV-02-F', FormTypeIndex, LastNo), 18)) + // Specified 897 Capital Gains
          GetBlankedStringWithLength(160) +
          StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                           '));
    end;

    procedure WriteINTCRec()
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := IntTypeIndex;
        LastNo := FormTypeLastNo[IntTypeIndex];

        // C Record - 1 per Payer per 1099 type
        IncrementSequenceNo();
        IRSData.Add('C' +
          StrSubstNo('#1######', Helper.FormatAmount(PayeeCount[IntTypeIndex], 8)) +
          StrSubstNo('      ') + // Blank 6
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-01', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-02', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-03', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-04', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-05', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-06', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-08', FormTypeIndex, LastNo) +
              Helper.GetTotal('INT-09', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-09', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-10', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-11', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-13', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(
              Helper.GetTotal('INT-12', FormTypeIndex, LastNo), 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('#1################', Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('          ') +
          StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                           '));
    end;

    procedure WriteNECCRec()
    var
        FormTypeIndex: Integer;
        LastNo: Integer;
    begin
        FormTypeIndex := NecTypeIndex;
        LastNo := FormTypeLastNo[NecTypeIndex];

        // C Record - 1 per Payer per 1099 type
        IncrementSequenceNo();
        IRSData.Add('C' +
          StrSubstNo(GetHashTagStringWithLength(8), Helper.FormatAmount(PayeeCount[NecTypeIndex], 8)) +
          '      ' +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullNecCode(1), FormTypeIndex, LastNo), 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(
              Helper.GetTotal(GetFullNecCode(4), FormTypeIndex, LastNo), 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          StrSubstNo(GetHashTagStringWithLength(18), Helper.FormatMoneyAmount(0, 18)) +
          '                                                  ' +
          '                                                  ' +
          '                                                  ' +
          '          ' +
          StrSubstNo(GetHashTagStringWithLength(8), Helper.FormatAmount(SequenceNo, 8)) +
          '                                                  ' +
          '                                                  ' +
          '                                                  ' +
          '                                                  ' +
          '                                           ');
    end;

    procedure WriteFRec()
    begin
        // F Record - 1
        IncrementSequenceNo();
        IRSData.Add('F' +
          StrSubstNo('#1######', Helper.FormatAmount(ARecNum, 8)) + // number of A recs.
          StrSubstNo('#1########', Helper.FormatAmount(0, 10)) + // 21 zeros
          StrSubstNo('#1#########', Helper.FormatAmount(0, 11)) +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                   ') +
          StrSubstNo('#1######', Helper.FormatAmount(SequenceNo, 8)) + // sequence number for all rec types
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                                  ') +
          StrSubstNo('                                           '));
    end;

    local procedure GetFullMiscCode(Number: Integer): Code[10]
    begin
        exit(GetFullCode(MiscCodeTok, Number));
    end;

    local procedure GetFullNecCode(Number: Integer): Code[10]
    begin
        exit(GetFullCode(NecCodeTok, Number));
    end;

    local procedure GetFullCode(Prefix: Text; Number: Integer) FullCode: Code[10]
    begin
        FullCode += Prefix;
        if Number < 10 then
            FullCode += Format(0);
        exit(FullCode + Format(Number));
    end;

    local procedure GetHashTagStringWithLength(Length: Integer) Result: Text
    var
        j: Integer;
    begin
        Result += HashTagTok + Format(1);
        for j := 1 to (Length - 2) do
            Result += HashTagTok;
        exit(Result);
    end;

    local procedure GetBlankedStringWithLength(Length: Integer) Result: Text
    var
        j: Integer;
    begin
        for j := 1 to Length do
            Result += BlankTagTok;
        exit(Result);
    end;

    procedure IncrementSequenceNo()
    begin
        SequenceNo := SequenceNo + 1;
    end;

    local procedure bTestFileOnAfterValidate()
    begin
        if bTestFile then
            TestFile := 'T';
    end;

    procedure InitializeRequest(NewFileName: Text)
    begin
        FileName := NewFileName;
    end;

    local procedure GetFullVendorName(Vendor: Record Vendor): Text
    begin
        exit(Vendor.Name + Vendor."Name 2");
    end;

    local procedure UpdateSequenceNoInRecLine(var RecLine: Text)
    var
        StartString: Text;
        EndString: Text;
        SequenceText: Text;
        SeqNoStartPos: Integer;
        SeqNoEndPos: Integer;
    begin
        SeqNoStartPos := 500;
        SeqNoEndPos := 507;
        StartString := RecLine.Substring(1, SeqNoStartPos - 1); // before the sequence number
        EndString := RecLine.Substring(SeqNoEndPos + 1);        // after the sequence number
        SequenceText := Helper.FormatAmount(SequenceNo, 8);
        RecLine := StartString + SequenceText + EndString;      // insert sequence number to 500-507 position
    end;

    local procedure UpdateProgressDialog(Number: Integer; NewText: Text)
    begin
        if GuiAllowed() then
            ProgressDialog.Update(Number, NewText + '%');
    end;

    local procedure GetAdjustmentRec(var IRS1099Adjustment: Record "IRS 1099 Vendor Form Box Adj."; VendorLedgerEntry: Record "Vendor Ledger Entry"): Boolean
    begin
        if VendorLedgerEntry."IRS 1099 Form Box No." = '' then
            exit(false);
        exit(
          IRS1099Adjustment.Get(
            Date2DMY(VendorLedgerEntry."Posting Date", 3), VendorLedgerEntry."Vendor No.",
            VendorLedgerEntry."IRS 1099 Form No.", VendorLedgerEntry."IRS 1099 Form Box No."));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDownloadFile(var TempBlob: Codeunit "Temp Blob")
    begin
    end;
}
