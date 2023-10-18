// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.Dimension;
using Microsoft.Purchases.Document;

page 18492 "Subcontracting Order List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Subcontracting Orders';
    CardPageID = "Subcontracting Order";
    DataCaptionFields = "Document Type";
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Purchase Header";
    SourceTableView = sorting("Document Type", "No.")
                      order(Ascending)
                      where(Subcontracting = filter(true));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number.';
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("Order Address Code"; Rec."Order Address Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the order address used in the document.';
                    Visible = false;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the vendor.';
                }
                field("Vendor Authorization No."; Rec."Vendor Authorization No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the authorization number given by the vendor, if any.';
                }
                field("Buy-from Post Code"; Rec."Buy-from Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the post code of the vendor.';
                    Visible = false;
                }
                field("Buy-from Country/Region Code"; Rec."Buy-from Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the vendor.';

                    Visible = false;
                }
                field("Buy-from Contact"; Rec."Buy-from Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contact number of the vendor.';
                    Visible = false;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the pay to vendor code.';
                    Visible = false;
                }
                field("Pay-to Name"; Rec."Pay-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the pay to vendor name.';
                    Visible = false;
                }
                field("Pay-to Post Code"; Rec."Pay-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the pay to vendor postal code.';
                    Visible = false;
                }
                field("Pay-to Country/Region Code"; Rec."Pay-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the pay to vendor.';
                    Visible = false;
                }
                field("Pay-to Contact"; Rec."Pay-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the pay to contact code of the pay to vendor';
                    Visible = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to code used for the document.';
                    Visible = false;
                }
                field("Ship-to Name"; Rec."Ship-to Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to name.';
                    Visible = false;
                }

                field("Ship-to Post Code"; Rec."Ship-to Post Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to post code.';
                    Visible = false;
                }
                field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code of the ship to code.';
                    Visible = false;
                }
                field("Ship-to Contact"; Rec."Ship-to Contact")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ship to contact.';
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension 1 code';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimMgt.LookupDimValueCodeNoUpdate(1);
                    end;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension 2 code';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        DimMgt.LookupDimValueCodeNoUpdate(2);
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company location code.';
                    Visible = true;
                }
                field("Purchaser Code"; Rec."Purchaser Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assigned purchaser from the organization.';
                    Visible = false;
                }
                field("Assigned User ID"; Rec."Assigned User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user id assigned to the document.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code used in the document.';
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Card)
                {
                    Caption = 'Card';
                    ToolTip = 'Card';
                    Image = EditLines;
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = Basic, Suite;

                    trigger OnAction()
                    begin
                        case Rec."Document Type" of
                            Rec."Document Type"::Quote:
                                Page.Run(Page::"Purchase Quote", Rec);

                            Rec."Document Type"::"Blanket Order":
                                Page.Run(Page::"Blanket Purchase Order", Rec);

                            Rec."Document Type"::Order:
                                if not Rec.Subcontracting then
                                    Page.Run(Page::"Purchase Order", Rec)
                                else
                                    Page.Run(Page::"Subcontracting Order", Rec);

                            Rec."Document Type"::Invoice:
                                Page.Run(Page::"Purchase Invoice", Rec);

                            Rec."Document Type"::"Return Order":
                                Page.Run(Page::"Purchase Return Order", Rec);

                            Rec."Document Type"::"Credit Memo":
                                Page.Run(Page::"Purchase Credit Memo", Rec);
                        end;
                    end;
                }
            }
        }
    }

    var
        DimMgt: Codeunit DimensionManagement;
}
