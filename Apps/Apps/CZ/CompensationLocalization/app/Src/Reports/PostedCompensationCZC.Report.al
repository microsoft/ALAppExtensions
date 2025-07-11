// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.Compensations;

using Microsoft.CRM.Contact;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using System.Globalization;
using System.Utilities;

report 31271 "Posted Compensation CZC"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PostedCompensation.rdl';
    Caption = 'Posted Compensation';
    UsageCategory = None;

    dataset
    {
        dataitem(PostedCompensationHeaderCZC; "Posted Compensation Header CZC")
        {
            DataItemTableView = sorting("No.");
            RequestFilterfields = "No.", "Company No.";
            column(CompensationHeader_No; "No.")
            {
            }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                dataitem(PageLoop; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(ResidenceLbl; ResidenceLbl)
                    {
                    }
                    column(BusinessNameLbl; BusinessNameLbl)
                    {
                    }
                    column(RegistrationNoLbl; RegistrationNoLbl)
                    {
                    }
                    column(BankConnectionLbl; BankConnectionLbl)
                    {
                    }
                    column(ParagraphLbl; ParagraphLbl)
                    {
                    }
                    column(RemainingAmountLbl; RemainingAmountLbl)
                    {
                    }
                    column(CompensationAmountLbl; CompensationAmountLbl)
                    {
                    }
                    column(LedgerEntryRemainingAmountLbl; LedgerEntryRemainingAmountLbl)
                    {
                    }
                    column(LedgerEntryOriginalAmountLbl; LedgerEntryOriginalAmountLbl)
                    {
                    }
                    column(DueDateLbl; DueDateLbl)
                    {
                    }
                    column(EnterIntoForceLbl; EnterIntoForceLbl)
                    {
                    }
                    column(NameAndSignatureLbl; NameAndSignatureLbl)
                    {
                    }
                    column(InAndDateLbl; InAndDateLbl)
                    {
                    }
                    column(SendBackLbl; SendBackLbl)
                    {
                    }
                    column(ForLbl; ForLbl)
                    {
                    }
                    column(MakeDateLbl; MakeDateLbl)
                    {
                    }
                    column(CurrencyCodeLbl; CurrencyCodeLbl)
                    {
                    }
                    column(VariableSymbolLbl; VariableSymbolLbl)
                    {
                    }
                    column(DocumentNoLbl; DocumentNoLbl)
                    {
                    }
                    column(DocumentTypeLbl; DocumentTypeLbl)
                    {
                    }
                    column(PostingDateLbl; PostingDateLbl)
                    {
                    }
                    column(CompensationHeader_Address; CompanyAddress)
                    {
                    }
                    column(CompensationHeader_Name; CompanyName)
                    {
                    }
                    column(CompanyInfo_RegistrationNo; CompanyInformation."Registration No.")
                    {
                    }
                    column(CompanyInfo_BankAccountNo; CompanyInformation."Bank Account No.")
                    {
                    }
                    column(CompanyInfo_Address_PostCode_City; CompanyInformation.Address + ', ' + CompanyInformation."Post Code" + '  ' + CompanyInformation.City)
                    {
                    }
                    column(CompanyInfo_Name; CompanyInformation.Name)
                    {
                    }
                    column(CompensationHeader_AgreementNo; StrSubstNo(AgreementTxt, PostedCompensationHeaderCZC."No."))
                    {
                    }
                    column(CompensationHeader_PostingDate; StrSubstNo(ToDateTxt, Format(PostedCompensationHeaderCZC."Posting Date", 0, 4)))
                    {
                    }
                    column(CompensationHeader_RegistrationNo; CompanyRegistrationNo)
                    {
                    }
                    column(PageLoop_OutputCounter; OutputCounter)
                    {
                    }
                    column(PageLoop_Number; Number)
                    {
                    }
                    dataitem(CustomerPostedCompensationLineCZC; "Posted Compensation Line CZC")
                    {
                        DataItemLink = "Compensation No." = field("No.");
                        DataItemLinkReference = PostedCompensationHeaderCZC;
                        DataItemTableView = sorting("Compensation No.", "Line No.") where("Source Type" = const(Customer));
                        column(CustomerCompensationLine_Name; StrSubstNo(ReceivablesTxt, CompanyName))
                        {
                        }
                        column(CustomerCompensationLine_RemainingAmount; "Remaining Amount")
                        {
                        }
                        column(CustomerCompensationLine_Amount; Amount)
                        {
                        }
                        column(CustomerCompensationLine_LERemainingAmount; "Ledg. Entry Remaining Amount")
                        {
                        }
                        column(CustomerCompensationLine_LEOriginalAmount; "Ledg. Entry Original Amount")
                        {
                        }
                        column(CustomerCompensationLine_DueDate; Format(CustomerDueDate))
                        {
                        }
                        column(CustomerCompensationLine_CurrencyCode; "Currency Code")
                        {
                        }
                        column(CustomerCompensationLine_VariableSymbol; "Variable Symbol")
                        {
                        }
                        column(CustomerCompensationLine_DocumentNo; "Document No.")
                        {
                        }
                        column(CustomerCompensationLine_DocumentType; "Document Type")
                        {
                        }
                        column(CustomerCompensationLine_PostingDate; Format("Posting Date"))
                        {
                        }
                        column(CustomerCompensationLine_LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            CustLedgerEntry.Get("Source Entry No.");
                            CustomerDueDate := CustLedgerEntry."Due Date";

                            if "Currency Code" = '' then
                                "Currency Code" := GeneralLedgerSetup."LCY Code";

                            if "Remaining Amount" <> 0 then begin
                                TempCustomerPostedCompensationLineCZC := CustomerPostedCompensationLineCZC;
                                TempCustomerPostedCompensationLineCZC.Insert();
                            end;
                        end;
                    }
                    dataitem(VendorPostedCompensationLineCZC; "Posted Compensation Line CZC")
                    {
                        DataItemLink = "Compensation No." = field("No.");
                        DataItemLinkReference = PostedCompensationHeaderCZC;
                        DataItemTableView = sorting("Compensation No.", "Line No.") where("Source Type" = const(Vendor));
                        column(VendorCompensationLine_Name; StrSubstNo(PayablesTxt, CompanyName))
                        {
                        }
                        column(VendorCompensationLine_RemainingAmount; -"Remaining Amount")
                        {
                        }
                        column(VendorCompensationLine_Amount; -Amount)
                        {
                        }
                        column(VendorCompensationLine_LERemainingAmount; -"Ledg. Entry Remaining Amount")
                        {
                        }
                        column(VendorCompensationLine_LEOriginalAmount; -"Ledg. Entry Original Amount")
                        {
                        }
                        column(VendorCompensationLine_DueDate; Format(VendorDueDate))
                        {
                        }
                        column(VendorCompensationLine_CurrencyCode; "Currency Code")
                        {
                        }
                        column(VendorCompensationLine_VariableSymbol; "Variable Symbol")
                        {
                        }
                        column(VendorCompensationLine_DocumentNo; "Document No.")
                        {
                        }
                        column(VendorCompensationLine_DocumentType; "Document Type")
                        {
                        }
                        column(VendorCompensationLine_PostingDate; Format("Posting Date"))
                        {
                        }
                        column(VendorCompensationLine_LineNo; "Line No.")
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            VendorLedgerEntry.Get("Source Entry No.");
                            VendorDueDate := VendorLedgerEntry."Due Date";

                            if "Currency Code" = '' then
                                "Currency Code" := GeneralLedgerSetup."LCY Code";

                            if "Remaining Amount" <> 0 then begin
                                TempVendorPostedCompensationLineCZC := VendorPostedCompensationLineCZC;
                                TempVendorPostedCompensationLineCZC.Insert();
                            end;
                        end;
                    }
                    dataitem(CustomerInteger; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(CustomerInteger_Name; StrSubstNo(RemainingReceivablesAndPayablesTxt, RemaningCompanyName))
                        {
                        }
                        column(CustomerInteger_VariableSymbol; StrSubstNo(AmountAfterCompensationTxt, TempCustomerPostedCompensationLineCZC."Variable Symbol",
                                Format(Abs(TempCustomerPostedCompensationLineCZC."Remaining Amount"), 0, '<Precision,2:2><Sign><Integer><1000Character, ><Decimals>'),
                                TempCustomerPostedCompensationLineCZC."Currency Code"))
                        {
                        }
                        column(CustomerInteger_Number; Number)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not TempCustomerPostedCompensationLineCZC.FindSet() then
                                    CurrReport.Break();
                            end else
                                if TempCustomerPostedCompensationLineCZC.Next() = 0 then
                                    CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempCustomerPostedCompensationLineCZC.SetRange("Source Type", TempCustomerPostedCompensationLineCZC."Source Type"::Customer);
                            RemaningCompanyName := CompanyInformation.Name;
                        end;
                    }
                    dataitem(VendorInteger; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        column(VendorInteger_Name; StrSubstNo(RemainingReceivablesAndPayablesTxt, RemaningCompanyName))
                        {
                        }
                        column(VendorInteger_VariableSymbol; StrSubstNo(AmountAfterCompensationTxt, TempVendorPostedCompensationLineCZC."Variable Symbol",
                                Format(Abs(TempVendorPostedCompensationLineCZC."Remaining Amount"), 0, '<Precision,2:2><Sign><Integer><1000Character, ><Decimals>'),
                                TempVendorPostedCompensationLineCZC."Currency Code"))
                        {
                        }
                        column(VendorInteger_Number; Number)
                        {
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if Number = 1 then begin
                                if not TempVendorPostedCompensationLineCZC.FindSet() then
                                    CurrReport.Break();
                            end else
                                if TempVendorPostedCompensationLineCZC.Next() = 0 then
                                    CurrReport.Break();
                        end;

                        trigger OnPreDataItem()
                        begin
                            TempVendorPostedCompensationLineCZC.SetRange("Source Type", TempVendorPostedCompensationLineCZC."Source Type"::Vendor);
                            RemaningCompanyName := CompanyName;
                        end;
                    }
                    dataitem(Summary; Integer)
                    {
                        DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                        MaxIteration = 1;
                        column(WORKDATE; Format(WorkDate()))
                        {
                        }
                        column(Summary_Number; Number)
                        {
                        }
                    }
                }

                trigger OnAfterGetRecord()
                begin
                    if Number > 1 then
                        OutputCounter += 1;

                    TempCustomerPostedCompensationLineCZC.Reset();
                    TempCustomerPostedCompensationLineCZC.DeleteAll();
                    Clear(TempCustomerPostedCompensationLineCZC);

                    TempVendorPostedCompensationLineCZC.Reset();
                    TempVendorPostedCompensationLineCZC.DeleteAll();
                    Clear(TempVendorPostedCompensationLineCZC);
                end;

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;
                    SetRange(Number, 1, NoOfLoops);
                    OutputCounter := 1;
                end;
            }

            trigger OnAfterGetRecord()
            var
                Vendor: Record Vendor;
                Customer: Record Customer;
                Contact: Record Contact;
            begin
                Clear(CompanyName);
                Clear(CompanyAddress);
                Clear(CompanyRegistrationNo);

                CompanyName := "Company Name";
                if "Company Name 2" <> '' then
                    CompanyName := CompanyName + ' ' + "Company Name 2";

                CompanyAddress := "Company Address";
                if "Company Address 2" <> '' then
                    CompanyAddress := CompanyAddress + ' ' + "Company Address 2";
                if ("Company Post Code" <> '') or ("Company City" <> '') then
                    CompanyAddress := CompanyAddress + ', ' + "Company Post Code" + ' ' + "Company City";

                case "Company Type" of
                    "Company Type"::Vendor:
                        if Vendor.Get("Company No.") then
                            CompanyRegistrationNo := Vendor."Registration Number";
                    "Company Type"::Customer:
                        if Customer.Get("Company No.") then
                            CompanyRegistrationNo := Customer."Registration Number";
                    "Company Type"::Contact:
                        if Contact.Get("Company No.") then
                            CompanyRegistrationNo := Contact."Registration Number";
                end;

                CurrReport.Language := LanguageMgt.GetLanguageIdOrDefault("Language Code");
                CurrReport.FormatRegion := LanguageMgt.GetFormatRegionOrDefault("Format Region");
            end;

            trigger OnPreDataItem()
            begin
                CompanyInformation.Get();
                GeneralLedgerSetup.Get();
                GeneralLedgerSetup.TestField("LCY Code");
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
                    field(NoOfCopiesCZC; NoOfCopies)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'No. of Copies';
                        ToolTip = 'Specifies the number of copies to print.';
                    }
                }
            }
        }
    }

    labels
    {
        DotsLbl = '......................................................................';
    }

    var
        CompanyInformation: Record "Company Information";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TempCustomerPostedCompensationLineCZC, TempVendorPostedCompensationLineCZC : Record "Posted Compensation Line CZC" temporary;
        LanguageMgt: Codeunit Language;
        CompanyName, CompanyAddress, CompanyRegistrationNo, RemaningCompanyName : Text;
        CustomerDueDate, VendorDueDate : Date;
        NoOfCopies, NoOfLoops, OutputCounter : Integer;

        AgreementTxt: Label 'AGREEMENT %1', Comment = '%1 = Compensation No.';
        ToDateTxt: Label 'To Date %1', Comment = '%1 = Posting Date';
        ReceivablesTxt: Label 'Receivables %1', Comment = '%1 = Company Name';
        PayablesTxt: Label 'Payables %1', Comment = '%1 = Company Name';
        RemainingReceivablesAndPayablesTxt: Label 'Remaining Receivable and Payables of %1 to pay after realize Compensation.', Comment = '%1 = Company Name';
        AmountAfterCompensationTxt: Label 'for the variable symbol %1 are %2 %3 after the Compensation.', Comment = '%1 = Variable Symbol, %2 = Remaining Amount, %3 = Currency Code';
        ResidenceLbl: Label 'Residence:';
        BusinessNameLbl: Label 'Business Name:';
        RegistrationNoLbl: Label 'Reg. No.:';
        BankConnectionLbl: Label 'Bank connection:';
        ParagraphLbl: Label 'by reciprocally Compensation receibables by PAR. 1982-1991 of Civil Code No. 89/2012';
        RemainingAmountLbl: Label 'Remaining Amount';
        CompensationAmountLbl: Label 'Compensation Amount';
        LedgerEntryRemainingAmountLbl: Label 'Ledg. Entry Remaining Amount';
        LedgerEntryOriginalAmountLbl: Label 'Ledg. Entry Original Amount';
        DueDateLbl: Label 'Due Date';
        EnterIntoForceLbl: Label 'This agreement shall enter into force upon signature by both parties.';
        NameAndSignatureLbl: Label 'Name and Signature';
        InAndDateLbl: Label 'In .............................., date .................';
        SendBackLbl: Label 'In case you agree, send one confirmed agreement back to our address.';
        ForLbl: Label 'For';
        MakeDateLbl: Label 'Make Date';
        CurrencyCodeLbl: Label 'Currency Code';
        VariableSymbolLbl: Label 'Variable Symbol';
        DocumentNoLbl: Label 'Document No';
        DocumentTypeLbl: Label 'Document Type';
        PostingDateLbl: Label 'Posting Date';
}
