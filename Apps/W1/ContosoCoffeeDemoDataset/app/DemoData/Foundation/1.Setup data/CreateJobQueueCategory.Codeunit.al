// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 5414 "Create Job Queue Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoJobQueue: Codeunit "Contoso Job Queue";
    begin
        ContosoJobQueue.InsertJobQueueCategory(SalesPurchasePosting(), SalesPurchasePostCategoryLbl);
        ContosoJobQueue.InsertJobQueueCategory(GeneralLedgerPosting(), JournlPostPostCategoryLbl);
    end;

    procedure GeneralLedgerPosting(): Code[10]
    begin
        exit(JrnlPostTok);
    end;

    procedure SalesPurchasePosting(): Code[10]
    begin
        exit(DocPostTok);
    end;

    var
        DocPostTok: Label 'DOCPOST', MaxLength = 10;
        JrnlPostTok: Label 'JRNLPOST', MaxLength = 10;
        SalesPurchasePostCategoryLbl: Label 'Sales/Purchase Posting', MaxLength = 30;
        JournlPostPostCategoryLbl: Label 'General Ledger Posting', MaxLength = 30;
}
