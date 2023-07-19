pageextension 31248 "Fixed Asset Card CZF" extends "Fixed Asset Card"
{
    layout
    {
        modify(FAPostingGroup)
        {
            trigger OnBeforeValidate()
            begin
                if FADepreciationBook."FA Posting Group" <> FADepreciationBookOld."FA Posting Group" then
                    FADepreciationBook.CheckDefaultFAPostingGroupCZF();
            end;

            trigger OnAfterValidate()
            begin
                UpdateFAPostingGroup(FADepreciationBook."FA Posting Group");
            end;
        }
        addafter("Responsible Employee")
        {
            field("Tax Deprec. Group Code CZF"; Rec."Tax Deprec. Group Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the tax deprecation book.';
                Visible = false;
            }
            field("Classification Code CZF"; Rec."Classification Code CZF")
            {
                ApplicationArea = FixedAssets;
                ToolTip = 'Specifies the fixed asset''s classification (CZ-CC, CZ-CPA, DNM).';
            }
        }
    }
    actions
    {
        modify(Acquire)
        {
            Visible = false;
        }
        addlast(History)
        {
            action(FAHistoryCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA History Entries';
                Image = History;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "FA History Entries CZF";
                RunPageLink = "FA No." = field("No.");
                RunPageView = sorting("FA No.");
                ToolTip = 'Open fixed asset history entries.';
            }
        }
        addlast(reporting)
        {
            action(FixedAssetHistoryCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset History';
                Image = PrintReport;
                RunObject = Report "Fixed Asset History CZF";
                ToolTip = 'The report prints fixed asset history entries.';
            }
            action(FAAssignmentDiscardCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'FA Assignment/Discard';
                Image = PrintAcknowledgement;
                Ellipsis = true;
                RunObject = Report "FA Assignment/Discard CZF";
                ToolTip = 'The report prints fixed assignment/discard protocol.';
            }
            action(FixedAssetAcquisitionCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Acquisition';
                Image = PrintReport;
                RunObject = Report "Fixed Asset Acquisition CZF";
                ToolTip = 'The report prints fixed asset acquisition.';
            }
            action(FixedAssetDisposalCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Disposal';
                Image = PrintReport;
                RunObject = Report "Fixed Asset Disposal CZF";
                ToolTip = 'The report prints fixed assets disposal.';
            }
            action(FixedAssetCardCZF)
            {
                ApplicationArea = FixedAssets;
                Caption = 'Fixed Asset Card';
                Image = FixedAssets;
                RunObject = Report "Fixed Asset Card CZF";
                ToolTip = 'The report prints fixed assets card and entries.';
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        if FADepreciationBook.Count() > 1 then begin
            FASetup.Get();
            if not FADepreciationBook.Get(Rec."No.", FASetup."Default Depr. Book") then
                FADepreciationBook.Init();
        end;
        UpdateFAPostingGroup(FADepreciationBook."FA Posting Group");
    end;

    var
        FASetup: Record "FA Setup";

    local procedure UpdateFAPostingGroup(FAPostingGroup: Code[20])
    begin
        if FAPostingGroup = Rec."FA Posting Group" then
            exit;
        Rec.Validate("FA Posting Group", FAPostingGroup);
        CurrPage.Update();
    end;
}
