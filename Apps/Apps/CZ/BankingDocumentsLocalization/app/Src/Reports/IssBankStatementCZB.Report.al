// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

report 31283 "Iss. Bank Statement CZB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/IssBankStatement.rdl';
    Caption = 'Issued Bank Statement';

    dataset
    {
        dataitem("Iss. Bank Statement Header CZB"; "Iss. Bank Statement Header CZB")
        {
            CalcFields = Amount;
            RequestFilterFields = "No.", "Bank Account No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(IssBankStatementHeader_No; "No.")
            {
                IncludeCaption = true;
            }
            column(IssBankStatementHeader_BankAccountNo; "Bank Account No.")
            {
                IncludeCaption = true;
            }
            column(IssBankStatementHeader_AccountNo; "Account No.")
            {
                IncludeCaption = true;
            }
            column(IssBankStatementHeader_DocumentDate; "Document Date")
            {
                IncludeCaption = true;
            }
            column(IssBankStatementHeader_CurrencyCode; "Currency Code")
            {
                IncludeCaption = true;
            }
            column(IssBankStatementHeader_Amount; Amount)
            {
                IncludeCaption = true;
            }
            dataitem("Iss. Bank Statement Line CZB"; "Iss. Bank Statement Line CZB")
            {
                DataItemLink = "Bank Statement No." = field("No.");
                DataItemTableView = sorting("Bank Statement No.", "Line No.");
                column(IssBankStatementLine_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(IssBankStatementLine_AccountNo; "Account No.")
                {
                    IncludeCaption = true;
                }
                column(IssBankStatementLine_VariableSymbol; "Variable Symbol")
                {
                    IncludeCaption = true;
                }
                column(IssBankStatementLine_ConstantSymbol; "Constant Symbol")
                {
                    IncludeCaption = true;
                }
                column(IssBankStatementLine_SpecificSymbol; "Specific Symbol")
                {
                    IncludeCaption = true;
                }
                column(IssBankStatementLine_Amount; Amount)
                {
                    IncludeCaption = true;
                }
            }
        }
    }

    labels
    {
        ReportLbl = 'Bank Statement';
        PageLbl = 'Page';
        TotalAmountLbl = 'Total Amount';
    }
}
