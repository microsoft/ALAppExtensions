// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using Microsoft.Bank.BankAccount;
using System.Utilities;

report 31282 "Bank Statement - Test CZB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/BankStatementTest.rdl';
    Caption = 'Bank Statement - Test';

    dataset
    {
        dataitem("Bank Statement Header CZB"; "Bank Statement Header CZB")
        {
            CalcFields = Amount;
            RequestFilterFields = "No.", "Bank Account No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(BankStatementHeader_No; "No.")
            {
                IncludeCaption = true;
            }
            column(BankStatementHeader_DocumentDate; "Document Date")
            {
                IncludeCaption = true;
            }
            column(BankStatementHeader_Amount; Amount)
            {
                IncludeCaption = true;
            }
            column(BeginingBalance; BankAccount.Balance)
            {
            }
            dataitem("Bank Statement Line CZB"; "Bank Statement Line CZB")
            {
                DataItemLink = "Bank Statement No." = field("No.");
                DataItemTableView = sorting("Bank Statement No.", "Line No.");
                column(BankStatementLine_LineNo; "Line No.")
                {
                }
                column(BankStatementLine_Type; Type)
                {
                    IncludeCaption = true;
                }
                column(BankStatementLine_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(BankStatementLine_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(BankStatementLine_AccountNo; "Account No.")
                {
                    IncludeCaption = true;
                }
                column(BankStatementLine_VariableSymbol; "Variable Symbol")
                {
                    IncludeCaption = true;
                }
                column(BankStatementLine_SpecificSymbol; "Specific Symbol")
                {
                    IncludeCaption = true;
                }
                column(BankStatementLine_Amount; Amount)
                {
                    IncludeCaption = true;
                }
                dataitem(Integer; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = filter(1 ..));
                    column(ErrorText; ErrorText)
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        IssueBankStatementCZB.ReturnError(ErrorText, Number);
                        if ErrorText = '' then
                            CurrReport.Break();
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    IssBankStatementLineCZB: Record "Iss. Bank Statement Line CZB";
                    IsHandled: Boolean;
                begin
                    IsHandled := false;
                    OnBeforeCheckBankStatementLine("Bank Statement Line CZB", IsHandled);
                    if not IsHandled then begin
                        IssBankStatementLineCZB.TransferFields("Bank Statement Line CZB");
                        Clear(IssueBankStatementCZB);
                        if IssueBankStatementCZB.CheckBankStatementLine(IssBankStatementLineCZB, false, true) then;
                        TransferFields(IssBankStatementLineCZB);
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                BankAccount.Get("Bank Account No.");
                BankAccount.CalcFields(Balance);
            end;
        }
    }

    labels
    {
        ReportLbl = 'Bank Statement - Test';
        PageLbl = 'Page';
        BeginingBalanceLbl = 'Begining Balance';
        EndingBalanceLbl = 'Ending Balance';
        ErrorTextLbl = 'Warning!';
        TotalLbl = 'Total';
    }

    var
        BankAccount: Record "Bank Account";
        IssueBankStatementCZB: Codeunit "Issue Bank Statement CZB";
        ErrorText: Text;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckBankStatementLine(var BankStatementLineCZB: Record "Bank Statement Line CZB"; var IsHandled: Boolean);
    begin
    end;
}
