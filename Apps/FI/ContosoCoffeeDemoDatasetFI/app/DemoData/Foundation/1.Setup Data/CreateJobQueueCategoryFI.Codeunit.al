// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 13412 "Create Job Queue Category FI"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoJobQueue: Codeunit "Contoso Job Queue";
    begin
        ContosoJobQueue.InsertJobQueueCategory(PurchPost(), PurchasePostCategoryLbl);
        ContosoJobQueue.InsertJobQueueCategory(SalesPost(), SalesPostCategoryLbl);
    end;

    procedure PurchPost(): Code[10]
    begin
        exit(PurchPostTok);
    end;

    procedure SalesPost(): Code[10]
    begin
        exit(SalesPostTok);
    end;

    var
        PurchPostTok: Label 'PURCHPOST', Locked = true;
        SalesPostTok: Label 'SALESPOST', Locked = true;
        PurchasePostCategoryLbl: Label 'Purchase Posting', MaxLength = 30;
        SalesPostCategoryLbl: Label 'Sales Posting', MaxLength = 30;
}
