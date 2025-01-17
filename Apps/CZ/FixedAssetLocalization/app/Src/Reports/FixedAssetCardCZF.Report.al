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
using Microsoft.Purchases.History;
using Microsoft.Sales.History;

report 31246 "Fixed Asset Card CZF"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/FixedAssetCard.rdl';
    ApplicationArea = FixedAssets;
    Caption = 'Fixed Asset Card';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
            column(CompanyName; CompanyProperty.DisplayName())
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
            dataitem("Fixed Asset"; "Fixed Asset")
            {
                DataItemTableView = sorting("No.");
                RequestFilterFields = "No.", "FA Posting Date Filter";
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
                }
                column(FixedAsset_Inactive; FormatBoolean(Inactive))
                {
                }
                column(Employee_FullName; Employee.FullName())
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
                dataitem("FA Depreciation Book"; "FA Depreciation Book")
                {
                    DataItemLink = "FA No." = field("No."), "FA Posting Date Filter" = field("FA Posting Date Filter");
                    DataItemTableView = sorting("FA No.", "Depreciation Book Code");
                    RequestFilterFields = "Depreciation Book Code";
                    column(DisposedText; DisposedText)
                    {
                    }
                    column(FABook_Gain_Loss; "Gain/Loss")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Proceeds_on_Disposal; "Proceeds on Disposal")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Book_Value; "Book Value")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Depreciation; Depreciation)
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Acquisition_Cost; "Acquisition Cost")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Depreciation_Method; "Depreciation Method")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Depreciation_Starting_Date; "Depreciation Starting Date")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_NoOfDepreciationYears; "No. of Depreciation Years")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_NoOfDepreciationMonths; "No. of Depreciation Months")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Straight_Line; "Straight-Line %")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Disposal_Date; "Disposal Date")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Acquisition_Date; "Acquisition Date")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_FA_Posting_Date_Filter; GetFilter("FA Posting Date Filter"))
                    {
                    }
                    column(FABook_Depreciation_Book_Code; "Depreciation Book Code")
                    {
                    }
                    column(FABook_ReceiptDate; ReceiptDate)
                    {
                    }
                    column(FABook_Tax_Depreciation_Group_Code; "Tax Deprec. Group Code CZF")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_FA_Posting_Group; "FA Posting Group")
                    {
                        IncludeCaption = true;
                    }
                    column(FABook_Appreciation; Appreciation)
                    {
                        IncludeCaption = true;
                    }
                    dataitem("FA Ledger Entry"; "FA Ledger Entry")
                    {
                        DataItemLink = "FA No." = field("FA No."), "Depreciation Book Code" = field("Depreciation Book Code"), "FA Posting Date" = field("FA Posting Date Filter");
                        DataItemTableView = sorting("FA No.", "Depreciation Book Code", "Posting Date");
                        column(FALedgerEntry_Credit_Amount_; "Credit Amount")
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_Debit_Amount_; "Debit Amount")
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_Amount; Amount)
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_FA_Posting_Type_; "FA Posting Type")
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_FA_Posting_Category_; "FA Posting Category")
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_External_DocumentNo; "External Document No.")
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_DocumentNo; "Document No.")
                        {
                            IncludeCaption = true;
                        }
                        column(FALedgerEntry_FA_Posting_Date_; "FA Posting Date")
                        {
                            IncludeCaption = true;
                        }
                        column(VendCustName; VendCustName)
                        {
                        }
                        column(FALedgerEntry_Entry_No_; "Entry No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            SalesInvoiceHeader: Record "Sales Invoice Header";
                            PurchInvHeader: Record "Purch. Inv. Header";
                        begin
                            VendCustName := '';
                            if (("FA Posting Type" = "FA Posting Type"::"Acquisition Cost") and not FASetup."FA Acquisition As Custom 2 CZF") or
                               (("FA Posting Type" = "FA Posting Type"::"Custom 2") and FASetup."FA Acquisition As Custom 2 CZF")
                            then
                                if PurchInvHeader.Get("Document No.") then
                                    VendCustName := PurchInvHeader."Buy-from Vendor Name";
                            if "FA Posting Type" = "FA Posting Type"::"Proceeds on Disposal" then
                                if SalesInvoiceHeader.Get("Document No.") then
                                    VendCustName := SalesInvoiceHeader."Sell-to Customer Name";
                        end;

                        trigger OnPreDataItem()
                        begin
                            if not ShowEntries then
                                CurrReport.Break();
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        FALedgerEntry: Record "FA Ledger Entry";
                    begin
                        Disposed := "Disposal Date" > 0D;
                        if Disposed then
                            DisposedText := DispTxt
                        else
                            DisposedText := NotDispTxt;

                        ReceiptDate := 0D;

                        if FASetup."FA Acquisition As Custom 2 CZF" then begin
                            FALedgerEntry.Reset();
                            FALedgerEntry.SetCurrentKey(
                              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Posting Date");
                            FALedgerEntry.SetRange("FA No.", "FA No.");
                            FALedgerEntry.SetRange("Depreciation Book Code", "Depreciation Book Code");
                            FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry."FA Posting Category"::" ");
                            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Custom 2");
                            if FALedgerEntry.FindLast() then
                                ReceiptDate := FALedgerEntry."FA Posting Date"
                            else begin
                                FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
                                if FALedgerEntry.FindLast() then
                                    ReceiptDate := FALedgerEntry."FA Posting Date";
                            end;
                        end else begin
                            FALedgerEntry.Reset();
                            FALedgerEntry.SetCurrentKey(
                              "FA No.", "Depreciation Book Code", "FA Posting Category", "FA Posting Type", "Posting Date");
                            FALedgerEntry.SetRange("FA No.", "FA No.");
                            FALedgerEntry.SetRange("Depreciation Book Code", "Depreciation Book Code");
                            FALedgerEntry.SetRange("FA Posting Category", FALedgerEntry."FA Posting Category"::" ");
                            FALedgerEntry.SetRange("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
                            if FALedgerEntry.FindLast() then
                                ReceiptDate := FALedgerEntry."FA Posting Date";
                        end;
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if not Location.Get("Location Code") then
                        Clear(Location);
                    if not FALocation.Get("FA Location Code") then
                        Clear(FALocation);
                    if not Employee.Get("Responsible Employee") then
                        Clear(Employee);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                FASetup.Get();
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
                    field(ShowEntriesCZF; ShowEntries)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Show Entries';
                        ToolTip = 'Specifies when the entries is to be show';
                    }
                }
            }
        }
    }

    labels
    {
        FixedAssetCardLbl = 'Fixed Asset Card';
        PageLbl = 'Page';
        TotalLbl = 'Total';
        ResponsibleEmployeeLbl = 'Responsible Employee';
        FALocationLbl = 'FA Location';
        FADepreciationBookLbl = 'FA Depreciation Book';
        ReceiptDateLbl = 'Receipt Date';
        ExternalCompanyNameLbl = 'External Company Name';
        InactiveLbl = 'Inactive';
    }

    var
        Location: Record Location;
        FALocation: Record "FA Location";
        Employee: Record Employee;
        FASetup: Record "FA Setup";
        FormatAddress: Codeunit "Format Address";
        Disposed, ShowEntries : Boolean;
        DisposedText, VendCustName : Text;
        CompanyAddr: array[8] of Text[100];
        ReceiptDate: Date;
        NotDispTxt: Label 'Not Disposed Of';
        DispTxt: Label 'Disposed Of';
        BooleanValuesTxt: Label 'Yes,No';

    local procedure FormatBoolean(BoolValue: Boolean): Text
    begin
        if BoolValue then
            exit(SelectStr(1, BooleanValuesTxt));
        exit(SelectStr(2, BooleanValuesTxt));
    end;
}
