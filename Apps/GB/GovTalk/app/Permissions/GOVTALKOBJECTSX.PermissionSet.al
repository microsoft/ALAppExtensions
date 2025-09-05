// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

permissionset 10526 "GovTalk - Objects X"
{
    Access = Internal;
    Assignable = false;
    Permissions = codeunit "Create VAT Declaration Req." = X,
                  codeunit "EC Sales List Submit GB" = X,
                  codeunit "EC Sales List XML" = X,
                  codeunit "GovTalk Message Management" = X,
                  codeunit "Gov Talk Setup" = X,
                  codeunit "GovTalk Validate VAT Report" = X,
                  codeunit "HMRC GovTalk Msg. Scheduler" = X,
                  codeunit "HMRC Submission Helpers" = X,
                  codeunit "Sandbox Cleanup" = X,
                  codeunit "Submit VAT Declaration Req." = X,
                  page "Gov Talk Setup" = X,
                  query "EU VAT Entries GB" = X;
}