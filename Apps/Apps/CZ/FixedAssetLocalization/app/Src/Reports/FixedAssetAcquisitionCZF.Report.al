// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Ledger;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Location;

report 31254 "Fixed Asset Acquisition CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetAcquisition.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Acquisition';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr6; CompanyAddr[6])
            {
            }
            column(Member1; Member[1])
            {
            }
            column(Member2; Member[2])
            {
            }
            dataitem("Fixed Asset"; "Fixed Asset")
            {
                DataItemTableView = sorting("No.");
                RequestFilterFields = "No.";
                column(ReportFilter; GetFilters())
                {
                }
                column(FixedAsset_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(FixedAsset_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(FixedAsset_Description2; "Description 2")
                {
                    IncludeCaption = true;
                }
                column(FixedAsset_Inactive; FormatBoolean(Inactive))
                {
                }
                column(FixedAsset_SerialNo; "Serial No.")
                {
                    IncludeCaption = true;
                }
                column(FixedAsset_FAClassCode; "FA Class Code")
                {
                    IncludeCaption = true;
                }
                column(FixedAsset_FASubclassCode; "FA Subclass Code")
                {
                    IncludeCaption = true;
                }
                column(FALocation_Name; FALocation.Name)
                {
                }
                column(Employee_FullName; Employee.FullName())
                {
                }
                column(DeprBookCode; DeprBookCode)
                {
                }
                column(AcquisitionReportNo; AcquisitionReportNo)
                {
                }
                column(AcquisitionReportDate; AcquisitionReportDate)
                {
                }
                column(UseStartReportDate; UseReportStartDate)
                {
                }
                dataitem("FA Depreciation Book"; "FA Depreciation Book")
                {
                    DataItemLink = "FA No." = field("No.");
                    DataItemTableView = sorting("FA No.", "Depreciation Book Code");
                    column(FADepreciationBook_DepreciationBookCode; "Depreciation Book Code")
                    {
                    }
                    column(FADeprStartDate; FADeprStartDate)
                    {
                    }
                    column(FAAcquisitionCost; FAAcquisitionCost)
                    {
                    }
                    column(FAAcquisitionDate; FAAcquisitionDate)
                    {
                    }
                    column(DisposedText; DisposedText)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Disposed := "Disposal Date" > 0D;
                        if Disposed then
                            DisposedText := FADisposedTxt
                        else
                            DisposedText := '';

                        CalcFields("Acquisition Cost", "Custom 2");
                        if "Acquisition Cost" <> 0 then
                            FAAcquisitionCost := "Acquisition Cost"
                        else
                            FAAcquisitionCost := "Custom 2";

                        FAAcquisitionDate := "Last Acquisition Cost Date";
                        FADeprStartDate := "Depreciation Starting Date";
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Depreciation Book Code", DeprBookCode);
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not Location.Get("Location Code") then
                        Location.Init();
                    if not FALocation.Get("FA Location Code") then
                        FALocation.Init();
                    if not Employee.Get("Responsible Employee") then
                        Employee.Init();

                    if PrintFALedgDate then begin
                        FASetup.Get();
                        if FASetup."FA Acquisition As Custom 2 CZF" then begin
                            FALedgerEntry.Reset();
                            FALedgerEntry.SetCurrentKey(
                              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Posting Date");
                            FALedgerEntry.SetRange("FA No.", "No.");
                            FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode);
                            FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry."FA Posting Category"::" ");
                            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Custom 2");
                            if FALedgerEntry.FindLast() then begin
                                FAAcquisitionDate := FALedgerEntry."FA Posting Date";
                                AcquisitionReportNo := FALedgerEntry."Document No.";
                            end else begin
                                FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
                                if FALedgerEntry.FindLast() then begin
                                    FAAcquisitionDate := FALedgerEntry."FA Posting Date";
                                    AcquisitionReportNo := FALedgerEntry."Document No.";
                                end;
                            end;
                        end else begin
                            FALedgerEntry.Reset();
                            FALedgerEntry.SetCurrentKey(
                              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Posting Date");
                            FALedgerEntry.SetRange("FA No.", "No.");
                            FALedgerEntry.SetRange("Depreciation Book Code", DeprBookCode);
                            FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry."FA Posting Category"::" ");
                            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
                            if FALedgerEntry.FindLast() then begin
                                FAAcquisitionDate := FALedgerEntry."FA Posting Date";
                                AcquisitionReportNo := FALedgerEntry."Document No.";
                            end;
                        end;
                    end;
                end;

            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
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
                    field(DeprBookCodeCZF; DeprBookCode)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                        ToolTip = 'Specifies the depreciation book for the printing of entries.';
                    }
                    field(PrintFALedgDateCZF; PrintFALedgDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print FA Ledger Entry Dates';
                        ToolTip = 'Specifies to print the fixed asset ledger entry dates.';

                        trigger OnValidate()
                        begin
                            PrintFALedgDateOnAfterValida();
                        end;
                    }
                    field(AcquisitionReportNoCZF; AcquisitionReportNo)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Acquisition Report No.';
                        Editable = FAAcquisitionNoCtrlEditable;
                        ToolTip = 'Specifies a fixed asset receipt number.';
                    }
                    field(AcquisitionReportDateCZF; AcquisitionReportDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Acquisition Report Date';
                        Editable = FAAcquisitionDateCtrlEditable;
                        ToolTip = 'Specifies a fixed asset receipt date.';
                    }
                    field(UseReportStartDateCZF; UseReportStartDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Use Report Start Date';
                        Editable = FAUseStartReportDateCtrlEditable;
                        ToolTip = 'Specifies a fixed asset start date.';
                    }
                    field(Member1; Member[1])
                    {
                        ApplicationArea = FixedAssets;
                        Caption = '1. Persona';
                        ToolTip = 'Specifies an employee name from the Company Official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(Page::"Company Official List CZL", CompanyOfficialCZL) = ACTION::LookupOK then
                                Member[1] := CompanyOfficialCZL.FullName();
                        end;
                    }
                    field(Member2; Member[2])
                    {
                        ApplicationArea = FixedAssets;
                        Caption = '2. Persona';
                        ToolTip = 'Specifies an employee name from the Company Official table. Each persona will print on the report with a corresponding signature line for authorization.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            CompanyOfficialCZL.Reset();
                            if Page.RunModal(Page::"Company Official List CZL", CompanyOfficialCZL) = ACTION::LookupOK then
                                Member[2] := CompanyOfficialCZL.FullName();
                        end;
                    }
                }
            }
        }

        trigger OnInit()
        begin
            FAUseStartReportDateCtrlEditable := true;
            FAAcquisitionDateCtrlEditable := true;
            FAAcquisitionNoCtrlEditable := true;
        end;

        trigger OnOpenPage()
        begin
            FAAcquisitionNoCtrlEditable := not PrintFALedgDate;
            FAAcquisitionDateCtrlEditable := not PrintFALedgDate;
            FAUseStartReportDateCtrlEditable := not PrintFALedgDate;
        end;
    }

    labels
    {
        ReportLbl = 'Fixed Asset Acquisition Protocol';
        PageLbl = 'Page';
        ResponsibleEmployeeLbl = 'Responsible Employee';
        DepreciationBookLbl = 'FA Depreciation Book';
        N1Lbl = '1.';
        N2Lbl = '2.';
        FALocationLbl = 'FA Location';
        AcquisitionNoLbl = 'Acquisition No.';
        AcquisitionDateLbl = 'Acquisition Date';
        DeprStartDateLbl = 'Depreciation Start Date';
        AcquisitionCostLbl = 'Acquisition Cost';
        CommitteeMembersLbl = 'Committee Members';
        CommentsLbl = 'Comments';
        AcceptedLbl = 'Accepted by';
        ApprovedLbl = 'Approved by Committee Members';
        DateSignatureLbl = 'Date, Signature';
        InactiveLbl = 'Inactive';
    }

    trigger OnPreReport()
    begin
        if DeprBookCode = '' then
            Error(EmptyDeprBookErr);
        if not PrintFALedgDate then begin
            if AcquisitionReportNo = '' then
                Error(EmptyNoErr);
            if AcquisitionReportDate = 0D then
                Error(EmptyDate1Err);
            if UseReportStartDate = 0D then
                Error(EmptyDate2Err);
        end;
    end;

    var
        CompanyOfficialCZL: Record "Company Official CZL";
        Location: Record Location;
        FALocation: Record "FA Location";
        Employee: Record Employee;
        FALedgerEntry: Record "FA Ledger Entry";
        FASetup: Record "FA Setup";
        FormatAddress: Codeunit "Format Address";
        AcquisitionReportNo, DeprBookCode : Code[20];
        AcquisitionReportDate, FADeprStartDate, FAAcquisitionDate, UseReportStartDate : Date;
        Disposed, PrintFALedgDate : Boolean;
        DisposedText: Text;
        CompanyAddr: array[8] of Text[100];
        Member: array[2] of Text;
        FAAcquisitionCost: Decimal;
        FAAcquisitionNoCtrlEditable, FAAcquisitionDateCtrlEditable, FAUseStartReportDateCtrlEditable : Boolean;
        FADisposedTxt: Label 'FA Disposed';
        EmptyDeprBookErr: Label 'Depreciation book code must not be empty.';
        EmptyNoErr: Label 'Acquisition report no. must not be empty.';
        EmptyDate1Err: Label 'Acquisition report date must not be empty.';
        EmptyDate2Err: Label 'Use report start date must not be empty.';
        BooleanValuesTxt: Label 'Yes,No';

    local procedure PrintFALedgDateOnAfterValida()
    begin
        if PrintFALedgDate then begin
            AcquisitionReportNo := '';
            AcquisitionReportDate := 0D;
            UseReportStartDate := 0D;
        end;
        FAAcquisitionNoCtrlEditable := not PrintFALedgDate;
        FAAcquisitionDateCtrlEditable := not PrintFALedgDate;
        FAUseStartReportDateCtrlEditable := not PrintFALedgDate;
    end;

    local procedure FormatBoolean(BoolValue: Boolean): Text
    begin
        if BoolValue then
            exit(SelectStr(1, BooleanValuesTxt));
        exit(SelectStr(2, BooleanValuesTxt));
    end;
}
