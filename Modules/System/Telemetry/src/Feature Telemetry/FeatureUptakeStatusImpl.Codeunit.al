// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8705 "Feature Uptake Status Impl."
{
    Access = Internal;
    TableNo = "Feature Uptake";
    Permissions = tabledata "Feature Uptake" = rimd;

    trigger OnRun()
    begin
        if not Rec.IsTemporary() then
            exit;

        UpdateFeatureUptakeStatus(Rec);
    end;

    procedure UpdateFeatureUptakeStatus(FeatureName: Text; FeatureUptakeStatus: Enum "Feature Uptake Status"; IsPerUser: Boolean; PerformWriteTransactionsInASeparateSession: Boolean; Publisher: Text) IsExpectedUpdate: Boolean
    var
        TempFeatureUptake: Record "Feature Uptake" temporary;
        UserSecurityIDForTheFeature: Guid;
        SessionID: Integer;
        IsExpectedTransition: Boolean;
    begin
        if IsPerUser then
            UserSecurityIDForTheFeature := UserSecurityId();

        TempFeatureUptake."Feature Name" := CopyStr(FeatureName, 1, MaxStrLen(TempFeatureUptake."Feature Name"));
        TempFeatureUptake."User Security ID" := UserSecurityIDForTheFeature;
        TempFeatureUptake."Feature Uptake Status" := FeatureUptakeStatus;
        TempFeatureUptake.Publisher := CopyStr(Publisher, 1, MaxStrLen(TempFeatureUptake.Publisher));

        if NeedToUpdateFeatureUptakeStatus(TempFeatureUptake, IsExpectedTransition) then
            if PerformWriteTransactionsInASeparateSession then
                StartSession(SessionID, Codeunit::"Feature Uptake Status Impl.", CompanyName(), TempFeatureUptake)
            else
                UpdateFeatureUptakeStatus(TempFeatureUptake);

        exit(IsExpectedTransition);
    end;

    local procedure NeedToUpdateFeatureUptakeStatus(TempFeatureUptake: Record "Feature Uptake" temporary; var IsExpectedTransition: Boolean): Boolean
    begin
        case TempFeatureUptake."Feature Uptake Status" of
            Enum::"Feature Uptake Status"::Discovered:
                exit(NeedToUpdateToFirstState(TempFeatureUptake, IsExpectedTransition));
            Enum::"Feature Uptake Status"::"Set up":
                exit(NeedToUpdateToIntermediateState(TempFeatureUptake, IsExpectedTransition));
            Enum::"Feature Uptake Status"::Used:
                exit(NeedToUpdateToIntermediateState(TempFeatureUptake, IsExpectedTransition));
            Enum::"Feature Uptake Status"::Undiscovered:
                begin
                    IsExpectedTransition := false; // the feature is now undiscovered
                    exit(NeedToResetState(TempFeatureUptake));
                end;
        end;
    end;

    local procedure UpdateFeatureUptakeStatus(TempFeatureUptake: Record "Feature Uptake" temporary)
    var
        FeatureUptake: Record "Feature Uptake";
    begin
        if FeatureUptake.Get(TempFeatureUptake."Feature Name", TempFeatureUptake."User Security ID", TempFeatureUptake.Publisher) then begin
            if TempFeatureUptake."Feature Uptake Status" = Enum::"Feature Uptake Status"::Undiscovered then
                FeatureUptake.Delete()
            else begin
                FeatureUptake."Feature Uptake Status" := TempFeatureUptake."Feature Uptake Status";
                FeatureUptake.Modify();
            end;
        end else begin
            FeatureUptake := TempFeatureUptake;
            FeatureUptake.Insert();
        end;
    end;

    local procedure NeedToUpdateToFirstState(TempFeatureUptake: Record "Feature Uptake" temporary; var IsExpectedTransition: Boolean): Boolean
    var
        FeatureUptake: Record "Feature Uptake";
    begin
        if FeatureUptake.Get(TempFeatureUptake."Feature Name", TempFeatureUptake."User Security ID", TempFeatureUptake.Publisher) then begin
            IsExpectedTransition := false; // the feature has already been discovered
            exit(false);
        end;

        IsExpectedTransition := true; // the status has changed to "Discovered"
        exit(true);
    end;

    local procedure NeedToUpdateToIntermediateState(TempFeatureUptake: Record "Feature Uptake" temporary; var IsExpectedTransition: Boolean): Boolean
    var
        FeatureUptake: Record "Feature Uptake";
        PreviousFeatureUptakeStatus: Enum "Feature Uptake Status";
    begin

        PreviousFeatureUptakeStatus := Enum::"Feature Uptake Status".FromInteger(TempFeatureUptake."Feature Uptake Status".AsInteger() - 1);

        if FeatureUptake.Get(TempFeatureUptake."Feature Name", TempFeatureUptake."User Security ID", TempFeatureUptake.Publisher) then begin
            if FeatureUptake."Feature Uptake Status" = PreviousFeatureUptakeStatus then begin
                // expected transition
                IsExpectedTransition := true;
                exit(true);
            end else begin
                // the user went back to the FeatureUptakeStatus step
                IsExpectedTransition := false;
                exit(false);
            end;
        end else begin
            FeatureUptake.SetRange("Feature Name", TempFeatureUptake."Feature Name");
            FeatureUptake.SetRange(Publisher, TempFeatureUptake.Publisher);
            if FeatureUptake.IsEmpty() then begin
                // there was no record with the previous feature uptake status
                IsExpectedTransition := false;
                exit(true);
            end else begin
                // per-tenant feature switches to being per-user or vice versa
                IsExpectedTransition := false;
                exit(false);
            end;
        end;
    end;

    local procedure NeedToResetState(TempFeatureUptake: Record "Feature Uptake" temporary): Boolean
    var
        FeatureUptake: Record "Feature Uptake";
    begin
        if FeatureUptake.Get(TempFeatureUptake."Feature Name", TempFeatureUptake."User Security ID", TempFeatureUptake.Publisher) then
            exit(true);

        exit(false);
    end;
}