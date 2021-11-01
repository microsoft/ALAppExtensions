reportextension 31000 "Suggest Payments CZZ" extends "Suggest Payments CZB"
{
    dataset
    {
#if not CLEAN19
        modify("Purch. Advance Letter Header")
        {
            trigger OnBeforePreDataItem()
            begin
                if AdvancePaymentsEnabledCZZ then
                    CurrReport.Break();
            end;
        }
        modify(PurchAdvLetterHdrPerLine)
        {
            trigger OnBeforePreDataItem()
            begin
                if AdvancePaymentsEnabledCZZ then
                    CurrReport.Break();
            end;
        }
#endif
        addafter("Vendor Ledger Entry Disc")
        {
            dataitem("Purch. Adv. Letter Header CZZ"; "Purch. Adv. Letter Header CZZ")
            {
                DataItemTableView = sorting("Advance Due Date") where(Status = const("To Pay"), "On Hold" = const(''));
                CalcFields = "To Pay";

                trigger OnPreDataItem()
                var
                    PurchaseAdvancesTxt: Label 'Processing Purchase Advances...';
                begin
                    if not VendorAdvancesCZZ then
                        CurrReport.Break();
                    if StopPayments then
                        CurrReport.Break();
                    WindowDialog.Open(PurchaseAdvancesTxt);
                    DialogOpen := true;

                    SetRange("Advance Due Date", 0D, LastDueDateToPayReq);
                    case CurrencyType of
                        CurrencyType::"Payment Order":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
                        CurrencyType::"Bank Account":
                            SetRange("Currency Code", PaymentOrderHeaderCZB."Currency Code");
                    end;
                    if VendorNoFilter <> '' then
                        SetFilter("Pay-to Vendor No.", VendorNoFilter);
                end;

                trigger OnAfterGetRecord()
                begin
                    if VendorType = VendorType::OnlyBalance then
                        if VendorBalanceTest("Pay-to Vendor No.") then
                            CurrReport.Skip();
                    if SkipBlocked and VendorBlockedTest("Pay-to Vendor No.") then begin
                        IsSkippedBlocked := true;
                        CurrReport.Skip();
                    end;

                    AddPurchaseAdvanceCZZ("Purch. Adv. Letter Header CZZ");
                    if StopPayments then
                        CurrReport.Break();
                end;

                trigger OnPostDataItem()
                begin
                    if DialogOpen then begin
                        WindowDialog.Close();
                        DialogOpen := false;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        layout
        {
            addafter(VendorTypeCZB)
            {
                field(VendorAdvancesCZZ; VendorAdvancesCZZ)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Vendor Advances';
                    ToolTip = 'Specifies payment suggestion of purchase advances.';
                }
            }
        }
    }

    var
#if not CLEAN19
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;
#endif
        VendorAdvancesCZZ: Boolean;

#if not CLEAN19
    trigger OnPreReport()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
#endif

    procedure AddPurchaseAdvanceCZZ(PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        PaymentOrderLineCZB.Init();
        PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order No.", PaymentOrderHeaderCZB."No.");
        PaymentOrderLineCZB."Line No." := LineNo;
        LineNo += 10000;

        PaymentOrderLineCZB.Type := PaymentOrderLineCZB.Type::Vendor;
        case CurrencyType of
            CurrencyType::" ":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PurchAdvLetterHeaderCZZ."Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PurchAdvLetterHeaderCZZ."Currency Code");
            CurrencyType::"Payment Order":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Payment Order Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PaymentOrderHeaderCZB."Payment Order Currency Code");
            CurrencyType::"Bank Account":
                if PaymentOrderLineCZB."Payment Order Currency Code" <> PaymentOrderHeaderCZB."Currency Code" then
                    PaymentOrderLineCZB.Validate(PaymentOrderLineCZB."Payment Order Currency Code", PaymentOrderHeaderCZB."Currency Code");
        end;
        PaymentOrderLineCZB.Validate("Purch. Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
        AddPaymentLine();
    end;
}
