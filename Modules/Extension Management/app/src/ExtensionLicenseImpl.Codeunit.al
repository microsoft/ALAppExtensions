// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2502 "Extension License Impl"
{
    SingleInstance = false;

    trigger OnRun()
    begin
    end;

    [Scope('OnPrem')]
    procedure LicenseCount(ProductId: Text;SkuId: Text): Integer
    begin
        exit(GetIsvLicenseCount(ProductId,SkuId,''));
    end;

    [Scope('OnPrem')]
    procedure GetIsvLicenseCount(ProductId: Text;SkuId: Text;IsvPrefix: Text): Integer
    var
        DotNetExtensionLicenseInformationProvider: DotNet ExtensionLicenseInformationProvider;
    begin
        if (ProductId = '') or (SkuId = '') then
          exit(-1);

        exit(DotNetExtensionLicenseInformationProvider.ALLicenseCount(ProductId,SkuId,IsvPrefix));
    end;
}

