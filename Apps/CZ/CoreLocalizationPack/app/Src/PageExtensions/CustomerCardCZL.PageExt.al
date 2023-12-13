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
}
