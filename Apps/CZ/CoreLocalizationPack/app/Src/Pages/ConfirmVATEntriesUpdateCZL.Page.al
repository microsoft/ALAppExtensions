// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;

page 31214 "Confirm VAT Entries Update CZL"
{
    Caption = 'Confirm VAT Entries Update';
    PageType = ConfirmationDialog;
    InstructionalText = 'An action is requested regarding the VAT Entry update.';
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;
    SourceTable = "VAT Entry";

    layout
    {
        area(Content)
        {
            label(ConfirmQuestion)
            {
                ApplicationArea = Basic, Suite;
                CaptionClass = Format(UpdateVATEntriesQst);
                MultiLine = true;
                ShowCaption = false;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved customer or vendor to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT specification of the involved item or resource to link transactions made for this record with the appropriate general ledger account according to the VAT posting setup.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT entry''s posting date.';
                }
                field("VAT Reporting Date"; Rec."VAT Reporting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT date on the VAT entry. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
#if not CLEAN22
                    Visible = ReplaceVATDateEnabled and VATDateEnabled;
#else
                    Visible = VATDateEnabled;
#endif
                }
#if not CLEAN22
#pragma warning disable AS0072
                field("VAT Date CZL"; Rec."VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'VAT Date (Obsolete)';
                    ToolTip = 'Specifies the VAT date on the VAT entry. This is either the date that the document was created or posted, depending on your setting on the General Ledger Setup page.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '22.0';
                    ObsoleteReason = 'Replaced by VAT Reporting Date.';
                    Visible = not ReplaceVATDateEnabled;
                }
#pragma warning restore AS0072
#endif
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number on the VAT entry.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document type that the VAT entry belongs to.';
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
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the VAT entry has been closed by the Calc. and Post VAT Settlement batch job.';
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
#pragma warning restore AL0432
        ReplaceVATDateEnabled: Boolean;
#endif
        VATDateEnabled: Boolean;
        UpdateVATEntriesQst: Label 'The following VAT Entries will be updated as well. Do you want to continue?';

    procedure Set(var TempVATEntry: Record "VAT Entry" temporary)
    begin
        if TempVATEntry.FindSet() then
            repeat
                Rec := TempVATEntry;
                Rec.Insert();
            until TempVATEntry.Next() = 0;
    end;
}
