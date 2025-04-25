// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.FixedAsset;

using Microsoft.DemoTool.Helpers;

codeunit 31184 "Create FA Depreciation Book CZ"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoFixedAsset: Codeunit "Contoso Fixed Asset";
        ContosoFixedAssetCZ: Codeunit "Contoso Fixed Asset CZ";
        ContosoUtilities: Codeunit "Contoso Utilities";
        CreateDepreciationBookCZ: Codeunit "Create Depreciation Book CZ";
        CreateFADepreciationBook: Codeunit "Create FA Depreciation Book";
        CreateFixedAsset: Codeunit "Create Fixed Asset";
    begin
        // Delete Company depreciation book from all fixed assets
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000010(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000020(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000030(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000040(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000050(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000060(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000070(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000080(), CreateFADepreciationBook.Company());
        ContosoFixedAssetCZ.DeleteFADepreciationBook(CreateFixedAsset.FA000090(), CreateFADepreciationBook.Company());

        // 1-ACCOUNT
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000010(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020101D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000020(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020501D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000030(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020601D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000040(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020101D), 0);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000050(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020101D), 10);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000060(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020201D), 8);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000070(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020301D), 4);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000080(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020401D), 8);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000090(), CreateDepreciationBookCZ.FirstAccount(), ContosoUtilities.AdjustDate(19020201D), 7);

        // 2-TAX
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000010(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020101D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000020(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020501D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000030(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020601D), 5);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000040(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020101D), 0);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000050(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020101D), 10);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000060(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020201D), 8);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000070(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020301D), 4);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000080(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020401D), 8);
        ContosoFixedAsset.InsertFADepreciationBook(CreateFixedAsset.FA000090(), CreateDepreciationBookCZ.SecondTax(), ContosoUtilities.AdjustDate(19020201D), 7);
    end;
}
