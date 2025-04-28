// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.NoSeries;
using System.Utilities;

table 31003 "Advance Letter Template CZZ"
{
    Caption = 'Advance Letter Template';
    DataClassification = CustomerContent;
    LookupPageId = "Advance Letter Templates CZZ";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Sales/Purchase"; Enum "Advance Letter Type CZZ")
        {
            Caption = 'Sales/Purchase';
            DataClassification = CustomerContent;
        }
        field(5; "Advance Letter G/L Account"; Code[20])
        {
            Caption = 'Advance Letter G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                ChangeAccountQst: Label 'Do you really want to change G/L Account although letters with status "To Use" exist?';
            begin
                if "Advance Letter G/L Account" = xRec."Advance Letter G/L Account" then
                    exit;

                case "Sales/Purchase" of
                    "Sales/Purchase"::Sales:
                        begin
                            SalesAdvLetterHeaderCZZ.SetCurrentKey("Bill-to Customer No.", Status);
                            SalesAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
                            SalesAdvLetterHeaderCZZ.SetRange("Advance Letter Code", Rec.Code);
                            if not SalesAdvLetterHeaderCZZ.IsEmpty() then
                                if not ConfirmManagement.GetResponse(ChangeAccountQst, false) then
                                    Error('');
                        end;
                    "Sales/Purchase"::Purchase:
                        begin
                            PurchAdvLetterHeaderCZZ.SetCurrentKey("Pay-to Vendor No.", Status);
                            PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
                            PurchAdvLetterHeaderCZZ.SetRange("Advance Letter Code", Rec.Code);
                            if not PurchAdvLetterHeaderCZZ.IsEmpty() then
                                if not ConfirmManagement.GetResponse(ChangeAccountQst, false) then
                                    Error('');
                        end;
                end;
                GLAccountCategoryMgt.CheckGLAccountWithoutCategory("Advance Letter G/L Account", false, false);
            end;

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory("Advance Letter G/L Account");
            end;
        }
        field(8; "Advance Letter Document Nos."; Code[20])
        {
            Caption = 'Advance Letter Document Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(10; "Advance Letter Invoice Nos."; Code[20])
        {
            Caption = 'Advance Letter Invoice Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(11; "Advance Letter Cr. Memo Nos."; Code[20])
        {
            Caption = 'Advance Letter Cr. Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(13; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(25; "Automatic Post VAT Document"; Boolean)
        {
            Caption = 'Automatic Post VAT Document';
            DataClassification = CustomerContent;
        }
#if not CLEANSCHEMA30
        field(26; "Automatic Post Non-Ded. VAT"; Boolean)
        {
            Caption = 'Automatic Post Non-Deductible VAT (Obsolete)';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether non-deductible VAT will be applied to the tax documents automatically. If you select NO, the system will ask you if you want to reduce input tax every time you post a tax document for non-deductible VAT. If you select YES, the reduction will be done automatically after the tax document is posted to the prepayment, if a combination of VAT posting groups with non-deductible VAT is set up in it.';
#if not CLEAN27            
            ObsoleteState = Pending;
            ObsoleteTag = '27.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '30.0';
#endif
            ObsoleteReason = 'The field is obsolete and will be removed in a future version. Non-deductible VAT must always be posted in advances so this field is useless.';
        }
#endif
        field(30; "Post VAT Doc. for Rev. Charge"; Boolean)
        {
            Caption = 'Post VAT Document for Reverse Charge';
            DataClassification = CustomerContent;
            InitValue = true;
            ToolTip = 'Specifies whether the VAT document will be posting for reverse charge.';
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
}