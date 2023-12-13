// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31116 "VAT Ctrl. Report Lines CZL"
{
    Caption = 'VAT Control Report Lines';
    Editable = false;
    LinksAllowed = false;
    PageType = List;
    SourceTable = "VAT Ctrl. Report Line CZL";
    ApplicationArea = VAT;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("VAT Ctrl. Report No."; Rec."VAT Ctrl. Report No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies .';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies .';
                }
                field("VAT Ctrl. Report Section Code"; Rec."VAT Ctrl. Report Section Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies section code for VAT Control Report.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the customer or vendor entry''s posting date.';
                }
                field("VAT Date"; Rec."VAT Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT date. This date must be shown on the VAT statement.';
                }
                field("Original Document VAT Date"; Rec."Original Document VAT Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT date of the original document.';
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the partner''s number (customer or vendor).';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT registration number. The field will be used when you do business with partners from EU countries/regions.';
                }
                field("Registration No."; Rec."Registration No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the registration number of customer or vendor.';
                }
                field("Tax Registration No."; Rec."Tax Registration No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the secondary VAT registration number for the partner.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the document number of sales or purchase.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the type of user setup lines list';
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a VAT business posting group code.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies a VAT product posting group code for the VAT Statement.';
                }
                field(Base; Rec.Base)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT base of document.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the VAT amount of document.';
                }
                field("VAT Rate"; Rec."VAT Rate")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies typ of VAT rate - base, reduced or reduced 2.';
                }
                field("Commodity Code"; Rec."Commodity Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies code from reverse charge.';
                }
                field("Supplies Mode Code"; Rec."Supplies Mode Code")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies supplies mode code from VAT layer.';
                }
                field("Corrections for Bad Receivable"; Rec."Corrections for Bad Receivable")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies whether the receivable is in insolvency proceedings or bad receivable.';
                }
                field("Ratio Use"; Rec."Ratio Use")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the document which the ratio use was used in.';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the customer''s name.';
                }
                field("Birth Date"; Rec."Birth Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the customer''s birth date in the cases you sale investment gold.';
                }
                field("Place of Stay"; Rec."Place of Stay")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the customer''s address in the cases you sale investment gold.';
                }
                field("Exclude from Export"; Rec."Exclude from Export")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies if the line should be excluded from export.';
                }
                field("Closed by Document No."; Rec."Closed by Document No.")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the document number whitch the document was closed.';
                }
                field("Closed Date"; Rec."Closed Date")
                {
                    ApplicationArea = VAT;
                    ToolTip = 'Specifies the document date of the document that was closed.';
                }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action("Show Document")
            {
                ApplicationArea = VAT;
                Caption = 'Show Document';
                Image = View;
                ShortcutKey = 'Shift+F7';
                ToolTip = 'Shows related VAT Control Report.';

                trigger OnAction()
                var
                    VATCtrlReportHeaderCZL: Record "VAT Ctrl. Report Header CZL";
                begin
                    VATCtrlReportHeaderCZL.Get(Rec."VAT Ctrl. Report No.");
                    VATCtrlReportHeaderCZL.SetRecFilter();
                    Page.RunModal(Page::"VAT Ctrl. Report Card CZL", VATCtrlReportHeaderCZL);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Show Document_Promoted"; "Show Document")
                {
                }
            }
        }
    }
}
