// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Setup;

using Microsoft.Finance.FinancialReports;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Reporting;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.NoSeries;
using Microsoft.Purchases.Archive;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Archive;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.Document;
using Microsoft.Service.History;
using System.Utilities;

tableextension 11713 "General Ledger Setup CZL" extends "General Ledger Setup"
{
    fields
    {
        modify("VAT Reporting Date Usage")
        {
            trigger OnAfterValidate()
            var
                GLEntry: Record "G/L Entry";
                ConfirmManagement: Codeunit "Confirm Management";
                InitVATDateQst: Label 'If you check field %1 you will let system post using %2 different from %3. Field %2 will be initialized from field %3 in all tables. It may take some time and you will not be able to undo this change after posting entries. Do you really want to continue?', Comment = '%1 = fieldcaption of Use VAT Date; %2 = fieldcaption of VAT Date; %3 = fieldcaption of Posting Date';
                CannotChangeFieldErr: Label 'You cannot change the contents of the %1 field because there are posted ledger entries.', Comment = '%1 = field caption';
                DisableVATDateQst: Label 'Are you sure you want to disable VAT Date functionality?';
            begin
                if ("VAT Reporting Date Usage" <> "VAT Reporting Date Usage"::Disabled) and
                   (xRec."VAT Reporting Date Usage" = xRec."VAT Reporting Date Usage"::Disabled)
                then
                    if ConfirmManagement.GetResponseOrDefault(StrSubstNo(InitVATDateQst, FieldCaption("VAT Reporting Date Usage"),
                        GLEntry.FieldCaption("VAT Reporting Date"), GLEntry.FieldCaption("Posting Date")), true)
                    then
                        InitVATDateCZL()
                    else
                        "VAT Reporting Date Usage" := xRec."VAT Reporting Date Usage";

                if ("VAT Reporting Date Usage" = "VAT Reporting Date Usage"::Disabled) and
                   ("VAT Reporting Date Usage" <> xRec."VAT Reporting Date Usage")
                then begin
                    GLEntry.SetFilter("VAT Reporting Date", '>%1', 0D);
                    if not GLEntry.IsEmpty() then
                        Error(CannotChangeFieldErr, FieldCaption("VAT Reporting Date Usage"));
#if not CLEAN24
                    if ConfirmManagement.GetResponseOrDefault(DisableVATDateQst, false) then begin
                        "VAT Reporting Date" := "VAT Reporting Date"::"Posting Date";
#pragma warning disable AL0432
                        "Allow VAT Posting From CZL" := 0D;
                        "Allow VAT Posting To CZL" := 0D;
#pragma warning restore AL0432
                    end else
#else
                    if ConfirmManagement.GetResponseOrDefault(DisableVATDateQst, false) then
                        "VAT Reporting Date" := "VAT Reporting Date"::"Posting Date"
                    else
#endif
                        "VAT Reporting Date Usage" := xRec."VAT Reporting Date Usage";
                end;
            end;
        }
#if not CLEANSCHEMA27
        field(11778; "Allow VAT Posting From CZL"; Date)
        {
            Caption = 'Allow VAT Posting From';
            DataClassification = CustomerContent;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'Replaced by "Allow VAT Date From" field from "VAT Setup" table.';
#if not CLEAN24

            trigger OnValidate()
            begin
                TestIsVATDateEnabledCZL();
            end;
#endif
        }
        field(11779; "Allow VAT Posting To CZL"; Date)
        {
            Caption = 'Allow VAT Posting To';
            DataClassification = CustomerContent;
#if not CLEAN24
            ObsoleteState = Pending;
            ObsoleteTag = '24.0';
#else
            ObsoleteState = Removed;
            ObsoleteTag = '27.0';
#endif
            ObsoleteReason = 'Replaced by "Allow VAT Date To" field from "VAT Setup" table.';
#if not CLEAN24

            trigger OnValidate()
            begin
                TestIsVATDateEnabledCZL();
            end;
#endif
        }
#endif
#if not CLEANSCHEMA25
        field(11780; "Use VAT Date CZL"; Boolean)
        {
            Caption = 'Use VAT Date';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '25.0';
            ObsoleteReason = 'Replaced by VAT Reporting Date.';
        }
#endif
        field(11781; "Do Not Check Dimensions CZL"; Boolean)
        {
            Caption = 'Do Not Check Dimensions';
            DataClassification = CustomerContent;
        }
        field(11782; "Check Posting Debit/Credit CZL"; Boolean)
        {
            Caption = 'Check Posting Debit/Credit';
            DataClassification = CustomerContent;
        }
        field(11783; "Mark Neg. Qty as Correct. CZL"; Boolean)
        {
            Caption = 'Mark Neg. Qty as Correction';
            DataClassification = CustomerContent;
        }
        field(11784; "Closed Per. Entry Pos.Date CZL"; Date)
        {
            Caption = 'Closed Period Entry Pos.Date';
            DataClassification = CustomerContent;
        }
        field(11785; "Rounding Date CZL"; Date)
        {
            Caption = 'Rounding Date';
            DataClassification = CustomerContent;
        }
        field(11786; "User Checks Allowed CZL"; Boolean)
        {
            Caption = 'User Checks Allowed';
            DataClassification = CustomerContent;
        }
        field(31085; "Shared Account Schedule CZL"; Code[10])
        {
            Caption = 'Shared Account Schedule';
            DataClassification = CustomerContent;
            TableRelation = "Acc. Schedule Name";
        }
        field(31086; "Acc. Schedule Results Nos. CZL"; Code[20])
        {
            Caption = 'Acc. Schedule Results Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(31090; "Def. Orig. Doc. VAT Date CZL"; Enum "Default Orig.Doc. VAT Date CZL")
        {
            Caption = 'Default Original Document VAT Date';
            DataClassification = CustomerContent;
        }
        field(31091; "Functional Currency CZL"; Boolean)
        {
            Caption = 'Functional Currency';
            DataClassification = CustomerContent;
        }
    }

    procedure InitVATDateCZL()
    var
        VATDateHandlerCZL: Codeunit "VAT Date Handler CZL";
    begin
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"G/L Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Gen. Journal Line");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Posted Gen. Journal Line");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"VAT Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Invoice Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Cr.Memo Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Sales Header Archive");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purchase Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Inv. Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purch. Cr. Memo Hdr.");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Purchase Header Archive");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Service Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Service Invoice Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Service Cr.Memo Header");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Cust. Ledger Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"Vendor Ledger Entry");
        VATDateHandlerCZL.InitVATDateFromRecordCZL(Database::"VAT Ctrl. Report Line CZL");
        OnAfterInitVATDateCZL();
    end;

    procedure TestIsVATDateEnabledCZL()
    begin
        if "VAT Reporting Date Usage" = "VAT Reporting Date Usage"::Disabled then
            FieldError("VAT Reporting Date Usage");
    end;

    procedure UpdateOriginalDocumentVATDateCZL(NewDate: Date; DefaultOrigDocVATDate: Enum "Default Orig.Doc. VAT Date CZL"; var OriginalDocumentVATDate: Date)
    begin
        if ("Def. Orig. Doc. VAT Date CZL" = DefaultOrigDocVATDate) then
            OriginalDocumentVATDate := NewDate;
    end;

    procedure GetOriginalDocumentVATDateCZL(PostingDate: Date; VATDate: Date; DocumentDate: Date): Date
    begin
        Get();
        case "Def. Orig. Doc. VAT Date CZL" of
            "Def. Orig. Doc. VAT Date CZL"::Blank:
                exit(0D);
            "Def. Orig. Doc. VAT Date CZL"::"Posting Date":
                exit(PostingDate);
            "Def. Orig. Doc. VAT Date CZL"::"VAT Date":
                exit(VATDate);
            "Def. Orig. Doc. VAT Date CZL"::"Document Date":
                exit(DocumentDate);
        end;
        exit(PostingDate);
    end;

    internal procedure GetAdditionalCurrencyCode(): Code[10]
    begin
        GetRecordOnce();
        exit("Additional Reporting Currency");
    end;

    internal procedure IsAdditionalCurrencyEnabled(): Boolean
    begin
        exit(GetAdditionalCurrencyCode() <> '');
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitVATDateCZL()
    begin
    end;
}
