// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument;

page 5579 "Digital Voucher Entry Setup"
{
    PageType = List;
    SourceTable = "Digital Voucher Entry Setup";
    AboutTitle = 'About setup of digital vouchers for each entry type';
    AboutText = 'Here you can select the line with a certain entry type and setup the type of the digital voucher''s check you want to perform.';
    ApplicationArea = Basic, Suite;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Type"; Rec."Entry Type")
                {
                    ToolTip = 'Specifies the entry type.';
                }
                field("Check Type"; Rec."Check Type")
                {
                    ToolTip = 'Specifies the check type.';
                    AboutTitle = 'Enter the check type';
                    AboutText = 'In case of check type None you can post this type of entry without any digital voucher. In case of check type Attachment you need to have an attachment to your entry. In case of check type Attachment or Note you can either have an attachment or a note for your entry.';
                }
                field("Generate Automatically"; Rec."Generate Automatically")
                {
                    ToolTip = 'Specifies if the digital voucher needs to be generated automatically.';
                }
                field("Skip If Manually Added"; Rec."Skip If Manually Added")
                {
                    ToolTip = 'Specifies if the automatically generated digital voucher do not to be added to the document even if the manual attachment has already been added.';
                }
            }
            group(VoucherEntryTypeDescription)
            {
                Caption = 'Entry Type Description';
                Visible = VoucherEntryTypeDescription <> '';
                field(VoucherEntryTypeDescriptionControl; VoucherEntryTypeDescription)
                {
                    ShowCaption = false;
                    Editable = false;
                    MultiLine = true;
                    ToolTip = 'Specifies the description of the voucher entry type.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(SourceCodes)
            {
                Caption = 'Source Codes';
                Image = ViewSourceDocumentLine;
                Scope = Repeater;
                ToolTip = 'Specifies the connected source codes.';
                AboutTitle = 'About source codes';
                AboutText = 'If you post a journal line, the connected source code identifies the entry type - general journal, sales journal, purchase journal, etc.';
                RunObject = Page "Voucher Entry Source Codes";
                RunPageLink = "Entry Type" = field("Entry Type");
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(SourceCodes_Promoted; SourceCodes)
                {

                }
            }
        }
    }

    var
        OpenedFromWizard: Boolean;
        VoucherEntryTypeDescription: Text;
        GeneralJournalEntryDescriptionTxt: Label 'Specifies postings you are doing from the General Journal for all Account Types excluding those related to Customer and Vendor. By choosing one of those options, you will change control of the posting process. If you select the Customer as the Account Type, the system will check your setup related to the Sales Journal. If you select the Vendor as the Account Type, the system will check your setup related to the Purchase Journal.';
        SalesJournalEntryDescriptionTxt: Label 'Specifies posting you are doing from the Sales Journal and the General Journal with the Customer selected as the Account Type.';
        PurchaseJournalEntryDescriptionTxt: Label 'Specifies posting you are doing from the Purchase Journal and the General Journal with the Vendor selected as the Account Type.';
        SalesDocumentEntryDescriptionTxt: Label 'Specifies postings you are doing from the sales documents.';
        PurchaseDocumentEntryDescriptionTxt: Label 'Specifies postings you are doing from the purchase documents.';

    trigger OnOpenPage()
    var
        DigitalVoucherFeature: Codeunit "Digital Voucher Feature";
    begin
        if not OpenedFromWizard then
            DigitalVoucherFeature.ThrowNotificationIfFeatureIsNotEnabled();
    end;

    trigger OnAfterGetRecord()
    begin
        SetVoucherEntryTypeDescription();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        SetVoucherEntryTypeDescription();
    end;

    procedure SetOpenFromGuide()
    begin
        OpenedFromWizard := true;
    end;

    local procedure SetVoucherEntryTypeDescription()
    var
        IsHandled: Boolean;
    begin
        OnBeforeSetVoucherEntryTypeDescription(VoucherEntryTypeDescription, IsHandled);
        if IsHandled then
            exit;
        case Rec."Entry Type" of
            Rec."Entry Type"::"General Journal":
                VoucherEntryTypeDescription := GeneralJournalEntryDescriptionTxt;
            Rec."Entry Type"::"Sales Journal":
                VoucherEntryTypeDescription := SalesJournalEntryDescriptionTxt;
            Rec."Entry Type"::"Purchase Journal":
                VoucherEntryTypeDescription := PurchaseJournalEntryDescriptionTxt;
            Rec."Entry Type"::"Sales Document":
                VoucherEntryTypeDescription := SalesDocumentEntryDescriptionTxt;
            Rec."Entry Type"::"Purchase Document":
                VoucherEntryTypeDescription := PurchaseDocumentEntryDescriptionTxt;
            else
                VoucherEntryTypeDescription := '';
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSetVoucherEntryTypeDescription(var NewVoucherEntryTypeDescription: Text; var IsHandled: Boolean)
    begin
    end;
}
