// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

page 4810 "Intrastat Report Setup"
{
    ApplicationArea = All;
    Caption = 'Intrastat Report Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTable = "Intrastat Report Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Report Receipts"; Rec."Report Receipts") { }
                field("Report Shipments"; Rec."Report Shipments") { }
                field("Include Drop Shipment"; Rec."Include Drop Shipment") { }
                field("Shipments Based On"; Rec."Shipments Based On") { }
#if not CLEAN26
                field("VAT No. Based On"; Rec."VAT No. Based On")
                {
                    Visible = false;
                    ObsoleteReason = 'Use "Sales VAT No. Based On" and "Purchase VAT No. Based On" fields instead.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '26.0';
                }
#endif
                field("Sales VAT No. Based On"; Rec."Sales VAT No. Based On") { }
                field("Purchase VAT No. Based On"; Rec."Purchase VAT No. Based On") { }
                field("Project VAT No. Based On"; Rec."Project VAT No. Based On") { }
                field("Sales Intrastat Info Based On"; Rec."Sales Intrastat Info Based On") { }
                field("Purch. Intrastat Info Based On"; Rec."Purch. Intrastat Info Based On") { }
                field("Intrastat Contact Type"; Rec."Intrastat Contact Type") { }
                field("Intrastat Contact No."; Rec."Intrastat Contact No.") { }
                field("Company VAT No. on File"; Rec."Company VAT No. on File") { }
                field("Vend. VAT No. on File"; Rec."Vend. VAT No. on File") { }
                field("Cust. VAT No. on File"; Rec."Cust. VAT No. on File") { }
                field("Get Partner VAT For"; Rec."Get Partner VAT For") { }
                field("Def. Country Code for Item Tr."; Rec."Def. Country Code for Item Tr.") { }
            }
            group("Default Transactions")
            {
                Caption = 'Default Transactions';
                field("Default Transaction Type"; Rec."Default Trans. - Purchase") { }
                field("Default Trans. Type - Returns"; Rec."Default Trans. - Return") { }
                field("Def. Private Person VAT No."; Rec."Def. Private Person VAT No.") { }
                field("Def. 3-Party Trade VAT No."; Rec."Def. 3-Party Trade VAT No.") { }
                field("Def. VAT for Unknown State"; Rec."Def. VAT for Unknown State") { }
                field("Def. Country/Region Code"; Rec."Def. Country/Region Code") { }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Data Exch. Def. Code"; Rec."Data Exch. Def. Code")
                {
                    Enabled = not Rec."Split Files";
                }
                field("Data Exch. Def. Name"; Rec."Data Exch. Def. Name")
                {
                    Enabled = not Rec."Split Files";
                }
                field("Split Files"; Rec."Split Files")
                {
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Zip Files"; Rec."Zip Files") { }
                field("Data Exch. Def. Code - Receipt"; Rec."Data Exch. Def. Code - Receipt")
                {
                    Enabled = Rec."Split Files";
                }
                field("Data Exch. Def. Name - Receipt"; Rec."Data Exch. Def. Name - Receipt")
                {
                    Enabled = Rec."Split Files";
                }
                field("Data Exch. Def. Code - Shpt."; Rec."Data Exch. Def. Code - Shpt.")
                {
                    Enabled = Rec."Split Files";
                }
                field("Data Exch. Def. Name - Shpt."; Rec."Data Exch. Def. Name - Shpt.")
                {
                    Enabled = Rec."Split Files";
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Intrastat Nos."; Rec."Intrastat Nos.") { }
            }
            group("MandatoryFields")
            {
                Caption = 'Mandatory Fields';
                field("Transaction Type Mandatory"; Rec."Transaction Type Mandatory") { }
                field("Transaction Spec. Mandatory"; Rec."Transaction Spec. Mandatory") { }
                field("Transport Method Mandatory"; Rec."Transport Method Mandatory") { }
                field("Shipment Method Mandatory"; Rec."Shipment Method Mandatory") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(IntrastatReportChecklist)
            {
                Caption = 'Intrastat Report Checklist';
                Image = Column;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "Intrastat Report Checklist";
                ToolTip = 'View and edit fields to be verified by the Intrastat check.';
            }
            action(ImportDefaultDataExchangeDef)
            {
                Caption = 'Create Default Data Exch. Def.';
                Image = Create;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Create/Restore Default Data Exchange Definition(-s)';
                trigger OnAction()
                var
                    IntrastatReportMgt: Codeunit IntrastatReportManagement;
                begin
                    IntrastatReportMgt.ReCreateDefaultDataExchangeDef();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}