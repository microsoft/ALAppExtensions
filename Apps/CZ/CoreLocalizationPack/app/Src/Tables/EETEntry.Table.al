// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.Utilities;
using System.Security.AccessControl;
using System.Utilities;

table 31128 "EET Entry CZL"
{
    Caption = 'EET Entry';
    DataCaptionFields = "Receipt Serial No.", "Entry No.";
    DrillDownPageId = "EET Entries CZL";
    LookupPageId = "EET Entries CZL";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(10; "Cash Register Type"; Enum "EET Cash Register Type CZL")
        {
            Caption = 'Cash Register Type';
            DataClassification = CustomerContent;
        }
        field(12; "Cash Register No."; Code[20])
        {
            Caption = 'Cash Register No.';
            DataClassification = CustomerContent;
        }
        field(20; "Business Premises Code"; Code[10])
        {
            Caption = 'Business Premises Code';
            NotBlank = true;
            TableRelation = "EET Business Premises CZL";
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(25; "Cash Register Code"; Code[10])
        {
            Caption = 'Cash Register Code';
            NotBlank = true;
            TableRelation = "EET Cash Register CZL".Code where("Business Premises Code" = field("Business Premises Code"));
            DataClassification = CustomerContent;
        }
        field(30; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(40; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Applied Document Type"; Enum "EET Applied Document Type CZL")
        {
            Caption = 'Applied Document Type';
            DataClassification = CustomerContent;
        }
        field(55; "Applied Document No."; Code[20])
        {
            Caption = 'Applied Document No.';
            DataClassification = CustomerContent;
        }
        field(60; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(62; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = CustomerContent;
        }
        field(70; "Status"; Enum "EET Status CZL")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(72; "Status Last Changed At"; DateTime)
        {
            Caption = 'Status Last Changed At';
            DataClassification = CustomerContent;
        }
        field(75; "Message UUID"; Text[36])
        {
            Caption = 'Message UUID';
            DataClassification = CustomerContent;
        }
        field(76; "Taxpayer's Signature Code"; Blob)
        {
            Caption = 'Taxpayer''s Signature Code';
            DataClassification = CustomerContent;
        }
        field(77; "Taxpayer's Security Code"; Text[44])
        {
            Caption = 'Taxpayer''s Security Code';
            DataClassification = CustomerContent;
        }
        field(78; "Fiscal Identification Code"; Text[39])
        {
            Caption = 'Fiscal Identification Code';
            DataClassification = CustomerContent;
        }
        field(85; "Receipt Serial No."; Code[50])
        {
            Caption = 'Receipt Serial No.';
            DataClassification = CustomerContent;
        }
        field(90; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            DataClassification = CustomerContent;
        }
        field(91; "Appointing VAT Reg. No."; Text[20])
        {
            Caption = 'Appointing VAT Reg. No.';
            DataClassification = CustomerContent;
        }
        field(95; "Sales Regime"; Enum "EET Sales Regime CZL")
        {
            Caption = 'Sales Regime';
            DataClassification = CustomerContent;
        }
        field(150; "Total Sales Amount"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Total Sales Amount';
            DataClassification = CustomerContent;
        }
        field(155; "Amount Exempted From VAT"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Exempted From VAT';
            DataClassification = CustomerContent;
        }
        field(160; "VAT Base (Basic)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base (Basic)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(161; "VAT Amount (Basic)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (Basic)';
            DataClassification = CustomerContent;
        }
        field(164; "VAT Base (Reduced)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base (Reduced)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(165; "VAT Amount (Reduced)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (Reduced)';
            DataClassification = CustomerContent;
        }
        field(167; "VAT Base (Reduced 2)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base (Reduced 2)';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(168; "VAT Amount (Reduced 2)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (Reduced 2)';
            DataClassification = CustomerContent;
        }
        field(170; "Amount - Art.89"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount - Art.89';
            DataClassification = CustomerContent;
        }
        field(175; "Amount (Basic) - Art.90"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (Basic) - Art.90';
            DataClassification = CustomerContent;
        }
        field(177; "Amount (Reduced) - Art.90"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (Reduced) - Art.90';
            DataClassification = CustomerContent;
        }
        field(179; "Amount (Reduced 2) - Art.90"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount (Reduced 2) - Art.90';
            DataClassification = CustomerContent;
        }
        field(190; "Amt. For Subseq. Draw/Settle"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amt. For Subseq. Draw/Settle';
            DataClassification = CustomerContent;
        }
        field(195; "Amt. Subseq. Drawn/Settled"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amt. Subseq. Drawn/Settled';
            DataClassification = CustomerContent;
        }
        field(200; "Canceled By Entry No."; Integer)
        {
            Caption = 'Canceled By Entry No.';
            TableRelation = "EET Entry CZL";
            DataClassification = CustomerContent;
        }
        field(210; "Simple Registration"; Boolean)
        {
            Caption = 'Simple Registration';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Business Premises Code", "Cash Register Code")
        {
        }
        key(Key3; "Status")
        {
        }
        key(Key4; "Document No.")
        {
        }
    }

    trigger OnInsert()
    begin
        InitRecord();
        ChangeStatus(Status::Created);
    end;

    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        EETControlCodesMgtCZL: Codeunit "EET Control Codes Mgt. CZL";
        EETManagementCZL: Codeunit "EET Management CZL";
        SignatureCodeErr: Label 'The signature code of EET Entry is not valid. Some of the following fields have changed.\"%1"\"%2"\"%3"\"%4"\"%5"\"%6"', Comment = '%1 = field caption, %2 = field caption, %3 = field caption, %4 = field caption, %5 = field caption, %6 = field caption';

    procedure InitRecord()
    var
        CompanyInformation: Record "Company Information";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeInitRecord(Rec, IsHandled, xRec);
        if IsHandled then
            exit;

        LockTable();
        "Entry No." := GetLastEntryNo() + 1;
        "Created By" := CopyStr(UserId(), 1, MaxStrLen("Created By"));
        "Created At" := CurrentDateTime();

        if "Receipt Serial No." = '' then begin
            TestReceiptSerialNoSeries();
            "Receipt Serial No." := NoSeriesManagement.GetNextNo(GetReceiptSerialNoSeriesCode(), Today(), true);
        end;

        if "VAT Registration No." = '' then begin
            CompanyInformation.Get();
            "VAT Registration No." := CompanyInformation."VAT Registration No.";
        end;

        EETServiceSetupCZL.Get();
        if "Appointing VAT Reg. No." = '' then
            "Appointing VAT Reg. No." := EETServiceSetupCZL."Appointing VAT Reg. No.";
        "Sales Regime" := EETServiceSetupCZL."Sales Regime";

        OnAfterInitRecord(Rec);
    end;

    procedure TestReceiptSerialNoSeries()
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeTestReceiptSerialNoSeries(Rec, IsHandled);
        if IsHandled then
            exit;

        GetEETCashRegister();
        EETCashRegisterCZL.TestField("Receipt Serial Nos.");
    end;

    procedure GetReceiptSerialNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetReceiptSerialNoSeriesCode(Rec, NoSeriesCode, IsHandled);
        if IsHandled then
            exit(NoSeriesCode);

        GetEETCashRegister();
        exit(EETCashRegisterCZL."Receipt Serial Nos.");
    end;

    local procedure GetEETCashRegister()
    begin
        if (EETCashRegisterCZL.Code <> "Cash Register Code") or
           (EETCashRegisterCZL."Business Premises Code" <> "Business Premises Code")
        then
            EETCashRegisterCZL.Get("Business Premises Code", "Cash Register Code");
    end;

    procedure GetLastEntryNo(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo("Entry No.")))
    end;

    procedure ShowStatusLog()
    var
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        EETEntryStatusLogCZL.SetCurrentKey("EET Entry No.");
        EETEntryStatusLogCZL.SetRange("EET Entry No.", "Entry No.");
        Page.Run(0, EETEntryStatusLogCZL);
    end;

    procedure ShowDocument()
    var
        InterfaceEETCashRegisterCZL: Interface "EET Cash Register CZL";
    begin
        TestField("Document No.");
        InterfaceEETCashRegisterCZL := "Cash Register Type";
        InterfaceEETCashRegisterCZL.ShowDocument("Cash Register No.", "Document No.");
    end;

    procedure GetCertificateCode() CertificateCode: Code[10]
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
    begin
        GetEETCashRegister();
        CertificateCode := EETCashRegisterCZL."Certificate Code";

        if CertificateCode = '' then begin
            EETBusinessPremisesCZL.Get("Business Premises Code");
            CertificateCode := EETBusinessPremisesCZL."Certificate Code";
        end;

        if CertificateCode = '' then begin
            EETServiceSetupCZL.Get();
            CertificateCode := EETServiceSetupCZL."Certificate Code";
        end;

        OnAfterGetCertificateCode(Rec, CertificateCode);

        if (CertificateCode = '') and (EETServiceSetupCZL."Certificate Code" = '') then
            EETServiceSetupCZL.Testfield("Certificate Code");
    end;

    procedure GetBusinessPremisesId(): Code[6]
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        EETBusinessPremisesCZL.Get("Business Premises Code");
        exit(EETBusinessPremisesCZL.Identification);
    end;

    procedure SaveSignatureCode(SignatureCode: Text)
    var
        SignatureCodeOutStream: OutStream;
    begin
        if SignatureCode = '' then
            exit;

        "Taxpayer's Signature Code".CreateOutStream(SignatureCodeOutStream);
        SignatureCodeOutStream.Write(SignatureCode);
    end;

    procedure GetSignatureCode(): Text
    var
        SignatureCodeInStream: InStream;
        SignatureCode: Text;
    begin
        CalcFields("Taxpayer's Signature Code");
        "Taxpayer's Signature Code".CreateInStream(SignatureCodeInStream);
        SignatureCodeInStream.Read(SignatureCode);
        exit(SignatureCode);
    end;

    procedure HasSignatureCode(): Boolean
    begin
        exit("Taxpayer's Signature Code".HasValue());
    end;

    procedure GenerateSignatureCode(): Text
    begin
        exit(EETControlCodesMgtCZL.GenerateSignatureCode(Rec));
    end;

    procedure CheckSignatureCode()
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckSignatureCode(Rec, IsHandled);
        if IsHandled then
            exit;

        if not HasSignatureCode() then
            exit;
        if GenerateSignatureCode() <> GetSignatureCode() then
            Error(SignatureCodeErr,
                FieldCaption("VAT Registration No."),
                FieldCaption("Business Premises Code"),
                FieldCaption("Cash Register Code"),
                FieldCaption("Receipt Serial No."),
                FieldCaption("Created At"),
                FieldCaption("Total Sales Amount"));
    end;

    procedure GenerateSecurityCode(SignatureCode: Text): Text[44]
    begin
        exit(EETControlCodesMgtCZL.GenerateSecurityCode(SignatureCode));
    end;

    procedure GenerateControlCodes(Force: Boolean)
    begin
        if not HasSignatureCode() or Force then
            SaveSignatureCode(GenerateSignatureCode());
        if ("Taxpayer's Security Code" = '') or Force then
            "Taxpayer's Security Code" := GenerateSecurityCode(GetSignatureCode());
    end;

    procedure GetSalesRegimeText(): Text
    var
        RegularSalesRegimeTxt: Label 'Regular record of sale';
        SimpleSalesRegimeTxt: Label 'Simplified record of sale';
    begin
        case "Sales Regime" of
            "Sales Regime"::Regular:
                exit(RegularSalesRegimeTxt);
            "Sales Regime"::Simplified:
                exit(SimpleSalesRegimeTxt);
        end;
    end;

    procedure IsFirstSending(): Boolean
    var
        EETEntryStatusLogCZL: Record "EET Entry Status Log CZL";
    begin
        EETEntryStatusLogCZL.SetRange("EET Entry No.", "Entry No.");
        EETEntryStatusLogCZL.SetRange(Status, EETEntryStatusLogCZL.Status::Sent);
        exit(EETEntryStatusLogCZL.Count = 1);
    end;

    procedure Send(ShowDialog: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        SendToServiceQst: Label 'Do you want to send %1 %2 to EET service?', Comment = '%1 = Table Caption; %2 = Entry No.';
    begin
        if not ConfirmManagement.GetResponseOrDefault(StrSubstNo(SendToServiceQst, TableCaption(), "Entry No."), true) then
            exit;

        EETManagementCZL.SendEntryToService(Rec, false);
    end;

    procedure Verify()
    begin
        EETManagementCZL.SendEntryToService(Rec, true);
    end;

    procedure Cancel(ShowDialog: Boolean)
    var
        ConfirmManagement: Codeunit "Confirm Management";
        EETEntryAlreadyCanceledQst: Label 'The %1 No. %2 has been already canceled by Entry No. %3.\\Do you want to continue?', Comment = '%1 = Tablecaption;%2 =  EET Entry No..;%3 = Canceled by Entry No.';
        CancelByEETEntryNoQst: Label 'EET Entry No. %1 will be canceled.\\Do you want to continue?', Comment = '%1 = EET Entry No.';
        CancelByEETEntryNoTxt: Label 'Cancel by EET Entry No. %1.', Comment = '%1 = EET Entry No.';
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCancel(Rec, ShowDialog, IsHandled);
        if IsHandled then
            exit;

        if ShowDialog then begin
            if "Canceled By Entry No." = 0 then
                if not ConfirmManagement.GetResponse(StrSubstNo(CancelByEETEntryNoQst, "Entry No."), false) then
                    Error('');

            if "Canceled By Entry No." <> 0 then
                if not ConfirmManagement.GetResponse(
                    StrSubstNo(EETEntryAlreadyCanceledQst, TableCaption(), "Entry No.", "Canceled By Entry No."), false)
                then
                    Error('');
        end;

        "Canceled By Entry No." := EETManagementCZL.CreateCancelEETEntry(Rec);
        if "Canceled By Entry No." = 0 then
            exit;

        ChangeStatus("Status", StrSubstNo(CancelByEETEntryNoTxt, "Canceled By Entry No."));
        EETManagementCZL.TrySendEntryToService("Canceled By Entry No.");
    end;

    procedure CalculateAmounts(VATEntry: Record "VAT Entry")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalculateAmounts(Rec, VATEntry, IsHandled);
        if IsHandled then
            exit;

        if (VATEntry."Entry No." = 0) or (VATEntry."Unrealized VAT Entry No." <> 0) then
            exit;

        CalculateAmounts(VATEntry.Base, VATEntry.Amount, VATEntry."VAT Bus. Posting Group", VATEntry."VAT Prod. Posting Group");

        OnAfterCalculateAmounts(Rec, VATEntry);
    end;

    procedure CalculateAmounts(Base: Decimal; Amount: Decimal; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20])
    var
        VATPostingSetup: Record "VAT Posting Setup";
        AmountArt89: Decimal;
        AmountArt90: Decimal;
        VATBase: Decimal;
        VATAmount: Decimal;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeBaseCalculateAmounts(Rec, Base, Amount, VATBusPostingGroupCode, VATProdPostingGroupCode, IsHandled);
        if IsHandled then
            exit;

        if Amount = 0 then begin
            "Amount Exempted From VAT" += -Base;
            exit;
        end;

        VATPostingSetup.Get(VATBusPostingGroupCode, VATProdPostingGroupCode);

        case VATPostingSetup."Supplies Mode Code CZL" of
            VATPostingSetup."Supplies Mode Code CZL"::"par. 89":
                AmountArt89 := Base + Amount;
            VATPostingSetup."Supplies Mode Code CZL"::"par. 90":
                AmountArt90 := Base + Amount;
            else begin
                VATBase := Base;
                VATAmount := Amount;
            end;
        end;

        "Amount - Art.89" += -AmountArt89;

        case VATPostingSetup."VAT Rate CZL" of
            VATPostingSetup."VAT Rate CZL"::" ":
                "Amount Exempted From VAT" += -(Base + Amount);
            VATPostingSetup."VAT Rate CZL"::Base:
                begin
                    "Amount (Basic) - Art.90" += -AmountArt90;
                    "VAT Base (Basic)" += -VATBase;
                    "VAT Amount (Basic)" += -VATAmount;
                end;
            VATPostingSetup."VAT Rate CZL"::Reduced:
                begin
                    "Amount (Reduced) - Art.90" += -AmountArt90;
                    "VAT Base (Reduced)" += -VATBase;
                    "VAT Amount (Reduced)" += -VATAmount;
                end;
            VATPostingSetup."VAT Rate CZL"::"Reduced 2":
                begin
                    "Amount (Reduced 2) - Art.90" += -AmountArt90;
                    "VAT Base (Reduced 2)" += -VATBase;
                    "VAT Amount (Reduced 2)" += -VATAmount;
                end;
        end;
    end;

    procedure ReverseAmounts()
    begin
        "Total Sales Amount" := -"Total Sales Amount";
        "Amount Exempted From VAT" := -"Amount Exempted From VAT";
        "VAT Base (Basic)" := -"VAT Base (Basic)";
        "VAT Amount (Basic)" := -"VAT Amount (Basic)";
        "VAT Base (Reduced)" := -"VAT Base (Reduced)";
        "VAT Amount (Reduced)" := -"VAT Amount (Reduced)";
        "VAT Base (Reduced 2)" := -"VAT Base (Reduced 2)";
        "VAT Amount (Reduced 2)" := -"VAT Amount (Reduced 2)";
        "Amount - Art.89" := -"Amount - Art.89";
        "Amount (Basic) - Art.90" := -"Amount (Basic) - Art.90";
        "Amount (Reduced) - Art.90" := -"Amount (Reduced) - Art.90";
        "Amount (Reduced 2) - Art.90" := -"Amount (Reduced 2) - Art.90";
        "Amt. For Subseq. Draw/Settle" := -"Amt. For Subseq. Draw/Settle";
        "Amt. Subseq. Drawn/Settled" := -"Amt. Subseq. Drawn/Settled";
    end;

    procedure RoundAmounts()
    begin
        "Amount Exempted From VAT" := Round("Amount Exempted From VAT");
        "VAT Base (Basic)" := Round("VAT Base (Basic)");
        "VAT Amount (Basic)" := Round("VAT Amount (Basic)");
        "VAT Base (Reduced)" := Round("VAT Base (Reduced)");
        "VAT Amount (Reduced)" := Round("VAT Amount (Reduced)");
        "VAT Base (Reduced 2)" := Round("VAT Base (Reduced 2)");
        "VAT Amount (Reduced 2)" := Round("VAT Amount (Reduced 2)");
        "Amount - Art.89" := Round("Amount - Art.89");
        "Amount (Basic) - Art.90" := Round("Amount (Basic) - Art.90");
        "Amount (Reduced) - Art.90" := Round("Amount (Reduced) - Art.90");
        "Amount (Reduced 2) - Art.90" := Round("Amount (Reduced 2) - Art.90");
    end;

    procedure CopyFromEETEntry(EETEntryCZL: Record "EET Entry CZL")
    begin
        "Cash Register Type" := EETEntryCZL."Cash Register Type";
        "Cash Register No." := EETEntryCZL."Cash Register No.";
        "Business Premises Code" := EETEntryCZL."Business Premises Code";
        "Cash Register Code" := EETEntryCZL."Cash Register Code";
        "Document No." := EETEntryCZL."Document No.";
        "Receipt Serial No." := EETEntryCZL."Receipt Serial No.";
        Description := EETEntryCZL.Description;
        "Applied Document Type" := EETEntryCZL."Applied Document Type";
        "Applied Document No." := EETEntryCZL."Applied Document No.";
        "VAT Registration No." := EETEntryCZL."VAT Registration No.";
        "Appointing VAT Reg. No." := EETEntryCZL."Appointing VAT Reg. No.";
        "Sales Regime" := EETEntryCZL."Sales Regime";
        "Total Sales Amount" := EETEntryCZL."Total Sales Amount";
        "Amount Exempted From VAT" := EETEntryCZL."Amount Exempted From VAT";
        "VAT Base (Basic)" := EETEntryCZL."VAT Base (Basic)";
        "VAT Amount (Basic)" := EETEntryCZL."VAT Amount (Basic)";
        "VAT Base (Reduced)" := EETEntryCZL."VAT Base (Reduced)";
        "VAT Amount (Reduced)" := EETEntryCZL."VAT Amount (Reduced)";
        "VAT Base (Reduced 2)" := EETEntryCZL."VAT Base (Reduced 2)";
        "VAT Amount (Reduced 2)" := EETEntryCZL."VAT Amount (Reduced 2)";
        "Amount - Art.89" := EETEntryCZL."Amount - Art.89";
        "Amount (Basic) - Art.90" := EETEntryCZL."Amount (Basic) - Art.90";
        "Amount (Reduced) - Art.90" := EETEntryCZL."Amount (Reduced) - Art.90";
        "Amount (Reduced 2) - Art.90" := EETEntryCZL."Amount (Reduced 2) - Art.90";
        "Amt. For Subseq. Draw/Settle" := EETEntryCZL."Amt. For Subseq. Draw/Settle";
        "Amt. Subseq. Drawn/Settled" := EETEntryCZL."Amt. Subseq. Drawn/Settled";

        OnAfterCopyFromEETEntry(Rec, EETEntryCZL);
    end;

    procedure SumPartialAmounts(): Decimal
    begin
        exit(
          "Amount Exempted From VAT" +
          "VAT Base (Basic)" + "VAT Amount (Basic)" +
          "VAT Base (Reduced)" + "VAT Amount (Reduced)" +
          "VAT Base (Reduced 2)" + "VAT Amount (Reduced 2)" +
          "Amount - Art.89" +
          "Amount (Basic) - Art.90" + "Amount (Reduced) - Art.90" + "Amount (Reduced 2) - Art.90" +
          "Amt. For Subseq. Draw/Settle" + "Amt. Subseq. Drawn/Settled");
    end;

    local procedure FormatDateTime(dt: DateTime): Text
    begin
        exit(Format(dt, 0, 3));
    end;

    procedure GetFormattedCreatedAt(): Text
    begin
        exit(FormatDateTime("Created At"));
    end;

    procedure GetFormattedStatusLastChangedAt(): Text
    begin
        exit(FormatDateTime("Status Last Changed At"));
    end;

    procedure GetStatusStyleExpr() StatusStyleExpr: Text
    begin
        case Status of
            Status::Created:
                StatusStyleExpr := 'Subordinate';
            Status::Failure:
                StatusStyleExpr := 'Unfavorable';
            Status::Success:
                StatusStyleExpr := 'Favorable';
            Status::Verified:
                StatusStyleExpr := 'StandardAccent';
            Status::"Verified with Warnings":
                StatusStyleExpr := 'AttentionAccent';
            Status::"Success with Warnings":
                StatusStyleExpr := 'Ambiguous';
        end;

        OnAfterGetStatusStyleExpr(Rec, StatusStyleExpr);
    end;

    procedure SetFilterToSending()
    begin
        SetFilter("Status", '%1|%2|%3|%4',
            "Status"::"Send Pending",
            "Status"::Failure,
            "Status"::Verified,
            "Status"::"Verified with Warnings");

        OnAfterSetFilterToSending(Rec);
    end;

    procedure ChangeStatus(NewStatus: Enum "EET Status CZL")
    begin
        ChangeStatus(NewStatus, '');
    end;

    procedure ChangeStatus(NewStatus: Enum "EET Status CZL"; NewDescription: Text)
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        Clear(TempErrorMessage);
        ChangeStatus(NewStatus, NewDescription, TempErrorMessage);
    end;

    procedure ChangeStatus(NewStatus: Enum "EET Status CZL"; NewDescription: Text; var TempErrorMessage: Record "Error Message" temporary)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeChangeStatus(Rec, NewStatus, NewDescription, TempErrorMessage, IsHandled);
        if IsHandled then
            exit;

        "Status" := NewStatus;
        "Status Last Changed At" := CurrentDateTime();
        if "Status" <> "Status"::Created then
            Modify();

        OnAfterChangeStatus(Rec, NewStatus, NewDescription, TempErrorMessage);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitRecord(var EETEntryCZL: Record "EET Entry CZL"; var IsHandled: Boolean; xEETEntryCZL: Record "EET Entry CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeTestReceiptSerialNoSeries(var EETEntryCZL: Record "EET Entry CZL"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetReceiptSerialNoSeriesCode(var EETEntryCZL: Record "EET Entry CZL"; var NoSeriesCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCancel(var EETEntryCZL: Record "EET Entry CZL"; var ShowDialog: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalculateAmounts(var EETEntryCZL: Record "EET Entry CZL"; var VATEntry: Record "VAT Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeBaseCalculateAmounts(var EETEntryCZL: Record "EET Entry CZL"; Base: Decimal; Amount: Decimal; VATBusPostingGroupCode: Code[20]; VATProdPostingGroupCode: Code[20]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeChangeStatus(var EETEntryCZL: Record "EET Entry CZL"; NewStatus: Enum "EET Status CZL"; var NewDescription: Text; var TempErrorMessage: Record "Error Message" temporary; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetCertificateCode(EETEntryCZL: Record "EET Entry CZL"; var CertificateCode: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetStatusStyleExpr(EETEntryCZL: Record "EET Entry CZL"; var StatusStyleExpr: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFilterToSending(var EETEntryCZL: Record "EET Entry CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitRecord(var EETEntryCZL: Record "EET Entry CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCopyFromEETEntry(var ToEETEntryCZL: Record "EET Entry CZL"; FromEETEntryCZL: Record "EET Entry CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateAmounts(var EETEntryCZL: Record "EET Entry CZL"; VATEntry: Record "VAT Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterChangeStatus(var EETEntryCZL: Record "EET Entry CZL"; NewStatus: Enum "EET Status CZL"; NewDescription: Text; var TempErrorMessage: Record "Error Message" temporary)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckSignatureCode(EETEntryCZL: Record "EET Entry CZL"; var IsHandled: Boolean)
    begin
    end;
}

