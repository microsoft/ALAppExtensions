// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.Registration;
#if not CLEAN21
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
#endif
using Microsoft.Sales.Receivables;

pageextension 11704 "Customer Card CZL" extends "Customer Card"
{
    layout
    {
        modify("Registration Number")
        {
            trigger OnDrillDown()
            var
                RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
            begin
                CurrPage.SaveRecord();
                RegistrationLogMgtCZL.AssistEditCustomerRegNo(Rec);
                CurrPage.Update(false);
            end;
        }
        addafter("VAT Registration No.")
        {
#if not CLEAN23
            field("Registration No. CZL"; Rec."Registration No. CZL")
            {
                Caption = 'Registration No. (Obsolete)';
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the registration number of customer.';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '23.0';
                ObsoleteReason = 'Replaced by standard "Registration Number" field.';

                trigger OnDrillDown()
                var
                    RegistrationLogMgtCZL: Codeunit "Registration Log Mgt. CZL";
                begin
                    CurrPage.SaveRecord();
                    RegistrationLogMgtCZL.AssistEditCustomerRegNo(Rec);
                    CurrPage.Update(false);
                end;
            }
#endif
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the customer.';
                Importance = Additional;
            }
        }
#if not CLEAN21
        addafter("Credit Limit (LCY)")
        {
            field(BalanceOfVendorCZL; BalanceAsVendor)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance As Vendor (LCY)';
                Editable = false;
                Enabled = BalanceOfVendorEnabled;
                ToolTip = 'Specifies the vendor''s balance which is connected with certain customer';
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteReason = 'Duplicated field.';
                ObsoleteTag = '21.0';

                trigger OnDrillDown()
                var
                    DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    DetailedVendorLedgEntry.SetRange("Vendor No.", Vendor."No.");
                    Rec.CopyFilter("Global Dimension 1 Filter", DetailedVendorLedgEntry."Initial Entry Global Dim. 1");
                    Rec.CopyFilter("Global Dimension 2 Filter", DetailedVendorLedgEntry."Initial Entry Global Dim. 2");
                    Rec.CopyFilter("Currency Filter", DetailedVendorLedgEntry."Currency Code");
                    VendorLedgerEntry.DrillDownOnEntries(DetailedVendorLedgEntry);
                end;
            }
        }
#endif
#if not CLEAN22
        addafter(PricesandDiscounts)
        {
#pragma warning disable AS0011
            group("Foreign Trade")
#pragma warning restore AS0011
            {
                Caption = 'Foreign Trade (Obsolete)';
                ObsoleteState = Pending;
                ObsoleteTag = '22.0';
                ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';

                field("Transaction Type CZL"; Rec."Transaction Type CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Transaction Type (Obsolete)';
                    ToolTip = 'Specifies the default Transaction type for Intrastat reporting purposes.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
                }
                field("Transaction Specification CZL"; Rec."Transaction Specification CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Transaction Specification (Obsolete)';
                    ToolTip = 'Specifies the default Transaction specification for Intrastat reporting purposes.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field will not be used anymore.';
                }
                field("Transport Method CZL"; Rec."Transport Method CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Transport Method (Obsolete)';
                    ToolTip = 'Specifies the default Transport Method for Intrastat reporting purposes.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
                }
            }
        }
#endif
    }
    actions
    {
        addafter(BackgroundStatement)
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                Promoted = true;
                PromotedCategory = "Report";
                ToolTip = 'Open the report for customer''s balance reconciliation.';

                trigger OnAction()
                begin
                    RunReport(Report::"Cust.- Bal. Reconciliation CZL", Rec."No.");
                end;
            }
        }
    }
#if not CLEAN21
    trigger OnAfterGetCurrRecord()
    begin
        if Vendor.Get(Rec.GetLinkedVendorCZL()) then begin
            Vendor.CalcFields("Balance (LCY)");
            BalanceAsVendor := Vendor."Balance (LCY)";
            BalanceOfVendorEnabled := true;
        end else begin
            BalanceAsVendor := 0;
            BalanceOfVendorEnabled := false;
        end;
    end;

    var
        Vendor: Record Vendor;
        BalanceAsVendor: Decimal;
        BalanceOfVendorEnabled: Boolean;
#endif
}
