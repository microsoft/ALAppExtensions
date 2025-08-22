// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

#pragma warning disable AS0007
namespace Microsoft.Agent.SalesOrderAgent;

page 4585 "SOA Billing Overview"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "SOA Billing Log";
    Permissions = tabledata "SOA Billing Log" = r;
    Caption = 'Sales Order Agent - Billing Overview';
    InherentEntitlements = X;
    InherentPermissions = X;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(ID; Rec.ID)
                {
                }
                field(Operation; Rec.Operation)
                {
                }
                field(Description; DescriptionTxt)
                {
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the operation';
                    trigger OnDrillDown()
                    begin
                        Message(DescriptionTxt);
                    end;
                }
                field("Agent Task ID"; Rec."Agent Task ID")
                {
                }
                field("Record System ID"; Rec."Record System ID")
                {
                    Visible = false;
                }
                field("Record Table"; Rec."Record Table")
                {
                    Visible = false;
                }
                field(Charged; Rec.Charged)
                {
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(PayEntries)
            {
                ApplicationArea = All;
                Caption = 'Pay entries';
                Image = Payment;
                ToolTip = 'This action will check for unregistered entries and then invoke the payment of all unpaid entries.';

                trigger OnAction()
                var
                    SOABillingTask: Codeunit "SOA Billing Task";
                begin
                    SOABillingTask.SetCheckOtherTasks(false);
                    SOABillingTask.Run();
                    Message(PaymentCompletedMsg);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(PayEntries_Promoted; PayEntries)
                {
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        SOABilling: Codeunit "SOA Billing";
    begin
        DescriptionTxt := SOABilling.GetDescription(Rec);
    end;

    var
        DescriptionTxt: Text;

        PaymentCompletedMsg: Label 'Completed successfully.';
}

