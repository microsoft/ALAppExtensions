// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GST.Purchase;
using Microsoft.Finance.TaxBase;
using Microsoft.Foundation.ExtendedText;
using Microsoft.Foundation.Navigate;
using Microsoft.Inventory.Item.Catalog;
using Microsoft.Purchases.Document;
#if not CLEAN25
using Microsoft.Purchases.Pricing;
#endif
using Microsoft.Sales.Document;

page 18493 "Subcontracting Order Subform"
{

    AutoSplitKey = true;
    Caption = 'Subcontracting Order Subform';
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "Purchase Line";
    SourceTableView = where("Document Type" = filter(Order), Subcontracting = const(true));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type of this document.';
                    trigger OnValidate()
                    begin
                        FormatLine();
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number of this line.';

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        NoOnAfterValidate();
                        FormatLine();
                    end;
                }
                field("Item Reference No."; Rec."Item Reference No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item reference number is linked with this line.';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchaseHeader: Record "Purchase Header";
                        ItemReferenceMgt: Codeunit "Item Reference Management";
                    begin
                        PurchaseHeader.Get("Document Type", "Document No.");
                        ItemReferenceMgt.PurchaseReferenceNoLookUp(Rec, PurchaseHeader);
                        InsertExtendedText(false);
                    end;

                    trigger OnValidate()
                    begin
                        ItemReferenceNoOnAfterValidate();
                    end;
                }
                field("IC Partner Code"; Rec."IC Partner Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the IC partner code this order is linked to.';
                    Visible = false;
                }
                field("IC Partner Ref. Type"; Rec."IC Partner Ref. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the IC partner reference number this order is linked to.';
                    Visible = false;
                }
                field("IC Partner Reference"; Rec."IC Partner Reference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the IC pPartner reference this order is linked to.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variant code of the item of this line.';
                    Visible = false;
                }
                field(Nonstock; Rec.Nonstock)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the item of this line is non stock item';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT product posting group of the item this order is linked to.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of this line.';
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the if drop shipment is applicable in this line.';
                    Visible = false;
                }
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the return reason code this order is linked to.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location code of this document.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the bin code of this document.';
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of this line.';
                    BlankZero = true;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reserved quantity of this line.';
                    BlankZero = true;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure code of the item of this line.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of the item of this line.';
                    Visible = false;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the direct unit cost of this line.';
                    BlankZero = true;
                }
                field("Indirect Cost %"; Rec."Indirect Cost %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the indirect unit cost % of this line.';
                    Visible = false;
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit cost (LCY) of this line.';
                    Visible = false;
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit price (LCY) of this line.';
                    BlankZero = true;
                    Visible = false;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line amount of this line.';
                    BlankZero = true;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the tax group code of this line.';
                    Visible = false;
                }

                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line discount % of this line.';
                    BlankZero = true;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line discount amount of this line.';
                    Visible = false;
                }
                field("Prepayment %"; Rec."Prepayment %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the prepayment % of this line.';
                    Visible = false;
                }
                field("Prepmt. Amt. Inv."; Rec."Prepmt. Amt. Inv.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if this is prepayment amount invoice line.';
                    Visible = false;
                }
                field("Allow Invoice Disc."; Rec."Allow Invoice Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if invoice discount is allowed in this line.';
                    Visible = false;
                }
                field("Inv. Discount Amount"; Rec."Inv. Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the invoice discount amount of this line.';
                    Visible = false;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be received.';
                    BlankZero = true;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity received.';
                    BlankZero = true;
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be invoiced.';
                    BlankZero = true;
                }
                field("Quantity Invoiced"; Rec."Quantity Invoiced")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity invoiced.';
                    BlankZero = true;
                }
                field("Prepmt Amt to Deduct"; Rec."Prepmt Amt to Deduct")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the prepayment amount needs to be deducted.';
                    Visible = false;
                }
                field("Prepmt Amt Deducted"; Rec."Prepmt Amt Deducted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the prepayment amount deducted.';
                    Visible = false;
                }
                field("Allow Item Charge Assignment"; Rec."Allow Item Charge Assignment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if item charge assignment is allowed.';
                    Visible = false;
                }
                field("Qty. to Assign"; Rec."Qty. to Assign")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity that needs to be assigned.';
                    BlankZero = true;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.ShowItemChargeAssgnt();
                        UpdateForm(false);
                    end;
                }
                field("Qty. Assigned"; Rec."Qty. Assigned")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity assigned.';
                    BlankZero = true;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord();
                        Rec.ShowItemChargeAssgnt();
                        UpdateForm(false);
                    end;
                }
                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job number this order is linked to.';
                    Visible = false;

                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job task number this order is linked to.';
                    Visible = false;
                }
                field("Job Line Type"; Rec."Job Line Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job line type this order is linked to.';
                    Visible = false;
                }
                field("Job Unit Price"; Rec."Job Unit Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job unit price of this order.';
                    Visible = false;
                }
                field("Job Line Amount"; Rec."Job Line Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job line amount of this order.';
                    Visible = false;
                }
                field("Job Line Discount Amount"; Rec."Job Line Discount Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job line discount amount of this order.';
                    Visible = false;
                }
                field("Job Line Discount %"; Rec."Job Line Discount %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job line discount % of this order.';
                    Visible = false;
                }
                field("Job Total Price"; Rec."Job Total Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job total price of this order.';
                    Visible = false;
                }
                field("Job Unit Price (LCY)"; Rec."Job Unit Price (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job unit price (LCY) of this order.';
                    Visible = false;
                }
                field("Job Total Price (LCY)"; Rec."Job Total Price (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job total price (LCY) of this order.';
                    Visible = false;
                }
                field("Job Line Amount (LCY)"; Rec."Job Line Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job line amount (LCY) of this order.';
                    Visible = false;
                }
                field("Job Line Disc. Amount (LCY)"; Rec."Job Line Disc. Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the job line discount amount (LCY) of this order.';
                    Visible = false;
                }
                field("Requested Receipt Date"; Rec."Requested Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the requested receipt date of this order.';
                    Visible = false;
                }
                field("Promised Receipt Date"; Rec."Promised Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the promised receipt date of this order.';
                    Visible = false;
                }
                field("Planned Receipt Date"; Rec."Planned Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the planned receipt date of this order.';
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the expected receipt date of this order.';
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order date of this order.';
                }
                field("Lead Time Calculation"; Rec."Lead Time Calculation")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the lead time calculation of this order.';
                    Visible = false;
                }
                field("Planning Flexibility"; Rec."Planning Flexibility")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the planning flexibility of this order.';
                    Visible = false;
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                    Visible = false;
                }
                field("Prod. Order Line No."; Rec."Prod. Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the released production order line number.';
                    Visible = false;
                }
                field("Operation No."; Rec."Operation No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the operation number linked with the subcontracting order.';
                    Visible = false;
                }
                field("Work Center No."; Rec."Work Center No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the work center number linked with the subcontracting order.';
                    Visible = false;
                }
                field(Finished; Rec.Finished)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontrcting order is in finished state.';
                    Visible = false;
                }
                field("Whse. Outstanding Qty. (Base)"; Rec."Whse. Outstanding Qty. (Base)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the warehouse outstanding quantity (Base).';
                    Visible = false;
                }
                field("Inbound Whse. Handling Time"; Rec."Inbound Whse. Handling Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Inbound Warehouse Handling Time.';
                    Visible = false;
                }
                field("Blanket Order No."; Rec."Blanket Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the blanket order number this order is linked to.';
                    Visible = false;
                }
                field("Blanket Order Line No."; Rec."Blanket Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the blanket order line number this order is linked to.';
                    Visible = false;
                }
                field("Appl.-to Item Entry"; Rec."Appl.-to Item Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the apply to item entry this order is linked to.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension 1 code this order is linked to.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension 2 code this order is linked to.';
                    Visible = false;
                }
                field(Subcontracting; Rec.Subcontracting)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order is subcontracting order';
                    Visible = false;
                }
                field(SubConSend; Rec.SubConSend)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order to send to vendor location';
                    Visible = false;
                }
                field("Delivery Challan Posted"; Rec."Delivery Challan Posted")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of delivery challan posted';
                    Visible = false;
                }
                field("Qty. to Reject (Rework)"; Rec."Qty. to Reject (Rework)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity to reject for rework';
                    Visible = false;
                }
                field("Qty. Rejected (Rework)"; Rec."Qty. Rejected (Rework)")
                {
                    ApplicationArea = Basic, suite;
                    ToolTip = 'Specifies the quantity rejected for rework';
                    Visible = false;
                }
                field(SendForRework; Rec.SendForRework)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity send to rework';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the GST posting setup.';

                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the GST posting setup.';
                }
                field("Qty. Rejected (C.E.)"; rec."Qty. Rejected (C.E.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity rejected CE';
                    Visible = false;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsHSNSACEditable;
                    ToolTip = 'Specifies the GST Group code for the calculation of GST on Transaction line.';
                    trigger OnValidate()
                    var
                        CalculateTax: Codeunit "Calculate Tax";
                    begin
                        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                    end;
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = IsHSNSACEditable;
                    ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on Transaction line.';
                    trigger OnValidate()
                    var
                        CalculateTax: Codeunit "Calculate Tax";
                    begin
                        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                    end;
                }
                field("GST Group Type"; Rec."GST Group Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST group is assigned for goods or service.';
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the service is exempted from GST.';

                    trigger OnValidate()
                    var
                        CalculateTax: Codeunit "Calculate Tax";
                    begin
                        CurrPage.SaveRecord();
                        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                    end;
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST Credit has to be availed or not.';

                    trigger OnValidate()
                    var
                        CalculateTax: Codeunit "Calculate Tax";
                    begin
                        CurrPage.SaveRecord();
                        CalculateTax.CallTaxEngineOnPurchaseLine(Rec, xRec);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Calculate &Invoice Discount")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Calculate &Invoice Discount';
                    ToolTip = 'Calculate Invoice Discount';
                    Image = CalculateInvoiceDiscount;

                    trigger OnAction()
                    begin
                        ApproveCalcInvDisc();
                    end;
                }
                action("E&xplode BOM")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'E&xplode BOM';
                    ToolTip = 'Explode BOM';
                    Image = ExplodeBOM;

                    trigger OnAction()
                    begin
                        ExplodeBOM();
                    end;
                }
                action("Insert &Ext. Texts")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insert &Ext. Texts';
                    ToolTip = 'Insert Extensed Tests';
                    Image = Text;

                    trigger OnAction()
                    begin
                        InsertExtendedText(true);
                    end;
                }
                group(DropShipment)
                {

                    Caption = 'Drop Shipment';
                    Image = Delivery;
                    action("Sales Order")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales &Order';
                        ToolTip = 'Sales Order';
                        Image = Document;

                        trigger OnAction()
                        begin
                            OpenSalesOrderForm();
                        end;
                    }
                }
                group(SpecialOrder)
                {
                    Caption = 'Special Order';
                    Image = SpecialOrder;
                    action("Sales &Order")
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sales &Order';
                        ToolTip = 'Sales Order';
                        Image = Document;

                        trigger OnAction()
                        begin
                            OpenSpecOrderSalesOrderForm();
                        end;
                    }
                }
                action("&Reserve")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Reserve';
                    ToolTip = 'Reserve';
                    Ellipsis = true;
                    Image = Reserve;

                    trigger OnAction()
                    begin
                        Rec.ShowReservation();
                    end;
                }
                action("Order &Tracking")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Order &Tracking';
                    ToolTip = 'Order Tracking';
                    Image = OrderTracking;

                    trigger OnAction()
                    begin
                        ShowTracking();
                    end;
                }
            }
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                group("Item Availability by")
                {

                    Caption = 'Item Availability by';
                    Image = ItemAvailability;
                    action(Period)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Period';
                        ToolTip = 'Period';
                        Image = Period;

                        trigger OnAction()
                        begin
                            ItemAvailability(0);
                        end;
                    }
                    action(Variant)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Variant';
                        ToolTip = 'Variant';
                        Image = ItemVariant;

                        trigger OnAction()
                        begin
                            ItemAvailability(1);
                        end;
                    }
                    action(Location)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Location';
                        ToolTip = 'Location';
                        Image = Warehouse;

                        trigger OnAction()
                        begin
                            ItemAvailability(2);
                        end;
                    }
                }
                action("Reservation Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;

                    trigger OnAction()
                    begin
                        Rec.ShowReservationEntries(true);
                    end;
                }
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action("Item Charge &Assignment")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item Charge &Assignment';
                    ToolTip = 'Item Charge Assignment';

                    trigger OnAction()
                    begin
                        ItemChargeAssgnt();
                    end;
                }
                action("Item &Tracking Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Item &Tracking Lines';
                    ToolTip = 'Item Tracking Lines';
                    Image = ItemTrackingLines;

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines();
                    end;
                }
                group("Order Subcon. Details")
                {
                    Caption = 'Order Subcon. Details';
                    Image = View;
                    action(Send)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Send';
                        ToolTip = 'Send to Subcontrator';
                        Image = SendTo;

                        trigger OnAction()
                        begin
                            ShowSubOrderDetailsDelForm();
                        end;
                    }
                    action(Receipt)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Receipt';
                        ToolTip = 'Receipt from Subcontractor';
                        Image = Receipt;

                        trigger OnAction()
                        begin
                            ShowSubOrderDetailsReceiptForm();
                            LineAmount := Rec."Line Amount";
                        end;
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if LineAmount <> 0 then begin
            Rec."Line Amount" := LineAmount;
            LineAmount := 0;
        end;
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        UpdateSubcontractDetails: Codeunit "Update Subcontract Details";
    begin
        if (Rec.Quantity <> 0) and Rec.ItemExists(Rec."No.") then begin
            Commit();

            if not ReservePurchLine.DeleteLineConfirm(Rec) then
                exit(false);

            ReservePurchLine.DeleteLine(Rec);
        end;

        UpdateSubcontractDetails.ValidateOrUpdateBeforeSubConOrderLineDelete(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Type := xRec.Type;
        Clear(ShortcutDimCode);
    end;

    var
#if not CLEAN25
        PurchHeader: Record "Purchase Header";
        PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
#endif
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ShortcutDimCode: array[8] of Code[20];
        UpdateAllowedVar: Boolean;
        LineAmount: Decimal;
        ViewModeMsg: Label 'Unable to run this function while in View mode.';

    procedure ApproveCalcInvDisc()
    begin
        Codeunit.Run(Codeunit::"Purch.-Disc. (Yes/No)", Rec);
    end;

    procedure CalcInvDisc()
    begin
        Codeunit.Run(Codeunit::"Purch.-Calc.Discount", Rec);
    end;

    procedure ExplodeBOM()
    begin
        codeunit.Run(Codeunit::"Purch.-Explode BOM", Rec);
    end;

    procedure OpenSalesOrderForm()
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
    begin
        Rec.Testfield("Sales Order No.");
        SalesHeader.SetRange("No.", Rec."Sales Order No.");
        SalesOrder.SetTableView(SalesHeader);
        SalesOrder.Editable := false;
        SalesOrder.Run();
    end;

    procedure InsertExtendedText(Unconditionally: Boolean)
    begin
        if TransferExtendedText.PurchCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord();
            TransferExtendedText.InsertPurchExtText(Rec);
        end;

        if TransferExtendedText.MakeUpdate() then
            UpdateForm(true);
    end;

    procedure ShowReservations()
    begin
        Rec.Find();
        Rec.ShowReservation();
    end;

    procedure ItemAvailability(AvailabilityType: Option Date,Variant,Location,Bin)
    begin
        ItemAvailability(AvailabilityType);
    end;

    procedure ShowTracking()
    var
        OrderTracking: Page "Order Tracking";
    begin
        OrderTracking.SetVariantRec(Rec, Rec."No.", Rec."Outstanding Qty. (Base)", Rec."Expected Receipt Date", Rec."Expected Receipt Date");
        OrderTracking.RunModal();
    end;

    procedure ShowDimension()
    begin
        Rec.ShowDimensions();
    end;

    procedure ItemChargeAssgnt()
    begin
        Rec.ShowItemChargeAssgnt();
    end;

    procedure OpenItemTrackingLine()
    begin
        Rec.OpenItemTrackingLines();
    end;

    procedure OpenSpecOrderSalesOrderForm()
    var
        SalesHeader: Record "Sales Header";
        SalesOrder: Page "Sales Order";
    begin
        Rec.Testfield("Special Order Sales No.");
        SalesHeader.SetRange("No.", Rec."Special Order Sales No.");
        SalesOrder.SetTableView(SalesHeader);
        SalesOrder.Editable := false;
        SalesOrder.Run();
    end;

    procedure UpdateForm(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

    procedure SetUpdateAllowed(UpdateAllowed: Boolean)
    begin
        UpdateAllowedVar := UpdateAllowed;
    end;

    procedure UpdateAllowed(): Boolean
    begin
        if UpdateAllowedVar = false then begin
            Message(ViewModeMsg);
            exit(false);
        end;

        exit(true);
    end;

#if not CLEAN25
#pragma warning disable AS0072
    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '19.0')]
