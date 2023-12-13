// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

page 31139 "VIES Declaration Subform CZL"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    MultipleNewLines = true;
    PageType = ListPart;
    SourceTable = "VIES Declaration Line CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Trade Type"; Rec."Trade Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies trade type for line of VIES declaration.';

                    trigger OnValidate()
                    begin
                        SetControlsEditable();
                    end;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line type (new, correction, or cancellation).';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the country/region code.';
                }
                field("EU Service"; Rec."EU Service")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies, that the trade is service in EU.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies VAT Registration No. of trade partner.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        Customer: Record Customer;
                        Vendor: Record Vendor;
                        CustomerList: Page "Customer List";
                        VendorList: Page "Vendor List";
                    begin
                        case Rec."Trade Type" of
                            Rec."Trade Type"::Sales:
                                begin
                                    Clear(CustomerList);
                                    CustomerList.LookupMode(true);
                                    Customer.SetCurrentKey("Country/Region Code");
                                    Customer.SetRange("Country/Region Code", Rec."Country/Region Code");
                                    CustomerList.SetTableView(Customer);
                                    if CustomerList.RunModal() = Action::LookupOK then begin
                                        CustomerList.GetRecord(Customer);
                                        Customer.TestField("VAT Registration No.");
                                        Rec.Validate("Country/Region Code", Customer."Country/Region Code");
                                        Rec.Validate("VAT Registration No.", Customer."VAT Registration No.");
                                    end;
                                end;
                            Rec."Trade Type"::Purchase:
                                begin
                                    Clear(VendorList);
                                    Vendor.SetCurrentKey("Country/Region Code");
                                    Vendor.SetRange("Country/Region Code", Rec."Country/Region Code");
                                    VendorList.SetTableView(Vendor);
                                    VendorList.LookupMode(true);
                                    if VendorList.RunModal() = Action::LookupOK then begin
                                        VendorList.GetRecord(Vendor);
                                        Vendor.TestField("VAT Registration No.");
                                        Rec.Validate("Country/Region Code", Vendor."Country/Region Code");
                                        Rec.Validate("VAT Registration No.", Vendor."VAT Registration No.");
                                    end;
                                end;
                        end;
                    end;
                }
                field("Number of Supplies"; Rec."Number of Supplies")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = NumberOfSuppliesEditable;
                    ToolTip = 'Specifies number of partner supplies for selected period.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    Editable = AmountLCYEditable;
                    ToolTip = 'Specifies total amounts of partner trades for selected period.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownAmountLCY();
                    end;

                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field("Trade Role Type"; Rec."Trade Role Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = TradeRoleTypeEditable;
                    ToolTip = 'Specifies for declaration line type of trade.';
                }
                field("Record Code"; Rec."Record Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies type of call-off stock trade.';

                    trigger OnValidate()
                    begin
                        SetControlsEditable();
                    end;
                }
                field("VAT Reg. No. of Original Cust."; Rec."VAT Reg. No. of Original Cust.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = VATRegNoOfOriginalCustEditable;
                    ToolTip = 'Specifies VAT Registration No. of original supposed customer for call-off stock items.';
                }
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        SetControlsEditable();
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CurrPage.Update();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        if VIESDeclarationHeaderCZL.Get(Rec."VIES Declaration No.") then
            Rec."Trade Type" := VIESDeclarationHeaderCZL."Trade Type";
    end;

    var
        NumberOfSuppliesEditable: Boolean;
        AmountLCYEditable: Boolean;
        TradeRoleTypeEditable: Boolean;
        VATRegNoOfOriginalCustEditable: Boolean;

    procedure SetControlsEditable()
    begin
        NumberOfSuppliesEditable := Rec."Trade Type" <> Rec."Trade Type"::" ";
        AmountLCYEditable := Rec."Trade Type" <> Rec."Trade Type"::" ";
        TradeRoleTypeEditable := Rec."Trade Type" <> Rec."Trade Type"::" ";
        VATRegNoOfOriginalCustEditable := Rec."Record Code" = Rec."Record Code"::"3";
    end;
}
