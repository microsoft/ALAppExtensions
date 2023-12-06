// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.HumanResources.Employee;
using System.Utilities;

report 31252 "FA Assignment/Discard CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FAAssignmentDiscard.rdl';
    Caption = 'FA Assignment/Discard';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = FixedAssets;

    dataset
    {
        dataitem("FA History Entry CZF"; "FA History Entry CZF")
        {
            DataItemTableView = sorting("Entry No.") where("Closed by Entry No." = const(0));
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Entry No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(FA_History_Entry_Entry_No_; "Entry No.")
            {
            }
            dataitem(Discard; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(0));
                PrintOnlyIfDetail = true;
                column(Discard_ReportType; FADiscardLbl)
                {
                }
                column(Discard_Type; Format("FA History Entry CZF".Type))
                {
                }
                column(Discard_FirstName; FirstNameCaption)
                {
                }
                column(Discard_FirstName2; FirstName)
                {
                }
                column(Discard_LastName; LastNameCaption)
                {
                }
                column(Discard_LastName2; LastName)
                {
                }
                column("Code"; Code)
                {
                }
                dataitem(DiscardFAHistoryEntry; "FA History Entry CZF")
                {
                    DataItemTableView = sorting("Entry No.");
                    column(DiscardFAHistoryEntry_FANo; "FA No.")
                    {
                    }
                    column(DiscardFAHistoryEntry_Description; Description)
                    {
                    }
                    column(DiscardFAHistoryEntry_SerialNo; SerialNo)
                    {
                    }
                    column(DiscardFAHistoryEntry_PostingDate; "Posting Date")
                    {
                    }
                    column(DiscardFAHistoryEntry_DocumentNo; "Document No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Copy("FA History Entry CZF");
                        if ShowReport(DiscardCount) then
                            CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        CopyFilters("FA History Entry CZF");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    case "FA History Entry CZF".Type of
                        "FA History Entry CZF".Type::"FA Location":
                            if FALocation.FindLast() then begin
                                Code := FALocation.Code;
                                FirstNameCaption := NameLbl;
                                FirstName := FALocation.Name;
                                LastNameCaption := '';
                                LastName := '';
                            end else
                                if ShowFlag then begin
                                    Code := '';
                                    FirstNameCaption := NameLbl;
                                    FirstName := '';
                                    LastNameCaption := '';
                                    LastName := '';
                                end else
                                    CurrReport.Break();
                        "FA History Entry CZF".Type::"Responsible Employee":
                            if Employee.FindLast() then begin
                                Code := Employee."No.";
                                FirstNameCaption := FirstNameLbl;
                                FirstName := Employee."First Name";
                                LastNameCaption := LastNameLbl;
                                LastName := Employee."Last Name";
                            end else
                                if ShowFlag then begin
                                    Code := '';
                                    FirstNameCaption := FirstNameLbl;
                                    FirstName := '';
                                    LastNameCaption := LastNameLbl;
                                    LastName := '';
                                end else
                                    CurrReport.Break();
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    case "FA History Entry CZF".Type of
                        "FA History Entry CZF".Type::"FA Location":
                            FALocation.SetRange(Code, "FA History Entry CZF"."Old Value");
                        "FA History Entry CZF".Type::"Responsible Employee":
                            Employee.SetRange("No.", "FA History Entry CZF"."Old Value");
                    end;

                    if "FA History Entry CZF"."New Value" = '' then
                        ShowFlag := true;
                end;
            }
            dataitem(Assignment; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = const(0));
                PrintOnlyIfDetail = true;
                column(Assignment_ReportType; FAAssignmentLbl)
                {
                }
                column(Assignment_Type; Format("FA History Entry CZF".Type))
                {
                }
                column(Assignment_LastName; LastNameCaption)
                {
                }
                column(Assignment_LastName2; LastName)
                {
                }
                column(Assignment_FirstName; FirstNameCaption)
                {
                }
                column(Assignment_FirstName2; FirstName)
                {
                }
                column(Assignment_Code; Code)
                {
                }
                dataitem(AssignmentFAHistoryEntry; "FA History Entry CZF")
                {
                    DataItemTableView = sorting("Entry No.");
                    column(AssignmentFAHistoryEntry_FANo; "FA No.")
                    {
                    }
                    column(AssignmentFAHistoryEntry_Description; Description)
                    {
                    }
                    column(AssignmentFAHistoryEntry_SerialNo; SerialNo)
                    {
                    }
                    column(AssignmentFAHistoryEntry_PostingDate; "Posting Date")
                    {
                    }
                    column(AssignmentFAHistoryEntry_DocumentNo; "Document No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        Copy("FA History Entry CZF");
                        if ShowReport(AssignmentCount) then
                            CurrReport.Break();
                    end;

                    trigger OnPreDataItem()
                    begin
                        CopyFilters("FA History Entry CZF");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    case "FA History Entry CZF".Type of
                        "FA History Entry CZF".Type::"FA Location":
                            if FALocation.FindLast() then begin
                                Code := FALocation.Code;
                                FirstNameCaption := NameLbl;
                                FirstName := FALocation.Name;
                                LastNameCaption := '';
                                LastName := '';
                            end;
                        "FA History Entry CZF".Type::"Responsible Employee":
                            if Employee.FindLast() then begin
                                Code := Employee."No.";
                                FirstNameCaption := FirstNameLbl;
                                FirstName := Employee."First Name";
                                LastNameCaption := LastNameLbl;
                                LastName := Employee."Last Name";
                            end;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    case "FA History Entry CZF".Type of
                        "FA History Entry CZF".Type::"FA Location":
                            FALocation.SetRange(Code, "FA History Entry CZF"."New Value");
                        "FA History Entry CZF".Type::"Responsible Employee":
                            Employee.SetRange("No.", "FA History Entry CZF"."New Value");
                    end;

                    if ShowFlag then begin
                        ShowFlag := false;
                        CurrReport.Break();
                    end;
                    if "FA History Entry CZF"."Old Value" <> '' then
                        ShowFlag := false;
                end;
            }
        }
    }

    labels
    {
        ReportLbl = 'Protocol on change of FA Location / Responsible Person';
        PageLbl = 'Page';
        CodeLbl = 'Code';
        SerialNoLbl = 'Serial No.';
        ApprovedLbl = 'Approved by';
        IssuedLbl = 'Issued by';
        ReturnedLbl = 'Returned by';
        ReceivedLbl = 'Received by';
        NoLbl = 'No.';
        DescriptionLbl = 'Description';
        DateDiscarddLbl = 'Date Discard';
        DateAssignedLbl = 'Date Assigned';
        DocumentNoLbl = 'Document No.';
    }

    var
        FALocation: Record "FA Location";
        FixedAsset: Record "Fixed Asset";
        Code, FirstNameCaption, LastNameCaption, FirstName, LastName, Description, SerialNo : Text;
        ShowFlag: Boolean;
        DiscardCount, AssignmentCount : Integer;
        NameLbl: Label 'Name';
        FirstNameLbl: Label 'First Name';
        LastNameLbl: Label 'Last Name';
        FAAssignmentLbl: Label 'FA Assignment';
        FADiscardLbl: Label 'FA Discard';

    protected var
        Employee: Record Employee;

    procedure ShowReport(var "Count": Integer): Boolean
    begin
        FixedAsset.Reset();
        FixedAsset.SetRange("No.", "FA History Entry CZF"."FA No.");
        if FixedAsset.FindLast() then begin
            Description := FixedAsset.Description;
            SerialNo := FixedAsset."Serial No.";
        end;
        Count += 1;
        if Count > 1 then begin
            Count := 0;
            exit(true);
        end;
    end;
}
