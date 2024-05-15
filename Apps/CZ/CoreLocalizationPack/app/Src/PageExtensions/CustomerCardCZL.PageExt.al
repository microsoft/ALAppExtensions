// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.Customer;

using Microsoft.Finance.Registration;
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
                ToolTip = 'Open the report for customer''s balance reconciliation.';

                trigger OnAction()
                begin
                    RunReport(Report::"Cust.- Bal. Reconciliation CZL", Rec."No.");
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
