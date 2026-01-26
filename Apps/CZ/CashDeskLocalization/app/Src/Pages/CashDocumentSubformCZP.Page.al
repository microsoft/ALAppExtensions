// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance.AllocationAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Foundation.ExtendedText;

page 31161 "Cash Document Subform CZP"
{
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Cash Document Line CZP";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Cash Desk Event"; Rec."Cash Desk Event")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the cash desk event in the cash document lines.';

                    trigger OnValidate()
                    begin
                        InsertExtendedText(false);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        CashDeskEventCZP: Record "Cash Desk Event CZP";
                        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
                    begin
                        Rec.TestField("Cash Desk No.");
                        Rec.TestField("Cash Document No.");

                        CashDocumentHeaderCZP.Get(Rec."Cash Desk No.", Rec."Cash Document No.");
                        CashDeskEventCZP.FilterGroup(2);
                        CashDeskEventCZP.SetFilter("Document Type", '%1|%2', CashDocumentHeaderCZP."Document Type"::" ", CashDocumentHeaderCZP."Document Type");
                        CashDeskEventCZP.SetFilter("Cash Desk No.", '%1|%2', '', CashDocumentHeaderCZP."Cash Desk No.");
                        CashDeskEventCZP.FilterGroup(0);
                        CashDeskEventCZP.Code := Rec."Cash Desk Event";
                        if Page.RunModal(0, CashDeskEventCZP) = Action::LookupOK then begin
                            Rec.Validate("Cash Desk Event", CashDeskEventCZP.Code);
                            InsertExtendedText(false);
                        end;
                    end;
                }
                field("Gen. Document Type"; Rec."Gen. Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash desk general document type is payment or refund.';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number that the vendor uses on the invoice they sent to you or number of receipt.';
                    Visible = false;
                }
                field("Account Type"; Rec."Account Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type of account thet the entry will be posted to. To see the options, choose the field.';

                    trigger OnValidate()
                    begin
                        CurrPage.SaveRecord();
                    end;
                }
                field("Account No."; Rec."Account No.")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = (Rec."Account Type" <> Rec."Account Type"::" ") and (Rec."Account No." <> '');
                    ToolTip = 'Specifies the number of the account that the entry on the journal line will be posted to.';

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                        InsertExtendedText(false);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the payment order line.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the another line for description if description is longer.';
                    Visible = false;
                }
                field("Gen. Posting Type"; Rec."Gen. Posting Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the general posting type is purchase (Purchase) or sale (Sale).';
                    Visible = false;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a VAT business posting group code.';
                    Visible = false;
                }
                field("VAT Prod. Posting Group"; Rec."VAT Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a VAT product posting group code for the VAT Statement.';
                    Visible = false;
                }
                field("Allocation Account No."; Rec."Selected Alloc. Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the allocation account number that will be used to distribute the amounts during the posting process.';
                    Visible = UseAllocationAccountNumber;

                    trigger OnValidate()
                    var
                        CashDocAllocAccMgtCZP: Codeunit "Cash Doc. Alloc. Acc. Mgt. CZP";
                    begin
                        CashDocAllocAccMgtCZP.VerifySelectedAllocationAccountNo(Rec);
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ShowMandatory = (Rec."Account Type" <> Rec."Account Type"::" ") and (Rec."Account No." <> '');
                    ToolTip = 'Specifies the total amount that the cash document line consists of.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the amount in the cash document line.';
                    Visible = false;
                }
                field("VAT Base Amount"; Rec."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the total VAT base amount for lines. The program calculates this amount from the sum of line VAT base amount fields.';
                }
                field("VAT Amount"; Rec."VAT Amount")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies the VAT amount for cash desk document line.';
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    BlankZero = true;
                    ToolTip = 'Specifies whether the unit price on the line should be displayed including or excluding VAT.';
                }
                field(RelatedAmountToApplyField; RelatedAmountToApply)
                {
                    Caption = 'Related Amount to Apply (LCY)';
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                    ToolTip = 'Specifies the total Amount (LCY) related suggestions to apply.';
                    BlankZero = true;
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownRelatedAmountToApply();
                    end;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 1, which is defined in the Shortcut Dimension 1 Code field in the General Ledger Setup window.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code of the Shortcut Dimension 2, which is defined in the Shortcut Dimension 2 Code field in the General Ledger Setup window.';
                    Visible = DimVisible2;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 3 of line';
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 4 of line';
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 5 of line';
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 6 of line';
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 7 of line';
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    ToolTip = 'Specifies shortcut dimension code No. 8 of line';
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Salespers./Purch. Code"; Rec."Salespers./Purch. Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which salesperson is assigned to the cash document line.';
                }
                field("Posting Group"; Rec."Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting group that will be used in posting the journal line.The field is used only if the account type is either customer or vendor.';
                    Visible = false;
                }
                field("Applies-To Doc. Type"; Rec."Applies-To Doc. Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the payment will be applied to an already-posted document. The field is used only if the account type is a customer or vendor account.';
                }
                field("Applies-To Doc. No."; Rec."Applies-To Doc. No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the cash document line will be applied to an already-posted document.';
                }
                field("Applies-to ID"; Rec."Applies-to ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the ID to apply to the general ledger entry.';
                    Visible = false;
                }
                field("EET Transaction"; Rec."EET Transaction")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies that the value of Yes will automatically be filled when the row meets the conditions for a recorded sale.';
                    Visible = false;
                }
                field("Depreciation Book Code"; Rec."Depreciation Book Code")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies the code for the depreciation book to which the line will be posted if you have selected Fixed Asset in the Type field for this line.';
                    Visible = false;
                }
                field("FA Posting Type"; Rec."FA Posting Type")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies if the cash document line amount represents a acquisition cost (Acquisition Cost) or a custom 2 (Custom 2) or a maintenance (Maintenance) of Fixed Asset.';
                    Visible = false;
                }
                field("Duplicate in Depreciation Book"; Rec."Duplicate in Depreciation Book")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies if you have selected Fixed Asset in the Account Type field for this line.';
                    Visible = false;
                }
                field("Use Duplication List"; Rec."Use Duplication List")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies if you have selected Fixed Asset in the Account Type field for this line.';
                    Visible = false;
                }
                field("Maintenance Code"; Rec."Maintenance Code")
                {
                    ApplicationArea = FixedAssets;
                    ToolTip = 'Specifies a maintenance code.';
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the reason code on the entry.';
                    Visible = false;
                }
                field("Project No."; Rec."Project No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related project.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Project Task No."; Rec."Project Task No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related project task.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        if Rec.ProjectTaskIsSet() then
                            Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Project Planning Line No."; Rec."Project Planning Line No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the project planning line number that the usage should be linked to when the project journal is posted. You can only link to project planning lines that have the Apply Usage Link option enabled.';
                    Visible = false;
                }
                field("Project Line Type"; Rec."Project Line Type")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the type of planning line to create when a project ledger entry is posted. If the field is empty, no planning lines are created.';
                    Visible = false;
                }
                field("Project Quantity"; Rec."Project Quantity")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the quantity of the project line.';
                    Visible = false;
                }
                field("Project Unit Price"; Rec."Project Unit Price")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the unit price of the project line.';
                    Visible = false;
                }
            }
            group(Control2)
            {
                ShowCaption = false;
                field(VATBaseAmount; TotalCashDocumentHeaderCZP."VAT Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = TotalCashDocumentHeaderCZP."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = CashDocumentTotalsCZP.GetTotalExclVATCaption(TotalCashDocumentHeaderCZP."Currency Code");
                    Caption = 'Total Amount Excl. VAT';
                    Editable = false;
                    ToolTip = 'Specifies the total amout excl. VAT.';
                }
                field(VATAmount; VATAmount)
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = TotalCashDocumentHeaderCZP."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = CashDocumentTotalsCZP.GetTotalVATCaption(TotalCashDocumentHeaderCZP."Currency Code");
                    Caption = 'Total VAT';
                    Editable = false;
                    ToolTip = 'Specifies the total amout of VAT.';
                }
                field(AmountIncludingVAT; TotalCashDocumentHeaderCZP."Amount Including VAT")
                {
                    ApplicationArea = Basic, Suite;
                    AutoFormatExpression = TotalCashDocumentHeaderCZP."Currency Code";
                    AutoFormatType = 1;
                    CaptionClass = CashDocumentTotalsCZP.GetTotalInclVATCaption(TotalCashDocumentHeaderCZP."Currency Code");
                    Caption = 'Total Amount Incl. VAT';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total amout incl. VAT.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                Caption = 'Line';
                Image = Line;
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit the dimension sets that are set up for the cash document.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
            }
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Apply Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Apply Entries';
                    Image = ApplyEntries;
                    ShortCutKey = 'Shift+F11';
                    ToolTip = 'The function allows to apply customer''s or vendor''s entries.';

                    trigger OnAction()
                    begin
                        Rec.ApplyEntries();
                    end;
                }
                action("Insert Ext. Texts CZP")
                {
                    AccessByPermission = TableData "Extended Text Header" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Insert &Ext. Texts';
                    Image = Text;
                    ToolTip = 'Insert the extended item description that is set up for the item that is being processed on the line.';

                    trigger OnAction()
                    begin
                        InsertExtendedText(true);
                    end;
                }
            }
            group("Related Information")
            {
                Caption = 'Related Information';
                action(RedistributeAccAllocations)
                {
                    ApplicationArea = All;
                    Caption = 'Redistribute Account Allocations';
                    Image = EditList;
#pragma warning disable AA0219
                    ToolTip = 'Use this action to redistribute the account allocations for this line.';
#pragma warning restore AA0219

                    trigger OnAction()
                    var
                        AllocAccManualOverride: Page "Redistribute Acc. Allocations";
                    begin
                        if ((Rec."Account Type" <> Rec."Account Type"::"Allocation Account") and (Rec."Selected Alloc. Account No." = '')) then
                            Error(ActionOnlyAllowedForAllocationAccountsErr);

                        AllocAccManualOverride.SetParentSystemId(Rec.SystemId);
                        AllocAccManualOverride.SetParentTableId(Database::"Cash Document Line CZP");
                        AllocAccManualOverride.RunModal();
                    end;
                }
                action(ReplaceAllocationAccountWithLines)
                {
                    ApplicationArea = All;
                    Caption = 'Generate lines from Allocation Account Line';
                    Image = CreateLinesFromJob;
#pragma warning disable AA0219
                    ToolTip = 'Use this action to replace the Allocation Account line with the actual lines that would be generated from the line itself.';
#pragma warning restore AA0219

                    trigger OnAction()
                    var
                        CashDocAllocAccMgtCZP: Codeunit "Cash Doc. Alloc. Acc. Mgt. CZP";
                    begin
                        if ((Rec."Account Type" <> Rec."Account Type"::"Allocation Account") and (Rec."Selected Alloc. Account No." = '')) then
                            Error(ActionOnlyAllowedForAllocationAccountsErr);

                        CashDocAllocAccMgtCZP.CreateLinesFromAllocationAccountLine(Rec);
                        Rec.Delete();
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        CashDocumentTotalsCZP.CalculateCashDocumentTotals(TotalCashDocumentHeaderCZP, VATAmount, Rec);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
        RelatedAmountToApply := Rec.CalcRelatedAmountToApply();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    begin
        UseAllocationAccountNumber := AllocationAccountMgt.UseAllocationAccountNoField();
        SetDimensionsVisibility();
    end;

    var
        TotalCashDocumentHeaderCZP: Record "Cash Document Header CZP";
        AllocationAccountMgt: Codeunit "Allocation Account Mgt.";
        CashDocumentTotalsCZP: Codeunit "Cash Document Totals CZP";
#if not CLEAN26
        AccountTypeIsFilled: Boolean;
#endif
        VATAmount: Decimal;
        RelatedAmountToApply: Decimal;
        ActionOnlyAllowedForAllocationAccountsErr: Label 'This action is only available for lines that have Allocation Account set as Type.';

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;
        UseAllocationAccountNumber: Boolean;
#if not CLEAN27
    [Obsolete('The statistics action will be replaced with the CashDocumentStatistics action. The new action uses RunObject and does not run the action trigger. Use a page extension to modify the behaviour.', '27.0')]
    procedure ShowStatistics()
    begin
        Rec.ExtStatistics();
    end;
#endif

    procedure UpdatePage(SetSaveRecord: Boolean)
    begin
        CurrPage.Update(SetSaveRecord);
    end;

#if not CLEAN26
    [Obsolete('The procedure is not used and will be obsoleted', '26.0')]
    procedure SetShowMandatoryConditions()
    begin
        AccountTypeIsFilled := Rec."Account Type" <> Rec."Account Type"::" ";
    end;
#endif
    procedure InsertExtendedText(Unconditionally: Boolean)
    var
        TransferExtendedTextCZP: Codeunit "Transfer Extended Text CZP";
    begin
        OnBeforeInsertExtendedText(Rec);
        if TransferExtendedTextCZP.CashDeskCheckIfAnyExtText(Rec, Unconditionally) then begin
            CurrPage.SaveRecord();
            Commit();
            TransferExtendedTextCZP.InsertCashDeskExtText(Rec);
        end;
        OnInsertExtendedTextOnAfterInsertCashDeskExtText(Rec);

        if TransferExtendedTextCZP.MakeUpdate() then
            CurrPage.Update(true);
    end;

    local procedure SetDimensionsVisibility()
    var
        DimensionManagement: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;
        DimensionManagement.UseShortcutDims(DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);
        Clear(DimensionManagement);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertExtendedText(var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnInsertExtendedTextOnAfterInsertCashDeskExtText(CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
    end;
}
