// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Documents;

using System.Utilities;

report 31284 "Payment Order - Test CZB"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/PaymentOrderTest.rdl';
    Caption = 'Payment Order - Test';

    dataset
    {
        dataitem("Payment Order Header CZB"; "Payment Order Header CZB")
        {
            RequestFilterFields = "No.", "Bank Account No.";
            column(COMPANYNAME; CompanyProperty.DisplayName())
            {
            }
            column(ReportFilter; GetFilters())
            {
            }
            column(PaymentOrderHeader_No; "No.")
            {
                IncludeCaption = true;
            }
            column(PaymentOrderHeader_BankAccountNo; "Bank Account No.")
            {
                IncludeCaption = true;
            }
            column(PaymentOrderHeader_AccountNo; "Account No.")
            {
                IncludeCaption = true;
            }
            column(PaymentOrderHeader_DocumentDate; "Document Date")
            {
                IncludeCaption = true;
            }
            column(PaymentOrderHeader_CurrencyCode; "Currency Code")
            {
                IncludeCaption = true;
            }
            dataitem("Payment Order Line CZB"; "Payment Order Line CZB")
            {
                DataItemLink = "Payment Order No." = field("No.");
                DataItemTableView = sorting("Payment Order No.", "Line No.");
                column(PaymentOrderLine_Description; Description)
                {
                    IncludeCaption = true;
                }
                column(PaymentOrderLine_AccountNo; "Account No.")
                {
                    IncludeCaption = true;
                }
                column(PaymentOrderLine_VariableSymbol; "Variable Symbol")
                {
                    IncludeCaption = true;
                }
                column(PaymentOrderLine_ConstantSymbol; "Constant Symbol")
                {
                    IncludeCaption = true;
                }
                column(PaymentOrderLine_SpecificSymbol; "Specific Symbol")
                {
                    IncludeCaption = true;
                }
                column(PaymentOrderLine_AmountToPay; Amount)
                {
                }
                column(PaymentOrderHeader_Amount; "Payment Order Header CZB".Amount)
                {
                }
                column(PaymentOrderLine_DescriptionCaption; FieldCaption(Description))
                {
                }
                column(PaymentOrderLine_AccountNoCaption; FieldCaption("Account No."))
                {
                }
                column(PaymentOrderLine_VariableSymbolCaption; FieldCaption("Variable Symbol"))
                {
                }
                column(PaymentOrderLine_ConstantSymbolCaption; FieldCaption("Constant Symbol"))
                {
                }
                column(PaymentOrderLine_SpecificSymbolCaption; FieldCaption("Specific Symbol"))
                {
                }
                column(PaymentOrderLine_AmountToPayCaption; FieldCaption(Amount))
                {
                }
                column(PaymentOrderLine_LineNo; "Line No.")
                {
                }
                column(TotalAmount; TotalAmount)
                {
                }
                dataitem("Error Message"; "Error Message")
                {
                    DataItemTableView = sorting(ID);
                    UseTemporary = true;
                    column(ID_ErrorMessage; ID)
                    {
                    }
                    column(MessageType_ErrorMessage; "Message Type")
                    {
                    }
                    column(Description_ErrorMessage; "Message")
                    {
                    }

                    trigger OnPreDataItem()
                    begin
                        SetRange("Record ID", "Payment Order Line CZB".RecordId());
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    IsHandled: Boolean;
                begin
                    IsHandled := false;
                    OnBeforeCheckPaymentOrderLine("Payment Order Line CZB", IsHandled);
                    if not IsHandled then begin
                        PaymentOrderManagementCZB.CheckPaymentOrderLineCustVendBlocked("Payment Order Line CZB", false);
                        PaymentOrderManagementCZB.CheckPaymentOrderLineApply("Payment Order Line CZB", false);
                        PaymentOrderManagementCZB.CheckPaymentOrderLineFormat("Payment Order Line CZB", false);
                        PaymentOrderManagementCZB.CheckPaymentOrderLineCustom("Payment Order Line CZB", false);
                    end;
                    PaymentOrderManagementCZB.CopyErrorMessageToTemp("Error Message");
                    TotalAmount += Amount;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Skip Payment", false);
                    if PrintIncludingSkipPayments then
                        SetRange("Skip Payment");
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(General)
                {
                    Caption = 'General';
                    field(PrintIncludingSkipPaymentsCZB; PrintIncludingSkipPayments)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print including skip payments';
                        ToolTip = 'Specifies if the document will be print including skip payments.';
                    }
                }
            }
        }
    }

    labels
    {
        ReportLbl = 'Payment Order - Test';
        PageLbl = 'Page';
        TotalAmountLbl = 'Total Amount';
    }

    var
        PaymentOrderManagementCZB: Codeunit "Payment Order Management CZB";
        PrintIncludingSkipPayments: Boolean;
        TotalAmount: Decimal;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentOrderLine(var PaymentOrderLineCZB: Record "Payment Order Line CZB"; var IsHandled: Boolean);
    begin
    end;
}
