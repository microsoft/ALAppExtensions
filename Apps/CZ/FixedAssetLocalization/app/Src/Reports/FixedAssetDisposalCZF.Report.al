// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.Depreciation;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Inventory.Location;

report 31255 "Fixed Asset Disposal CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetDisposal.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Disposal';
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
                column(FixedAsset_Inactive; Inactive)
                {
                    IncludeCaption = true;
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
                column(DisposalReportDate; DisposalReportDate)
                {
                }
                column(DisposalReportNo; DisposalReportNo)
                {
                }
                dataitem("FA Depreciation Book"; "FA Depreciation Book")
                {
                    DataItemLink = "FA No." = field("No.");
                    DataItemTableView = sorting("FA No.", "Depreciation Book Code");
                    column(FADepreciationBook_DepreciationBookCode; "Depreciation Book Code")
                    {
                    }
                    column(FADepreciationBook_Appreciation; Appreciation)
                    {
                        IncludeCaption = true;
                    }
                    column(FADepreciationBook_BookValueOnDisposal; "Book Value on Disposal")
                    {
                        IncludeCaption = true;
                    }
                    column(FADepreciationBook_BookValue; "Book Value")
                    {
                        IncludeCaption = true;
                    }
                    column(FADepreciationBook_Depreciation; Depreciation)
                    {
                        IncludeCaption = true;
                    }
                    column(FADepreciationBook_AcquisitionCost; "Acquisition Cost")
                    {
                        IncludeCaption = true;
                    }
                    column(FADepreciationBook_AcquisitionDate; "Acquisition Date")
                    {
                        IncludeCaption = true;
                    }
                    column(FADisposalReportDate; FADisposalDate)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        if PrintFADispRepDate then
                            FADisposalDate := DisposalReportDate
                        else
                            FADisposalDate := "Disposal Date";
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
                    field(PrintFADispRepDateCZF; PrintFADispRepDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Print FA Disposal Report Date';
                        ToolTip = 'Specifies to print the fixed asset disposal report date.';

                        trigger OnValidate()
                        begin
                            PrintFADispRepDateOnAfterValid();
                        end;
                    }
                    field(DisposalReportNoCZF; DisposalReportNo)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Disposal Report No.';
                        ToolTip = 'Specifies a fixed asset disposal report number.';
                    }
                    field(DisposalReportDateCZF; DisposalReportDate)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Disposal Report Date';
                        Editable = FADisposalReportDateCtrlEditable;
                        ToolTip = 'Specifies a fixed asset disposal report date.';
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
            FADisposalReportDateCtrlEditable := true;
        end;

        trigger OnOpenPage()
        begin
            FADisposalReportDateCtrlEditable := PrintFADispRepDate;
        end;
    }

    labels
    {
        ReportLbl = 'Fixed Asset Disposal Protocol';
        PageLbl = 'Page';
        ResponsibleEmployeeLbl = 'Responsible Employee';
        DepreciationBookLbl = 'FA Depreciation Book';
        N1Lbl = '1.';
        N2Lbl = '2.';
        FALocationLbl = 'FA Location';
        DisposalNoLbl = 'Disposal No.';
        DisposalDateLbl = 'Disposal Date';
        CommitteeMembersLbl = 'Committee Members';
        CommentsLbl = 'Comments';
        ApprovedLbl = 'Approved by Committee Members';
        DateSignatureLbl = 'Date, Signature';
    }

    trigger OnPreReport()
    begin
        if DeprBookCode = '' then
            Error(EmptyDeprBookErr);
        if DisposalReportNo = '' then
            Error(EmptyRepNoErr);
        if PrintFADispRepDate then
            if DisposalReportDate = 0D then
                Error(EmptyRepDateErr);
    end;

    var
        CompanyOfficialCZL: Record "Company Official CZL";
        Location: Record Location;
        FALocation: Record "FA Location";
        Employee: Record Employee;
        FormatAddress: Codeunit "Format Address";
        DisposalReportNo, DeprBookCode : Code[20];
        DisposalReportDate, FADisposalDate : Date;
        PrintFADispRepDate: Boolean;
        CompanyAddr: array[8] of Text[100];
        Member: array[2] of Text;
        FADisposalReportDateCtrlEditable: Boolean;
        EmptyDeprBookErr: Label 'Depreciation book code must not be empty.';
        EmptyRepNoErr: Label 'Disposal report no. must not be empty.';
        EmptyRepDateErr: Label 'Disposal report date must not be empty.';

    local procedure PrintFADispRepDateOnAfterValid()
    begin
        if not PrintFADispRepDate then
            DisposalReportDate := 0D;
        FADisposalReportDateCtrlEditable := PrintFADispRepDate;
    end;
}
