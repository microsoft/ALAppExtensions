// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.History;

using Microsoft.Bank.Setup;
using Microsoft.Finance.Currency;
#if not CLEAN22
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
#endif
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
#if not CLEAN22
using System.Utilities;
#endif

tableextension 11727 "Sales Cr.Memo Header CZL" extends "Sales Cr.Memo Header"
{
    fields
    {
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = "Customer Bank Account".Code where("Customer No." = field("Bill-to Customer No."));
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11721; "Bank Account No. CZL"; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11722; "Bank Branch No. CZL"; Text[20])
        {
            Caption = 'Bank Branch No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11723; "Bank Name CZL"; Text[100])
        {
            Caption = 'Bank Name';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11724; "Transit No. CZL"; Text[20])
        {
            Caption = 'Transit No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11725; "IBAN CZL"; Code[50])
        {
            Caption = 'IBAN';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11726; "SWIFT Code CZL"; Code[20])
        {
            Caption = 'SWIFT Code';
            Editable = false;
            TableRelation = "SWIFT Code";
            DataClassification = CustomerContent;
        }
        field(11774; "VAT Currency Factor CZL"; Decimal)
        {
            Caption = 'VAT Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(11775; "VAT Currency Code CZL"; Code[10])
        {
            Caption = 'VAT Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            Editable = false;
        }
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Replaced by VAT Reporting Date.';
#if not CLEAN22
            trigger OnValidate()
            var
                VATEntry: Record "VAT Entry";
                GLEntry: Record "G/L Entry";
                ConfirmManagement: Codeunit "Confirm Management";
                VATDateModifyQst: Label 'Do you really want to modify VAT Date?';
                VATEntryClosedErr: Label 'VAT Entry is already closed and the date cannot be modified. VAT Date = %1.', Comment = '%1 = VAT Date';
                VATDateCannotBeChangedErr: Label 'Selected document is not Credit Memo. Field VAT Date cannot be changed.';
            begin
                if not ConfirmManagement.GetResponse(VATDateModifyQst, false) then begin
                    "VAT Date CZL" := xRec."VAT Date CZL";
                    exit;
                end;
#pragma warning disable AL0432
                CheckVATDateCZL();
#pragma warning restore AL0432
                VATEntry.LockTable();
                VATEntry.SetCurrentKey("Document No.", "Posting Date");
                VATEntry.SetRange("Document Type", VATEntry."Document Type"::"Credit Memo");
                VATEntry.SetRange("Posting Date", "Posting Date");
                VATEntry.SetRange("Document No.", "No.");
                VATEntry.SetRange(Type, VATEntry.Type::Sale);
                if VATEntry.FindSet(true) then
                    repeat
                        if VATEntry.Closed then
                            Error(VATEntryClosedErr, VATEntry."VAT Date CZL");
                        VATEntry.Validate("VAT Date CZL", "VAT Date CZL");
                        Codeunit.Run(Codeunit::"VAT Entry - Edit", VATEntry);
                    until VATEntry.Next() = 0
                else begin
                    "VAT Date CZL" := xRec."VAT Date CZL";
                    Error(VATDateCannotBeChangedErr);
                end;

                GLEntry.SetCurrentKey("Document No.", "Posting Date");
                GLEntry.SetRange("Document Type", GLEntry."Document Type"::"Credit Memo");
                GLEntry.SetRange("Posting Date", "Posting Date");
                GLEntry.SetRange("Document No.", "No.");
                GLEntry.LockTable();
                if GLEntry.FindSet(true) then
                    repeat
                        GLEntry.Validate("VAT Date CZL", "VAT Date CZL");
                        Codeunit.Run(Codeunit::"G/L Entry-Edit", GLEntry);
                    until GLEntry.Next() = 0;
            end;
#endif
        }
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(11786; "Credit Memo Type CZL"; Enum "Credit Memo Type CZL")
        {
            Caption = 'Credit Memo Type';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(31068; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        }
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
#if not CLEAN22
            ObsoleteState = Pending;
            ObsoleteTag = '22.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
#endif
            ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions. This field is not used any more.';
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;
        }
    }
#if not CLEAN22

    [Obsolete('The VAT Date CZL will be replaced by VAT Reporting Date.', '22.0')]
    procedure CheckVATDateCZL()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
#pragma warning disable AL0432
        ReplaceVATDateMgtCZL: Codeunit "Replace VAT Date Mgt. CZL";
#pragma warning restore AL0432
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
        VATDateRangeErr: Label 'VAT Date %1 is not within your range of allowed VAT dates.\Correct the date or change VAT posting period.', Comment = '%1 = VAT Date';
    begin
        if ReplaceVATDateMgtCZL.IsEnabled() then
            exit;
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Use VAT Date CZL" then begin
            TestField("VAT Date CZL");
            if not VATDateHandlerCZL.IsVATDateInAllowedPeriod("VAT Date CZL") then
                Error(VATDateRangeErr, "VAT Date CZL");
            VATDateHandlerCZL.VATPeriodCZLCheck("VAT Date CZL");
        end;
    end;
#endif
}
