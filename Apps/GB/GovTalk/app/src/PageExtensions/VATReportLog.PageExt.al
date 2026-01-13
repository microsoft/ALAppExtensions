// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;

pageextension 10519 "VAT Report Log" extends "VAT Report Log"
{
    actions
    {
        modify("Download Submission Message")
        {
#if not CLEAN27
            Visible = DownloadMessage;
#else
            Visible = true;
#endif
        }
        modify("Download Response Message")
        {
#if not CLEAN27
            Visible = DownloadMessage;
#else
            Visible = true;
#endif
        }
    }

#if not CLEAN27
    trigger OnOpenPage()
    var
        GovTalk: Codeunit GovTalk;
    begin
        DownloadMessage := GovTalk.IsEnabled();
    end;

    var
        DownloadMessage: Boolean;
#endif
}