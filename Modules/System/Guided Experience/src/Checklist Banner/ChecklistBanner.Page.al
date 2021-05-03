// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Lists the checklist items that a user should go through to finalize their onboarding experience.
/// </summary>
page 1990 "Checklist Banner"
{
    PageType = CardPart;
    SourceTable = "Checklist Item Buffer";
    SourceTableTemporary = true;
    RefreshOnActivate = true;
    Extensible = false;

    // ---------------------IMPORTANT---------------------------
    // ---------------------------------------------------------
    // DO NOT CHANGE THE NAMES OF ANY OF THE FIELDS ON THIS PAGE.
    // THE CLIENT WILL NOT BE ABLE TO RENDER THE PAGE PROPERLY 
    // OTHERWISE.
    // ---------------------------------------------------------
    // ---------------------IMPORTANT---------------------------

    layout
    {
        area(content)
        {
            field(Title; TitleTxt)
            {
                ApplicationArea = All;
                ToolTip = 'Title';
                Caption = 'Title';
            }
            field(Header; HeaderTxt)
            {
                ApplicationArea = All;
                ToolTip = 'Header';
                Caption = 'Header';
            }
            field(Description; DescriptionTxt)
            {
                ApplicationArea = All;
                ToolTip = 'Description';
                Caption = 'Description';
            }
            field(TitleCollapsed; TitleCollapsedTxt)
            {
                ApplicationArea = All;
                ToolTip = 'Title';
                Caption = 'Title';
            }
            field(HeaderCollapsed; HeaderCollapsedTxt)
            {
                ApplicationArea = All;
                ToolTip = 'Description';
                Caption = 'Description';
            }
            field(SetupMarkAsDone; MarkChecklistAsCompleted)
            {
                ApplicationArea = All;
                ToolTip = 'Mark as completed';
                Caption = 'Mark as completed';

                trigger OnValidate()
                var
                    UserChecklistStatus: Enum "Checklist Status";
                begin
                    if MarkChecklistAsCompleted then begin
                        SetChecklistStatusAndLabels(false, false, true);
                        ChecklistBanner.UpdateUserChecklistStatus(UserId(), UserChecklistStatus::Completed);
                    end;
                end;
            }


            repeater(Checklist)
            {
                Caption = 'Your checklist:';
                Visible = IsChecklistInProgress;

                field(TaskTitle; Rec."Short Title")
                {
                    ApplicationArea = All;
                    ToolTip = 'Title';
                }
                field(TaskHeader; Rec.Title)
                {
                    ApplicationArea = All;
                    ToolTip = 'Header';
                }
                field(TaskDescription; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Description';
                }
                field(TaskStatus; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Status';
                }
                field(TaskStatusText; ChecklistBanner.GetStatusText(Rec))
                {
                    ApplicationArea = All;
                    Visible = Status <> Status::Started;
                    ToolTip = 'Status';
                    Caption = 'Status';
                }
                field(TaskExclusiveWhenStarted; true)
                {
                    ApplicationArea = All;
                    ToolTip = 'Exclusive when started';
                    Caption = 'Exclusive when started';
                }
                field(TaskMarkAsCompleted; MarkChecklistItemAsCompleted)
                {
                    ApplicationArea = All;
                    Caption = 'Mark as completed';
                    ToolTip = 'Mark as completed';
                    Visible = IsChecklistItemStarted;

                    trigger OnValidate()
                    begin
                        if MarkChecklistItemAsCompleted then
                            ChecklistBanner.UpdateChecklistItemUserStatus(Rec, UserId(), Rec.Status::Completed);

                        ChecklistCompletionCount += 1;

                        CheckForChecklistCompletion();

                        UpdateLabelTexts();

                        IsChecklistItemStarted := Status = Status::Started;
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(StartSetup)
            {
                ApplicationArea = All;
                Caption = 'Get started';
                ToolTip = 'Get started';
                Visible = not IsChecklistInProgress and not IsChecklistDisplayed and not AreAllItemsCompletedOrSkipped;
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    OnChecklistStart();
                end;
            }
            action(CloseSetup)
            {
                ApplicationArea = All;
                Caption = 'Got it';
                ToolTip = 'Got it';
                Visible = AreAllItemsCompletedOrSkipped;
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    ChecklistImplementation.SetChecklistVisibility(UserId(), false);
                    CurrPage.Close();
                end;
            }
            action(SkipSetup)
            {
                ApplicationArea = All;
                Caption = 'Skip checklist';
                ToolTip = 'Skip checklist';
                Visible = IsChecklistInProgress and not AreAllItemsCompletedOrSkipped;
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    if Confirm(SkipSetupConfirmLbl) then begin
                        ChecklistBanner.UpdateUserChecklistStatus(UserId(), ChecklistStatus::Skipped);
                        ChecklistImplementation.SetChecklistVisibility(UserId(), false);

                        CurrPage.Close();
                    end;
                end;
            }
            action(BackToChecklist)
            {
                ApplicationArea = All;
                Caption = 'Back to checklist';
                ToolTip = 'Back to checklist';
                Visible = not IsChecklistDisplayed and (IsChecklistInProgress or AreAllItemsCompletedOrSkipped);
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    OnChecklistStart();
                end;
            }
            action(TaskStart)
            {
                ApplicationArea = All;
                Caption = 'Start';
                ToolTip = 'Start';
                Scope = Repeater;
                Visible = IsChecklistInProgress and ((Status = Status::"Not Started") or (Status = Status::Skipped));
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    ExecuteChecklistItem();
                end;
            }
            action(TaskStartOver)
            {
                ApplicationArea = All;
                Caption = 'Revisit';
                ToolTip = 'Revisit';
                Scope = Repeater;
                Visible = IsChecklistInProgress and ((Status = Status::Started) or (Status = Status::Completed));
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    ExecuteChecklistItem();
                end;
            }
            action(TaskSkip)
            {
                ApplicationArea = All;
                Caption = 'Skip for now';
                ToolTip = 'Skip for now';
                Scope = Repeater;
                Visible = IsChecklistInProgress and ((Status = Status::"Not Started") or (Status = Status::Started));
                Image = AssessFinanceCharges;

                trigger OnAction()
                begin
                    ChecklistBanner.UpdateChecklistItemUserStatus(Rec, UserId(), Rec.Status::Skipped);

                    ChecklistSkipCount += 1;

                    CheckForChecklistCompletion();

                    UpdateLabelTexts();
                end;
            }
        }
    }

    var
        ChecklistItemBuffer: Record "Checklist Item Buffer";
        ChecklistBanner: Codeunit "Checklist Banner";
        ChecklistImplementation: Codeunit "Checklist Implementation";
        ChecklistStatus: Enum "Checklist Status";
        IsChecklistInProgress: Boolean;
        AreAllItemsCompletedOrSkipped: Boolean;
        IsChecklistDisplayed: Boolean;
        IsChecklistItemStarted: Boolean;
        MarkChecklistItemAsCompleted: Boolean;
        MarkChecklistAsCompleted: Boolean;
        TitleTxt: Text;
        TitleCollapsedTxt: Text;
        HeaderTxt: Text;
        HeaderCollapsedTxt: Text;
        DescriptionTxt: Text;
        SkipSetupConfirmLbl: Label 'Are you sure that you want to skip the remaining steps of the checklist?';
        ChecklistCompletionCount: Integer;
        ChecklistSkipCount: Integer;
        ChecklistTotalCount: Integer;

    trigger OnInit()
    begin
        UpdateLabelTexts();
    end;

    trigger OnOpenPage()
    begin
        ChecklistBanner.OnChecklistBannerOpen(Rec, IsChecklistInProgress, IsChecklistDisplayed);

        SetChecklistRecord();

        SetCounts();
        AreAllItemsCompletedOrSkipped := AreAllChecklistItemsCompletedOrSkipped();

        if Rec.Count > 0 then
            UpdateLabelTexts();

        ChecklistItemBuffer.Copy(Rec, true);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        IsChecklistItemStarted := Status = Status::Started;
    end;

    trigger OnAfterGetRecord()
    begin
        MarkChecklistItemAsCompleted := Status = Status::Completed;
    end;

    trigger OnClosePage()
    begin
        if ChecklistBanner.IsUserChecklistStatusComplete(UserId) then
            ChecklistImplementation.SetChecklistVisibility(UserId(), false);
    end;

    local procedure OnChecklistStart()
    begin
        ChecklistBanner.UpdateUserChecklistStatus(UserId(), ChecklistStatus::"In progress");

        SetChecklistRecord();

        SetChecklistStatusAndLabels(true, true, AreAllChecklistItemsCompletedOrSkipped());

        CurrPage.Update();
    end;

    local procedure SetChecklistRecord()
    begin
        Rec.SetRange(Status, Status::Started);
        if Rec.FindFirst() then
            CurrPage.SetRecord(Rec)
        else begin
            Rec.SetRange(Status, Status::"Not Started");
            if Rec.FindFirst() then
                CurrPage.SetRecord(Rec);
        end;

        Rec.Reset();
        Rec.SetCurrentKey("Order ID");
    end;

    local procedure SetChecklistStatusAndLabels(ChecklistInProgress: Boolean; ChecklistDisplayed: Boolean; AllItemsSkippedOrCompleted: Boolean)
    begin
        IsChecklistInProgress := ChecklistInProgress;
        IsChecklistDisplayed := ChecklistDisplayed;
        AreAllItemsCompletedOrSkipped := AllItemsSkippedOrCompleted;

        UpdateLabelTexts();
    end;

    local procedure UpdateLabelTexts()
    begin
        ChecklistBanner.UpdateBannerLabels(Rec, TitleTxt, TitleCollapsedTxt, HeaderTxt, HeaderCollapsedTxt, DescriptionTxt, IsChecklistInProgress, AreAllItemsCompletedOrSkipped);
    end;

    local procedure CheckForChecklistCompletion()
    begin
        AreAllItemsCompletedOrSkipped := AreAllChecklistItemsCompletedOrSkipped();

        if AreAllItemsCompletedOrSkipped then begin
            ChecklistBanner.UpdateUserChecklistStatus(UserId(), ChecklistStatus::Completed);
            IsChecklistDisplayed := false;
        end;
    end;

    local procedure AreAllChecklistItemsCompletedOrSkipped(): Boolean
    begin
        exit(ChecklistCompletionCount + ChecklistSkipCount = ChecklistTotalCount);
    end;

    local procedure SetCounts()
    begin
        ChecklistTotalCount := Rec.Count;

        Rec.SetFilter(Status, '=%1', Status::Skipped);
        ChecklistSkipCount := Rec.Count;

        Rec.SetFilter(Status, '=%1', Status::Completed);
        ChecklistCompletionCount := Rec.Count;

        SetChecklistRecord();
    end;

    local procedure UpdateChecklistCountsAfterStatusUpdate(OldStatus: Enum "Checklist Item Status")
    begin
        if OldStatus = OldStatus::Skipped then
            ChecklistSkipCount -= 1
        else
            if OldStatus = OldStatus::Completed then
                ChecklistCompletionCount -= 1;
    end;

    local procedure ExecuteChecklistItem()
    var
        IsLastChecklistItem: Boolean;
    begin
        UpdateChecklistCountsAfterStatusUpdate(Status);

        Rec.Validate(Status, Status::Started);
        Modify();

        if ChecklistItemBuffer.FindLast() then
            if ChecklistItemBuffer.Code = Rec.Code then
                IsLastChecklistItem := true;

        if ChecklistBanner.ExecuteChecklistItem(Rec, IsLastChecklistItem) then
            ChecklistCompletionCount += 1;

        CheckForChecklistCompletion();

        UpdateLabelTexts();
    end;
}
