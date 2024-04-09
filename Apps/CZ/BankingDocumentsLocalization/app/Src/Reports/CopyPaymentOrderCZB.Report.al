// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

report 31281 "Copy Payment Order CZB"
{
    Caption = 'Copy Payment Order';
    ProcessingOnly = true;

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DocNoCZB; DocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of issued payment order.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            IssPaymentOrderHeaderCZB: Record "Iss. Payment Order Header CZB";
                        begin
                            if IssPaymentOrderHeaderCZB.Get(DocNo) then;
                            if Page.RunModal(0, IssPaymentOrderHeaderCZB) = Action::LookupOK then
                                DocNo := IssPaymentOrderHeaderCZB."No.";
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreReport()
    var
        BankStatementLineCZB: Record "Bank Statement Line CZB";
        IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB";
        LineNo: Integer;
    begin
        if DocNo = '' then
            Error(DocNoErr);

        BankStatementLineCZB.LockTable();
        BankStatementLineCZB.SetRange("Bank Statement No.", BankStatementHeaderCZB."No.");
        if BankStatementLineCZB.FindLast() then
            LineNo := BankStatementLineCZB."Line No.";

        IssPaymentOrderLineCZB.SetRange("Payment Order No.", DocNo);
        if IssPaymentOrderLineCZB.FindSet() then
            repeat
                LineNo += 10000;
                BankStatementLineCZB.Init();
                BankStatementLineCZB.Validate("Bank Statement No.", BankStatementHeaderCZB."No.");
                BankStatementLineCZB."Line No." := LineNo;
                BankStatementLineCZB.Description := IssPaymentOrderLineCZB.Description;
                BankStatementLineCZB."Account No." := IssPaymentOrderLineCZB."Account No.";
                BankStatementLineCZB."Variable Symbol" := IssPaymentOrderLineCZB."Variable Symbol";
                BankStatementLineCZB."Constant Symbol" := IssPaymentOrderLineCZB."Constant Symbol";
                BankStatementLineCZB."Specific Symbol" := IssPaymentOrderLineCZB."Specific Symbol";
                BankStatementLineCZB.Validate(Amount, -IssPaymentOrderLineCZB.Amount);
                BankStatementLineCZB."Transit No." := IssPaymentOrderLineCZB."Transit No.";
                BankStatementLineCZB.IBAN := IssPaymentOrderLineCZB.IBAN;
                BankStatementLineCZB."SWIFT Code" := IssPaymentOrderLineCZB."SWIFT Code";
                OnBeforeBankStatementLineInsert(BankStatementLineCZB, IssPaymentOrderLineCZB);
                BankStatementLineCZB.Insert();
            until IssPaymentOrderLineCZB.Next() = 0;
    end;

    var
        BankStatementHeaderCZB: Record "Bank Statement Header CZB";
        DocNo: Code[20];
        DocNoErr: Label 'Enter Document No.';

    procedure SetBankStatementHeader(NewBankStatementHeaderCZB: Record "Bank Statement Header CZB")
    begin
        BankStatementHeaderCZB := NewBankStatementHeaderCZB;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBankStatementLineInsert(var BankStatementLineCZB: Record "Bank Statement Line CZB"; IssPaymentOrderLineCZB: Record "Iss. Payment Order Line CZB")
    begin
    end;
}
