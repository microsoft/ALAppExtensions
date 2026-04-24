// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;
using Microsoft.Foundation.NoSeries;

codeunit 11764 "Copy Fixed Asset Handler CZF"
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    var
        FASetup: Record "FA Setup";
        FAHistoryManagementCZF: Codeunit "FA History Management CZF";
        CopyFALocation: Boolean;
        CopyResponsibleEmployee: Boolean;
        PostingDateOfFAHistoryEntry: Date;

    procedure Activate()
    begin
        BindSubscription(this);
    end;

    procedure SetCopyFALocation(NewCopyFALocation: Boolean)
    begin
        CopyFALocation := NewCopyFALocation;
    end;

    procedure SetCopyResponsibleEmployee(NewCopyResponsibleEmployee: Boolean)
    begin
        CopyResponsibleEmployee := NewCopyResponsibleEmployee;
    end;

    procedure SetPostingDateOfFAHistoryEntry(NewPostingDateOfFAHistoryEntry: Date)
    begin
        PostingDateOfFAHistoryEntry := NewPostingDateOfFAHistoryEntry;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Fixed Asset", 'OnOnPreReportOnBeforeFA2Insert', '', false, false)]
    local procedure OnOnPreReportOnBeforeFA2Insert(var FixedAsset2: Record "Fixed Asset"; var FixedAsset: Record "Fixed Asset")
    begin
        if not CopyFALocation then
            FixedAsset2."FA Location Code" := '';
        if not CopyResponsibleEmployee then
            FixedAsset2."Responsible Employee" := '';
    end;

    [EventSubscriber(ObjectType::Report, Report::"Copy Fixed Asset", 'OnAfterFixedAssetCopied', '', false, false)]
    local procedure InitializeHistoryOnAfterFixedAssetCopied(FixedAsset2: Record "Fixed Asset")
    var
        NoSeries: Codeunit "No. Series";
        DocumentNo: Code[20];
    begin
        FASetup.Get();
        if not FASetup."Fixed Asset History CZF" then
            exit;

        if (FixedAsset2."FA Location Code" <> '') or (FixedAsset2."Responsible Employee" <> '') then begin
            FASetup.TestField("Fixed Asset History Nos. CZF");
            DocumentNo := NoSeries.GetNextNo(FASetup."Fixed Asset History Nos. CZF");
        end;
        FAHistoryManagementCZF.InitializeFAHistory(FixedAsset2, PostingDateOfFAHistoryEntry, DocumentNo);
    end;
}