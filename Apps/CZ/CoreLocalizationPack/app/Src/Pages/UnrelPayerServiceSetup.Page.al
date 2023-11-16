// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.Vendor;

using System.Privacy;

page 11754 "Unrel. Payer Service Setup CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Unreliable Payer Service Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Unrel. Payer Service Setup CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group("Unreliable Payer Service")
            {
                Caption = 'Unreliable Payer Service';
                field("Unreliable Payer Web Service"; Rec."Unreliable Payer Web Service")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies web service URL for control unreliable payers.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the service is enabled.';

                    trigger OnValidate()
                    var
                        CustomerConsentMgt: Codeunit "Customer Consent Mgt.";
                    begin
                        if Rec.Enabled = xRec.Enabled then
                            exit;

                        if Rec.Enabled then
                            Rec.Enabled := CustomerConsentMgt.ConfirmUserConsent();
                    end;
                }
            }
            group(Parameters)
            {
                Caption = 'Parameters';
                field("Public Bank Acc.Chck.Star.Date"; Rec."Public Bank Acc.Chck.Star.Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the first date for checking public bank account of unreliable payer.';
                }
                field("Public Bank Acc.Check Limit"; Rec."Public Bank Acc.Check Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the limit of purchase document for checking public bank account of unreliable payer.';
                }
                field("Unr.Payer Request Record Limit"; Rec."Unr.Payer Request Record Limit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the record limit in one batch for checking unreliable payer.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    actions
    {
        area(creation)
        {
            action(SettoDefault)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Set Default Web Service';
                Image = Default;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Set the default URL in the Unreliable Payer Web Service field.';

                trigger OnAction()
                begin
                    UnreliablePayerMgtCZL.SetDefaultUnreliablePayerServiceURL(Rec);
                    Rec.Modify(true);
                end;
            }
        }
    }
    var
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            UnreliablePayerMgtCZL.SetDefaultUnreliablePayerServiceURL(Rec);
            Rec.Enabled := false;
            Rec.Insert();
        end;
    end;
}
