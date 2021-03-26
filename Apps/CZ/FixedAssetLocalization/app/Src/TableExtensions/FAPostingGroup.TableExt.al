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
        TestField("Acq. Cost Bal. Acc. Disp. CZF");
        exit("Acq. Cost Bal. Acc. Disp. CZF");
    end;

    procedure GetBookValueBalAccountOnDisposalCZF(): Code[20]
    begin
        TestField("Book Value Bal. Acc. Disp. CZF");
        exit("Book Value Bal. Acc. Disp. CZF");
    end;

    procedure UseStandardDisposalCZF(): Boolean
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        FAExtendedPostingGroupCZF.SetRange("FA Posting Group Code", Code);
        FAExtendedPostingGroupCZF.SetRange("FA Posting Type", FAExtendedPostingGroupCZF."FA Posting Type"::Disposal);
        exit(FAExtendedPostingGroupCZF.IsEmpty());
    end;

    procedure UseStandardMaintenanceCZF(): Boolean
    var
        FAExtendedPostingGroupCZF: Record "FA Extended Posting Group CZF";
    begin
        FAExtendedPostingGroupCZF.SetRange("FA Posting Group Code", Code);
        FAExtendedPostingGroupCZF.SetRange("FA Posting Type", FAExtendedPostingGroupCZF."FA Posting Type"::Maintenance);
        exit(FAExtendedPostingGroupCZF.IsEmpty());
    end;
}
