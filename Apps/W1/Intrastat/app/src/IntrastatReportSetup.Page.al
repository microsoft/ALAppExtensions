// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

page 4810 "Intrastat Report Setup"
{
    ApplicationArea = BasicEU, BasicCH, BasicNO;
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
                field("Report Receipts"; Rec."Report Receipts")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies that you must include arrivals of received goods in Intrastat reports.';
                }
                field("Report Shipments"; Rec."Report Shipments")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies that you must include shipments of dispatched items in Intrastat reports.';
                }
                field("Include Drop Shipment"; Rec."Include Drop Shipment")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies if drop shipment transactions are included in Intrastat reports.';
                }
                field("Shipments Based On"; Rec."Shipments Based On")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies based on which country code Intrastat report lines are taken.';
                }
                field("VAT No. Based On"; Rec."VAT No. Based On")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies based on which customer/vendor code VAT number is taken for the Intrastat report.';
                }
                field("Intrastat Contact Type"; Rec."Intrastat Contact Type")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the Intrastat contact type.';
                }
                field("Intrastat Contact No."; Rec."Intrastat Contact No.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the Intrastat contact.';
                }
                field("Company VAT No. on File"; Rec."Company VAT No. on File")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the information to include in the company''s VAT registration number when it''s exported to the Intrastat file.';
                }
                field("Vend. VAT No. on File"; Rec."Vend. VAT No. on File")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the information to include in a vendor''s VAT registration number when it''s exported to the Intrastat file.';
                }
                field("Cust. VAT No. on File"; Rec."Cust. VAT No. on File")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the information to include in a customer''s VAT registration number when it''s exported to the Intrastat file.';
                }
                field("Get Partner VAT For"; Rec."Get Partner VAT For")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the type of line that the partner''s VAT registration number is updated for.';
                }
                field("Def. Country Code for Item Tr."; Rec."Def. Country Code for Item Tr.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default source of country code for item tracking.';
                }
            }
            group("Default Transactions")
            {
                Caption = 'Default Transactions';
                field("Default Transaction Type"; Rec."Default Trans. - Purchase")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments, and purchase receipts.';
                }
                field("Default Trans. Type - Returns"; Rec."Default Trans. - Return")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default transaction type for sales returns and service returns, and purchase returns.';
                }
                field("Def. Private Person VAT No."; Rec."Def. Private Person VAT No.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default private person VAT number.';
                }
                field("Def. 3-Party Trade VAT No."; Rec."Def. 3-Party Trade VAT No.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default 3-party trade VAT number.';
                }
                field("Def. VAT for Unknown State"; Rec."Def. VAT for Unknown State")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default VAT number for unknown state.';
                }
                field("Def. Country/Region Code"; Rec."Def. Country/Region Code")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the default receiving country code.';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Data Exch. Def. Code"; Rec."Data Exch. Def. Code")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the data exchange definition code to generate the intrastat file.';
                    Enabled = not Rec."Split Files";
                }
                field("Data Exch. Def. Name"; Rec."Data Exch. Def. Name")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the data exchange definition name to generate the intrastat file.';
                    Enabled = not Rec."Split Files";
                }
                field("Split Files"; Rec."Split Files")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies if Receipts and Shipments shall be reported in two separate files.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Zip Files"; Rec."Zip Files")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies if report file (-s) shall be added to Zip file.';
                }
                field("Data Exch. Def. Code - Receipt"; Rec."Data Exch. Def. Code - Receipt")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for received goods.';
                    Enabled = Rec."Split Files";
                }
                field("Data Exch. Def. Name - Receipt"; Rec."Data Exch. Def. Name - Receipt")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for received goods.';
                    Enabled = Rec."Split Files";
                }
                field("Data Exch. Def. Code - Shpt."; Rec."Data Exch. Def. Code - Shpt.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the data exchange definition code to generate the intrastat file for shipped goods.';
                    Enabled = Rec."Split Files";
                }
                field("Data Exch. Def. Name - Shpt."; Rec."Data Exch. Def. Name - Shpt.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the data exchange definition name to generate the intrastat file for shipped goods.';
                    Enabled = Rec."Split Files";
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Intrastat Nos."; Rec."Intrastat Nos.")
                {
                    ApplicationArea = BasicEU, BasicCH, BasicNO;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to intrastat documents. To see the number series that have been set up in the No. Series table, click the drop-down arrow in the field.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(IntrastatReportChecklist)
            {
                ApplicationArea = BasicEU, BasicCH, BasicNO;
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
                ApplicationArea = BasicEU, BasicNO, BasicCH;
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
}