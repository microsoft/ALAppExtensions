// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using Microsoft.Finance.Registration;
using Microsoft.Purchases.Payables;

pageextension 11705 "Vendor Card CZL" extends "Vendor Card"
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
                RegistrationLogMgtCZL.AssistEditVendorRegNo(Rec);
                CurrPage.Update(false);
            end;
        }
        addafter("VAT Registration No.")
        {
            field("Tax Registration No. CZL"; Rec."Tax Registration No. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the secondary VAT registration number for the vendor.';
                Importance = Additional;
            }
        }
        addlast(Invoicing)
        {
            field("Last Unreliab. Check Date CZL"; Rec."Last Unreliab. Check Date CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the date of the last check of unreliability.';
            }
            field("VAT Unreliable Payer CZL"; Rec."VAT Unreliable Payer CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies if the Vendor is VAT Unreliable Payer.';
            }
            field("Disable Unreliab. Check CZL"; Rec."Disable Unreliab. Check CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that the check of VAT Unreliable Payer is disabled.';
            }
        }
    }
    actions
    {
        addlast("Ven&dor")
        {
            action(UnreliabilityStatusCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unreliability Status';
                Image = CustomerRating;
                ToolTip = 'View the VAT payer unreliable entries.';

                trigger OnAction()
                begin
                    Rec.ShowUnreliableEntriesCZL();
                end;
            }
        }
        addlast("F&unctions")
        {
            action(UnreliableVATPaymentCheckCZL)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Unreliable VAT Payment Check';
                Image = ElectronicPayment;
                ToolTip = 'Checks unreliability of the VAT payer.';

                trigger OnAction()
                var
                    UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
                    UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
                    UnrelPayerServiceNotSet: Boolean;
                begin
                    if not UnrelPayerServiceSetupCZL.Get() then
                        UnrelPayerServiceNotSet := true
                    else
                        UnrelPayerServiceNotSet := not UnrelPayerServiceSetupCZL.Enabled;
                    if UnrelPayerServiceNotSet then
                        UnreliablePayerMgtCZL.CreateUnrelPayerServiceNotSetNotification();

                    Rec.ImportUnrPayerStatusCZL();
                end;
            }
        }
        addafter("Vendor - Balance to Date")
        {
            action("Balance Reconciliation CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Reconciliation';
                Image = Balance;
                ToolTip = 'Open the report for vendor''s balance reconciliation.';

                trigger OnAction()
                var
                    Vendor: Record Vendor;
                begin
                    Vendor.SetRange("No.", Rec."No.");
                    Report.RunModal(Report::"Vendor-Bal. Reconciliation CZL", true, true, Vendor);
                end;
            }
        }
        addlast(Category_Report)
        {
            actionref("Balance Reconciliation CZL_Promoted"; "Balance Reconciliation CZL")
            {
            }
        }
    }
}
