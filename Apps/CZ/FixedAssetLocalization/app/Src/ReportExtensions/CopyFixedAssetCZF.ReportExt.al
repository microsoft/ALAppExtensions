// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.FixedAssets;

using Microsoft.FixedAssets.FixedAsset;
using Microsoft.FixedAssets.Setup;

reportextension 11706 "Copy Fixed Asset CZF" extends "Copy Fixed Asset"
{
    requestpage
    {
        layout
        {
            addlast(Options)
            {
                field(PostingDateOfFAHistoryEntryCZF; PostingDateOfFAHistoryEntry)
                {
                    ApplicationArea = FixedAssets;
                    Visible = FAHistoryEnabled;
                    Enabled = FAHistoryEnabled;
                    Caption = 'Posting Date of FA History Entry';
                    ToolTip = 'Specifies the posting date of the FA history entry if the fixed asset is copied to the new fixed asset.';

                    trigger OnValidate()
                    begin
                        CopyFixedAssetHandlerCZF.SetPostingDateOfFAHistoryEntry(PostingDateOfFAHistoryEntry);
                    end;
                }
            }
            addafter(Options)
            {
                group(ApplyCZF)
                {
                    Caption = 'Apply';
                    field(CopyFALocationCZF; CopyFALocation)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Copy FA Location';
                        ToolTip = 'Specifies that the fixed asset location will be copied to the new fixed asset.';

                        trigger OnValidate()
                        begin
                            CopyFixedAssetHandlerCZF.SetCopyFALocation(CopyFALocation);
                        end;
                    }
                    field(CopyResponsibleEmployeeCZF; CopyResponsibleEmployee)
                    {
                        ApplicationArea = FixedAssets;
                        Caption = 'Copy Responsible Employee';
                        ToolTip = 'Specifies that the responsible employee will be copied to the new fixed asset.';

                        trigger OnValidate()
                        begin
                            CopyFixedAssetHandlerCZF.SetCopyResponsibleEmployee(CopyResponsibleEmployee);
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            FAHistoryEnabled := IsFixedAssetHistoryEnabled();
            CopyFALocation := true;
            CopyResponsibleEmployee := true;
            PostingDateOfFAHistoryEntry := WorkDate();

            CopyFixedAssetHandlerCZF.SetCopyFALocation(CopyFALocation);
            CopyFixedAssetHandlerCZF.SetCopyResponsibleEmployee(CopyResponsibleEmployee);
            CopyFixedAssetHandlerCZF.SetPostingDateOfFAHistoryEntry(PostingDateOfFAHistoryEntry);
            CopyFixedAssetHandlerCZF.Activate();
        end;
    }

    var
        CopyFixedAssetHandlerCZF: Codeunit "Copy Fixed Asset Handler CZF";
        CopyFALocation: Boolean;
        CopyResponsibleEmployee: Boolean;
        FAHistoryEnabled: Boolean;
        PostingDateOfFAHistoryEntry: Date;

    local procedure IsFixedAssetHistoryEnabled(): Boolean
    var
        FixedAssetSetup: Record "FA Setup";
    begin
        FixedAssetSetup.Get();
        exit(FixedAssetSetup."Fixed Asset History CZF");
    end;
}