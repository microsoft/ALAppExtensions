// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Base;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.GST.StockTransfer;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Location;
using Microsoft.Projects.Resources.Resource;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Sales.Setup;
using Microsoft.Service.Document;
using Microsoft.Service.Pricing;

codeunit 18001 "GST Base Validation"
{
    var
        LengthErr: Label 'The Length of the GST Registration Nos. must be 15.';
        StateCodeErr: Label 'The GST Registration No. for the state %1 should start with %2.', Comment = '%1 = StateCode ; %2 = GST Reg. No';
        OnlyAlphabetErr: Label 'Only Alphabet is allowed in the position %1.', Comment = '%1 = Position';
        OnlyNumericErr: Label 'Only Numeric is allowed in the position %1.', Comment = '%1 = Position';
        OnlyAlphaNumericErr: Label 'Only AlphaNumeric is allowed in the position %1.', Comment = '%1 = Position';
        SamePanErr: Label 'In GST Registration No from postion 3 to 12 the value should be same as the PAN No. %1.', Comment = '%1 = PANNo';
        PANErr: Label 'PAN No. must be entered in Company Information.';
        GSTCompyErr: Label 'Please delete the GST Registration No. %1 from Company Information.', Comment = '%1 =GstRegNo';
        GSTLocaErr: Label 'Please delete the GST Registration No. %1 from Location %2.', Comment = '%1 = GstRegNo ;%2 = LocationCode';
        CompnayGSTPANErr: Label 'Please delete the record %1 from GST Registration No.of state %2  since the PAN No. is not same as in Company Information.', Comment = '%1 = GstRegNo ; %2 = StateCode';
        GSTStateCodeErr: Label '%1 %2 is already in use', Comment = '%1 = StateCode ; %2 = GstRegNo';
        LengthStateErr: Label 'The Length of the State Code (GST Reg. No.) must be 2.';
        POSLOCDiffErr: Label 'You can select POS Out Of India field on header only if Customer / Vendor State Code and Location State Code are same.';
        CustGSTTypeErr: Label 'You can select POS Out Of India field on header only if GST Customer/Vednor Type is Registered, Unregistered or Deemed Export.';
        VendGSTTypeErr: Label 'You can select POS Out Of India field on header only if GST Vendor Type is Registered.';
        AccountingPeriodErr: Label 'GST Accounting Period does not exist for the given Date %1.', Comment = '%1 = Posting Date';
        PeriodClosedErr: Label 'Accounting Period has been closed till %1, Document Posting Date must be greater than or equal to %2.', Comment = '%1 = Last Closed Date ; %2 = Document Posting Date';
        VendGSTARNErr: Label 'Either Vendor GST Registration No. or ARN No. in Vendor should have a value.';
        OrderAddressGSTARNErr: Label 'Either Order Address GST Registration No. or ARN No. in Order Address should have a value.';
        CustGSTARNErr: Label 'Either Customer GST Registration No. or ARN No. in Customer should have a value.';
        PostGSTtoCustErr: Label 'Only allow for GST Customer type SEZ Development & SEZ Unit.';

    //Same Functon in Called in GST Sales
    procedure CheckGSTRegistrationNo(StateCode: Code[10]; RegistrationNo: Code[20]; PANNo: Code[20])
    var
        State: Record State;
        Position: Integer;
    begin
        if RegistrationNo = '' then
            exit;

        if StrLen(RegistrationNo) <> 15 then
            Error(LengthErr);

        State.Get(StateCode);
        if State."State Code (GST Reg. No.)" <> CopyStr(RegistrationNo, 1, 2) then
            Error(StateCodeErr, StateCode, State."State Code (GST Reg. No.)");

        if PANNo <> '' then
            if PANNo <> CopyStr(RegistrationNo, 3, 10) then
                Error(SamePanErr, PANNo);

        for Position := 3 to 15 do
            case Position of
                3 .. 7, 12:
                    CheckIsAlphabet(RegistrationNo, Position);
                8 .. 11:
                    CheckIsNumeric(RegistrationNo, Position);
                13:
                    CheckIsAlphaNumeric(RegistrationNo, Position);
                15:
                    CheckIsAlphaNumeric(RegistrationNo, Position)
            end;
    end;

    procedure CheckGSTRegistrationNoforGidandUid(StateCode: Code[10]; RegistrationNo: Code[20]; PANNo: Code[20])
    var
        State: Record State;
        Position: Integer;
    begin
        if RegistrationNo = '' then
            exit;

        if StrLen(RegistrationNo) <> 15 then
            Error(LengthErr);

        State.Get(StateCode);
        if State."State Code (GST Reg. No.)" <> CopyStr(RegistrationNo, 1, 2) then
            Error(StateCodeErr, StateCode, State."State Code (GST Reg. No.)");

        if PANNo <> '' then
            if PANNo <> CopyStr(RegistrationNo, 3, 10) then
                Error(SamePanErr, PANNo);

        for Position := 3 to 15 do
            case Position of
                3 .. 7, 12:
                    CheckIsAlphabet(RegistrationNo, Position);
                8 .. 11:
                    CheckIsNumeric(RegistrationNo, Position);
                13:
                    CheckIsAlphaNumeric(RegistrationNo, Position);
                14:
                    CheckIsAlphabet(RegistrationNo, Position);
                15:
                    CheckIsAlphaNumeric(RegistrationNo, Position)
            end;
    end;


    //Same Funciton is called in GST Sales
    procedure VerifyPOSOutOfIndia(
        PartyType: Enum "Party Type";
        LocationStateCode: Code[10];
        VendCustStateCode: Code[10];
        GSTVendorType: Enum "GST Vendor Type";
        GSTCustomerType: Enum "GST Customer Type")
    begin
        if LocationStateCode <> VendCustStateCode then
            Error(POSLOCDiffErr);

        if PartyType = PartyType::Customer then begin
            if not (GSTCustomerType in [GSTCustomerType::" ", GSTCustomerType::Registered, GSTCustomerType::Unregistered, GSTCustomerType::"Deemed Export"]) then
                Error(CustGSTTypeErr);
        end else
            if not (GSTVendorType in [GSTVendorType::Registered, GSTVendorType::" "]) then
                Error(VendGSTTypeErr);
    end;

    procedure OpenGSTEntries(FromEntry: Integer; ToEntry: Integer)
    var
        GSTLedgerEntry: Record "GST Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Entry No.", FromEntry, ToEntry);
        if GLEntry.FindFirst() then begin
            GSTLedgerEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            Page.Run(0, GSTLedgerEntry);
        end;
    end;

    procedure OpenDetailedGSTEntries(FromEntry: Integer; ToEntry: Integer)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Entry No.", FromEntry, ToEntry);
        if GLEntry.FindFirst() then begin
            DetailedGSTLedgerEntry.SetRange("Transaction No.", GLEntry."Transaction No.");
            Page.Run(0, DetailedGSTLedgerEntry);
        end;
    end;

    //GST Ledger Entry
    [EventSubscriber(ObjectType::Table, Database::"GST Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateGSTLedgerEntryOnafterInsertEvent(var Rec: Record "GST Ledger Entry"; RunTrigger: Boolean)
    var
        GSTPostingManagement: Codeunit "GST Posting Management";
        SignFactor: Integer;
        DocTypeEnum: Enum "Document Type Enum";
        TransTypeEnum: Enum "Transaction Type Enum";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateGSTLedgerEntry(Rec, RunTrigger, IsHandled);
        if IsHandled then
            exit;

        if (not RunTrigger) or (Rec."Entry Type" <> Rec."Entry Type"::"Initial Entry") or (Rec."Skip Tax Engine Trigger") then
            exit;

        UpdateDetailedGSTEntryTransNo(Rec);
        TransTypeEnum := GSTLedgerTransactionTypeTransactionTypeEnum(Rec."Transaction Type");
        if Rec."GST on Advance Payment" then begin
            if Rec."Transaction Type" = Rec."Transaction Type"::Purchase then
                SignFactor := 1
            else
                SignFactor := -1;
        end else begin
            DocTypeEnum := GSTLedgerDocument2DocumentTypeEnum(Rec."document type");
            SignFactor := Getsign(DocTypeEnum, TransTypeEnum);
        end;

        OnAfterUpdateGSTLedgerEntrySignFactor(Rec, SignFactor, DocTypeEnum, TransTypeEnum);

        if Rec."Transaction Type" = Rec."Transaction Type"::Sales then begin
            Rec."GST Base Amount" := (Rec."GST Base Amount") * SignFactor;
            Rec."GST Amount" := (Rec."GST Amount") * SignFactor;
        end else begin
            Rec."GST Base Amount" := Abs(Rec."GST Base Amount") * SignFactor;
            Rec."GST Amount" := Abs(Rec."GST Amount") * SignFactor;
        end;

        if GSTPostingManagement.GetPaytoVendorNo() <> '' then
            if Rec."Source Type" = Rec."Source Type"::Vendor then
                Rec."Source No." := GSTPostingManagement.GetPaytoVendorNo();

        OnAfterUpdateGSTLedgerEntryOnBeforeModify(Rec);
        Rec.Modify();
    end;

    //Detailed GST Ledger Entry
    [EventSubscriber(ObjectType::Table, Database::"Detailed GST Ledger Entry", 'OnAfterInsertEvent', '', false, false)]
    local procedure UpdateDetailedGstLedgerEntryOnafterInsertEvent(var Rec: Record "Detailed GST Ledger Entry"; RunTrigger: Boolean)
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTPostingManagement: Codeunit "GST Posting Management";
        SignFactor: Integer;
        DocTypeEnum: Enum "Document Type Enum";
        OriginalDocTypeEnum: Enum "Original Doc Type";
        TransTypeEnum: Enum "Transaction Type Enum";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateDetailedGstLedgerEntryOnafterInsertEvent(Rec, RunTrigger, IsHandled);
        if IsHandled then
            exit;

        GSTPostingManagement.SetRecord(Rec); //If called other than tax engine

        if (not RunTrigger) or (Rec."Entry Type" <> Rec."Entry Type"::"Initial Entry") or (Rec."Skip Tax Engine Trigger") then
            exit;

        if DetailedGSTLedgerEntryInfo.Get(Rec."Entry No.") then;

        SalesReceivablesSetup.Get();
        if Rec."Currency Code" <> '' then begin
            GSTPostingManagement.SetGSTAmountFCY(Rec."GST Amount");
            GSTPostingManagement.SetGSTBaseAmountFCY(Rec."GST Base Amount");

            Rec."GST Base Amount" := Abs(ConvertGSTAmountToLCY(
                                        Rec."Currency Code",
                                        Rec."GST Base Amount",
                                        Rec."Currency Factor",
                                        Rec."Posting Date",
                                        Rec."GST Component Code",
                                        DetailedGSTLedgerEntryInfo."Component Calc. Type"));

            Rec."GST Amount" := Abs(ConvertGSTAmountToLCY(
                                    Rec."Currency Code",
                                    Rec."GST Amount",
                                    Rec."Currency Factor",
                                    Rec."Posting Date",
                                    Rec."GST Component Code",
                                    DetailedGSTLedgerEntryInfo."Component Calc. Type"));

            if Rec."Transaction Type" = Rec."Transaction Type"::Purchase then begin
                if Rec."GST Assessable Value" <> 0 then
                    Rec."GST Assessable Value" := Abs(ConvertGSTAmountToLCY(
                                                    Rec."Currency Code",
                                                    Rec."GST Assessable Value",
                                                    Rec."Currency Factor",
                                                    Rec."Posting Date",
                                                    Rec."GST Component Code",
                                                    DetailedGSTLedgerEntryInfo."Component Calc. Type"));

                if Rec."Custom Duty Amount" <> 0 then
                    Rec."Custom Duty Amount" := Abs(ConvertGSTAmountToLCY(
                                                    Rec."Currency Code",
                                                    Rec."Custom Duty Amount",
                                                    Rec."Currency Factor",
                                                    Rec."Posting Date",
                                                    Rec."GST Component Code",
                                                    DetailedGSTLedgerEntryInfo."Component Calc. Type"));
            end;
        end;

        GetRoundingPrecision(Rec);
        if GSTRegistrationNos.Get(Rec."Location  Reg. No.") then
            Rec."Input Service Distribution" := GSTRegistrationNos."Input Service Distributor";

        TransTypeEnum := DetailedGSTLedgerTransactionType2TransactionTypeEnum(Rec."Transaction Type");
        if Rec."GST on Advance Payment" then begin
            if Rec."Transaction Type" = Rec."Transaction Type"::Purchase then
                SignFactor := 1
            else
                SignFactor := -1
        end else begin
            DocTypeEnum := DetailedGSTLedgerDocument2DocumentTypeEnum(Rec."Document Type");
            SignFactor := Getsign(DocTypeEnum, TransTypeEnum);
        end;

        OnAfterUpdateDetailedGSTLedgerEntrySignFactor(Rec, SignFactor, DocTypeEnum, TransTypeEnum);

        if Rec."Transaction Type" = Rec."Transaction Type"::Sales then begin
            Rec."GST Base Amount" := (Rec."GST Base Amount") * SignFactor;
            Rec."GST Amount" := (Rec."GST Amount") * SignFactor;
        end else begin
            Rec."GST Base Amount" := Abs(Rec."GST Base Amount") * SignFactor;
            Rec."GST Amount" := Abs(Rec."GST Amount") * SignFactor;
        end;

        if Rec."Document Type" = Rec."Document Type"::"Credit Memo" then
            Rec.Quantity := Abs(Rec.Quantity)
        else
            if ((Rec."Transaction Type" = Rec."Transaction Type"::Sales) and (Rec."Document Type" = Rec."Document Type"::Refund)) then
                Rec.Quantity := Abs(Rec.Quantity) * (-1)
            else
                Rec.Quantity := Abs(Rec.Quantity) * SignFactor;

        Rec."Remaining Base Amount" := Rec."GST Base Amount";
        Rec."Remaining GST Amount" := Rec."GST Amount";
        OriginalDocTypeEnum := DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(Rec."Document Type");
        if Rec."Document Type" = Rec."Document Type"::Refund then
            Rec."Remaining Quantity" := 0
        else
            Rec."Remaining Quantity" := Rec.Quantity;
        Rec."Amount Loaded on Item" := Abs(Rec."Amount Loaded on Item");
        if (Rec."Amount Loaded on Item" <> Rec."GST Amount") and (Rec."Amount Loaded on Item" <> 0) and (Rec."GST Credit" = Rec."GST Credit"::"Non-Availment") then
            Rec."Amount Loaded on Item" := Rec."GST Amount";

        OnAfterUpdateDetailedGstLedgerEntryAmountsField(Rec, SignFactor);

        if (Rec."Transaction Type" = Rec."Transaction Type"::Sales) and (Rec."GST Place of Supply" = Rec."GST Place of Supply"::" ") then
            Rec."GST Place of Supply" := SalesReceivablesSetup."GST Dependency Type";

        if (Rec."Transaction Type" = Rec."Transaction Type"::Purchase) and (Rec."Source Type" <> Rec."Source Type"::Party) then
            Rec."Source Type" := Rec."Source Type"::Vendor
        else
            if Rec."Transaction Type" = Rec."Transaction Type"::Sales then
                Rec."Source Type" := Rec."Source Type"::Customer;

        Rec."Executed Use Case ID" := GSTPostingManagement.GetUseCaseID();
        if Rec."Source Type" = Rec."Source Type"::Vendor then
            if GSTPostingManagement.GetPaytoVendorNo() <> '' then
                Rec."Source No." := GSTPostingManagement.GetPaytoVendorNo();

        if GSTPostingManagement.GetBuyerSellerRegNo() <> '' then
            Rec."Buyer/Seller Reg. No." := GSTPostingManagement.GetBuyerSellerRegNo();

        OnAfterUpdateDetailedGstLedgerEntryOnafterInsertEventOnBeforeModify(Rec, GSTRegistrationNos, DetailedGSTLedgerEntryInfo);
        Rec.Modify();

        GSTPostingManagement.SetRecord(Rec); //if Called from tax engine
    end;

    [EventSubscriber(ObjectType::Table, Database::"Detailed GST Ledger Entry Info", 'OnBeforeInsertEvent', '', false, false)]
    local procedure UpdateDetailedGSTEntryInfo(var Rec: Record "Detailed GST Ledger Entry Info")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        GSTPostingManagement: Codeunit "GST Posting Management";
        OriginalDocTypeEnum: Enum "Original Doc Type";
        DocTypeEnum: Enum "Document Type Enum";
        TransTypeEnum: Enum "Transaction Type Enum";
        Record: Variant;
        SignFactor: Integer;
    begin
        Record := DetailedGSTLedgerEntry;
        GSTPostingManagement.GetRecord(Record, Database::"Detailed GST Ledger Entry");
        DetailedGSTLedgerEntry := Record;
        if DetailedGSTLedgerEntry."Skip Tax Engine Trigger" then
            exit;

        Rec."Entry No." := DetailedGSTLedgerEntry."Entry No.";
        if DetailedGSTLedgerEntry."GST on Advance Payment" then begin
            if DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase then
                SignFactor := 1
            else
                SignFactor := -1
        end else begin
            TransTypeEnum := DetailedGSTLedgerTransactionType2TransactionTypeEnum(DetailedGSTLedgerEntry."Transaction Type");
            DocTypeEnum := DetailedGSTLedgerDocument2DocumentTypeEnum(DetailedGSTLedgerEntry."Document Type");
            SignFactor := Getsign(DocTypeEnum, TransTypeEnum);
        end;

        if DetailedGSTLedgerEntry."Currency Code" <> '' then begin
            Rec."GST Amount FCY" := GSTPostingManagement.GetGSTAmountFCY();
            Rec."GST Base Amount FCY" := GSTPostingManagement.GetGSTBaseAmountFCY();
        end;

        if DetailedGSTLedgerEntry."Entry Type" <> DetailedGSTLedgerEntry."Entry Type"::Application then begin
            OriginalDocTypeEnum := DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(DetailedGSTLedgerEntry."Document Type");
            Rec."Original Doc. Type" := OriginalDocTypeEnum;
            Rec."Original Doc. No." := DetailedGSTLedgerEntry."Document No.";
        end;

        if Rec."GST Amount FCY" <> 0 then
            Rec."GST Amount FCY" := Abs(Rec."GST Amount FCY") * SignFactor;

        if Rec."GST Base Amount FCY" <> 0 then
            Rec."GST Base Amount FCY" := Abs(Rec."GST Base Amount FCY") * SignFactor;

        if DetailedGSTLedgerEntry."GST Amount" > 0 then
            Rec.Positive := true
        else
            Rec.Positive := false;

        if (DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase)
            and (DetailedGSTLedgerEntry."Source Type" <> DetailedGSTLedgerEntry."Source Type"::Party) then
            Rec."Nature of Supply" := Rec."Nature of Supply"::B2B
        else
            if DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Sales then
                if DetailedGSTLedgerEntry."GST Customer Type" = DetailedGSTLedgerEntry."GST Customer Type"::Unregistered then
                    Rec."Nature of Supply" := Rec."Nature of Supply"::B2C
                else
                    Rec."Nature of Supply" := Rec."Nature of Supply"::B2B;

        if (DetailedGSTLedgerEntry."Transaction Type" = DetailedGSTLedgerEntry."Transaction Type"::Purchase) and
            (DetailedGSTLedgerEntry."Entry Type" = DetailedGSTLedgerEntry."Entry Type"::"Initial Entry") and
            (DetailedGSTLedgerEntry.Type = DetailedGSTLedgerEntry.Type::Item) and
            (Rec."Original Doc. Type" in [Rec."Original Doc. Type"::Invoice, Rec."Original Doc. Type"::"Credit Memo"])
        then
            UpdateGSTTrackingFromToEntryNo(DetailedGSTLedgerEntry."Entry No.");

        if GSTPostingManagement.GetBuyerSellerStateCode() <> '' then
            Rec."Buyer/Seller State Code" := GSTPostingManagement.GetBuyerSellerStateCode();

        UpdateECommOperatorGSTRegNo(DetailedGSTLedgerEntry, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterValidateEvent', 'P.A.N. No.', false, false)]
    local procedure ValidatePANNoOnAfterValidateEvent(var Rec: Record "Company Information")
    begin
        if Rec."P.A.N. No." <> '' then
            CheckGSTRegBlankInRef(Rec."P.A.N. No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterValidateEvent', 'State Code', False, False)]
    local procedure ValidateCompanyStateCodeOnAfterValidateEvent(var Rec: Record "Company Information")
    begin
        Rec.TestField("GST Registration No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Company Information", 'OnAfterValidateEvent', 'GST Registration No.', False, False)]
    local procedure ValdiateGSTRegistrationNoOnAfterValidateEvent(var Rec: Record "Company Information")
    begin
        Rec.TestField("State Code");
    end;

    //GST Group Validations - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Gst Group", 'OnAfterValidateEvent', 'GST Group Type', False, False)]
    local procedure ValidateGSTGroupTypeOnafterValidateEvent(var Rec: Record "GST Group")
    begin
        Rec.TestField("Reverse Charge", false);
    end;

    //GST Registration Nos. - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"GST Registration Nos.", 'OnAfterValidateEvent', 'Code', false, false)]
    local procedure ValidateRegistrationCodeonAfterValidateEvent(var Rec: Record "GST Registration Nos."; var xRec: Record "GST Registration Nos.")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        if CompanyInformation."P.A.N. No." <> '' then
            CheckGSTRegistrationNo(Rec."State Code", Rec.Code, CompanyInformation."P.A.N. No.")
        else
            Error(PANErr);

        if xRec.Code <> '' then
            CheckDependentDataInCompanyAndLocationAtEditing(xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Registration Nos.", 'OnAfterValidateEvent', 'State Code', false, false)]
    local procedure ValidateStateCodeonAfterValidateEvent(var Rec: Record "GST Registration Nos.")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CheckGSTRegistrationNo(Rec."State Code", Rec.Code, CompanyInformation."P.A.N. No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Registration Nos.", 'OnAfterDeleteEvent', '', false, false)]
    local procedure ValidateDeleteOnAfterDeleteEvent(var Rec: Record "GST Registration Nos.")
    begin
        CheckDependentDataInCompanyAndLocation(Rec);
    end;

    //GST Posting Setup - Subscribers
    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'receivable Account', False, False)]
    local procedure ValidatereceivableAccountOnafterValidateEvent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."receivable Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'Payable Account', False, False)]
    local procedure ValidatePayableAccountOnafterValidateEvent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."Payable Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'receivable Account (Interim)', False, False)]
    local procedure ValidatereceivableAccountInterimOnafterValidateEvent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."receivable Account (Interim)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'Payables Account (Interim)', False, False)]
    local procedure ValidatePayablesAccountInterimOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."Payables Account (Interim)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'Expense Account', False, False)]
    local procedure ValidateExpenseAccountOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."Expense Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'Refund Account', False, False)]
    local procedure ValidateRefundAccountOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."Refund Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'receivable Acc. Interim (Dist)', False, False)]
    local procedure ValidatereceivableAccInterimDistOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."receivable Acc. Interim (Dist)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'receivable Acc. (Dist)', False, False)]
    local procedure ValidatereceivableAccDisOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."receivable Acc. (Dist)");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'GST Credit Mismatch Account', False, False)]
    local procedure ValidateGSTCreditMismatchAccountOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."GST Credit Mismatch Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'GST TDS receivable Account', False, False)]
    local procedure ValidateGSTTDSreceivableAccountOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."GST TDS receivable Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'GST TCS receivable Account', False, False)]
    local procedure ValidateGSTTCSreceivableAccountOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."GST TCS receivable Account");
    end;

    [EventSubscriber(ObjectType::Table, Database::"GST Posting Setup", 'OnAfterValidateEvent', 'GST TCS Payable Account', False, False)]
    local procedure ValidateGSTTCSPayableAccountOnafterValidatEevent(var Rec: Record "GST Posting Setup")
    begin
        CheckGLAcc(Rec."GST TCS Payable Account");
    end;

    //Location Subscribers
    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'State Code', false, false)]
    local procedure CheckBlankGSTRegNoOnafterValidatEevent(var Rec: Record Location)
    begin
        Rec.TestField("GST Registration No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::Location, 'OnAfterValidateEvent', 'GST Registration No.', false, false)]
    local procedure validateGSTRegistrationNoOnafterValidatEevent(var Rec: Record Location)
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        Rec."GST Input Service Distributor" := false;
        if GSTRegistrationNos.Get(Rec."GST Registration No.") then
            Rec."GST Input Service Distributor" := GSTRegistrationNos."Input Service Distributor";
    end;

    //State Subscribers
    [EventSubscriber(ObjectType::Table, Database::State, 'OnAfterValidateEvent', 'State Code (GST Reg. No.)', False, False)]
    local procedure ValidateStateCodeGSTRegNoOnAfterValidateEvent(var Rec: Record State)
    begin
        if (Rec."State Code (GST Reg. No.)" <> '') and (StrLen(Rec."State Code (GST Reg. No.)") <> 2) then
            Error(LengthStateErr);

        Rec.TestField(Code);
        CheckUniqueGSTRegNoStateCode(Rec."State Code (GST Reg. No.)");
    end;

    //item Subscribers
    [EventSubscriber(ObjectType::Table, Database::item, 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateitemGSTGroupCodeOnAfterValidateEvent(var Rec: Record Item; var xRec: Record Item)
    begin
        if Rec."GST Group Code" <> xRec."GST Group Code" then
            Rec."HSN/SAC Code" := '';
    end;

    //G/L Account Subscribers
    [EventSubscriber(ObjectType::Table, Database::"G/L Account", 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure validateGLGSTGroupCodeOnAfterValidateEvent(var Rec: Record "G/L Account"; var xRec: Record "G/L Account")
    begin
        if Rec."GST Group Code" <> xRec."GST Group Code" then
            Rec."HSN/SAC Code" := '';
    end;

    //FA Subscribers
    [EventSubscriber(ObjectType::Table, Database::"Fixed Asset", 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateFAGSTGroupCodeOnAfterValidateEvent(var Rec: Record "Fixed Asset"; var xRec: Record "Fixed Asset")
    begin
        if Rec."GST Group Code" <> xRec."GST Group Code" then
            Rec."HSN/SAC Code" := '';
    end;

    //Resource Validations
    [EventSubscriber(ObjectType::Table, Database::Resource, 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateResourceGSTGroupCodeOnAfterValidateEvent(var Rec: Record Resource; var xRec: Record Resource)
    begin
        if Rec."GST Group Code" <> xRec."GST Group Code" then
            Rec."HSN/SAC Code" := '';
    end;

    //ItemCharge Validations
    [EventSubscriber(ObjectType::Table, Database::"Item Charge", 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateItemChargeGSTGroupCodeOnAfterValidateEvent(var Rec: Record "Item Charge"; var xRec: Record "Item Charge")
    begin
        if Rec."GST Group Code" <> xRec."GST Group Code" then
            Rec."HSN/SAC Code" := '';
    end;

    //ServiceCost Validations
    [EventSubscriber(ObjectType::Table, Database::"Service Cost", 'OnAfterValidateEvent', 'GST Group Code', False, False)]
    local procedure ValidateServiceCostGSTGroupCodeOnAfterValidateEvent(var Rec: Record "Service Cost"; var xRec: Record "Service Cost")
    begin
        if Rec."GST Group Code" <> xRec."GST Group Code" then
            Rec."HSN/SAC Code" := '';
    end;

    //Bank Account Validations
    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterValidateEvent', 'State Code', False, False)]
    local procedure ValidateBankAccStateCodeOnAfterValidateEvent(var Rec: Record "Bank Account")
    begin
        if Rec."GST Registration Status" = Rec."GST Registration Status"::Registered then
            Rec.TestField("GST Registration No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterValidateEvent', 'GST Registration Status', False, False)]
    local procedure ValidateGSTRegistrationStatusOnAfterValidateEvent(var Rec: Record "Bank Account")
    begin
        if Rec."GST Registration Status" = Rec."GST Registration Status"::Registered then begin
            Rec.TestField("GST Registration No.");
            Rec.TestField("State Code");
            CheckGSTRegistrationNo(Rec."State Code", Rec."GST Registration No.", '')
        end else
            Rec.TestField("GST Registration No.", '');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Account", 'OnAfterValidateEvent', 'GST Registration No.', False, False)]
    local procedure ValidateGSTRegistrationNoBankAccOnAfterValidateEvent(var Rec: Record "Bank Account")
    begin
        if Rec."GST Registration No." <> '' then begin
            Rec.TestField("State Code");
            CheckGSTRegistrationNo(Rec."State Code", Rec."GST Registration No.", '');
            Rec."GST Registration Status" := Rec."GST Registration Status"::Registered
        end else
            Rec."GST Registration Status" := Rec."GST Registration Status"::" ";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterRunWithoutCheck', '', false, false)]
    local procedure CheckProvisionalEntry(var GenJnlLine: Record "Gen. Journal Line")
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        if (GenJnlLine."TDS Section Code" = '') or (not GenJnlLine."Provisional Entry") then
            exit;

        TaxTransactionValue.SetLoadFields("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", GenJnlLine.RecordId);
        if TaxTransactionValue.IsEmpty then
            exit;

        GenJnlLine.TestField("GST Group Code", '');
    end;

    //Customer Subscribers
    [EventSubscriber(ObjectType::Table, Database::Customer, 'OnAfterValidateEvent', 'Post GST to Customer', False, False)]
    local procedure ValidatePostGSTtoCustomerOnAfterValidateEvent(var Rec: Record Customer)
    begin
        if not (Rec."GST Customer Type" In [Rec."GST Customer Type"::"SEZ Development", Rec."GST Customer Type"::"SEZ Unit"]) then
            Error(PostGSTtoCustErr)
    end;

    local procedure CheckGSTRegBlankInRef(PANNO: Code[20])
    var
        GSTRegistrationNos: Record "GST Registration Nos.";
    begin
        if GSTRegistrationNos.FindSet() then
            repeat
                if PANNO <> CopyStr(GSTRegistrationNos.Code, 3, 10) then
                    Error(CompnayGSTPANErr, GSTRegistrationNos.Code, GSTRegistrationNos."State Code");
            until GSTRegistrationNos.Next() = 0;
    end;

    local procedure CheckIsAlphabet(RegistrationNo: Code[20]; Position: Integer)
    begin
        if not (CopyStr(RegistrationNo, Position, 1) in ['A' .. 'Z']) then
            Error(OnlyAlphabetErr, Position);
    end;

    local procedure CheckIsNumeric(RegistrationNo: Code[20]; Position: Integer)
    begin
        if not (CopyStr(RegistrationNo, Position, 1) in ['0' .. '9']) then
            Error(OnlyNumericErr, Position);
    end;

    local procedure CheckIsAlphaNumeric(RegistrationNo: Code[20]; Position: Integer)
    begin
        if not ((CopyStr(RegistrationNo, Position, 1) in ['0' .. '9']) or (CopyStr(RegistrationNo, Position, 1) in ['A' .. 'Z'])) then
            Error(OnlyAlphaNumericErr, Position);
    end;

    local procedure CheckDependentDataInCompanyAndLocation(var GSTRegistrationNos: Record "GST Registration Nos.")
    var
        CompanyInformation: Record "Company Information";
        Location: Record location;
    begin
        if not CompanyInformation.Get() then
            exit;

        if CompanyInformation."GST Registration No." = GSTRegistrationNos.Code then
            Error(GSTCompyErr, GSTRegistrationNos.Code);

        Location.SetRange("GST Registration No.", GSTRegistrationNos.Code);
        if Location.FindFirst() then
            Error(GSTLocaErr, GSTRegistrationNos.Code, Location.Code);
    end;

    local procedure CheckDependentDataInCompanyAndLocationAtEditing(var GSTRegistrationNos: Record "GST Registration Nos.")
    var
        CompanyInformation: Record "Company Information";
        Location: Record Location;
    begin
        if not CompanyInformation.Get() then
            exit;

        if (CompanyInformation."GST Registration No." <> '') and (CompanyInformation."GST Registration No." = GSTRegistrationNos.Code) then
            Error(GSTCompyErr, GSTRegistrationNos.Code);

        Location.SetRange("GST Registration No.", GSTRegistrationNos.Code);
        if Location.FindFirst() then
            if (Location."GST Registration No." <> '') and (Location."GST Registration No." = GSTRegistrationNos.Code) then
                Error(GSTLocaErr, GSTRegistrationNos.Code, Location.Code);
    end;

    local procedure CheckGLAcc(AccNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo <> '' then begin
            GLAccount.Get(AccNo);
            GLAccount.CheckGLAcc();
        end;
    end;

    local procedure CheckUniqueGSTRegNoStateCode(StateCodeGSTRegNo: Code[10])
    var
        State: Record state;
    begin
        if StateCodeGSTRegNo <> '' then begin
            State.SetRange("State Code (GST Reg. No.)", "StateCodeGSTRegNo");
            if not State.IsEmpty() then
                Error(GSTStateCodeErr, State.FieldCaption("State Code (GST Reg. No.)"), StateCodeGSTRegNo);
        end;
    end;

    local procedure ConvertGSTAmountToLCY(
        CurrencyCode: Code[10]; Amount: Decimal;
        CurrencyFactor: Decimal;
        PostingDate: Date;
        ComponentCode: Text[30];
        CompCalcType: Enum "Component Calc Type"): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        TaxRateComputation: Codeunit "Tax Rate Computation";
    begin
        if CurrencyCode <> '' then begin
            if not GSTSetup.Get() then
                exit;

            GSTSetup.TestField("GST Tax Type");
            if CompCalcType = CompCalcType::General then
                TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type")
            else
                TaxComponent.SetRange("Tax Type", GSTSetup."Cess Tax Type");
            TaxComponent.SetFilter(Name, ComponentCode);
            TaxComponent.FindFirst();

            exit(TaxRateComputation.RoundAmount(CurrencyExchangeRate.ExchangeAmtFCYToLCY(PostingDate, CurrencyCode, Amount, CurrencyFactor),
                TaxComponent."Rounding Precision",
                TaxComponent.Direction));
        end;
    end;

    local procedure GetRoundingPrecision(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTInvRoundingType: Enum "GST Inv Rounding Type";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetRange(Name, DetailedGSTLedgerEntry."GST Component Code");
        if TaxComponent.FindFirst() then begin
            GSTInvRoundingType := TaxComponentDirections2DetailedGSTLedgerDirection(TaxComponent.Direction);
            DetailedGSTLedgerEntry."GST Rounding Precision" := TaxComponent."Rounding Precision";
            DetailedGSTLedgerEntry."GST Rounding Type" := GSTInvRoundingType;
        end;
    end;

    local procedure GetSign(DocumentType: Enum "Document Type Enum"; TransactionType: Enum "Transaction Type Enum") Sign: Integer
    begin
        if DocumentType in [DocumentType::Order, DocumentType::Invoice, DocumentType::Quote, DocumentType::"Blanket Order"] then
            Sign := 1
        else
            Sign := -1;

        if TransactionType = TransactionType::Purchase then
            Sign := Sign * 1
        else
            Sign := Sign * -1;

        exit(Sign);
    end;

    local procedure GetVendorLedgerEntryNo(TransactionNo: Integer): Integer
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetCurrentKey("Transaction No.");
        VendorLedgerEntry.SetRange("Transaction No.", TransactionNo);
        if VendorLedgerEntry.FindFirst() then
            exit(VendorLedgerEntry."Entry No.")
    end;

    local procedure GetCustomerLedgerEntryNo(TransactionNo: Integer): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetCurrentKey("Transaction No.");
        CustLedgerEntry.SetRange("Transaction No.", TransactionNo);
        if CustLedgerEntry.FindFirst() then
            exit(CustLedgerEntry."Entry No.")
    end;

    local procedure UpdateDetailedGSTEntryTransNo(var GSTLedgerEntry: Record "GST Ledger Entry")
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info";
        GSTPreviewHandler: Codeunit "GST Preview Handler";
        TransTypeEnum: Enum "Detail Ledger Transaction Type";
        DocumentTypeEnum: Enum "GST Document Type";
        IsHandled: Boolean;
    begin
        OnBeforeUpdateDetailedGstEntryTransNo(GSTLedgerEntry, IsHandled);
        if IsHandled then
            exit;

        TransTypeEnum := GSTLedgerTransactionType2DetailedLedgerTransactionType(GSTLedgerEntry."Transaction Type");
        DocumentTypeEnum := GSTLedgerDocumentType2DetailedLedgerDocumentType(GSTLedgerEntry."Document Type");
        DetailedGSTLedgerEntry.Reset();
        DetailedGSTLedgerEntry.SetCurrentKey("Transaction Type", "Entry Type", "Document Type", "Document No.", "Posting Date");
        DetailedGSTLedgerEntry.SetRange("Transaction Type", TransTypeEnum);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Document Type", DocumentTypeEnum);
        DetailedGSTLedgerEntry.SetRange("Document No.", GSTLedgerEntry."Document No.");
        DetailedGSTLedgerEntry.SetRange("Posting Date", GSTLedgerEntry."Posting Date");
        DetailedGSTLedgerEntry.SetRange("GST Component Code", GSTLedgerEntry."GST Component Code");
        if DetailedGSTLedgerEntry.FindSet() then begin

            if GSTLedgerEntry."Currency Code" <> '' then begin
                if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then;
                UpdteGSTLedgerEntryAmount(GSTLedgerEntry, DetailedGSTLedgerEntryInfo);
            end;

            DetailedGSTLedgerEntry.SetRange("GST Component Code");
            DetailedGSTLedgerEntry.FindSet();
            repeat
                DetailedGSTLedgerEntry."Transaction No." := GSTLedgerEntry."Transaction No.";
                if DetailedGSTLedgerEntryInfo.Get(DetailedGSTLedgerEntry."Entry No.") then begin
                    if GSTLedgerEntry."Transaction Type" = GSTLedgerEntry."Transaction Type"::Sales then
                        DetailedGSTLedgerEntryInfo."CLE/VLE Entry No." := GetCustomerLedgerEntryNo(GSTLedgerEntry."Transaction No.")
                    else
                        if GSTLedgerEntry."Transaction Type" = GSTLedgerEntry."Transaction Type"::Purchase then
                            DetailedGSTLedgerEntryInfo."CLE/VLE Entry No." := GetVendorLedgerEntryNo(GSTLedgerEntry."Transaction No.");

                    DetailedGSTLedgerEntryInfo.Modify();
                end;

                DetailedGSTLedgerEntry.Modify();
                GSTPreviewHandler.UpdateTempDetailedGSTLedgerEntry(DetailedGSTLedgerEntry);
            until DetailedGSTLedgerEntry.Next() = 0;
        end;
    end;

    local procedure GSTLedgerDocument2DocumentTypeEnum(GSTLedgerDocumentType: Enum "Detail GST Document Type"): Enum "Document Type Enum"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = GST Ledger Document Type';
    begin
        case GSTLedgerDocumentType of
            GSTLedgerDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            GSTLedgerDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            GSTLedgerDocumentType::Refund:
                exit("Document Type Enum"::Refund);
            GSTLedgerDocumentType::payment:
                exit("Document Type Enum"::payment);
            else
                Error(ConversionErr, GSTLedgerDocumentType);
        end;
    end;

    local procedure DetailedGSTLedgerDocument2DocumentTypeEnum(DetailedGSTLedgerDocumentType: Enum "GST Document Type"): Enum "Document Type Enum"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Detailed GST Ledger Document Type';
    begin
        case DetailedGSTLedgerDocumentType of
            DetailedGSTLedgerDocumentType::"Credit Memo":
                exit("Document Type Enum"::"Credit Memo");
            DetailedGSTLedgerDocumentType::Invoice:
                exit("Document Type Enum"::Invoice);
            DetailedGSTLedgerDocumentType::Refund:
                exit("Document Type Enum"::Refund);
            DetailedGSTLedgerDocumentType::payment:
                exit("Document Type Enum"::payment);
            else
                Error(ConversionErr, DetailedGSTLedgerDocumentType);
        end;
    end;

    local procedure DetailedGSTLedgerDocument2OriginalDocumentTypeEnum(DetailedGSTLedgerDocumentType: Enum "GST Document Type"): Enum "Original Doc Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = Detailed GST Ledger Document Type';
    begin
        case DetailedGSTLedgerDocumentType of
            DetailedGSTLedgerDocumentType::"Credit Memo":
                exit("Original Doc Type"::"Credit Memo");
            DetailedGSTLedgerDocumentType::Invoice:
                exit("Original Doc Type"::Invoice);
            DetailedGSTLedgerDocumentType::Refund:
                exit("Original Doc Type"::Refund);
            DetailedGSTLedgerDocumentType::payment:
                exit("Original Doc Type"::payment);
            else
                Error(ConversionErr, DetailedGSTLedgerDocumentType);
        end;
    end;

    local procedure GSTLedgerTransactionTypeTransactionTypeEnum(GSTLedgerTransactionType: Enum "GST Ledger Transaction Type"): Enum "Transaction Type Enum"
    var
        ConversionErr: Label 'Transaction Type %1 is not a valid option.', Comment = '%1 = GST Ledger Transaction Type';
    begin
        case GSTLedgerTransactionType of
            GSTLedgerTransactionType::purchase:
                exit("Transaction Type Enum"::Purchase);
            GSTLedgerTransactionType::Sales:
                exit("Transaction Type Enum"::sales);
            else
                Error(ConversionErr, GSTLedgerTransactionType);
        end;
    end;

    local procedure DetailedGSTLedgerTransactionType2TransactionTypeEnum(DetailedGSTLedgerTransactionType: Enum "Detail Ledger Transaction Type"): Enum "Transaction Type Enum"
    var
        ConversionErr: Label 'Transaction Type %1 is not a valid option.', Comment = '%1 = Detailed GST Ledger Transaction Type';
    begin
        case DetailedGSTLedgerTransactionType of
            DetailedGSTLedgerTransactionType::Purchase:
                exit("Transaction Type Enum"::Purchase);
            DetailedGSTLedgerTransactionType::Sales:
                exit("Transaction Type Enum"::Sales);
            DetailedGSTLedgerTransactionType::Transfer:
                exit("Transaction Type Enum"::Transfer);
            else
                Error(ConversionErr, DetailedGSTLedgerTransactionType);
        end;
    end;

    local procedure GSTLedgerTransactionType2DetailedLedgerTransactionType(GSTLedgerTransactionType: Enum "GST Ledger Transaction Type"): Enum "Detail Ledger Transaction Type"
    var
        ConversionErr: Label 'Transaction Type %1 is not a valid option.', Comment = '%1 = GST Ledger Transaction Type';
    begin
        case GSTLedgerTransactionType of
            GSTLedgerTransactionType::Purchase:
                exit("Detail Ledger Transaction Type"::Purchase);
            GSTLedgerTransactionType::Sales:
                exit("Detail Ledger Transaction Type"::Sales);
            else
                Error(ConversionErr, GSTLedgerTransactionType);
        end;
    end;

    local procedure TaxComponentDirections2DetailedGSTLedgerDirection(TaxComponentDirection: Enum "Rounding Direction"): Enum "GST Inv Rounding Type"
    var
        ConversionErr: Label 'Rounding Type %1 is not a valid option.', Comment = '%1 = GST Ledger Transaction Type';
    begin
        case TaxComponentDirection of
            TaxComponentDirection::Nearest:
                exit("GST Inv Rounding Type"::nearest);
            TaxComponentDirection::Up:
                exit("GST Inv Rounding Type"::Up);
            TaxComponentDirection::Down:
                exit("GST Inv Rounding Type"::Down);
            else
                Error(ConversionErr, TaxComponentDirection);
        end;
    end;

    local procedure GSTLedgerDocumentType2DetailedLedgerDocumentType(GSTLedgerDocumentType: Enum "Detail GST Document Type"): Enum "GST Document Type"
    var
        ConversionErr: Label 'Document Type %1 is not a valid option.', Comment = '%1 = GST Ledger Document Type';
    begin
        case GSTLedgerDocumentType of
            GSTLedgerDocumentType::Payment:
                exit("GST Document Type"::Payment);
            GSTLedgerDocumentType::Invoice:
                exit("GST Document Type"::Invoice);
            GSTLedgerDocumentType::"Credit Memo":
                exit("GST Document Type"::"Credit Memo");
            GSTLedgerDocumentType::Refund:
                exit("GST Document Type"::Refund);
            else
                Error(ConversionErr, GSTLedgerDocumentType);
        end;
    end;
    //Same Function called in GST Sales and Purchase
    procedure CheckGSTAccountingPeriod(PostingDate: Date; UsedForSettlement: Boolean)
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        TaxAccountingSubPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
        LastClosedDate: Date;
    begin

        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        LastClosedDate := GetLastClosedSubAccPeriod();
        TaxAccountingPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        if TaxAccountingPeriod.FindLast() then begin
            TaxAccountingPeriod.SetFilter("Starting Date", '>=%1', PostingDate);
            if not TaxAccountingPeriod.FindFirst() then
                Error(AccountingPeriodErr, PostingDate);

            if not UsedForSettlement then
                if LastClosedDate <> 0D then
                    if PostingDate < CalcDate('<1M>', LastClosedDate) then
                        Error(PeriodClosedErr, CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)), CalcDate('<1M>', LastClosedDate));

            TaxAccountingSubPeriod.Get(GSTSetup."GST Tax Type", TaxAccountingPeriod."Starting Date");
        end else
            Error(AccountingPeriodErr, PostingDate);

        TaxAccountingPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        if not UsedForSettlement then
            TaxAccountingPeriod.SetRange(Closed, false);

        TaxAccountingPeriod.SetFilter("Starting Date", '<=%1', PostingDate);
        if TaxAccountingPeriod.FindLast() then begin
            TaxAccountingPeriod.SetFilter("Starting Date", '>=%1', PostingDate);
            if not TaxAccountingPeriod.FindFirst() then
                if LastClosedDate <> 0D then
                    if PostingDate < CalcDate('<1M>', LastClosedDate) then
                        Error(PeriodClosedErr, CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)), CalcDate('<1M>', LastClosedDate));

            if not UsedForSettlement then
                TaxAccountingPeriod.TestField(Closed, false);
        end else
            if LastClosedDate <> 0D then
                if PostingDate < CalcDate('<1M>', LastClosedDate) then
                    Error(PeriodClosedErr, CalcDate('<-1D>', CalcDate('<1M>', LastClosedDate)), CalcDate('<1M>', LastClosedDate));
    end;

    local procedure GetLastClosedSubAccPeriod(): Date
    var
        TaxAccountingPeriod: Record "Tax Accounting Period";
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        GSTSetup.TestField("GST Tax Type");
        TaxAccountingPeriod.SetRange("Tax Type Code", GSTSetup."GST Tax Type");
        TaxAccountingPeriod.SetRange(Closed, true);
        if TaxAccountingPeriod.FindLast() then
            exit(TaxAccountingPeriod."Starting Date");
    end;

    procedure RoundGSTPrecision(GSTAmount: Decimal): Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GSTRoundingDirection: Text[1];
        GSTRoundingPrecision: Decimal;
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup.TestField("Inv. Rounding Precision (LCY)");
        case GeneralLedgerSetup."Inv. Rounding Type (LCY)" of
            GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest:
                GSTRoundingDirection := '=';
            GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Up:
                GSTRoundingDirection := '>';
            GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Down:
                GSTRoundingDirection := '<';
        end;

        GSTRoundingPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";
        exit(Round(GSTAmount, GSTRoundingPrecision, GSTRoundingDirection));
    end;

    procedure GetSignTransfer(DocumentType: Enum "Document Type Enum"; TransactionType: Enum "Transaction Type Enum") Sign: Integer
    begin
        if DocumentType in [DocumentType::Order, DocumentType::Invoice, DocumentType::Quote, DocumentType::"Blanket Order"] then
            Sign := 1
        else
            Sign := -1;

        if TransactionType = TransactionType::Purchase then
            Sign := Sign * 1
        else
            Sign := Sign * -1;

        exit(Sign);
    end;

    procedure RoundGSTInvoicePrecision(GSTAmount: Decimal; CurrencyCode: Code[10]): Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        GSTRoundingDirection: Text[1];
        GSTRoundingPrecision: Decimal;
    begin
        if GSTAmount = 0 then
            exit(0);

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Inv. Rounding Precision (LCY)" = 0 then
            exit;

        case GeneralLedgerSetup."Inv. Rounding Type (LCY)" of
            GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Nearest:
                GSTRoundingDirection := '=';
            GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Up:
                GSTRoundingDirection := '>';
            GeneralLedgerSetup."Inv. Rounding Type (LCY)"::Down:
                GSTRoundingDirection := '<';
        end;

        GSTRoundingPrecision := GeneralLedgerSetup."Inv. Rounding Precision (LCY)";

        exit(Round(GSTAmount, GSTRoundingPrecision, GSTRoundingDirection));
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnAfterGetGSTAmountFromTransNo', '', false, false)]
    local procedure UpdateGSTAmountInTDSEntry(TransactionNo: Integer; DocumentNo: Code[20]; var GSTAmount: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        GSTAmount := 0;
        DetailedGSTLedgerEntry.SetRange("Transaction No.", TransactionNo);
        DetailedGSTLedgerEntry.SetRange("Document No.", DocumentNo);
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        DetailedGSTLedgerEntry.SetRange("Journal Entry", true);
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                GSTAmount += DetailedGSTLedgerEntry."GST Amount";
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnBeforeSkipCallingTaxEngineForPurchLine', '', false, false)]
    local procedure OnBeforeSkipCallingTaxEngineForPurchLine(var PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        CheckGSTVendorType(PurchLine, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnBeforeEnableCallingTaxEngineForPurchLine', '', false, false)]
    local procedure OnBeforeEnableCallingTaxEngineForPurchLine(var PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    begin
        CheckGSTVendorType(PurchLine, IsHandled);
    end;

    local procedure CheckGSTVendorType(PurchLine: Record "Purchase Line"; var IsHandled: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if not PurchaseHeader.Get(PurchLine."Document Type", PurchLine."Document No.") then
            exit;

        if PurchaseHeader."GST Vendor Type" = PurchaseHeader."GST Vendor Type"::" " then
            IsHandled := true;
    end;

    local procedure UpdteGSTLedgerEntryAmount(var GSTLedgerEntry: Record "GST Ledger Entry"; var DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info")
    begin
        GSTLedgerEntry."GST Base Amount" := Abs(ConvertGSTAmountToLCY(
                                                    GSTLedgerEntry."Currency Code",
                                                    GSTLedgerEntry."GST Base Amount",
                                                    GSTLedgerEntry."Currency Factor",
                                                    GSTLedgerEntry."Posting Date",
                                                    GSTLedgerEntry."GST Component Code",
                                                    DetailedGSTLedgerEntryInfo."Component Calc. Type"));

        GSTLedgerEntry."GST Amount" := Abs(ConvertGSTAmountToLCY(
                                GSTLedgerEntry."Currency Code",
                                GSTLedgerEntry."GST Amount",
                                GSTLedgerEntry."Currency Factor",
                                GSTLedgerEntry."Posting Date",
                                GSTLedgerEntry."GST Component Code",
                                DetailedGSTLedgerEntryInfo."Component Calc. Type"));

        GSTLedgerEntry.Modify();
    end;

    procedure GenLedInvRoundingType2GSTInvRoundingTypeEnum(GenLedInvRoundingType: Option Nearest,Up,Down): Enum "GST Inv Rounding Type"
    begin
        case GenLedInvRoundingType of
            GenLedInvRoundingType::Down:
                exit("GST Inv Rounding Type"::Down);
            GenLedInvRoundingType::Nearest:
                exit("GST Inv Rounding Type"::Nearest);
            GenLedInvRoundingType::Up:
                exit("GST Inv Rounding Type"::Up);
        end;
    end;

    procedure CallTaxEngineOnPurchHeader(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        if PurchaseLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure UpdateGSTTrackingFromToEntryNo(EntryNo: Integer)
    var
        GSTTrackingEntry: Record "GST Tracking Entry";
        GSTPostingManagement: Codeunit "GST Posting Management";
        GSTTrackingEntNo: Integer;
    begin
        GSTTrackingEntNo := GSTPostingManagement.GetGSTTrackingEntryNo();
        if GSTTrackingEntry.Get(GSTTrackingEntNo) then begin
            if GSTTrackingEntry."From Entry No." = 0 then
                GSTTrackingEntry."From Entry No." := EntryNo;
            if GSTTrackingEntry."From To No." < EntryNo then
                GSTTrackingEntry."From To No." := EntryNo;
            GSTTrackingEntry.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Base Subscribers", 'OnAfterGetGSTAmountForSalesInvLines', '', false, false)]
    local procedure GetGSTAmountForSalesInvLines(SalesInvoiceLine: Record "Sales Invoice Line"; var GSTBaseAmount: Decimal; var GSTAmount: Decimal)
    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
    begin
        GSTAmount := 0;
        GSTBaseAmount := 0;
        DetailedGSTLedgerEntry.SetRange("Transaction Type", DetailedGSTLedgerEntry."Transaction Type"::Sales);
        DetailedGSTLedgerEntry.SetRange("Document Type", DetailedGSTLedgerEntry."Document Type"::Invoice);
        DetailedGSTLedgerEntry.SetRange("Document No.", SalesInvoiceLine."Document No.");
        DetailedGSTLedgerEntry.SetRange("Document Line No.", SalesInvoiceLine."Line No.");
        DetailedGSTLedgerEntry.SetRange("Entry Type", DetailedGSTLedgerEntry."Entry Type"::"Initial Entry");
        if DetailedGSTLedgerEntry.FindSet() then
            repeat
                if GSTBaseAmount = 0 then
                    GSTBaseAmount := DetailedGSTLedgerEntry."GST Base Amount";
                GSTAmount += DetailedGSTLedgerEntry."GST Amount";
            until DetailedGSTLedgerEntry.Next() = 0;
    end;

    procedure CheckGSTRegistrationNo(TransactionType: Enum "Transaction Type Enum"; DocType: Enum "Sales Document Type"; DocNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        PurchaseHeader: Record "Purchase Header";
        ServiceHeader: Record "Service Header";
        Customer: Record "Customer";
        Vendor: Record "Vendor";
        OrderAddress: Record "Order Address";
    begin
        case TransactionType of
            TransactionType::Purchase:
                begin
                    PurchaseHeader.Get(DocType, DocNo);
                    if (PurchaseHeader."Order Address Code" <> '') and
                        not (PurchaseHeader."GST Vendor Type" In [PurchaseHeader."GST Vendor Type"::Unregistered, PurchaseHeader."GST Vendor Type"::Import])
                    then begin
                        if PurchaseHeader."Order Address GST Reg. No." = '' then
                            if OrderAddress.Get(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Order Address Code") then
                                if OrderAddress."ARN No." = '' then
                                    Error(OrderAddressGSTARNErr);
                    end else
                        if PurchaseHeader."GST Vendor Type" In
                            [PurchaseHeader."GST Vendor Type"::Registered,
                            PurchaseHeader."GST Vendor Type"::Exempted,
                            PurchaseHeader."GST Vendor Type"::Composite,
                            PurchaseHeader."GST Vendor Type"::SEZ]
                        then
                            if PurchaseHeader."Vendor GST Reg. No." = '' then
                                if Vendor.GET(PurchaseHeader."Buy-from Vendor No.") then
                                    if Vendor."ARN No." = '' then
                                        Error(VendGSTARNErr);
                end;
            TransactionType::Sales:
                begin
                    SalesHeader.Get(DocType, DocNo);
                    if not (SalesHeader."GST Customer Type" In [SalesHeader."GST Customer Type"::Unregistered, SalesHeader."GST Customer Type"::Export]) then
                        if SalesHeader."Customer GST Reg. No." = '' then
                            if Customer.Get(SalesHeader."Sell-to Customer No.") then
                                if (Customer."ARN No." = '') or (SalesHeader."Bill-to Customer No." <> '') then
                                    if Customer.Get(SalesHeader."Bill-to Customer No.") then
                                        if Customer."ARN No." = '' then
                                            Error(CustGSTARNErr);
                end;
            TransactionType::Service:
                begin
                    ServiceHeader.Get(DocType, DocNo);
                    if not (ServiceHeader."GST Customer Type" In [ServiceHeader."GST Customer Type"::Unregistered, ServiceHeader."GST Customer Type"::Export]) then
                        if ServiceHeader."Customer GST Reg. No." = '' then
                            if Customer.Get(ServiceHeader."Customer No.") then
                                if Customer."ARN No." = '' then
                                    Error(CustGSTARNErr);
                end;
        end;
    end;

    procedure GetTaxComponentRoundingPrecision(var DetailedGSTEntryBuffer: Record "Detailed GST Entry Buffer"; TaxTransactionValue: Record "Tax Transaction value"): Decimal
    var
        TaxComponent: Record "Tax Component";
    begin
        if not TaxComponent.Get(TaxTransactionValue."Tax Type", TaxTransactionValue."Value ID") then
            exit;

        DetailedGSTEntryBuffer."GST Rounding Type" := TaxComponentDirections2DetailedGSTLedgerDirection(TaxComponent.Direction);
        DetailedGSTEntryBuffer."GST Rounding Precision" := TaxComponent."Rounding Precision";
        DetailedGSTEntryBuffer."GST Inv. Rounding Precision" := TaxComponent."Rounding Precision";
        DetailedGSTEntryBuffer."GST Inv. Rounding Type" := TaxComponentDirections2DetailedGSTLedgerDirection(TaxComponent.Direction);
    end;

    procedure RoundGSTPrecisionThroughTaxComponent(ComponenetCode: Code[30]; GSTAmount: Decimal): Decimal
    var
        TaxComponent: Record "Tax Component";
        GSTSetup: Record "GST Setup";
        GSTRoundingDirection: Text[1];
        GSTRoundingPrecision: Decimal;
    begin
        if not GSTSetup.Get() then
            exit;

        TaxComponent.SetFilter("Tax Type", '%1|%2', GSTSetup."GST Tax Type", GSTSetup."Cess Tax Type");
        TaxComponent.SetRange(Name, ComponenetCode);
        if TaxComponent.FindFirst() then begin
            GSTRoundingDirection := GetRoundingPrecisionofTaxComponent(TaxComponent);
            GSTRoundingDirection := GSTRoundingDirection;
            GSTRoundingPrecision := TaxComponent."Rounding Precision";
        end;

        exit(Round(GSTAmount, GSTRoundingPrecision, GSTRoundingDirection));
    end;

    local procedure GetRoundingPrecisionofTaxComponent(TaxComponent: Record "Tax Component"): Text[1]
    begin
        case TaxComponent.Direction of
            TaxComponent.Direction::Nearest:
                exit('=');
            TaxComponent.Direction::Up:
                exit('>');
            TaxComponent.Direction::Down:
                exit('<');
        end;
    end;

    local procedure UpdateECommOperatorGSTRegNo(
            DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
            var DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info")
    var
        ECommMerchant: Record "E-Comm. Merchant";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeGetEcommerceMerchant(DetailedGSTLedgerEntryInfo, IsHandled);
        if IsHandled then
            exit;

        if DetailedGSTLedgerEntryInfo."E-Comm. Merchant Id" = '' then
            exit;

        if ECommMerchant.Get(DetailedGSTLedgerEntry."Source No.", DetailedGSTLedgerEntryInfo."E-Comm. Merchant Id") then
            DetailedGSTLedgerEntryInfo."E-Comm. Operator GST Reg. No." := ECommMerchant."Company GST Reg. No.";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetEcommerceMerchant(DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateGSTLedgerEntry(var GSTLedgerEntry: Record "GST Ledger Entry"; RunTrigger: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateGSTLedgerEntryOnBeforeModify(var GSTLedgerEntry: Record "GST Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDetailedGstEntryTransNo(var GSTLedgerEntry: Record "GST Ledger Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateDetailedGstLedgerEntryOnafterInsertEvent(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; RunTrigger: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDetailedGstLedgerEntryOnafterInsertEventOnBeforeModify(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; GSTRegistrationNos: Record "GST Registration Nos."; var DetailedGSTLedgerEntryInfo: Record "Detailed GST Ledger Entry Info")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDetailedGstLedgerEntryAmountsField(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; SignFactor: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateDetailedGSTLedgerEntrySignFactor(var DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry"; var SignFactor: Integer; DocTypeEnum: Enum Microsoft.Finance.GST.Base."Document Type Enum"; TransTypeEnum: Enum Microsoft.Finance.GST.Base."Transaction Type Enum")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateGSTLedgerEntrySignFactor(var GSTLedgerEntry: Record "GST Ledger Entry"; var SignFactor: Integer; DocTypeEnum: Enum Microsoft.Finance.GST.Base."Document Type Enum"; TransTypeEnum: Enum Microsoft.Finance.GST.Base."Transaction Type Enum")
    begin
    end;

}
