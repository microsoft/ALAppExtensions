// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Sales.History;
using System.Utilities;

#pragma implicitwith disable
page 31137 "EET Simple Registration CZL"
{
    Caption = 'EET Simple Registration';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    ShowFilter = false;
    SourceTable = "EET Entry CZL";
    SourceTableTemporary = true;
    SourceTableView = sorting("Entry No.") where("Entry No." = const(0));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Business Premises Code"; Rec."Business Premises Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of the business premises.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupBusinessPremisesCode(Text));
                    end;

                    trigger OnValidate()
                    begin
                        ValidateBusinessPremisesCode();
                    end;
                }
                field("Cash Register Code"; Rec."Cash Register Code")
                {
                    ApplicationArea = Basic, Suite;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the code of the EET cash register.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupCashRegisterCode(Text));
                    end;

                    trigger OnValidate()
                    begin
                        ValidateCashRegisterCode();
                    end;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s document number.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the EET entry.';
                }
                field(TotalSalesAmount; TotalSalesAmount)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total Sales Amount';
                    ToolTip = 'Specifies the total amount of cash document.';

                    trigger OnValidate()
                    begin
                        ValidateTotalSalesAmount();
                    end;
                }
                field("Applied Document Type"; Rec."Applied Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the type of the applied document.';

                    trigger OnValidate()
                    begin
                        ValidateAppliedDocType();
                    end;
                }
                field("Applied Document No."; Rec."Applied Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the applied document.';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        exit(LookupAppliedDocNo(Text));
                    end;

                    trigger OnValidate()
                    begin
                        ValidateAppliedDocNo();
                    end;
                }
            }
            group(Sales)
            {
                Caption = 'Sales';
                group(GroupVATRateBasic)
                {
                    Caption = 'VAT Rate Basic';
                    field("SalesAmount[1]"; SalesAmount[1])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Sales Amount';
                        ToolTip = 'Specifies Sales Amount (VAT Rate Basic)';

                        trigger OnValidate()
                        begin
                            ValidateSalesAmount(1);
                        end;
                    }
                    field("VATBase[1]"; VATBase[1])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'VAT Base';
                        ToolTip = 'Specifies the VAT base amount.';

                        trigger OnValidate()
                        begin
                            ValidateVATBase(1);
                        end;
                    }
                    field("VATAmount[1]"; VATAmount[1])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'VAT Amount';
                        ToolTip = 'Specifies the base VAT amount.';

                        trigger OnValidate()
                        begin
                            ValidateVATAmount(1);
                        end;
                    }
                    field("VATRate[1]"; VATRate[1])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT %';
                        DecimalPlaces = 0 : 2;
                        MaxValue = 100;
                        MinValue = 0;
                        ToolTip = 'Specifies VAT %';

                        trigger OnValidate()
                        begin
                            ValidateVATRate(1);
                        end;
                    }
                    field("AmountArt90[1]"; AmountArt90[1])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amount - Art.90';
                        Importance = Additional;
                        ToolTip = 'Specifies the base amount under paragraph 90th.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                }
                group(GroupVATRateReduced)
                {
                    Caption = 'VAT Rate Reduced';
                    field("SalesAmount[2]"; SalesAmount[2])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Sales Amount';
                        ToolTip = 'Specifies Sales Amount (VAT Rate Reduced)';

                        trigger OnValidate()
                        begin
                            ValidateSalesAmount(2);
                        end;
                    }
                    field("VATBase[2]"; VATBase[2])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'VAT Base';
                        ToolTip = 'Specifies the reduced VAT base amount.';

                        trigger OnValidate()
                        begin
                            ValidateVATBase(2);
                        end;
                    }
                    field("VATAmount[2]"; VATAmount[2])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'VAT Amount';
                        ToolTip = 'Specifies the reduced VAT amount.';

                        trigger OnValidate()
                        begin
                            ValidateVATAmount(2);
                        end;
                    }
                    field("VATRate[2]"; VATRate[2])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT %';
                        DecimalPlaces = 0 : 2;
                        MaxValue = 100;
                        MinValue = 0;
                        ToolTip = 'Specifies VAT %';

                        trigger OnValidate()
                        begin
                            ValidateVATRate(2);
                        end;
                    }
                    field("AmountArt90[2]"; AmountArt90[2])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amount - Art.90';
                        Importance = Additional;
                        ToolTip = 'Specifies the reduced amount under paragraph 90th.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                }
                group(GroupVATRateReduced2)
                {
                    Caption = 'VAT Rate Reduced 2';
                    field("SalesAmount[3]"; SalesAmount[3])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Sales Amount';
                        ToolTip = 'Specifies Sales Amount (VAT Rate Reduced 2)';

                        trigger OnValidate()
                        begin
                            ValidateSalesAmount(3);
                        end;
                    }
                    field("VATBase[3]"; VATBase[3])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'VAT Base';
                        ToolTip = 'Specifies the reduced VAT base amount.';

                        trigger OnValidate()
                        begin
                            ValidateVATBase(3);
                        end;
                    }
                    field("VATAmount[3]"; VATAmount[3])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'VAT Amount';
                        ToolTip = 'Specifies the reduced VAT amount 2.';

                        trigger OnValidate()
                        begin
                            ValidateVATAmount(3);
                        end;
                    }
                    field("VATRate[3]"; VATRate[3])
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'VAT %';
                        DecimalPlaces = 0 : 2;
                        MaxValue = 100;
                        MinValue = 0;
                        ToolTip = 'Specifies VAT %';

                        trigger OnValidate()
                        begin
                            ValidateVATRate(3);
                        end;
                    }
                    field("AmountArt90[3]"; AmountArt90[3])
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amount - Art.90';
                        Importance = Additional;
                        ToolTip = 'Specifies the reduced VAT base amount.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                }
                group(GroupAmountOthers)
                {
                    Caption = 'Others';
                    field(AmountArt89; AmountArt89)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amount - Art.89';
                        Importance = Additional;
                        ToolTip = 'Specifies the amount under paragraph 89th.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                    field(AmountExtFromVAT; AmountExtFromVAT)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amount Exempted From VAT';
                        Importance = Additional;
                        ToolTip = 'Specifies the amount of cash document VAT-exempt.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                    field(AmtForSubseqDrawSettle; AmtForSubseqDrawSettle)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amt. For Subseq. Draw/Settle';
                        Importance = Additional;
                        ToolTip = 'Specifies the amount of the payments for subsequent drawdown or settlement.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                    field(AmtSubseqDrawnSettled; AmtSubseqDrawnSettled)
                    {
                        ApplicationArea = Basic, Suite;
                        AutoFormatType = 1;
                        Caption = 'Amt. Subseq. Drawn/Settled';
                        Importance = Additional;
                        ToolTip = 'Specifies the amount of the subsequent drawing or settlement.';

                        trigger OnValidate()
                        begin
                            UpdateTotalSalesAmount();
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Send)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Send';
                Image = SendElectronicDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Sends the selected entry to the EET service to register.';

                trigger OnAction()
                begin
                    SendToService();
                    CurrPage.Update();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        GetSetup();
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        EETServiceSetupCZL: Record "EET Service Setup CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        TotalSalesAmount: Decimal;
        SalesAmount: array[3] of Decimal;
        VATRate: array[3] of Decimal;
        VATBase: array[3] of Decimal;
        VATAmount: array[3] of Decimal;
        AmountArt89: Decimal;
        AmountArt90: array[3] of Decimal;
        AmountExtFromVAT: Decimal;
        AmtForSubseqDrawSettle: Decimal;
        AmtSubseqDrawnSettled: Decimal;

    local procedure GetSetup()
    begin
        GeneralLedgerSetup.Get();
        EETServiceSetupCZL.Get();
        InitVATRate();
    end;

    local procedure InitVATRate()
    var
        VATPostingSetup: Record "VAT Posting Setup";
        i: Integer;
    begin
        for i := 1 to 3 do begin
            VATPostingSetup.SetRange("VAT Rate CZL", i);
            if VATPostingSetup.FindFirst() then
                VATRate[i] := VATPostingSetup."VAT %";
        end;
    end;

    local procedure LookupBusinessPremisesCode(var Text: Text): Boolean
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        EETBusinessPremisesCZL.Code := Rec."Business Premises Code";
        if Page.RunModal(0, EETBusinessPremisesCZL) = Action::LookupOK then begin
            Rec."Business Premises Code" := EETBusinessPremisesCZL.Code;
            ValidateBusinessPremisesCode();
            Text := EETBusinessPremisesCZL.Code;
            exit(true);
        end;
    end;

    local procedure ValidateBusinessPremisesCode()
    var
        EETBusinessPremisesCZL: Record "EET Business Premises CZL";
    begin
        if Rec."Business Premises Code" <> '' then
            EETBusinessPremisesCZL.Get(Rec."Business Premises Code");
        Rec."Cash Register Code" := '';
    end;

    local procedure LookupCashRegisterCode(var Text: Text): Boolean
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        EETCashRegisterCZL.SetRange("Business Premises Code", Rec."Business Premises Code");
        EETCashRegisterCZL."Business Premises Code" := Rec."Business Premises Code";
        EETCashRegisterCZL.Code := Rec."Cash Register Code";
        if Page.RunModal(0, EETCashRegisterCZL) = Action::LookupOK then begin
            Text := EETCashRegisterCZL.Code;
            exit(true);
        end;
    end;

    local procedure ValidateCashRegisterCode()
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
    begin
        Rec."Cash Register Type" := Rec."Cash Register Type"::Default;
        Rec."Cash Register No." := '';

        if Rec."Cash Register Code" <> '' then begin
            EETCashRegisterCZL.Get(Rec."Business Premises Code", Rec."Cash Register Code");
            Rec."Cash Register Type" := EETCashRegisterCZL."Cash Register Type";
            Rec."Cash Register No." := EETCashRegisterCZL."Cash Register No.";
        end;
    end;

    local procedure ValidateAppliedDocType()
    begin
        Rec."Applied Document No." := '';
    end;

    local procedure LookupAppliedDocNo(var Text: Text): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case Rec."Applied Document Type" of
            Rec."Applied Document Type"::Invoice:
                begin
                    SalesInvoiceHeader."No." := Rec."Applied Document No.";
                    if Page.RunModal(0, SalesInvoiceHeader) = Action::LookupOK then begin
                        Text := SalesInvoiceHeader."No.";
                        exit(true);
                    end;
                end;
            Rec."Applied Document Type"::"Credit Memo":
                begin
                    SalesCrMemoHeader."No." := Rec."Applied Document No.";
                    if Page.RunModal(0, SalesCrMemoHeader) = Action::LookupOK then begin
                        Text := SalesCrMemoHeader."No.";
                        exit(true);
                    end;
                end;
        end;
    end;

    local procedure ValidateAppliedDocNo()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        if Rec."Applied Document No." <> '' then
            case Rec."Applied Document Type" of
                Rec."Applied Document Type"::Invoice:
                    SalesInvoiceHeader.Get(Rec."Applied Document No.");
                Rec."Applied Document Type"::"Credit Memo":
                    SalesCrMemoHeader.Get(Rec."Applied Document No.");
            end;
    end;

    local procedure ValidateSalesAmount(Index: Integer)
    begin
        VATBase[Index] := Round(SalesAmount[Index] / (1 + VATRate[Index] / 100), GeneralLedgerSetup."Amount Rounding Precision");
        VATAmount[Index] := SalesAmount[Index] - VATBase[Index];
        UpdateTotalSalesAmount();
    end;

    local procedure ValidateVATBase(Index: Integer)
    begin
        VATAmount[Index] := Round(VATBase[Index] * VATRate[Index] / 100, GeneralLedgerSetup."Amount Rounding Precision");
        SalesAmount[Index] := VATBase[Index] + VATAmount[Index];
        UpdateTotalSalesAmount();
    end;

    local procedure ValidateVATAmount(Index: Integer)
    begin
        SalesAmount[Index] := VATBase[Index] + VATAmount[Index];
        if VATBase[Index] <> 0 then
            VATRate[Index] := Round(VATAmount[Index] / VATBase[Index] * 100, 0.01);
        UpdateTotalSalesAmount();
    end;

    local procedure ValidateVATRate(Index: Integer)
    begin
        VATAmount[Index] := Round(VATBase[Index] * VATRate[Index] / 100, GeneralLedgerSetup."Amount Rounding Precision");
        SalesAmount[Index] := VATBase[Index] + VATAmount[Index];
        UpdateTotalSalesAmount();
    end;

    local procedure ValidateTotalSalesAmount()
    begin
        Clear(SalesAmount);
        Clear(VATBase);
        Clear(VATAmount);
        Clear(VATRate);
        Clear(AmountArt89);
        Clear(AmountArt90);
        Clear(AmountExtFromVAT);
        Clear(AmtForSubseqDrawSettle);
        Clear(AmtSubseqDrawnSettled);
        InitVATRate();

        SalesAmount[1] := TotalSalesAmount;
        ValidateSalesAmount(1);
    end;

    local procedure UpdateTotalSalesAmount()
    begin
        TotalSalesAmount :=
          SalesAmount[1] + SalesAmount[2] + SalesAmount[3] +
          AmountArt89 + AmountArt90[1] + AmountArt90[2] + AmountArt90[3] +
          AmountExtFromVAT + AmtForSubseqDrawSettle + AmtSubseqDrawnSettled;
    end;

    procedure SendToService()
    var
        EETEntryCZL: Record "EET Entry CZL";
        EETManagementCZL: Codeunit "EET Management CZL";
        NewEETEntryNo: Integer;
        MustEnterErr: Label 'You must enter %1.', Comment = '%1 = Field Name';
        SendToServiceQst: Label 'Do you want to send sales to EET service?';
        OpenNewEntryQst: Label 'The new entry %1 has been created. Do you want to open the new entry?', Comment = '%1 = New EET Entry No.';
    begin
        if Rec."Business Premises Code" = '' then
            Error(MustEnterErr, Rec.FieldCaption("Business Premises Code"));
        if Rec."Cash Register Code" = '' then
            Error(MustEnterErr, Rec.FieldCaption("Cash Register Code"));
        if TotalSalesAmount = 0 then
            Error(MustEnterErr, Rec.FieldCaption("Total Sales Amount"));

        if not ConfirmManagement.GetResponseOrDefault(SendToServiceQst, true) then
            exit;

        Rec."Total Sales Amount" := TotalSalesAmount;
        Rec."Amount Exempted From VAT" := AmountExtFromVAT;
        Rec."VAT Base (Basic)" := VATBase[1];
        Rec."VAT Amount (Basic)" := VATAmount[1];
        Rec."VAT Base (Reduced)" := VATBase[2];
        Rec."VAT Amount (Reduced)" := VATAmount[2];
        Rec."VAT Base (Reduced 2)" := VATBase[3];
        Rec."VAT Amount (Reduced 2)" := VATAmount[3];
        Rec."Amount - Art.89" := AmountArt89;
        Rec."Amount (Basic) - Art.90" := AmountArt90[1];
        Rec."Amount (Reduced) - Art.90" := AmountArt90[2];
        Rec."Amount (Reduced 2) - Art.90" := AmountArt90[3];
        Rec."Amt. For Subseq. Draw/Settle" := AmtForSubseqDrawSettle;
        Rec."Amt. Subseq. Drawn/Settled" := AmtSubseqDrawnSettled;

        EETEntryCZL.Init();
        EETEntryCZL.CopyFromEETEntry(Rec);
        EETEntryCZL.TestField("Total Sales Amount", EETEntryCZL.SumPartialAmounts());
        NewEETEntryNo := EETManagementCZL.CreateSimpleEETEntry(EETEntryCZL);
        Commit();

        EETEntryCZL.Get(NewEETEntryNo);
        EETManagementCZL.TrySendEntryToService(EETEntryCZL);

        Rec.Init();
        CurrPage.Update();
        InitVATRate();
        Clear(TotalSalesAmount);
        ValidateTotalSalesAmount();

        Commit();
        if ConfirmManagement.GetResponse(StrSubstNo(OpenNewEntryQst, EETEntryCZL."Entry No."), true) then
            Page.Run(Page::"EET Entry Card CZL", EETEntryCZL);
    end;
}
