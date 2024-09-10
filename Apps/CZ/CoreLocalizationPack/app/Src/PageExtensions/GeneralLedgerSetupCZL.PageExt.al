// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Setup;

pageextension 11717 "General Ledger Setup CZL" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Mark Neg. Qty as Correct. CZL"; Rec."Mark Neg. Qty as Correct. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to automatically mark postings with negative quantities as corrections. This will set the Correction field to Yes for any lines with negative quantities.';
            }
            field("Check Posting Debit/Credit CZL"; Rec."Check Posting Debit/Credit CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies checking posting debit/credit.';
            }
            field("Do Not Check Dimension CZL"; Rec."Do Not Check Dimensions CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether the system does or does not check the dimension setup by closing operation depending on whether the field is checked.';
            }
            field("Acc. Schedule Results Nos. CZL"; Rec."Acc. Schedule Results Nos. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the number series that will be used to assign numbers to account schedule results.';
            }
        }
        addlast(content)
        {
            group(VatCZL)
            {
                Caption = 'VAT';

                field("Def. Orig. Doc. VAT Date CZL"; Rec."Def. Orig. Doc. VAT Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the default original document VAT date type for purchase document (posting date, document date, VAT date or blank).';
                }
#if not CLEAN24
                field("Allow VAT Posting From CZL"; Rec."Allow VAT Posting From CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Allow VAT Posting From (Obsolete)';
                    ToolTip = 'Specifies the earliest VAT date on which posting to the company is allowed.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '24.0';
                    ObsoleteReason = 'Replaced by "Allow VAT Date From" field from "VAT Setup" table.';
                    Visible = false;
                }
                field("Allow VAT Posting To CZL"; Rec."Allow VAT Posting To CZL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Allow VAT Posting To (Obsolete)';
                    ToolTip = 'Specifies the latest VAT date on which posting to the company is allowed.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '24.0';
                    ObsoleteReason = 'Replaced by "Allow VAT Date To" field from "VAT Setup" table.';
                    Visible = false;
                }
#endif
                field("Allow VAT Date From CZL"; VATSetup."Allow VAT Date From")
                {
                    ApplicationArea = VAT;
                    Caption = 'Allow VAT Date From';
                    ToolTip = 'Specifies the earliest date on which VAT posting to the company books is allowed.';
                    Visible = IsVATDateEnabled;

                    trigger OnValidate()
                    begin
                        VATSetup.Validate("Allow VAT Date From");
                        VATSetup.Modify();
                    end;
                }
                field("Allow VAT Date To CZL"; VATSetup."Allow VAT Date To")
                {
                    ApplicationArea = VAT;
                    Caption = 'Allow VAT Date To';
                    ToolTip = 'Specifies the last date on which VAT posting to the company books is allowed.';
                    Visible = IsVATDateEnabled;

                    trigger OnValidate()
                    begin
                        VATSetup.Validate("Allow VAT Date To");
                        VATSetup.Modify();
                    end;
                }
            }
        }
        addlast(content)
        {
            group("Other CZL")
            {
                Caption = 'Other';

                field("User Checks Allowed CZL"; Rec."User Checks Allowed CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether extended user controls will be activated based on User setup.';
                }
                field("Closed Per. Entry Pos.Date CZL"; Rec."Closed Per. Entry Pos.Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of closed period entries in inventory adjustement';
                }
                field("Rounding Date CZL"; Rec."Rounding Date CZL")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date for the inventory rounding adjustment by inventory adjustement';
                }
            }
        }
        addlast(Reporting)
        {
            field("Shared Account Schedule CZL"; Rec."Shared Account Schedule CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to share the account schedule in general ledger setup.';
            }
        }
        movefirst(VatCZL; "VAT Reporting Date Usage", "Default VAT Reporting Date")
    }
    actions
    {
        addlast("VAT Posting")
        {
            action("Non-Deductible VAT Setup CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Non-Deductible VAT Setup';
                Image = VATPostingSetup;
                RunObject = Page "Non-Deductible VAT Setup CZL";
                ToolTip = 'Set up VAT coefficient correction.';
                Visible = NonDeductibleVATVisible;
            }
        }
    }

    trigger OnOpenPage()
    var
        VATReportingDateMgt: Codeunit "VAT Reporting Date Mgt";
    begin
        IsVATDateEnabled := VATReportingDateMgt.IsVATDateEnabled();
        NonDeductibleVATVisible := NonDeductibleVATCZL.IsNonDeductibleVATEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        VATSetup.Get();
    end;

    var
        VATSetup: Record "VAT Setup";
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
        IsVATDateEnabled: Boolean;
        NonDeductibleVATVisible: Boolean;
}
