// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Company;
using Microsoft.HumanResources.Employee;
using Microsoft.Sales.Setup;
using System.Security.User;
using System.Utilities;

report 11735 "Withdrawal Cash Document CZP"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/WithdrawalCashDocument.rdl';
    PreviewMode = PrintLayout;
    Caption = 'Withdrawal Cash Document';
    UsageCategory = None;

    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView = sorting("Primary Key");
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
            column(RegistrationNo_CompanyInformation; "Company Information"."Registration No.")
            {
            }
            column(VATRegistrationNo_CompanyInformation; "Company Information"."VAT Registration No.")
            {
            }
            column(HomePage_CompanyInformation; "Company Information"."Home Page")
            {
            }
            column(Picture_CompanyInformation; "Company Information".Picture)
            {
            }
            dataitem("Sales & Receivables Setup"; "Sales & Receivables Setup")
            {
                DataItemTableView = sorting("Primary Key");
                column(LogoPositiononDocuments_SalesReceivablesSetup; Format("Logo Position on Documents", 0, 2))
                {
                }
                dataitem("General Ledger Setup"; "General Ledger Setup")
                {
                    DataItemTableView = sorting("Primary Key");
                    column(LCYCode_GeneralLedgerSetup; "LCY Code")
                    {
                    }
                }
            }

            trigger OnAfterGetRecord()
            begin
                FormatAddress.Company(CompanyAddr, "Company Information");
            end;

            trigger OnPreDataItem()
            begin
                CalcFields(Picture);
            end;
        }
        dataitem(CashDocumentHeaderCZP; "Cash Document Header CZP")
        {
            CalcFields = "Amount Including VAT";
            column(CashDeskNo_CashDocumentHeader; "Cash Desk No.")
            {
            }
            column(No_CashDocumentHeader; "No.")
            {
            }
            column(Status_CashDocumentHeader; Format(Status, 0, 2))
            {
            }
            column(CurrencyCode_CashDocumentHeader; "Currency Code")
            {
            }
            column(VATDate_CashDocumentHeader; Format("VAT Date"))
            {
            }
            column(DocumentDate_CashDocumentHeader; Format("Document Date"))
            {
            }
            column(PaymentPurpose_CashDocumentHeader; "Payment Purpose")
            {
                IncludeCaption = true;
            }
            column(RegistrationNo_CashDocumentHeader; "Registration No.")
            {
                IncludeCaption = true;
            }
            column(VATRegistrationNo_CashDocumentHeader; "VAT Registration No.")
            {
                IncludeCaption = true;
            }
            column(PaidTo_CashDocumentHeader; "Paid To")
            {
                IncludeCaption = true;
            }
            column(IdentificationCardNo_CashDocumentHeader; "Identification Card No.")
            {
                IncludeCaption = true;
            }
            column(PaidBy_CashDocumentHeader; "Paid By")
            {
                IncludeCaption = true;
            }
            column(CalculatedExchRate; CalculatedExchRate)
            {
            }
            column(ExchRateText; ExchRateText)
            {
            }
            column(FromAmountToDescription_CashDocumentHeader; CashDeskManagementCZP.FromAmountToDescription("Amount Including VAT"))
            {
            }
            dataitem(CopyLoop; Integer)
            {
                DataItemTableView = sorting(Number);
                column(CopyNo; Number)
                {
                }
                dataitem(CashDocumentLineCZP; "Cash Document Line CZP")
                {
                    DataItemLink = "Cash Desk No." = field("Cash Desk No."), "Cash Document No." = field("No.");
                    DataItemLinkReference = CashDocumentHeaderCZP;
                    DataItemTableView = sorting("Cash Desk No.", "Cash Document No.", "Line No.");
                    column(LineNo_CashDocumentLine; "Line No.")
                    {
                    }
                    column(Description_CashDocumentLine; Description)
                    {
                        IncludeCaption = true;
                    }
                    column(AmountIncludingVAT_CashDocumentLine; "Amount Including VAT")
                    {
                        IncludeCaption = true;
                    }
                    column(VAT_CashDocumentLine; "VAT %")
                    {
                        IncludeCaption = true;
                    }
                    column(VATAmount_CashDocumentLine; "VAT Amount")
                    {
                        IncludeCaption = true;
                    }
                    column(VATBaseAmount_CashDocumentLine; "VAT Base Amount")
                    {
                        IncludeCaption = true;
                    }

                    trigger OnPreDataItem()
                    begin
                        TempVATAmountLine.DeleteAll();
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.Init();
                        TempVATAmountLine."VAT Identifier" := "VAT Identifier";
                        TempVATAmountLine."VAT Calculation Type" := "VAT Calculation Type";
                        TempVATAmountLine."VAT %" := "VAT %";
                        TempVATAmountLine."VAT Base" := "VAT Base Amount";
                        TempVATAmountLine."VAT Amount" := "VAT Amount";
                        TempVATAmountLine."Amount Including VAT" := "Amount Including VAT";
                        TempVATAmountLine."VAT Base (LCY) CZL" := "VAT Base Amount (LCY)";
                        TempVATAmountLine."VAT Amount (LCY) CZL" := "VAT Amount (LCY)";
                        TempVATAmountLine.InsertLine();
                    end;
                }
                dataitem(VATCounter; Integer)
                {
                    DataItemTableView = sorting(Number);
                    column(VATAmtLineVATIdentifier; TempVATAmountLine."VAT Identifier")
                    {
                    }
                    column(VATAmtLineVATPer; TempVATAmountLine."VAT %")
                    {
                        DecimalPlaces = 0 : 5;
                        IncludeCaption = true;
                    }
                    column(VATAmtLineVATBase; TempVATAmountLine."VAT Base")
                    {
                        AutoFormatExpression = CashDocumentHeaderCZP."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmt; TempVATAmountLine."VAT Amount")
                    {
                        AutoFormatExpression = CashDocumentHeaderCZP."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATBaseLCY; TempVATAmountLine."VAT Base (LCY) CZL")
                    {
                        AutoFormatExpression = CashDocumentHeaderCZP."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmtLineVATAmtLCY; TempVATAmountLine."VAT Amount (LCY) CZL")
                    {
                        AutoFormatExpression = CashDocumentHeaderCZP."Currency Code";
                        AutoFormatType = 1;
                    }
                    dataitem("User Setup"; "User Setup")
                    {
                        DataItemLinkReference = CashDocumentHeaderCZP;
                        DataItemTableView = sorting("User ID");
                        dataitem(Employee; Employee)
                        {
                            DataItemLink = "No." = field("Employee No. CZL");
                            DataItemTableView = sorting("No.");
                            column(FullName_Employee; FullName())
                            {
                            }
                            column(PhoneNo_Employee; "Phone No.")
                            {
                            }
                            column(CompanyEMail_Employee; "Company E-Mail")
                            {
                            }
                        }

                        trigger OnPreDataItem()
                        begin
                            case CashDocumentHeaderCZP.Status of
                                CashDocumentHeaderCZP.Status::Open:
                                    SetRange("User ID", CashDocumentHeaderCZP."Created ID");
                                CashDocumentHeaderCZP.Status::Released:
                                    SetRange("User ID", CashDocumentHeaderCZP."Released ID");
                            end;
                        end;
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange(Number, 1, TempVATAmountLine.Count);
                    end;

                    trigger OnAfterGetRecord()
                    begin
                        TempVATAmountLine.GetLine(Number);
                    end;
                }

                trigger OnPreDataItem()
                begin
                    NoOfLoops := Abs(NoOfCopies) + 1;
                    if NoOfLoops <= 0 then
                        NoOfLoops := 1;

                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if Status = Status::Released then
                    TestField("Amount Including VAT", "Released Amount");

                if "Currency Code" = '' then
                    "Currency Code" := "General Ledger Setup"."LCY Code"
                else
                    if ("Currency Factor" <> 0) and ("Currency Factor" <> 1) then begin
                        CurrencyExchangeRate.FindCurrency("Posting Date", "Currency Code", 1);
                        CalculatedExchRate := Round(1 / "Currency Factor" * CurrencyExchangeRate."Exchange Rate Amount", 0.00001);
                        ExchRateText :=
                          StrSubstNo(
                            ExchangeRateTxt, CalculatedExchRate, "General Ledger Setup"."LCY Code",
                            CurrencyExchangeRate."Exchange Rate Amount", "Currency Code");
                    end else
                        CalculatedExchRate := 1;
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
                    field(NoOfCopiesCZP; NoOfCopies)
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
        DocumentLbl = 'Withdrawal Cash Document';
        PageLbl = 'Page';
        CompanyLbl = 'Company';
        TotalLbl = 'Total';
        TotalTextLbl = 'Total Text';
        TestLbl = 'Test';
        VATIdentLbl = 'VAT Recapitulation';
        VATPercentLbl = 'VAT %';
        VATBaseLbl = 'VAT Base';
        VATAmtLbl = 'VAT Amount';
        VATLbl = 'VAT';
        CreatedLbl = 'Created by';
        ReleasedLbl = 'Released by';
        CopyLbl = 'Copy';
        VATDateLbl = 'VAT Date';
        DocumentDateLbl = 'Document Date';
    }

    var
        TempVATAmountLine: Record "VAT Amount Line" temporary;
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        FormatAddress: Codeunit "Format Address";
        CashDeskManagementCZP: Codeunit "Cash Desk Management CZP";
        ExchRateText: Text[50];
        CompanyAddr: array[8] of Text[100];
        CalculatedExchRate: Decimal;
        ExchangeRateTxt: Label 'Exchange Rate %1 %2 / %3 %4', Comment = '%1 = Calculated Exchange Rate Amount; %2 = LCY Code; %3 = Exchange Rate Amount; %4 = Currency Code';
        NoOfCopies: Integer;
        NoOfLoops: Integer;

    procedure InitializeRequest(NewNoOfCopies: Integer)
    begin
        NoOfCopies := NewNoOfCopies;
    end;
}
