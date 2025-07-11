// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Reports;

using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using System.Security.AccessControl;
using System.Utilities;

report 11766 "General Ledger Document CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/GeneralLedgerDocument.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'General Ledger Document CZ';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("G/L Register"; "G/L Register")
        {
            DataItemTableView = sorting("No.");

            trigger OnAfterGetRecord()
            begin
                GLRegister := "G/L Register";
                CurrReport.Break();
            end;

            trigger OnPreDataItem()
            begin
                if "G/L Register".GetFilters = '' then
                    CurrReport.Break();
            end;
        }
        dataitem("G/L Entry"; "G/L Entry")
        {
            DataItemTableView = sorting("Document No.", "Posting Date");
            RequestFilterFields = "Entry No.", "Document No.";
            column(ReportName; ReportNameLbl)
            {
            }
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(USERID; UserId)
            {
            }
            column(ShowDim; ShouldShowDim)
            {
            }
            column(AccTransLiabilityCaption; AccTransLiabilityCaptionLbl)
            {
            }
            column(PostingLiabilityCaption; PostingLiabilityCaptionLbl)
            {
            }
            column(PostedByCaption; PostedByCaptionLbl)
            {
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(CompanyAddr5; CompanyAddr[5])
            {
            }
            column(CompanyAddr4; CompanyAddr[4])
            {
            }
            column(CompanyAddr3; CompanyAddr[3])
            {
            }
            column(CompanyAddr2; CompanyAddr[2])
            {
            }
            column(CompanyAddr1; CompanyAddr[1])
            {
            }
            column(VATRegistrationNo; StrSubstNo(CaptionValueTok, CompanyInformation.FieldCaption("VAT Registration No."), CompanyInformation."VAT Registration No."))
            {
            }
            column(RegistrationNo; StrSubstNo(CaptionValueTok, CompanyInformation.FieldCaption("Registration No."), CompanyInformation."Registration No."))
            {
            }
            column(UserFullName_GLEntry; UserFullName("User ID"))
            {
            }
            column(PostingDate_GLEntryCaption; PostingDateCaptionLbl)
            {
            }
            column(PostingDate_GLEntry; Format("Posting Date", 0, 4))
            {
            }
            column(DocumentDate_GLEntryCaption; DocumentDateCaptionLbl)
            {
            }
            column(DocumentDate_GLEntry; Format("Document Date", 0, 4))
            {
            }
            column(DocumentNo_GLEntryCaption; DocumentNoCaptionLbl)
            {
            }
            column(DocumentNo_GLEntry; "Document No.")
            {
            }
            column(GLAccountNo_GLEntryCaption; FieldCaption("G/L Account No."))
            {
            }
            column(GLAccountNo_GLEntry; "G/L Account No.")
            {
            }
            column(Description_GLEntryCaption; FieldCaption(Description))
            {
            }
            column(Description_GLEntry; Description)
            {
            }
            column(DebitAmount_GLEntryCaption; FieldCaption("Debit Amount"))
            {
            }
            column(DebitAmount_GLEntry; "Debit Amount")
            {
            }
            column(CreditAmount_GLEntryCaption; FieldCaption("Credit Amount"))
            {
            }
            column(CreditAmount_GLEntry; "Credit Amount")
            {
            }
            column(GlobalDimension1Code_GLEntryCaption; FieldCaption("Global Dimension 1 Code"))
            {
            }
            column(GlobalDimension1Code_GLEntry; "Global Dimension 1 Code")
            {
            }
            column(GlobalDimension2Code_GLEntryCaption; FieldCaption("Global Dimension 2 Code"))
            {
            }
            column(GlobalDimension2Code_GLEntry; "Global Dimension 2 Code")
            {
            }
            column(ExternalDocumentNo_GLEntryCaption; FieldCaption("External Document No."))
            {
            }
            column(ExternalDocumentNo_GLEntry; "External Document No.")
            {
            }
            column(EntryNo_GLEntryCaption; FieldCaption("Entry No."))
            {
            }
            column(EntryNo_GLEntry; "Entry No.")
            {
            }
            dataitem(DimensionLoop; "Integer")
            {
                DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                column(DimText; DimText)
                {
                }
                column(DimensionsCaption; DimensionsCaptionLbl)
                {
                }
                column(DimensionLoop_Number; Number)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Number = 1 then begin
                        if not DimensionSetEntry.Find('-') then
                            CurrReport.Break();
                    end else
                        if not Continue then
                            CurrReport.Break();

                    Clear(DimText);
                    Continue := false;
                    repeat
                        OldDimText := DimText;
                        if DimText = '' then
                            DimText := StrSubstNo(CaptionValue2Tok, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code")
                        else
                            DimText :=
                              StrSubstNo(
                                DimTextAppenderTok, DimText, DimensionSetEntry."Dimension Code", DimensionSetEntry."Dimension Value Code");
                        if StrLen(DimText) > MaxStrLen(OldDimText) then begin
                            DimText := OldDimText;
                            Continue := true;
                            exit;
                        end;
                    until DimensionSetEntry.Next() = 0;
                end;

                trigger OnPreDataItem()
                begin
                    if not ShouldShowDim then
                        CurrReport.Break();

                    DimensionSetEntry.Reset();
                    DimensionSetEntry.SetRange("Dimension Set ID", "G/L Entry"."Dimension Set ID");
                end;
            }
            trigger OnPreDataItem()
            begin
                if GLRegister."No." <> 0 then
                    SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
            end;
        }
    }
    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(ShowDim; ShouldShowDim)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Dimensions';
                        ToolTip = 'Specifies when the dimensions is to be show';
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        FormatAddress.Company(CompanyAddr, CompanyInformation);
    end;

    var
        CompanyInformation: Record "Company Information";
        DimensionSetEntry: Record "Dimension Set Entry";
        GLRegister: Record "G/L Register";
        User: Record User;
        FormatAddress: Codeunit "Format Address";
        ShouldShowDim: Boolean;
        Continue: Boolean;
        DimText: Text;
        OldDimText: Text;
        CompanyAddr: array[8] of Text[100];
        ReportNameLbl: Label 'General Ledger Document';
        DocumentNoCaptionLbl: Label 'DOCUMENT NO.:';
        AccTransLiabilityCaptionLbl: Label 'Accounting transaction liability:';
        PostingLiabilityCaptionLbl: Label 'Posting liability:';
        PostingDateCaptionLbl: Label 'Posting date:';
        PostedByCaptionLbl: Label 'Posted by:';
        DocumentDateCaptionLbl: Label 'Document Date:';
        PageCaptionLbl: Label 'Page:';
        DimensionsCaptionLbl: Label 'Dimensions';
        UnknownUserTxt: Label 'Unknown User ID %1', Comment = '%1 = USERID';
        CaptionValueTok: Label '%1: %2', Comment = '%1 = Field Caption ; %2 = Field Value', Locked = true;
        CaptionValue2Tok: Label '%1 - %2', Comment = '%1 = Field Caption ; %2 = Field Value', Locked = true;
        DimTextAppenderTok: Label '%1; %2 - %3', Comment = '%1 = Old Dimension Text ; %2 = Dimension Code ; %3 = Dimension Value Code', Locked = true;

    procedure UserFullName(ID: Code[50]): Text[100]
    begin
        if ID = '' then
            exit('');

        if User."User Name" = ID then
            exit(User."Full Name");

        User.SetCurrentKey("User Name");
        User.SetRange("User Name", ID);
        if User.FindFirst() then
            exit(User."Full Name");

        exit(StrSubstNo(UnknownUserTxt, ID));
    end;
}
