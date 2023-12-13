// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

report 11759 "Unreliable Payer List CZL"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Src/Reports/UnreliablePayerList.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Unreliable Payer List';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Vendor Posting Group", "Country/Region Code", "Tax Area Code";
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(OnlyErrors_fld; Format(OnlyErrors))
            {
            }
            column(VendorFilters; GetFilters)
            {
            }
            column(No_Vendor_fld; "No.")
            {
            }
            column(Name_Vendor_fld; Name)
            {
            }
            column(CountryCode_Vendor_fld; "Country/Region Code")
            {
            }
            column(VATRegNo_Vendor_fld; "VAT Registration No.")
            {
            }
            column(CheckDate_Vendor_var; Format(FirstUnreliablePayerEntryCZL."Check Date"))
            {
            }
            column(UncertPayer_Vendor_var; Format(FirstUnreliablePayerEntryCZL."Unreliable Payer"))
            {
            }
            column(TaxOfficeNo_Vendor_var; FirstUnreliablePayerEntryCZL."Tax Office Number")
            {
            }
            column(WarningText_Vendor_var; WarningText)
            {
            }
            dataitem("Vendor Bank Account"; "Vendor Bank Account")
            {
                DataItemLink = "Vendor No." = field("No.");
                DataItemTableView = sorting("Vendor No.", Code);
                column(BankAccNo_VBA_fld; "Bank Account No.")
                {
                }
                column(IBAN_VBA_fld; IBAN)
                {
                }
                column(PublicBA_VBA_var; Format(PublicBankAccount))
                {
                }
                column(BankAccType_VBA_var; Format(SecondUnreliablePayerEntryCZL."Bank Account No. Type"))
                {
                }
                column(PublicDate_VBA_var; Format(SecondUnreliablePayerEntryCZL."Public Date"))
                {
                }
                column(EndPublicDate_VBA_var; Format(SecondUnreliablePayerEntryCZL."End Public Date"))
                {
                }
                column(RecCount_VBA_var; RecCount)
                {
                }
                trigger OnAfterGetRecord()
                begin
                    PublicBankAccount := UnreliablePayerMgtCZL.IsPublicBankAccount("Vendor No.", VendorVATRegistrationNoCZL(), "Bank Account No.", IBAN);

                    SecondUnreliablePayerEntryCZL.SetRange("VAT Registration No.", VendorVATRegistrationNoCZL());
                    SecondUnreliablePayerEntryCZL.SetFilter("Full Bank Account No.", '%1|%2', "Bank Account No.", IBAN);
                    if not SecondUnreliablePayerEntryCZL.FindLast() then
                        Clear(SecondUnreliablePayerEntryCZL);

                    if OnlyErrors and PublicBankAccount then
                        CurrReport.Skip();

                    RecCount += 1;
                end;

                trigger OnPreDataItem()
                begin
                    if not PrintVendBankAcc then
                        CurrReport.Break();

                    SecondUnreliablePayerEntryCZL.Reset();
                    SecondUnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
                    SecondUnreliablePayerEntryCZL.SetRange("Entry Type", SecondUnreliablePayerEntryCZL."Entry Type"::"Bank Account");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                if "Privacy Blocked" then
                    CurrReport.Skip();
                if Blocked = Blocked::All then
                    CurrReport.Skip();

                Clear(RecCount);
                Clear(WarningText);
                if "VAT Registration No." <> '' then begin
                    if not UnreliablePayerMgtCZL.IsVATRegNoExportPossible("VAT Registration No.", "Country/Region Code") then
                        CurrReport.Skip();
                end else
                    WarningText := NotUseLbl;

                Clear(FirstUnreliablePayerEntryCZL);
                if WarningText = '' then begin
                    FirstUnreliablePayerEntryCZL.SetRange("VAT Registration No.", "VAT Registration No.");
                    FirstUnreliablePayerEntryCZL.SetRange("Entry Type", FirstUnreliablePayerEntryCZL."Entry Type"::Payer);
                    if not FirstUnreliablePayerEntryCZL.FindLast() then
                        WarningText := NotCheckLbl
                    else
                        case FirstUnreliablePayerEntryCZL."Unreliable Payer" of
                            FirstUnreliablePayerEntryCZL."Unreliable Payer"::YES:
                                WarningText := UnreliableLbl;
                            FirstUnreliablePayerEntryCZL."Unreliable Payer"::NOTFOUND:
                                WarningText := NotCheckLbl;
                        end;
                end;

                if OnlyErrors and (WarningText = '') then begin
                    VendorBankAccount.SetRange("Vendor No.", "No.");
                    if VendorBankAccount.FindSet() then
                        repeat
                            PublicBankAccount := UnreliablePayerMgtCZL.IsPublicBankAccount(VendorBankAccount."Vendor No.",
                                VendorBankAccount.VendorVATRegistrationNoCZL(),
                                VendorBankAccount."Bank Account No.", VendorBankAccount.IBAN);
                            if not PublicBankAccount then
                                WarningText := NonPublicLbl;
                        until (VendorBankAccount.Next() = 0) or (WarningText <> '');
                end;
                if OnlyErrors and (WarningText = '') then
                    CurrReport.Skip();
            end;

            trigger OnPreDataItem()
            begin
                FirstUnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
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
                    field(PrintVendBankAccCZL; PrintVendBankAcc)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print Vendor Bank Accounts';
                        ToolTip = 'Specifies if vendor bank accounts have to be printed.';
                    }
                    field(OnlyErrorsCZL; OnlyErrors)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Print only errors';
                        ToolTip = 'Specifies if only errors entries have to be printed.';
                    }
                }
            }
        }
    }
    labels
    {
        ReportCaptionLbl = 'VAT pay unreliable status list';
        VendorTableCaption = 'Vendor';
        PageCaptionLbl = 'Page';
        OnlyErrorsLbl = 'Print only errors:';
        No_Vendor_Lbl = 'No.';
        Name_Vendor_Lbl = 'Name';
        CountryCode_Vendor_Lbl = 'Country Code';
        VATRegNo_Vendor_Lbl = 'VAT Registration No.';
        CheckDate_Vendor_Lbl = 'Check Date';
        UncertPayer_Vendor_Lbl = 'No Reliability Payer';
        TaxOffNo_Vendor_Lbl = 'Tax Office No.';
        AccNo_VBA_Lbl = 'Bank Account No.';
        IBAN_VBA_Lbl = 'IBAN';
        PublicBankAcc_VBA_Lbl = 'Public Bank Account';
        BankAccType_VBA_Lbl = 'Bank Acc. Type';
        PublicDate_VBA_Lbl = 'Public Date';
        UnPublicDate_VBA_Lbl = 'End public Date';
        Printed_Lbl = 'Printed';
        Pages_Of_Report_Lbl = 'Page Of Report';
    }

    var
        FirstUnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        SecondUnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        VendorBankAccount: Record "Vendor Bank Account";
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        WarningText: Text[250];
        PrintVendBankAcc: Boolean;
        OnlyErrors: Boolean;
        PublicBankAccount: Boolean;
        RecCount: Integer;
        NotCheckLbl: Label 'Payer unreliable does not check.';
        UnreliableLbl: Label 'VAT payer is unreliable!';
        NotUseLbl: Label 'VAT Registration No. not use!';
        NonPublicLbl: Label 'Contains non public bank accounts.';
}
