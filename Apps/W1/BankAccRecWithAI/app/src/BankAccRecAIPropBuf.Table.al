namespace Microsoft.Bank.Reconciliation;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.Dimension;

table 7251 "Bank Acc. Rec. AI Prop. Buf."
{
    TableType = Temporary;
    Extensible = false;
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    fields
    {
        field(1; "Bank Account No."; Code[20])
        {
            Caption = 'Bank Account No.';
            TableRelation = "Bank Account";
        }
        field(2; "Statement No."; Code[20])
        {
            Caption = 'Statement No.';
            TableRelation = "Bank Acc. Reconciliation"."Statement No." where("Bank Account No." = field("Bank Account No."));
        }
        field(3; "Statement Line No."; Integer)
        {
            Caption = 'Statement Line No.';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(5; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
        }
        field(6; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(8; Difference; Decimal)
        {
            AutoFormatExpression = GetCurrencyCode();
            AutoFormatType = 1;
            BlankZero = true;
            Caption = 'Amount to Apply';
        }
        field(20; "Statement Type"; Enum "Bank Acc. Rec. Stmt. Type")
        {
            Caption = 'Statement Type';
        }
        field(40; "G/L Account No."; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'G/L Account No.';
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                GLAccount: Record "G/L Account";
            begin
                if not GLAccount.Get("G/L Account No.") then
                    exit;

                "AI Proposal" := StrSubstNo(PostPaymentProposalTxt, "G/L Account No.", GLAccount.Name);
            end;
        }
        field(42; "AI Proposal"; Text[2048])
        {
            DataClassification = SystemMetadata;
            Caption = 'Proposal';
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            Editable = false;
            TableRelation = "Dimension Set Entry";

            trigger OnValidate()
            begin
                Rec."Dimension Set Text" := GetDimensionSetText(Rec."Dimension Set ID");
            end;
        }
        field(7480; "Dimension Set Text"; Text[2048])
        {
            Caption = 'Dimension Set Text';
            Editable = false;
        }
    }
    keys
    {
        key(Key1; "Statement Type", "Bank Account No.", "Statement No.", "Statement Line No.")
        {
            Clustered = true;
        }
    }

    local procedure GetCurrencyCode(): Code[10]
    var
        BankAccount: Record "Bank Account";
    begin
        if "Bank Account No." = BankAccount."No." then
            exit(BankAccount."Currency Code");

        if BankAccount.Get("Bank Account No.") then
            exit(BankAccount."Currency Code");

        exit('');
    end;

    internal procedure GetDimensionSetText(DimensionSetId: Integer): Text[2048]
    begin
        if DimensionSetId = 0 then
            exit(SetDimensionsLbl)
        else
            exit(EditDimensionsLbl)
    end;


    procedure EditDimensions() IsChanged: Boolean
    var
        OldDimSetID: Integer;
        NewDimSetId: Integer;
    begin
        OldDimSetID := Rec."Dimension Set ID";
        NewDimSetId := DimMgt.EditDimensionSet(Rec."Dimension Set ID", DimensionsForProposalTxt);

        IsChanged := OldDimSetID <> NewDimSetId;

        if IsChanged then
            Rec.Validate("Dimension Set ID", NewDimSetId);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        DimensionsForProposalTxt: label 'Dimensions for Copilot proposal';
        PostPaymentProposalTxt: label '%1 (%2)', Comment = '%1 - G/L Account number, %2 - G/L Account name';
        SetDimensionsLbl: label 'Set...';
        EditDimensionsLbl: label 'Edit...';
}