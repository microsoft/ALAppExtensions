// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

report 31285 "Iss. Payment Order CZB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/IssPaymentOrder.rdl';
    Caption = 'Issued Payment Order';

    dataset
    {
        dataitem("Iss. Payment Order Header CZB"; "Iss. Payment Order Header CZB")
        {
            CalcFields = Amount;
            RequestFilterFields = "No.", "Bank Account No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(IssPaymentOrderHeader_No; "No.")
            {
                IncludeCaption = true;
            }
            column(IssPaymentOrderHeader_BankAccountNo; "Bank Account No.")
            {
                IncludeCaption = true;
            }
            column(IssPaymentOrderHeader_AccountNo; "Account No.")
            {
                IncludeCaption = true;
            }
            column(IssPaymentOrderHeader_DocumentDate; "Document Date")
            {
                IncludeCaption = true;
            }
            column(IssPaymentOrderHeader_CurrencyCode; "Currency Code")
            {
                IncludeCaption = true;
            }
            column(IssPaymentOrderHeader_CurrencyCodeCaption; FieldCaption("Currency Code"))
            {
            }
            column(IssPaymentOrderHeader_Amount; Amount)
            {
            }
            dataitem("Iss. Payment Order Line CZB"; "Iss. Payment Order Line CZB")
            {
                DataItemLink = "Payment Order No." = field("No.");
                DataItemTableView = sorting("Payment Order No.", "Line No.") where(Status = const(" "));
                column(IssPaymentOrderLine_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(IssPaymentOrderLine_AccountNo; "Account No.")
                {
                    IncludeCaption = true;
                }
                column(IssPaymentOrderLine_VariableSymbol; "Variable Symbol")
                {
                    IncludeCaption = true;
                }
                column(IssPaymentOrderLine_ConstantSymbol; "Constant Symbol")
                {
                    IncludeCaption = true;
                }
                column(IssPaymentOrderLine_SpecificSymbol; "Specific Symbol")
                {
                    IncludeCaption = true;
                }
                column(IssPaymentOrderLine_Amount; Amount)
                {
                    IncludeCaption = true;
                }
            }
        }
    }

    labels
    {
        ReportLbl = 'Payment Order';
        PageLbl = 'Page';
        TotalAmountLbl = 'Total Amount';
    }
}
