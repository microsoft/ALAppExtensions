// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Preview;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

page 31192 "Preview Adv. VAT Entries CZZ"
{
    Caption = 'Preview Advance VAT Entries';
    Editable = false;
    PageType = List;
    SourceTable = "VAT Entry";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                    QuickEntry = true;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT entry''s posting date.';
                }
                field("VAT Reporting Date CZL"; Rec."VAT Reporting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date used to include entries on VAT reports in a VAT period. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
#if not CLEAN22
                    Visible = ReplaceVATDateEnabled and VATDateEnabled;
#else
                    Visible = VATDateEnabled;
#endif
                }
#if not CLEAN22
                field("VAT Date CZL"; Rec."VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Date (Obsolete)';
                    ToolTip = 'Specifies the VAT entry''s VAT date.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by VAT Reporting Date.';
                    Visible = not ReplaceVATDateEnabled;
                }
#endif
                field("Original Doc. VAT Date CZL"; Rec."Original Doc. VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT entry''s Original Document VAT Date.';
                    Visible = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the external document number on the VAT entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the VAT entry belongs to.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of the VAT entry.';
                    Visible = false;
                }
                field(Base; Rec.Base)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that the VAT amount (the amount shown in the Amount field) is calculated from.';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount of the VAT entry in LCY.';
                }
                field("VAT Difference"; Rec."VAT Difference")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the difference between the calculated VAT amount and a VAT amount that you have entered manually.';
                    Visible = false;
                }
                field("VAT Calculation Type"; Rec."VAT Calculation Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how VAT will be calculated for purchases or sales of items with this particular combination of VAT business posting group and VAT product posting group.';
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the bill-to customer or pay-to vendor that the entry is linked to.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT registration number of the customer or vendor that the entry is linked to.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region of the address.';
                }
                field("EU 3-Party Trade"; Rec."EU 3-Party Trade")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the transaction is related to trade with a third party within the EU.';
                }
            }
            group(TotalVAT)
            {
                Caption = 'Total VAT';
                field(TotalVATBase; TotalVATBase)
                {
                    Caption = 'Total VAT Base';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies total VAT Base in local currency after posting document.';
                }
                field(TotalVATAmount; TotalVATAmount)
                {
                    Caption = 'Total VAT Amount';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies total VAT Amount in local currency after posting document.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        VATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
#if not CLEAN22
        ReplaceVATDateEnabled := ReplaceVATDateMgtCZL.IsEnabled();
#endif
    end;

    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
#if not CLEAN22
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
        ReplaceVATDateEnabled: Boolean;
#pragma warning restore AL0432
#endif
        VATDateEnabled: Boolean;
        TotalVATBase, TotalVATAmount : Decimal;

    procedure Set(var PostingPreviewEventHandler: Codeunit "Posting Preview Event Handler")
    var
        VATEntryRecordRef: RecordRef;
    begin
        Clear(TotalVATBase);
        Clear(TotalVATAmount);

        PostingPreviewEventHandler.GetEntries(Database::"VAT Entry", VATEntryRecordRef);
        if VATEntryRecordRef.FindSet() then
            repeat
                VATEntryRecordRef.SetTable(Rec);
                Rec.Insert();
                TotalVATBase += Rec.Base;
                TotalVATAmount += Rec.Amount;
            until VATEntryRecordRef.Next() = 0;
    end;
}
