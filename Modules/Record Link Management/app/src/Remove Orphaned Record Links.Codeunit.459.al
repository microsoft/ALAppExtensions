// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 459 "Remove Orphaned Record Links"
{

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if ConfirmManagement.GetResponseOrDefault(RemoveLinkConfirmQst,true) then begin
          RemoveOrphanedLink;
          if GuiAllowed then
            Message(ResultMsg,NoOfRemoved);
        end;
    end;

    var
        RemoveLinkConfirmQst: Label 'Do you want to remove links with no record reference?';
        RemovingMsg: Label 'Removing Record Links without record reference.\';
        RemovingStatusMsg: Label '@1@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        ResultMsg: Label '%1 orphaned links were removed.', Comment='%1 = number of orphaned record links found.';
        NoOfRemoved: Integer;

    local procedure RemoveOrphanedLink()
    var
        RecordLink: Record "Record Link";
        RecordRef: RecordRef;
        PrevRecID: RecordID;
        Window: Dialog;
        i: Integer;
        Total: Integer;
        TimeLocked: Time;
        InTransaction: Boolean;
        RecordExists: Boolean;
    begin
        if GuiAllowed then
          Window.Open(RemovingMsg + RemovingStatusMsg);
        TimeLocked := Time;
        with RecordLink do begin
          SetFilter(Company,'%1|%2','',CompanyName);
          SetCurrentKey("Record ID");
          Total := Count;
          if Total = 0 then
            exit;
          if Find('-') then
            repeat
              i := i + 1;
              if GuiAllowed and ((i mod 1000) = 0) then
                Window.Update(1,Round(i / Total * 10000,1));
              if Format("Record ID") <> Format(PrevRecID) then begin  // Direct comparison doesn't work.
                PrevRecID := "Record ID";
                RecordExists := RecordRef.Get("Record ID");
              end;
              if not RecordExists then begin
                Delete;
                NoOfRemoved := NoOfRemoved + 1;
                if not InTransaction then
                  TimeLocked := Time;
                InTransaction := true;
              end;
              if InTransaction and (Time > (TimeLocked + 1000)) then begin
                Commit;
                TimeLocked := Time;
                InTransaction := false;
              end;
            until Next = 0;
        end;
        if GuiAllowed then
          Window.Close;
    end;
}

