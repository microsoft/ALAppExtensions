// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.FixedAssets.FixedAsset;

tableextension 31245 "FA Posting Group CZF" extends "FA Posting Group"
{
    fields
    {
        field(31240; "Acq. Cost Bal. Acc. Disp. CZF"; Code[20])
        {
            Caption = 'Acqusition Cost Bal. Account on Disposal';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Acq. Cost Bal. Acc. Disp. CZF");
            end;
        }
        field(31241; "Book Value Bal. Acc. Disp. CZF"; Code[20])
        {
            Caption = 'Book Value Bal. Account on Disposal';
            TableRelation = "G/L Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckGLAccount("Book Value Bal. Acc. Disp. CZF");
            end;
        }
    }

    var
        PostingSetupManagementCZF: Codeunit PostingSetupManagement;

    local procedure CheckGLAccount(AccNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        if AccNo = '' then
            exit;
        GLAccount.Get(AccNo);
        GLAccount.CheckGLAcc();
    end;

    procedure GetAcquisitionCostBalanceAccountOnDisposalCZF(): Code[20]
    begin
        if "Acq. Cost Bal. Acc. Disp. CZF" = '' then
            PostingSetupManagementCZF.LogFAPostingGroupFieldError(Rec, FieldNo("Acq. Cost Bal. Acc. Disp. CZF"));

        exit("Acq. Cost Bal. Acc. Disp. CZF");
    end;

    procedure GetBookValueBalAccountOnDisposalCZF(): Code[20]
    begin
        if "Book Value Bal. Acc. Disp. CZF" = '' then
            PostingSetupManagementCZF.LogFAPostingGroupFieldError(Rec, FieldNo("Book Value Bal. Acc. Disp. CZF"));

        exit("Book Value Bal. Acc. Disp. CZF");
    end;

    procedure GetSalesAccountOnDisposalGainCZF(ReasonCode: Code[20]): Code[20]
    begin
        if UseStandardDisposalCZF(ReasonCode) then
            exit(GetSalesAccountOnDisposalGain());
        exit(GetFAExtendedPostingGroupForDisposalCZF(ReasonCode).GetSalesAccountOnDisposalGain());
    end;

    procedure GetSalesAccountOnDisposalLossCZF(ReasonCode: Code[20]): Code[20]
    begin
        if UseStandardDisposalCZF(ReasonCode) then
            exit(GetSalesAccountOnDisposalLoss());
        exit(GetFAExtendedPostingGroupForDisposalCZF(ReasonCode).GetSalesAccountOnDisposalLoss());
    end;

    procedure GetBookValueAccountOnDisposalGainCZF(ReasonCode: Code[20]): Code[20]
    begin
        if UseStandardDisposalCZF(ReasonCode) then
            exit(GetBookValueAccountOnDisposalGain());
        exit(GetFAExtendedPostingGroupForDisposalCZF(ReasonCode).GetBookValueAccountOnDisposalGain());
    end;

    procedure GetBookValueAccountOnDisposalLossCZF(ReasonCode: Code[20]): Code[20]
    begin
        if UseStandardDisposalCZF(ReasonCode) then
            exit(GetBookValueAccountOnDisposalLoss());
        exit(GetFAExtendedPostingGroupForDisposalCZF(ReasonCode).GetBookValueAccountOnDisposalLoss());
    end;

    procedure GetMaintenanceExpenseAccountCZF(MaintenanceCode: Code[20]): Code[20]
    begin
        if UseStandardMaintenanceCZF(MaintenanceCode) then
            exit(GetMaintenanceExpenseAccount());
        exit(GetFAExtendedPostingGroupForMaintenanceCZF(MaintenanceCode).GetMaintenanceExpenseAccount());
    end;

    procedure GetMaintenanceBalanceAccountCZF(MaintenanceCode: Code[20]): Code[20]
    begin
        if UseStandardMaintenanceCZF(MaintenanceCode) then
            exit(GetMaintenanceBalanceAccount());
        exit(GetFAExtendedPostingGroupForMaintenanceCZF(MaintenanceCode).GetExtendedMaintenanceBalanceAccount());
    end;

    procedure CalcAllocatedBookValueGainCZF(ReasonCode: Code[20]): Decimal
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        if UseStandardDisposalCZF(ReasonCode) then begin
            CalcFields("Allocated Book Value % (Gain)");
            exit("Allocated Book Value % (Gain)");
        end;
        FAExtendedPostingGroupCZF := GetFAExtendedPostingGroupForDisposalCZF(ReasonCode);
        FAExtendedPostingGroupCZF.CalcFields("Allocated Book Value % (Gain)");
        exit(FAExtendedPostingGroupCZF."Allocated Book Value % (Gain)");
    end;

    procedure CalcAllocatedBookValueLossCZF(ReasonCode: Code[20]): Decimal
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        if UseStandardDisposalCZF(ReasonCode) then begin
            CalcFields("Allocated Book Value % (Loss)");
            exit("Allocated Book Value % (Loss)");
        end;
        FAExtendedPostingGroupCZF := GetFAExtendedPostingGroupForDisposalCZF(ReasonCode);
        FAExtendedPostingGroupCZF.CalcFields("Allocated Book Value % (Loss)");
        exit(FAExtendedPostingGroupCZF."Allocated Book Value % (Loss)");
    end;

    procedure UseStandardDisposalCZF(ReasonCode: Code[20]): Boolean
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        FAExtendedPostingGroupCZF.SetRange("FA Posting Group Code", Code);
        FAExtendedPostingGroupCZF.SetRange("FA Posting Type", FAExtendedPostingGroupCZF."FA Posting Type"::Disposal);
        FAExtendedPostingGroupCZF.SetRange(Code, ReasonCode);
        exit(FAExtendedPostingGroupCZF.IsEmpty());
    end;

    procedure UseStandardMaintenanceCZF(MaintenanceCode: Code[20]): Boolean
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        FAExtendedPostingGroupCZF.SetRange("FA Posting Group Code", Code);
        FAExtendedPostingGroupCZF.SetRange("FA Posting Type", FAExtendedPostingGroupCZF."FA Posting Type"::Maintenance);
        FAExtendedPostingGroupCZF.SetRange(Code, MaintenanceCode);
        exit(FAExtendedPostingGroupCZF.IsEmpty());
    end;

    local procedure GetFAExtendedPostingGroupForDisposalCZF(ReasonCode: Code[20]) FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF"
    begin
        FAExtendedPostingGroupCZF.Get(Code, Enum::"FA Extended Posting Type CZF"::Disposal, ReasonCode);
    end;

    local procedure GetFAExtendedPostingGroupForMaintenanceCZF(MaintenanceCode: Code[20]) FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF"
    begin
        FAExtendedPostingGroupCZF.Get(Code, Enum::"FA Extended Posting Type CZF"::Maintenance, MaintenanceCode);
    end;
}