#pragma warning restore AS0072
    procedure ShowPrices()
    begin
        PurchHeader.Get(Rec."Document Type", Rec."Document No.");
        Clear(PurchPriceCalcMgt);
        PurchPriceCalcMgt.GetPurchLinePrice(PurchHeader, Rec);
    end;

#pragma warning disable AS0072
    [Obsolete('Replaced by the new implementation (V16) of price calculation.', '19.0')]
#pragma warning restore AS0072
    procedure ShowLineDisc()
    begin
        PurchHeader.Get(Rec."Document Type", Rec."Document No.");
        Clear(PurchPriceCalcMgt);
        PurchPriceCalcMgt.GetPurchLineLineDisc(PurchHeader, Rec);
    end;
#endif

    procedure ShowLineComment()
    begin
        Rec.ShowLineComments();
    end;

    procedure ShowSubOrderDetailsDelForm()
    var
        PurchaseLine: Record "Purchase Line";
        SubOrderDetailsList: Page "Ord. Subcon Details Delv. List";
    begin

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", Rec."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", Rec."Document No.");
        PurchaseLine.SetRange("No.", Rec."No.");
        PurchaseLine.SetRange("Line No.", Rec."Line No.");
        PurchaseLine.FilterGroup := 2;
        SubOrderDetailsList.SetTableView(PurchaseLine);
        SubOrderDetailsList.RunModal();
    end;

    local procedure NoOnAfterValidate()
    begin
        InsertExtendedText(false);
        if (Rec.Type = Rec.Type::"Charge (Item)") and (Rec."No." <> xRec."No.") and
           (xRec."No." <> '')
        then
            CurrPage.SaveRecord();
    end;

    local procedure ItemReferenceNoOnAfterValidate()
    begin
        InsertExtendedText(false);
    end;

    procedure ShowSubOrderDetailsReceiptForm()
    var
        PurchaseLine: Record "Purchase Line";
        SubOrderDetailsReceiptList: Page "Ord. Subcon Details Rcpt.List";
    begin

        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", Rec."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", Rec."Document No.");
        PurchaseLine.SetRange("No.", Rec."No.");
        PurchaseLine.SetRange("Line No.", Rec."Line No.");
        PurchaseLine.FilterGroup(2);
        SubOrderDetailsReceiptList.SetTableView(PurchaseLine);
        SubOrderDetailsReceiptList.RunModal();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        FormatLine();
    end;

    local procedure FormatLine()
    var
        GSTPurchaseSubscribers: Codeunit "GST Purchase Subscribers";
    begin
        GSTPurchaseSubscribers.SetHSNSACEditable(Rec, IsHSNSACEditable);
    end;

    var
        IsHSNSACEditable: Boolean;
}
